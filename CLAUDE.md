# CLAUDE.md — AE-9 Linux Driver Project

---

## Hardware

- **Card:** Creative Sound Blaster AE-9 (PCI 1102:0010, SSID 1102:0071)
- **Main codec:** CA0132 D1 (addr=1) — DSP + HDA I/O
- **ACM interface codec:** CA0132 D2 (addr=2) — claimed as `is_d2_acm_only=true`
- **External DAC:** ESS Sabre **ES9038Q2M** (NOT CS43198 — confirmed hardware)
- **ACM board:** breakout box avec DAC, HP amp, volume knob, display
- **BAR0:** 0xfc500000 (HDA controller — `snd-hda-intel` manages), **BAR2:** 0xfc504000 → `spec->mem_base` (Creative extensions)
- **Casque:** Beyerdynamic MMX300 v2 (32Ω), branché sur jack 3.5mm ACM
- **OS:** Linux Mint 22.3, kernel 6.17.0-14-generic
- **Codename interne Creative:** "Malcolm" (confirmé dans tous les drivers Windows)

---

## Skills (apply automatically by context)

| Context | Skills |
|---------|--------|
| Any session start | `using-superpowers`, `linux-kernel-pro`, `verification-before-completion` |
| Debug / bug | `systematic-debugging`, `root-cause-tracing` |
| Plan/handoff | `documentation-technique-debug`, `writing-plans` |
| Mainline prep | `finishing-a-development-branch`, `receiving-code-review` |

---

## Current State (2026-03-19, 14h00)

### Fix en cours de test : 200ms manquant dans ae5_register_set()
**Hypothèse validée :** Le CA0113 échouait au boot normal parce que la Phase 2
du protocole d'init (200ms delay + second DMA cycle, avant 0x800001) n'était
pas implémentée. Fernando RE confirme ce 200ms hardcodé dans le driver Windows.

**Fix appliqué** dans `ae5_register_set()` juste avant `writel(0x00800001, 0x20c)`,
protégé par `if (ca0132_quirk(spec) == QUIRK_AE9)` — AE-5 et AE-7 non touchés :
```c
if (ca0132_quirk(spec) == QUIRK_AE9) {
    msleep(200);
    writel(0x01, spec->mem_base + 0x86c);
    readl(spec->mem_base + 0x86c);
    writel(0x6b, spec->mem_base + 0x800);
    readl(spec->mem_base + 0x800);
}
writel(0x00800001, spec->mem_base + 0x20c);
```

**Statut :** Compilé OK, installé, **en attente du poweroff/reboot pour tester.**

**Après reboot, vérifier en premier :**
```bash
dmesg | grep "AE-9.*CA0113\|CA0113.*handshake\|0x208"
```
- Si `0x208=0xffff4141` → fix confirmé, tester l'audio
- Si `0x208=0xffffffff` → essayer delayed_work (plan B dans docs/plans/)

### Comparaison boot normal vs blacklist+modprobe
| État | Boot normal | Blacklist+modprobe |
|------|-------------|-------------------|
| CA0113 handshake | ❌ 0xffffffff (poll 100/100) | ✅ 0xffff4141 (poll 0) |
| Handshake en live python | ❌ 0xffffffff | ✅ instantané |
| Timing handshake | T+14s (après ACM) | T+20s (après modprobe+sleep) |

### Working ✅
- DSP CA0132 downloaded and running (firmware `ctefx-desktop.bin`)
- ACM bus init: STATUS=0x03, PRESENCE=0x0f
- GPIO 4 (HP amp) et GPIO 5 (DAC power) activés
- GPIO5 keepalive permanent
- HDA DMA fonctionnel: **SD4 (OUT), tag=5, LPIB avance, FMT=0x0011**
- Stream 0x11 (HDA→DSP): Active=1, Type=0x04, HDA Node=0x15, StreamID=0x05, Format=0x0047
- Stream 0x18 (DSP→I2S): Active=1, src=0x09, dst=0xd1, 12 ports
- Audio router correct (all entries verified via Connor tools)
- D2 codec claimed pour ACM
- CA0113 handshake works with blacklist+modprobe
- `power_save=0` configured in `/etc/modprobe.d/snd-hda-powersave.conf`

### Not Working ❌
- **CA0113 handshake fails in normal boot** → fix 200ms en cours de test
- **Silence total** sur casque MMX300
- **SBX LED toujours allumée** despite PLAY_ENHANCEMENT=0
- DSP DMA ACTIVE=0 (may be normal — never verified under Windows)

---

## Architecture d'init AE-9 (code actuel sur disque)

