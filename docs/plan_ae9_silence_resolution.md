# AE-9 Audio Silence Resolution — Implementation Plan

> **For Claude:** Use this plan task-by-task. Each task is independent and testable.

**Goal:** Obtenir le son sur le casque Beyerdynamic MMX300 v2 branché sur l'ACM de l'AE-9 sous Linux.

**Architecture:** Le CA0113 (BAR2+0x208) est le verrou principal. Il ne répond qu'après l'init complète (DSP download + ACM init). Une fois réveillé, il faut re-envoyer toutes les commandes CA0113 perdues pendant l'init, puis vérifier le pipeline audio complet HDA→DSP→I2S→ES9038→casque.

**Contexte critique:** Le handshake CA0113 fonctionne avec un boot blacklist+modprobe mais PAS en boot normal. Il faut comprendre pourquoi et trouver une solution qui fonctionne au boot normal.

---

## Phase A : Comprendre le blocage CA0113 (diagnostic pur, pas de code)

### Task A1 : Reproduire le boot blacklist+modprobe qui fonctionne

**But:** Confirmer que le handshake fonctionne toujours avec cette méthode.

**Step 1:** Créer le blacklist
```bash
echo "blacklist snd_hda_intel" | sudo tee /etc/modprobe.d/blacklist-hda.conf
sudo poweroff
```

**Step 2:** Après reboot, activer le PCI device et charger le driver
```bash
sudo setpci -s 25:00.0 COMMAND=0x06
sudo modprobe snd_hda_intel power_save=0 power_save_controller=N
sleep 20
```

**Step 3:** Tester le handshake
```bash
sudo python3 -c "
import mmap,os,struct,time
fd=os.open('/sys/bus/pci/devices/0000:25:00.0/resource2',os.O_RDWR)
m=mmap.mmap(fd,0x1000,mmap.MAP_SHARED,mmap.PROT_READ|mmap.PROT_WRITE)
r=lambda o:struct.unpack('<I',m[o:o+4])[0]
w=lambda o,v:m.__setitem__(slice(o,o+4),struct.pack('<I',v))
print(f'BEFORE: 0x208={r(0x208):08x} 0x20c={r(0x20c):08x}')
w(0x20c,0x800003);time.sleep(0.016);w(0x208,0xffff);time.sleep(0.1)
print(f'AFTER: 0x208={r(0x208):08x}')
m.close();os.close(fd)
"
```

**Expected:** 0x208 = 0xffff4141 (CA0113 alive)

### Task A2 : Capturer l'état complet du boot blacklist+modprobe

**But:** Avoir un snapshot de référence de TOUS les registres quand ça marche.

**Step 1:** Après Task A1 réussie, capturer :
```bash
# dmesg complet
dmesg > ~/ae9_build/docs/dmesg_blacklist_boot.txt

# Registres BAR2 critiques
sudo python3 -c "
import mmap,os,struct
fd=os.open('/sys/bus/pci/devices/0000:25:00.0/resource2',os.O_RDONLY)
m=mmap.mmap(fd,0x1000,mmap.MAP_SHARED,mmap.PROT_READ)
for off in [0x000,0x004,0x01c,0x088,0x100,0x200,0x204,0x208,0x20c,0x210,0x300,0x304,0x308,0x320,0x800,0x804,0x830,0x860,0x86c]:
    print(f'0x{off:03x} = 0x{struct.unpack(chr(60)+chr(73),m[off:off+4])[0]:08x}')
m.close();os.close(fd)
" > ~/ae9_build/docs/bar2_blacklist_boot.txt
cat ~/ae9_build/docs/bar2_blacklist_boot.txt

# BAR0 registres
sudo python3 -c "
import mmap,os,struct
fd=os.open('/sys/bus/pci/devices/0000:25:00.0/resource0',os.O_RDONLY)
m=mmap.mmap(fd,0x100,mmap.MAP_SHARED,mmap.PROT_READ)
for off in [0x00,0x08,0x0c,0x0e,0x20,0x24,0x48,0x4c,0x58,0x5c,0x5d]:
    sz = 2 if off in [0x0c,0x0e] else 4
    v = struct.unpack('<H' if sz==2 else '<I', m[off:off+sz])[0]
    print(f'BAR0+0x{off:02x} = 0x{v:0{sz*2}x}')
m.close();os.close(fd)
" > ~/ae9_build/docs/bar0_blacklist_boot.txt
cat ~/ae9_build/docs/bar0_blacklist_boot.txt
```

