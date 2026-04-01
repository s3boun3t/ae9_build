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
| DAC (Front/HP) | **ESS ES9038Q2M** 2ch (CA0113 group 0x48) |
| DAC (Surround) | **ESS SABRE9006A** 8ch (CA0113 group 0x49) |
| ACM box | XAMP headphone amp, OLED display, volume knob, XLR mic |
| I2C controller | CA0113 MMIO at BAR2 + 0xC00 |
| HDMI cable | Proprietary: 5V + I2S + I2C + HPD (not standard HDMI A/V) |
| DSP firmware | `ctefx-desktop.bin` (655,856 bytes, 7 MXFL sections) |

### Dual-codec architecture

The AE-9 is unique in the CA0132 family: it has **two CA0132 chips** on the PCIe card.

- **D1 (addr=1):** Main DSP — runs firmware, effects (SBX/EQ/CrystalVoice), all audio routing.
  Manages both the ES9038Q2M (Front/HP) and SABRE9006A (Surround) via CA0113.
  Headphone output goes through D1 → CA0113 → I2S → HDMI cable → ACM → XAMP.
- **D2 (addr=2):** SPDIF optical I/O only. Idle unless EQ or DTS Connect is active.
  Windows uses Microsoft's generic HDA driver (MSHDAudio) for D2, not Creative's SoundCore3D.

### Current state

The driver successfully:
- Downloads the CA0132 DSP firmware (`ctefx-desktop.bin`)
- Initializes the ACM board via 29 I2C packets (byte-for-byte matching Windows)
- Powers GPIO4 (HP amp relay) and GPIO5 (DAC board power)
- Configures the DSP audio pipeline (streams 0x05, 0x0c, 0x11, 0x18)
- Sets dac2port=0xa1 (headphone routing)
- Sends all known SCP module commands (0x32, 0x37, 0x47, 0x80, 0x8F, 0x95, 0x96)
- Runs `pe_switch_set` → `select_out` normally (Direct Mode: FLOAT_ZERO)
- Initializes both DACs via CA0113 (50+ commands, all confirmed with 0x860=1)
- Runs GPIO5 keepalive watchdog (500ms cycle)
- ACM display shows volume, relay clicks on boot ✅

**Blocker:** The DSP Quartet firmware receives audio (HDA DMA ch0 advances) and
executes code (DBGCTL register changes), but its internal output channels (ch1 DSP→DAC,
ch2 DSP→I2S) remain frozen at 0x00010001. The firmware does not connect its internal
pipeline to the output DMA channels. All known ChipIO and SCP commands match Windows
captures exactly. SCP SET commands are fire-and-forget and likely processed; SCP GET
returns -EIO on ALL CA0132 cards (unsolicited response mechanism broken under Linux).

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
#   AE-9: pe_switch_set done (Direct Mode)
```

### Test audio

```bash
# Generate test tone (required after each boot — /tmp is volatile)
sox -n -r 48000 -b 32 -c 2 /tmp/test.wav synth 10 sine 440

# Stop PulseAudio/PipeWire
systemctl --user mask pipewire.socket pipewire.service pulseaudio.socket pulseaudio.service
systemctl --user stop pipewire.socket pipewire.service pulseaudio.socket pulseaudio.service

# Play directly to hardware
aplay -D hw:0,0 /tmp/test.wav

# Check DMA status
sudo dmesg | grep "DIAG DMA" | tail -3
```

### Known limitations

- **No audio output** — DSP DMA ch1/ch2 frozen (under investigation)
- **Rear PCIe jack also silent** — same root cause (DSP pipeline)
- **SBX LED stays ON** regardless of Direct Mode setting
- **SCP GET broken** on all CA0132 cards under Linux (unsolicited response IRQ)
- Volume knob does not control system volume
- Microphone input not exposed
- ~12 second delay before ACM initializes after boot

### Project structure

```
build/          kernel module source (ca0132.c + Makefile)
docs/           protocol documentation, CORB captures, register maps
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

Trois DACs : ES9038Q2M (Front/casque, group 0x48), SABRE9006A (surround, group 0x49),
et potentiellement un ES9038Q2M dans l'ACM pour le casque.

### État actuel

Le driver initialise correctement tout le pipeline numérique : DSP, ACM, GPIO,
streams ChipIO, routing DSP, commandes SCP, DACs ES9038Q2M + SABRE9006A.
Le **DSP Quartet ne connecte pas son pipeline de sortie interne** — les compteurs
DMA ch1/ch2 restent gelés. Investigation en cours.

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
