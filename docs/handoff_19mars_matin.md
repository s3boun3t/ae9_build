# PASSATION DE DEBUG — AE-9 Session 19 mars matin

Date : 19 mars 2026 ~06h-12h
Statut : **EN COURS** — CA0113 handshake fonctionne avec blacklist+modprobe, échoue en boot normal

## Résumé direct

Le CA0113 (BAR2+0x208) a été réveillé avec succès pour la première fois (0xffff4141)
lors d'un boot avec `snd-hda-intel` blacklisté puis chargé manuellement. Mais le
handshake échoue systématiquement en boot normal, même après l'ACM init. La cause
est probablement liée à l'ordre d'init ou au timing entre le boot blacklist+modprobe
et le boot normal.

## Découvertes majeures de cette session

### 1. CA0113 handshake FONCTIONNE (sous conditions)
- Boot avec `blacklist snd_hda_intel` → `setpci COMMAND=0x06` → `modprobe snd_hda_intel`
- Attendre que toute l'init se termine (~20s)
- Puis en python : `writel(0x800003, 0x20c)` + `writel(0xffff, 0x208)` → **0x208=0xffff4141**
- Le handshake réussit **immédiatement** (poll 0), pas besoin d'attendre

### 2. CA0113 handshake ÉCHOUE en boot normal
- Même séquence dans le driver : poll 100/100, 0x208=0xffffffff
- Même séquence en python live après boot normal : 0x208=0xffffffff
- Le CA0113 ne répond ni pendant le boot ni après en live

### 3. Le handshake nécessite TOUTE l'init complète
- Échoue avant le DSP download (T+5s)
- Échoue après le DSP download mais avant l'ACM init (T+10s)
- Échoue après l'ACM init en boot normal (T+14s)
- Réussit uniquement après boot blacklist + modprobe manuel

### 4. HDA DMA fonctionne correctement
- SD4 (OUT) : tag=5, run=1, LPIB avance (62764/65536), FMT=0x0011
- On lisait le mauvais stream descriptor (SD0 au lieu de SD4)
- ISS=4, OSS=6 — le playback est sur le 5ème descriptor (SD4)

### 5. DMA ACTIVE=0 est probablement normal
- Le CA0113 vivant n'a pas changé DMA ACTIVE=0
- Les commandes CA0113 renvoyées n'ont pas changé DMA ACTIVE=0
- Le registre DMACFG_ACTIVE est peut-être instantané (pas un état persistant)

### 6. power_save=0 configuré
- `/etc/modprobe.d/snd-hda-powersave.conf` : `options snd_hda_intel power_save=0 power_save_controller=N`
- Bug kernel 205275 mentionne que power_save interfère avec les codecs Creative

### 7. MMIO capture analysée (2.2M lignes)
- Le CA0113 se réveille 5s après le boot Windows, pas instantanément
- La séquence complète : 0x800000 → 400ms → 0x800001 → ~85 verbs → 0x800003 → 0xffff → poll
- 3653 accès MMIO entre 0x800001 et 0x800003 (verbs CORB/RIRB)
- Le 0x204=0x07 et les reads de 0x860/0x854/0x840 avant le handshake

## Hypothèse principale

La différence entre boot blacklist+modprobe et boot normal est probablement :
- **Timing** : le modprobe manuel charge plus lentement, laissant le hardware se stabiliser
- **Ordre** : le probe des deux codecs (D1+D2) se fait différemment
- **État initial** : le PCI device part d'un état différent (pas de driver actif vs driver intégré)
- **Codec reset** : `ae5_register_set` fait un double codec reset pour AE-5/AE-7 mais on l'a retiré pour AE-9 — peut-être qu'il est nécessaire APRÈS l'ACM init ?

## État du code sur disque

### Fichier : ~/ae9_build/build/ca0132.c

Architecture d'init :
```
ca0132_init()
  ├── ca0132_mmio_init_ae9()       → HDA basic + DMA + 0x20c=0x800000
  ├── ae5_register_set()           → PLL/clock + 0x20c=0x800001 (no GPIO/reset for AE-9)
  ├── ca0132_ca0113_init_ae9()     → GPIO5 power only (CA0113 dead)
  ├── init_params/flags/verbs
  ├── ca0132_alt_init()
  ├── ca0132_download_dsp()
  └── ae9_setup_defaults()
        ├── ae9_post_dsp_mmio_commands()  → I2S clock ramp only
        ├── ... (streams, effects, ACM)
        ├── ae9_acm_init()                → ACM I2C packets
        ├── CA0113 HANDSHAKE              → 0x800003 + 0xffff (FAILS in normal boot)
        ├── ca0132_alt_select_out()
        └── keepalive start
```

