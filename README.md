# Sound Blaster AE-9 — Linux Kernel Driver

> **Status:** ACM board initializes successfully ✅  
> DAC display lights up, analog audio output working.  
> Headphone output, microphone, and volume knob in progress.

---

## English

### What is this?

This project adds native Linux support for the **Creative Sound Blaster AE-9**
(PCI ID `1102:0010`, subsystem `1102:0071`) to the existing `snd-hda-codec-ca0132`
kernel driver.

The AE-9 includes an external DAC breakout box (the **ACM — Audio Control Module**)
connected via a proprietary I2C protocol over MMIO. Without this patch, the ACM
board stays powered off and the premium CS43198 DAC is inaccessible.

### Hardware

| Component | Details |
|-----------|---------|
| Main codec | CA0132 DSP (HDA addr 1, SSID 1102:0071) |
| ACM codec | CA0132 ACM interface (HDA addr 2, SSID 1102:0072) |
| DAC chip | CS43198 (on ACM board) |
| I2C controller | CA0113 MMIO at BAR2 + 0xc00 |

### How it works

The ACM board is powered by GPIO 5. Once the DSP is loaded and GPIO 5 is
asserted, the driver waits ~7 seconds for the ACM MCU to boot, then sends
an initialization sequence of 30 I2C packets to configure the CS43198 DAC.

See [docs/AE9_ACM_PROTOCOL.md](docs/AE9_ACM_PROTOCOL.md) for the full
protocol documentation derived from VFIO capture analysis.

### Build & install

**Requirements:** Linux kernel headers for your running kernel, `make`, `gcc`.

```bash
# 1 — clone
git clone https://github.com/s3boun3t/ae9_build.git
cd ae9_build/build

# 2 — build
make -C /lib/modules/$(uname -r)/build M=$(pwd) modules

# 3 — install
sudo cp snd-hda-codec-ca0132.ko \
  /lib/modules/$(uname -r)/kernel/sound/hda/codecs/snd-hda-codec-ca0132.ko
sudo rm -f \
  /lib/modules/$(uname -r)/kernel/sound/hda/codecs/snd-hda-codec-ca0132.ko.zst
sudo depmod -a

# 4 — cold reboot (power off, not just restart)
sudo poweroff
```

> ⚠️ **Cold power-off required** — the ACM board needs a full power cycle
> to reset its MCU. A warm reboot is not sufficient.

### Verify

After boot, wait ~15 seconds then check:

```bash
dmesg | grep "AE-9:" | tail -5
# Expected: "AE-9 ACM: init complete"
# The DAC front panel should display "-15.0" and the ring LED should be lit.
```

### Known limitations

- Volume knob does not yet control system volume
- Headphone output not yet exposed as separate ALSA device
- Microphone input not yet exposed
- ~14 second delay before DAC initializes after boot
- `byte-ack timeout` warnings in dmesg (non-blocking, cosmetic)

### Project structure

```
build/          kernel module source (ca0132.c + Makefile)
docs/           protocol documentation
sources/        reference kernel sources
```

### Contributing

This is a reverse-engineering effort based on VFIO MMIO capture from a
Windows 11 VM. Contributions, testing reports, and captures from other
AE-9 units are welcome.

---

## Français

### De quoi s'agit-il ?

Ce projet ajoute le support Linux natif pour la **Creative Sound Blaster AE-9**
(PCI ID `1102:0010`, sous-système `1102:0071`) au driver kernel existant
`snd-hda-codec-ca0132`.

L'AE-9 comprend un boîtier DAC externe (l'**ACM — Audio Control Module**)
connecté via un protocole I2C propriétaire sur MMIO. Sans ce patch, la carte
ACM reste éteinte et le DAC CS43198 premium est inaccessible.

### Matériel

| Composant | Détails |
|-----------|---------|
| Codec principal | CA0132 DSP (adresse HDA 1, SSID 1102:0071) |
| Codec ACM | Interface CA0132 ACM (adresse HDA 2, SSID 1102:0072) |
| Puce DAC | CS43198 (sur la carte ACM) |
| Contrôleur I2C | CA0113 MMIO sur BAR2 + 0xc00 |

### Comment ça fonctionne

La carte ACM est alimentée par GPIO 5. Une fois le DSP chargé et GPIO 5 activé,
le driver attend ~7 secondes que le MCU de l'ACM démarre, puis envoie une
séquence d'initialisation de 30 paquets I2C pour configurer le DAC CS43198.

Voir [docs/AE9_ACM_PROTOCOL.md](docs/AE9_ACM_PROTOCOL.md) pour la documentation
complète du protocole, dérivée de l'analyse d'une capture VFIO.

### Compilation et installation

**Prérequis :** en-têtes du kernel Linux pour votre kernel, `make`, `gcc`.

```bash
# 1 — cloner
git clone https://github.com/s3boun3t/ae9_build.git
cd ae9_build/build

# 2 — compiler
make -C /lib/modules/$(uname -r)/build M=$(pwd) modules

# 3 — installer
sudo cp snd-hda-codec-ca0132.ko \
  /lib/modules/$(uname -r)/kernel/sound/hda/codecs/snd-hda-codec-ca0132.ko
sudo rm -f \
  /lib/modules/$(uname -r)/kernel/sound/hda/codecs/snd-hda-codec-ca0132.ko.zst
sudo depmod -a

# 4 — extinction complète (pas un simple redémarrage)
sudo poweroff
```

> ⚠️ **Extinction complète obligatoire** — la carte ACM nécessite un cycle
> d'alimentation complet pour réinitialiser son MCU. Un redémarrage chaud
> ne suffit pas.

### Vérification

Après le démarrage, attendre ~15 secondes puis vérifier :

```bash
dmesg | grep "AE-9:" | tail -5
# Attendu : "AE-9 ACM: init complete"
# L'afficheur frontal du DAC doit afficher "-15.0" et l'anneau LED doit être allumé.
```

### Limitations connues

- La molette de volume ne contrôle pas encore le volume système
- La sortie casque n'est pas encore exposée comme périphérique ALSA séparé
- L'entrée microphone n'est pas encore exposée
- ~14 secondes de délai avant l'initialisation du DAC au démarrage
- Avertissements `byte-ack timeout` dans dmesg (non bloquants, cosmétiques)

### Structure du projet

```
build/          source du module kernel (ca0132.c + Makefile)
docs/           documentation du protocole
sources/        sources kernel de référence
```

### Contribuer

Ce projet est le résultat d'une ingénierie inverse basée sur une capture MMIO
VFIO depuis une VM Windows 11. Les contributions, rapports de tests et captures
depuis d'autres unités AE-9 sont les bienvenus.

---

## Credits

Protocol reverse engineering and driver implementation: **s3boun3t**  
Based on the AE-5/AE-7 work by **Connor McAdams** (mainlined in Linux 5.10)  
VFIO capture analysis assisted by **Claude (Anthropic)**