### Task A3 : Boot normal — capturer les mêmes registres

**Step 1:** Retirer le blacklist et rebooter
```bash
sudo rm /etc/modprobe.d/blacklist-hda.conf
sudo poweroff
```

**Step 2:** Après boot normal, capturer les mêmes registres (copier les commandes de A2 mais sauver dans `*_normal_boot.txt`)

**Step 3:** Diff les deux fichiers
```bash
diff ~/ae9_build/docs/bar2_blacklist_boot.txt ~/ae9_build/docs/bar2_normal_boot.txt
diff ~/ae9_build/docs/bar0_blacklist_boot.txt ~/ae9_build/docs/bar0_normal_boot.txt
diff <(grep -v "^\[" ~/ae9_build/docs/dmesg_blacklist_boot.txt | head -200) \
     <(grep -v "^\[" ~/ae9_build/docs/dmesg_normal_boot.txt | head -200)
```

**Expected:** Identifier la différence exacte entre les deux modes de boot.

---

## Phase B : Résoudre le CA0113 au boot normal

### Task B1 : Tester `schedule_delayed_work` pour le handshake

**Hypothèse:** Le CA0113 a besoin de temps après l'init complète pour se stabiliser. Le boot blacklist+modprobe ajoute ~20s de délai. Un `delayed_work` de 5-10s après l'init pourrait suffire.

**Fichier:** `~/ae9_build/build/ca0132.c`

**Implémentation:** Ajouter un delayed work dans `ae9_setup_defaults()` qui fait le handshake CA0113 5 secondes après la fin de l'init. Les commandes CA0113 perdues sont re-envoyées dans ce worker.

**Avantage:** Non-bloquant, n'impacte pas le temps de boot.
**Risque:** Les commandes CA0113 sont envoyées tard — le premier playback avant le handshake sera silencieux.

### Task B2 : Tester le codec reset après ACM init

**Hypothèse:** Le double `AC_VERB_SET_CODEC_RESET` (retiré de ae5_register_set pour AE-9) est nécessaire pour réinitialiser le 8051 avant le handshake.

**Test:** Ajouter juste avant le handshake dans ae9_setup_defaults() :
```c
snd_hda_codec_write(codec, codec->core.afg, 0, AC_VERB_SET_CODEC_RESET, 0);
snd_hda_codec_write(codec, codec->core.afg, 0, AC_VERB_SET_CODEC_RESET, 0);
msleep(200);
```

### Task B3 : Tester le handshake dans pcm_prepare (lazy init)

**Hypothèse:** Faire le handshake au premier playback plutôt qu'au boot. À ce moment-là, tout le hardware est stable.

**Implémentation:** Dans `ca0132_playback_pcm_prepare`, pour QUIRK_AE9, vérifier si 0x208 == 0xffffffff. Si oui, faire le handshake + commandes. Flag `spec->ca0113_ready` pour ne le faire qu'une fois.

**Avantage:** Le handshake se fait au moment exact où l'utilisateur veut du son — le timing est garanti correct.

---

## Phase C : Pipeline audio post-CA0113

### Task C1 : Re-envoyer les commandes CA0113 après handshake

**But:** Une fois le CA0113 vivant, re-envoyer toutes les commandes qui ont été perdues pendant l'init.

