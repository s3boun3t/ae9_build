# Sound Blaster AE-9 — Linux Kernel Driver

> **Status:** DSP + ACM init working ✅ — DAC display active, DSP unmuté.  
> Audio pipeline complete. **ES9038 DAC silent — under active investigation.**

---

## English

### What is this?

This project adds native Linux support for the **Creative Sound Blaster AE-9**
(PCI ID `1102:0010`, subsystem `1102:0071`) to the existing `snd-hda-codec-ca0132`
kernel driver.

The AE-9 includes an external DAC breakout box (the **ACM — Audio Control Module**)
connected via a proprietary I2C protocol over MMIO. Without this patch, the ACM
board stays powered off and the premium **ES9038Q2M DAC** is inaccessible.

### Hardware

| Component | Details |
|-----------|---------|
| Main codec | CA0132 DSP (HDA addr 1, SSID 1102:0071) |
| ACM codec | CA0132 ACM interface (HDA addr 2, SSID 1102:0072) |
| DAC chip | **ESS ES9038Q2M** (on ACM board) |
| I2C controller | CA0113 MMIO at BAR2 + 0xc00 |
| BAR0 | 0xfc500000 (HDA controller) |
| BAR2 | 0xfc504000 (Creative MMIO) |

### Current state

The driver successfully:
- Downloads the CA0132 DSP firmware
- Initializes the ACM board via 29 I2C packets (byte-for-byte matching Windows)
- Powers GPIO 4 (HP amp) and GPIO 5 (DAC board)
- Configures the DSP audio pipeline (streams 0x0c, 0x11, 0x18)
- Sets dac2port=0xa1 (headphone routing)
- Unmutes the DSP (SPEAKER_TUNING_MUTE=FLOAT_ZERO confirmed)
- Runs HDA DMA at correct 48kHz timing

**Known issue:** The ES9038Q2M DAC produces no audio output. The digital
pipeline is complete and correct. Suspected cause: ES9038 hardware automute
triggered by zero-signal I2S during DSP init, or missing keepalive sequences.
Investigation ongoing.

### Build & install

**Requirements:** Linux kernel headers for your running kernel, `make`, `gcc`.

```bash
# 1 — clone
git clone https://github.com/s3boun3t/ae9_build.git
cd ae9_build

# 2 — build (run from repo root, NOT from build/)
make -C /lib/modules/$(uname -r)/build M=$(pwd)/build modules

# 3 — install
sudo cp build/snd-hda-codec-ca0132.ko \
  /lib/modules/$(uname -r)/kernel/sound/hda/codecs/
sudo rm -f \
  /lib/modules/$(uname -r)/kernel/sound/hda/codecs/snd-hda-codec-ca0132.ko.zst
sudo depmod -a

# 4 — cold power-off (NOT reboot)
sudo poweroff
```

> ⚠️ **Cold power-off required** — use `poweroff`, never `reboot`.
> A warm reboot causes `azx_single_send_cmd` spam and may leave the ACM in
> a broken state.

> ⚠️ **Remove .ko.zst** — if a `.ko.zst` file exists alongside your `.ko`,
> the compressed version takes priority and Plymouth will hang at boot.
> Always delete it before installing a custom module.

### Verify

After boot, wait ~12 seconds then check:

```bash
dmesg | grep "AE-9" | grep -v "DEBUG\|stream_control" | tail -10
# Expected:
#   AE-9: DSP ready, starting post-DSP setup
#   AE-9: GPIO 5 set (DAC board power ON)
#   AE-9 ACM: init complete STATUS=0x03 PRESENCE=0x0f
#   AE-9 select_out: unmute OK
```

### Test audio

```bash
systemctl --user stop pipewire pipewire-pulse wireplumber 2>/dev/null
amixer -c 0 sset 'Master' 99 unmute
amixer -c 0 sset 'Front' 90 unmute
amixer -c 0 sset 'Output Select' 'Headphone'
speaker-test -c 2 -t sine -f 1000 -D hw:0,0
```

### Known limitations

- **No audio output** — ES9038 DAC silent (under investigation)
- Volume knob does not control system volume
- Microphone input not exposed
- ~12 second delay before DAC initializes after boot

### Project structure

```
build/          kernel module source (ca0132.c + Makefile)
docs/           protocol documentation (AE9_ACM_PROTOCOL.md)
```

---

## Français

### De quoi s'agit-il ?

Ce projet ajoute le support Linux natif pour la **Creative Sound Blaster AE-9**
au driver kernel existant `snd-hda-codec-ca0132`.

L'AE-9 comprend un boîtier DAC externe (l'**ACM — Audio Control Module**)
connecté via un protocole I2C propriétaire sur MMIO. Sans ce patch, la carte
ACM reste éteinte et le DAC **ES9038Q2M** premium est inaccessible.

### État actuel

Le driver initialise correctement tout le pipeline numérique : DSP, ACM, GPIO,
streams ChipIO, routing DSP. Le **DAC ES9038Q2M reste silencieux** — investigation
en cours, cause probable : automute hardware de l'ES9038 ou séquences I2S
manquantes.

### Compilation et installation

```bash
git clone https://github.com/s3boun3t/ae9_build.git
cd ae9_build
make -C /lib/modules/$(uname -r)/build M=$(pwd)/build modules
sudo cp build/snd-hda-codec-ca0132.ko \
  /lib/modules/$(uname -r)/kernel/sound/hda/codecs/
sudo rm -f \
  /lib/modules/$(uname -r)/kernel/sound/hda/codecs/snd-hda-codec-ca0132.ko.zst
sudo depmod -a && sudo poweroff
```

> ⚠️ `sudo poweroff` — jamais `sudo reboot`

---

## Credits

Protocol reverse engineering and driver implementation: **s3boun3t**  
Based on the AE-5/AE-7 work by **Connor McAdams** (mainlined in Linux 5.10)  
VFIO capture analysis assisted by **Claude (Anthropic)**