```
ca0132_init()
  ├── ca0132_mmio_init_ae9()       → HDA basic regs + DMA 0→1 + 0x20c=0x800000
  ├── ae5_register_set()           → PLL/clock + 0x20c=0x800001 (no GPIO/reset for AE-9)
  ├── ca0132_ca0113_init_ae9()     → GPIO5 power only (CA0113 dead at this point)
  ├── ca0132_init_params/flags     → ~85 HDA verbs
  ├── snd_hda_sequence_write       → base init verbs
  ├── ca0132_alt_init()
  ├── ca0132_download_dsp()        → firmware load (~5s)
  └── ae9_setup_defaults()
        ├── ae9_post_dsp_mmio_commands()  → I2S clock ramp only
        ├── streams, effects, SCP
        ├── ae9_acm_bus_init() + ae9_acm_init()  → ACM I2C (T+14s)
        ├── **CA0113 HANDSHAKE** → 0x800003 + 0xffff → FAILS (0xffffffff)
        ├── ca0132_alt_select_out()
        └── keepalive start
```

---

## CORB Windows Dump (Direct Mode)

### NID 0x02 (DAC) — Windows
- `SET_STREAM_FORMAT = 0x0031` (48kHz/32bit/stereo)
- `SET_CHANNEL_STREAMID = tag 1, ch 0`

### Différences NID 0x02 Linux vs Windows
| Param | Linux | Windows |
|-------|-------|---------|
| Stream tag | 5 | **1** |
| Format NID 0x02 | 0x0011 (16bit) | **0x0031 (32bit)** |

---

## CA0113 Init Sequence (décodé de MMIO capture Windows, 2.2M lignes)

### Séquence complète (ce que Windows fait)
```
Phase 1: 0x86c=0→1 + 0x800=0x6b + 0x804=0x57 + 0x20c=0x800000
Phase 2: 200ms delay + second DMA cycle + 0x20c=0x800001
Phase 3: ~85 CORB verbs (init_params/flags)
Phase 4: 0x804=0x48 + 0x20c=0x800003 (bit 1 = command enable)
Phase 5: write 0xffff to 0x208 → poll → CA0113 responds (0xffffff00)
Phase 6: Protocol 0x800002→0x800003→0x800005 + 0x804=0x49
```

### Ce qui fonctionne / ce qui ne fonctionne pas dans notre driver
- Phase 1 : ✅ implémentée dans `ca0132_mmio_init_ae9()`
- Phase 2 : ✅ **200ms + second DMA cycle ajoutés** dans `ae5_register_set()` (fix 19 mars)
- Phase 3 : ✅ ~85 verbs HDA dans init_params/flags
- Phases 4-6 : ✅ code correct dans `ae9_setup_defaults()` après ACM init
- **Résultat du fix Phase 2 : à confirmer après le prochain boot**

---

## Fichiers

- **Source:** `~/ae9_build/build/ca0132.c` (~11900 lignes)
- **Build:**
  ```bash
  cd ~/ae9_build && make -C /lib/modules/$(uname -r)/build M=$(pwd)/build modules
  ```
- **Install:**
  ```bash
  sudo rm -f /lib/modules/$(uname -r)/kernel/sound/hda/codecs/snd-hda-codec-ca0132.ko.zst
  sudo cp build/snd-hda-codec-ca0132.ko /lib/modules/$(uname -r)/kernel/sound/hda/codecs/
  sudo depmod -a && sudo poweroff
  ```
- **ALWAYS `poweroff`, NEVER `reboot`**
- **GitHub:** https://github.com/s3boun3t/ae9_build
- **Connor tools:** `~/ca0132-tools/` (compilés, fonctionnels avec sudo)
- **MMIO capture:** `~/Téléchargements/ae9_mmio_capture.txt` (2.2M lignes)
- **CORB dumps Windows:** `~/ae9_build/docs/ae9_corb_dump_*.txt`
- **Fernando RE:** projet Claude `Creative_Sound_Blaster_-_Reverse_Engineering_Fernando.md`
- **Transcripts:** `/mnt/transcripts/`

---

## Emergency Restore

```bash
sudo cp ~/ae9_build/snd-hda-codec-ca0132-stock.ko \
  /lib/modules/6.17.0-14-generic/kernel/sound/hda/codecs/snd-hda-codec-ca0132.ko \
  && sudo depmod -a && sudo poweroff
```
Stock srcversion: `C2D552AB8C31BB791D78182`

## Switch xanmod (pour VM Windows)

```bash
sudo mv /etc/modprobe.d/vfio.conf.vm-only /etc/modprobe.d/vfio.conf
# Boot sur kernel 6.19.7-x64v3-xanmod1
```