**Commandes à renvoyer (dans l'ordre) :**
```c
/* Deferred from ae5_register_set */
ca0113_mmio_command_set_type2(codec, 0x48, 0x07, 0x81);
ca0113_mmio_command_set(codec, 0x49, 0x0a, 0x07);
ca0113_mmio_gpio_set(codec, 2, false);
ca0113_mmio_command_set(codec, 0x48, 0x1d, 0x40);

/* From ae9_post_dsp_mmio_commands */
ca0113_mmio_command_set(codec, 0x48, 0x0d, 0x00);
ca0113_mmio_command_set(codec, 0x48, 0x17, 0x00);
ca0113_mmio_command_set(codec, 0x48, 0x19, 0x00);
ca0113_mmio_command_set(codec, 0x48, 0x11, 0xff);
ca0113_mmio_command_set(codec, 0x48, 0x12, 0xff);
ca0113_mmio_command_set(codec, 0x48, 0x13, 0xff);
ca0113_mmio_command_set(codec, 0x48, 0x14, 0x7f);
ca0113_mmio_command_set(codec, 0x48, 0x1d, 0x80);

/* From ae9_post_dsp_asi_setup */
ca0113_mmio_command_set(codec, 0x48, 0x0f, 0x04);
ca0113_mmio_command_set(codec, 0x48, 0x10, 0x04);
ca0113_mmio_command_set_type2(codec, 0x48, 0x07, 0x80);

/* From ae9_setup_defaults */
ca0113_mmio_gpio_set(codec, 3, false);
ca0113_mmio_command_set(codec, 0x49, 0x04, 0x1e);
ca0113_mmio_command_set(codec, 0x49, 0x05, 0x1e);
ca0113_mmio_command_set(codec, 0x49, 0x02, 0x1e);
ca0113_mmio_command_set(codec, 0x49, 0x03, 0x1e);
```

### Task C2 : Vérifier le pipeline audio complet

**Après CA0113 vivant + commandes envoyées :**
```bash
# 1. DMA ACTIVE
# 2. Stream 0x11 data via Connor tools
# 3. Jouer un son et vérifier LPIB sur SD4
# 4. Vérifier si le son sort
```

### Task C3 : Si toujours pas de son — vérifier le ES9038 DAC

Le driver hifibunny3 montre que l'ES9038Q2M a besoin de :
- Registre 0x2D (AUTO_CAL) = 0x05 (bias high, opamp ON)
- Registre 0x1D (GPIO_INV) = 0x00 (GPIO high, power ON)
- Registre 0x0E (SOFT_START) = 0x8C (ramp to AVCC/2, bit 7 = 1)

Vérifier si nos packets ACM I2C (`ae9_acm_init`) configurent correctement ces registres.

---

## Phase D : Stabilisation

### Task D1 : SBX LED off
- `ca0132_pe_switch_set()` déjà ajouté — vérifier que ça fonctionne après CA0113 vivant

### Task D2 : Nettoyage du code
- Retirer les debug prints excessifs
- Documenter l'architecture d'init
- Préparer pour soumission mainline

---

## Ordre d'exécution recommandé

1. **A1** (5 min) — Reproduire le boot qui marche
2. **A2** (5 min) — Capturer les registres
3. **A3** (10 min) — Comparer avec boot normal
4. **B3** (30 min) — Lazy init dans pcm_prepare (approche la plus prometteuse)
5. **C1** (15 min) — Re-envoyer les commandes CA0113
6. **C2** (10 min) — Tester le son
7. Si pas de son : **C3** (30 min) — Vérifier ES9038 DAC config
8. Si B3 ne marche pas : **B1** (30 min) — delayed_work
9. Si B1 ne marche pas : **B2** (15 min) — codec reset

## Risques identifiés

| Risque | Impact | Mitigation |
|--------|--------|-----------|
| Le handshake ne fonctionne plus en blacklist+modprobe | Bloquant | A1 vérifie immédiatement |
| CA0113 vivant mais toujours pas de son | Moyen | C2/C3 identifient le prochain blocage |
| delayed_work trop tard pour premier playback | Faible | L'utilisateur attend 5s au boot |
| Lazy init dans pcm_prepare crée une latence | Faible | ~100ms au premier playback uniquement |
| ES9038 DAC pas correctement configuré par ACM init | Moyen | C3 compare avec hifibunny3 driver |
