# PASSATION DE DEBUG — AE-9 Session 19 mars après-midi

Date : 19 mars 2026 ~14h00
Statut : **FIX COMPILÉ ET INSTALLÉ — en attente de test après reboot**

---

## Ce qu'on a fait cette session

### Diagnostic de la cause racine

Le CA0113 échouait au boot normal parce que la **Phase 2 du protocole d'init
était incomplète**. Windows fait :

```
Phase 1: 0x86c=0→1 + 0x800=0x6b + 0x804=0x57 + 0x20c=0x800000
Phase 2: 200ms delay + second DMA cycle (0x86c=1, 0x800=0x6b) + 0x20c=0x800001
```

Notre code faisait Phase 1 dans `ca0132_mmio_init_ae9()` puis écrivait
immédiatement 0x800001 dans `ae5_register_set()` **sans le 200ms ni le second
DMA cycle**. Le 8051 MCU n'avait pas le temps de booter son firmware → CA0113
mort → 0x208=0xffffffff.

Avec blacklist+modprobe ça marchait parce que l'utilisateur attend 20s après
le power-on → le 8051 avait eu le temps de booter peu importe le timing.

**Source :** Fernando RE (`~/Téléchargements/Creative Sound Blaster - Reverse
Engineering Fernando.md`) confirme le 200ms hardcodé dans le driver Windows.

---

## Fix appliqué

**Fichier :** `~/ae9_build/build/ca0132.c`
**Fonction :** `ae5_register_set()` (~ligne 11103)
**Protégé par :** `if (ca0132_quirk(spec) == QUIRK_AE9)` — AE-5/AE-7 non touchés

```c
/* Ajouté juste avant writel(0x00800001, spec->mem_base + 0x20c) : */
if (ca0132_quirk(spec) == QUIRK_AE9) {
    msleep(200);
    writel(0x01, spec->mem_base + 0x86c);
    readl(spec->mem_base + 0x86c);
    writel(0x6b, spec->mem_base + 0x800);
    readl(spec->mem_base + 0x800);
}
writel(0x00800001, spec->mem_base + 0x20c);
```

**Build :** OK (warning pre-existant dans ca0132_ca0113_init_ae9, pas lié)
**Install :** OK (ko.zst supprimé, ko copié, depmod -a)

---

## À faire immédiatement après reboot

```bash
# 1. Vérifier le handshake CA0113
dmesg | grep -E "CA0113|handshake|0x208"
```

**Si succès** (0x208=0xffff4141) :
```bash
# 2. Tester l'audio
systemctl --user stop pipewire pipewire-pulse wireplumber
speaker-test -D hw:0,0 -c 2 -t sine -l 1
```

**Si échec** (0x208=0xffffffff) → plan B : delayed_work
```
Voir : ~/ae9_build/docs/plans/2026-03-19-ca0113-handshake-fix.md
```

---

## Plan B si le fix 200ms ne suffit pas

Fichier plan complet : `docs/plans/2026-03-19-ca0113-handshake-fix.md`

Résumé :
- Réduire le poll de 100→20 iterations (1s max au lieu de 5s)
- Ajouter `spec->ae9_ca0113_work` (struct delayed_work) dans ca0132_spec
- Ajouter `spec->ca0113_ready` (bool) dans ca0132_spec
- Extraire le handshake inline dans `ae9_ca0113_handshake()`
- Scheduler un retry 15s après la fin de ae9_setup_defaults()

---

## Fichiers modifiés cette session

| Fichier | Changement |
|---------|-----------|
| `build/ca0132.c` | 200ms + second DMA cycle dans ae5_register_set() pour AE-9 |
| `CLAUDE.md` | Current state mis à jour |
| `docs/plans/2026-03-19-ca0113-handshake-fix.md` | Plan B delayed_work créé |
| `docs/handoff_19mars_aprem.md` | Ce fichier |

---

## Emergency restore si le reboot est cassé

```bash
sudo cp ~/ae9_build/snd-hda-codec-ca0132-stock.ko \
  /lib/modules/6.17.0-14-generic/kernel/sound/hda/codecs/snd-hda-codec-ca0132.ko \
  && sudo depmod -a && sudo poweroff
```