### Changements par rapport au stock driver
1. `ca0132_mmio_init_ae9()` — init HDA dédiée AE-9 (pas ae5)
2. `ca0132_ca0113_init_ae9()` — GPIO5 seulement, pas de handshake
3. `ae5_register_set()` AE-9 block — simplifié (pas de GPIO/reset)
4. `ae9_post_dsp_mmio_commands()` — I2S clock ramp seulement
5. CA0113 handshake après ACM init dans `ae9_setup_defaults()`
6. `ca0132_pe_switch_set()` après effets (SBX off)
7. `snd_hda_codec_read` + `VENDOR_CHIPIO_STREAM_FORMAT` dans pcm_prepare
8. Stream 0x05 dst=0xd0

## Prochaines actions

### P1 CRITIQUE : Comprendre pourquoi blacklist+modprobe fonctionne
1. Reproduire le boot blacklist + modprobe
2. Comparer les registres BAR0/BAR2 entre les deux modes
3. Comparer le dmesg complet entre les deux modes
4. Identifier la différence exacte (timing? état PCI? codec probe order?)

### P2 : Tester le codec reset
- Le double `AC_VERB_SET_CODEC_RESET` retiré de `ae5_register_set` pour AE-9
  pourrait être nécessaire. Le remettre APRÈS l'ACM init, juste avant le handshake.

### P3 : Essayer un delayed work pour le handshake
- Utiliser `schedule_delayed_work()` pour faire le handshake 5-10s après
  la fin de l'init complète, simulant le délai du modprobe manuel.

### P4 : Capturer les registres BAR0/BAR2 au moment exact du handshake
- Ajouter des debug prints dans le driver pour logger l'état de TOUS les
  registres critiques juste avant le handshake.

## Fichiers de référence
- Driver : ~/ae9_build/build/ca0132.c
- MMIO capture : ~/Téléchargements/ae9_mmio_capture.txt (2.2M lignes)
- Synthèse CA0113 : /mnt/user-data/outputs/synthese_ca0113_init_sequence.md
- Handoff précédent : /mnt/user-data/outputs/handoff_18mars_soir_final.md
- GitHub : https://github.com/s3boun3t/ae9_build
- Blacklist : /etc/modprobe.d/blacklist-hda.conf (À CRÉER pour reproduire)
- Power save : /etc/modprobe.d/snd-hda-powersave.conf (déjà en place)

## Commandes utiles
```bash
# Reproduire le boot qui fonctionne
echo "blacklist snd_hda_intel" | sudo tee /etc/modprobe.d/blacklist-hda.conf
sudo poweroff
# Après reboot:
sudo setpci -s 25:00.0 COMMAND=0x06
sudo modprobe snd_hda_intel power_save=0 power_save_controller=N
sleep 20
# Handshake test:
sudo python3 -c "
import mmap,os,struct,time
fd=os.open('/sys/bus/pci/devices/0000:25:00.0/resource2',os.O_RDWR)
m=mmap.mmap(fd,0x1000,mmap.MAP_SHARED,mmap.PROT_READ|mmap.PROT_WRITE)
r=lambda o:struct.unpack('<I',m[o:o+4])[0]
w=lambda o,v:m.__setitem__(slice(o,o+4),struct.pack('<I',v))
w(0x20c,0x800003);time.sleep(0.016);w(0x208,0xffff);time.sleep(0.1)
print(f'0x208={r(0x208):08x}')
m.close();os.close(fd)
"

# Retirer le blacklist pour revenir au boot normal
sudo rm /etc/modprobe.d/blacklist-hda.conf

# Emergency restore
sudo cp ~/ae9_build/snd-hda-codec-ca0132-stock.ko \
  /lib/modules/6.17.0-14-generic/kernel/sound/hda/codecs/snd-hda-codec-ca0132.ko \
  && sudo depmod -a && sudo poweroff
```