---

## Absolute Rules

1. Extend `ca0132.c` only — never rewrite from scratch
2. All AE-9 code behind `QUIRK_AE9`
3. Never break SBZ / AE-5 / AE-7 / ZxR
4. Kernel style: tabs=8, ~80 cols, English comments, always handle errno
5. **`sudo poweroff` only** — never `sudo reboot`
6. `.ko.zst` conflict: delete `.ko.zst` before installing custom `.ko`
7. WAV must be regenerated after each boot (`/tmp` is volatile)
8. Never invent: if info is missing, ask for the exact file/log/command
9. Mask PipeWire before audio tests
10. Upload `ca0132.c` to Claude project before poweroff
11. The canonical tracked file is `build/ca0132.c` only — never the repo root copy
12. Opus-generated code proposals have historically contained nonexistent function names — always verify against actual codebase

---

## Known Lessons — NEVER REPEAT

| ❌ Never do | Why |
|-------------|-----|
| `chipio_remap_stream()` on AE-9 stream 0x0c | Breaks sequential mapping ES9038 expects |
| `chipio_set_stream_source_dest` twice on same stream | Destroys exram allocation |
| Write to 0xC00-0xC0C outside `ae9_acm_bus_init()` | Corrupts I2C bus state |
| `sudo reboot` after module install | Persistent `azx_single_send_cmd` spam |
| IOCE set in SD_CTL | Stalls CA0132 DSP DMA |
| Reconfigure stream src/dst in pcm_prepare | Destroys exram allocation |
| Trust CA0113 MMIO commands before handshake | 0x208=0xffffffff → commands silently lost |
| CA0113 handshake before DSP download | CA0113 only responds after full init (DSP+ACM) |
| Assume `ctefx.bin` = `ctefx-desktop.bin` | Different firmware. AE-9 needs desktop variant |
| Propose functions that don't exist in codebase | Always verify against actual code |
| Read SD0 LPIB for playback check | Playback is on SD4 (ISS=4, OSS=6) |

---

## Key Technical Facts (CONFIRMED)

### CA0113
- Handshake: `writel(0x800003, 0x20c)` + `writel(0xffff, 0x208)` + poll
- Works with blacklist+modprobe, fails normal boot
- Response value: 0xffff4141 (when working)
- Protocol state machine: 0x800002→0x800003→0x800005
- 0x804 transitions: 0x57→0x48→0x49

### Streams (verified via Connor tools)
- Stream 0x11 (HDA→DSP): offset=0x34, 8 ports, Active=1, Type=0x04, StreamID=0x05
- Stream 0x18 (DSP→I2S): offset=0x20, 12 ports, Active=1, src=0x09, dst=0xd1
- Stream 0x05: never allocated in exram (0xff), dst should be 0xd0
- Stream 0x0c: never allocated in exram for AE-9

### HDA DMA
- SD4 (OUT): tag=5, run=1, LPIB advances, CBL=65536, FMT=0x0011
- DSP DMA CH_START=0x07/0x0f, ACTIVE=0x00 (may be normal)

### Firmware
- `ctefx-desktop.bin` (655856 bytes) loaded for AE-9
- DSP download takes ~5s

### Addresses
- BAR0: 0xfc500000, BAR2: 0xfc504000
- ChipIO audio router: 0x190000 region
- Exram map: 0x1578+stream_id = port offset start
- I2C ACM: BAR2+0xC00-0xC7C
- GPIO5 watchdog: BAR2+0x320 = 0x0105 every 500ms

---

## Prochaines Actions (19 mars 2026, après reboot)

### Priorité HAUTE — vérifier le fix 200ms
1. `dmesg | grep "CA0113\|handshake\|0x208"` → est-ce que 0x208=0xffff4141 ?
2. Si oui → tester l'audio (masquer PipeWire + speaker-test)
3. Si non → implémenter le delayed_work (voir `docs/plans/2026-03-19-ca0113-handshake-fix.md`)

### Priorité MOYENNE (si CA0113 vivant mais toujours silence)
4. Vérifier LPIB SD4 avance pendant playback
5. Vérifier ES9038 DAC configuré correctement par ACM init
6. SBX LED off

### Priorité BASSE
7. Volume knob ACM
8. Nettoyage des diagnostics
9. Mainline prep

---

## User Profile

- Not a kernel developer — all code and commands must be complete, copy-paste ready
- No pseudo-code, no "fill in here"
- Always show exact block to replace and replacement
- Commands must include full paths and options
- Opus window = diagnosis/planning/handoff, Sonnet window = code implementation
- Works in French, prefers direct technical communication
