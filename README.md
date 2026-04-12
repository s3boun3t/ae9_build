# Sound Blaster AE-9 — Linux Kernel Driver

> **Status:** DSP + ACM init working ✅ — DAC display active, relay clicks, DSP pipeline configured.  
> **Blocker:** DSP DMA ch1/ch2 frozen — firmware does not connect internal output pipeline.  
> Audio silence on ALL outputs (ACM headphone + rear PCIe jack). Under active investigation.

---

## English

### What is this?

This project adds native Linux support for the **Creative Sound Blaster AE-9**
(PCI ID `1102:0010`, subsystem `1102:0071`) to the existing `snd-hda-codec-ca0132`
kernel driver.

The AE-9 includes an external DAC breakout box (the **ACM — Audio Control Module**)
connected via a proprietary I2C protocol over MMIO. Without this patch, the ACM
board stays powered off and the DAC is inaccessible.

### Hardware

| Component | Details |
|-----------|---------|
| Main codec | CA0132 D1 — DSP + HDA I/O (addr=1, SSID 1102:0071) |
| Second codec | CA0132 D2 — SPDIF I/O only (addr=2, SSID 1102:0072) |
| DAC (Front/HP) | **ESS ES9038Q2M** 2ch (CA0113 group 0x48, on PCIe card) |
| DAC (Surround) | **ESS SABRE9006A** 8ch (CA0113 group 0x49, on PCIe card) |
| ACM box | **No DAC** — XAMP headphone amp, OLED display, volume knob, XLR mic preamp |
| I2C controller | CA0113 MMIO at BAR2 + 0xC00 |
| HDMI cable | Proprietary: **analog audio** + I2C + 5V + HPD (NOT digital I2S) |
| DSP firmware | `ctefx-desktop.bin` (655,856 bytes, 7 MXFL sections) |

### Dual-codec architecture

The AE-9 is unique in the CA0132 family: it has **two CA0132 chips** on the PCIe card.

- **D1 (addr=1):** Main DSP — runs firmware, effects (SBX/EQ/CrystalVoice), all audio routing.
  Manages both the ES9038Q2M (Front/HP) and SABRE9006A (Surround) via CA0113.
  Headphone output goes through D1 → CA0113 → I2S → ES9038Q2M (on PCIe card) → analog → HDMI cable → ACM XAMP.
- **D2 (addr=2):** SPDIF optical I/O only. Idle unless EQ or DTS Connect is active.
  Windows uses Microsoft's generic HDA driver (MSHDAudio) for D2, not Creative's SoundCore3D.


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

```

### Wiki

Detailed technical documentation is available in the
[GitHub Wiki](https://github.com/s3boun3t/ae9_build/wiki):

- [AE9 ACM Protocol](https://github.com/s3boun3t/ae9_build/wiki/AE9_ACM_PROTOCOL)
- [DSP ChipIO Architecture](https://github.com/s3boun3t/ae9_build/wiki/DSP_ChipIO_Architecture)
- [CORB Verbs Analysis](https://github.com/s3boun3t/ae9_build/wiki/AE9_CORB_Verbs_Analysis)

---

## Français

### De quoi s'agit-il ?

Ce projet ajoute le support Linux natif pour la **Creative Sound Blaster AE-9**
au driver kernel existant `snd-hda-codec-ca0132`.

L'AE-9 comprend un boîtier DAC externe (l'**ACM — Audio Control Module**)
connecté via un protocole I2C propriétaire sur MMIO. Sans ce patch, la carte
ACM reste éteinte et le DAC est inaccessible.

### Architecture dual-codec

L'AE-9 a **deux puces CA0132** sur la carte PCIe :
- **D1** (addr=1) : DSP principal — firmware, effets, routing audio, contrôle des DACs
- **D2** (addr=2) : SPDIF optique uniquement — inactif sauf EQ/DTS Connect
2 DACs sur la carte PCIe : ES9038Q2M (Front/casque, group 0x48) et SABRE9006A (surround, group 0x49).
L'ACM ne contient **aucun DAC** — c'est un étage purement analogique (ampli XAMP + préampli micro + alimentation).


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
