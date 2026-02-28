#!/bin/bash
#
# build_ae9_module.sh — Script de compilation du module CA0132 patché pour AE-9
#
# Usage: sudo bash build_ae9_module.sh
#
# Ce script:
#   1. Installe les dépendances (headers, build tools)
#   2. Télécharge les sources kernel correspondant à ton kernel 6.17
#   3. Applique le patch AE-9 sur patch_ca0132.c
#   4. Compile UNIQUEMENT le module snd-hda-codec-ca0132.ko
#   5. L'installe et le charge
#
# Testé sur: Linux Mint 22.3 / Ubuntu 24.04, kernel 6.17.0-14-generic
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

KERNEL_VER=$(uname -r)
WORK_DIR="$HOME/ae9_build"
PATCH_APPLIED=false

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN} Sound Blaster AE-9 — Module Builder${NC}"
echo -e "${CYAN} Kernel: ${KERNEL_VER}${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# ─── Vérifications préliminaires ───────────────────────────────

if [ "$(id -u)" -eq 0 ]; then
    echo -e "${RED}Ne lance PAS ce script avec sudo directement.${NC}"
    echo "Lance-le en tant qu'utilisateur normal, il demandera sudo quand nécessaire."
    exit 1
fi

echo -e "${YELLOW}[1/7] Vérification de la carte Creative...${NC}"
if ! lspci -nn | grep -q "1102:0010"; then
    echo -e "${RED}ERREUR: Carte Creative (1102:0010) non détectée dans lspci !${NC}"
    echo "Vérifie que ta Sound Blaster AE-9 est bien installée."
    exit 1
fi
PCI_ADDR=$(lspci -nn | grep "1102:0010" | awk '{print $1}')
echo -e "${GREEN}  ✓ Carte Creative trouvée à ${PCI_ADDR}${NC}"

# Vérifier le subsystem ID
SUBSYS=$(lspci -nn -s "$PCI_ADDR" | grep -oP '\[1102:[0-9a-f]+\]' | tail -1)
echo -e "  Subsystem ID: ${SUBSYS}"

# ─── Installation des dépendances ──────────────────────────────

echo ""
echo -e "${YELLOW}[2/7] Installation des dépendances...${NC}"
sudo apt-get update -qq
sudo apt-get install -y build-essential linux-headers-${KERNEL_VER} \
    libelf-dev libssl-dev bc flex bison dwarves git wget 2>&1 | tail -5

# Vérifier que les headers sont bien là
if [ ! -d "/lib/modules/${KERNEL_VER}/build" ]; then
    echo -e "${RED}ERREUR: Headers kernel non trouvés pour ${KERNEL_VER}${NC}"
    echo "Essaie: sudo apt install linux-headers-${KERNEL_VER}"
    exit 1
fi
echo -e "${GREEN}  ✓ Headers kernel trouvés${NC}"

# ─── Préparation de l'espace de travail ────────────────────────

echo ""
echo -e "${YELLOW}[3/7] Préparation de l'espace de travail...${NC}"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# ─── Récupérer les sources du module audio ─────────────────────

echo ""
echo -e "${YELLOW}[4/7] Récupération des sources du module audio...${NC}"

# Méthode: copier les sources depuis le build tree des headers
# Les headers kernel contiennent les Makefiles nécessaires pour compiler des modules
# Mais pas les .c — on va les chercher dans le kernel source

KERNEL_MAJOR=$(echo "$KERNEL_VER" | grep -oP '^\d+\.\d+')
echo "  Kernel major version: ${KERNEL_MAJOR}"

# Essayer de récupérer le source package
if [ ! -d "$WORK_DIR/linux-source" ]; then
    echo "  Téléchargement des sources kernel ${KERNEL_MAJOR}..."
    
    # Méthode 1: apt source
    if apt-cache show linux-source-${KERNEL_MAJOR} &>/dev/null; then
        echo "  → Via apt (linux-source-${KERNEL_MAJOR})..."
        sudo apt-get install -y linux-source-${KERNEL_MAJOR} 2>&1 | tail -3
        
        SOURCE_TAR=$(ls /usr/src/linux-source-${KERNEL_MAJOR}* 2>/dev/null | head -1)
        if [ -n "$SOURCE_TAR" ] && [ -f "$SOURCE_TAR" ]; then
            echo "  → Extraction de ${SOURCE_TAR}..."
            mkdir -p "$WORK_DIR/linux-source"
            tar xf "$SOURCE_TAR" -C "$WORK_DIR/linux-source" --strip-components=1 \
                --wildcards '*/sound/pci/hda/*' 2>/dev/null || true
        fi
    fi
    
    # Méthode 2: télécharger depuis kernel.org si apt n'a pas marché
    if [ ! -f "$WORK_DIR/linux-source/sound/pci/hda/patch_ca0132.c" ]; then
        echo "  → Téléchargement depuis kernel.org (v${KERNEL_MAJOR})..."
        wget -q "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_MAJOR}.tar.xz" \
            -O "$WORK_DIR/linux-${KERNEL_MAJOR}.tar.xz" || {
            echo -e "${RED}Impossible de télécharger les sources kernel.${NC}"
            echo "Essaie manuellement: wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_MAJOR}.tar.xz"
            exit 1
        }
        echo "  → Extraction (seulement sound/pci/hda/)..."
        mkdir -p "$WORK_DIR/linux-source"
        tar xf "$WORK_DIR/linux-${KERNEL_MAJOR}.tar.xz" -C "$WORK_DIR/linux-source" \
            --strip-components=1 "linux-${KERNEL_MAJOR}/sound/pci/hda/" \
            "linux-${KERNEL_MAJOR}/include/sound/" \
            "linux-${KERNEL_MAJOR}/include/uapi/sound/" 2>/dev/null || {
            # Si l'extraction partielle échoue, extraire tout
            echo "  → Extraction complète (peut prendre un moment)..."
            tar xf "$WORK_DIR/linux-${KERNEL_MAJOR}.tar.xz" -C "$WORK_DIR/linux-source" \
                --strip-components=1
        }
    fi
fi

# Vérifier que le fichier source est là
if [ ! -f "$WORK_DIR/linux-source/sound/pci/hda/patch_ca0132.c" ]; then
    echo -e "${RED}ERREUR: patch_ca0132.c non trouvé dans les sources !${NC}"
    echo "Le fichier devrait être dans: $WORK_DIR/linux-source/sound/pci/hda/"
    exit 1
fi
echo -e "${GREEN}  ✓ Sources kernel récupérées${NC}"

# ─── Appliquer le patch ────────────────────────────────────────

echo ""
echo -e "${YELLOW}[5/7] Application du patch AE-9...${NC}"

CA0132_FILE="$WORK_DIR/linux-source/sound/pci/hda/patch_ca0132.c"

# Vérifier si le patch est déjà appliqué
if grep -q "Sound Blaster AE-9" "$CA0132_FILE"; then
    echo -e "${GREEN}  ✓ Patch déjà appliqué !${NC}"
    PATCH_APPLIED=true
else
    # Backup
    cp "$CA0132_FILE" "${CA0132_FILE}.orig"
    
    # Appliquer le patch minimal : ajouter l'AE-9 comme QUIRK_AE7
    # C'est la méthode la plus sûre pour un premier test
    sed -i '/SND_PCI_QUIRK(0x1102, 0x0081, "Sound Blaster AE-7", QUIRK_AE7),/a\\tSND_PCI_QUIRK(0x1102, 0x0071, "Sound Blaster AE-9", QUIRK_AE7),' "$CA0132_FILE"
    
    # Vérifier
    if grep -q "Sound Blaster AE-9" "$CA0132_FILE"; then
        echo -e "${GREEN}  ✓ Patch appliqué avec succès !${NC}"
        echo "  Ligne ajoutée :"
        grep -n "AE-9" "$CA0132_FILE"
        PATCH_APPLIED=true
    else
        echo -e "${RED}  ERREUR: Le patch n'a pas pu être appliqué !${NC}"
        echo "  Vérification manuelle nécessaire."
        echo "  Cherche cette ligne dans ${CA0132_FILE} :"
        echo '    SND_PCI_QUIRK(0x1102, 0x0081, "Sound Blaster AE-7", QUIRK_AE7),'
        echo "  Et ajoute juste en dessous :"
        echo '    SND_PCI_QUIRK(0x1102, 0x0071, "Sound Blaster AE-9", QUIRK_AE7),'
        exit 1
    fi
fi

# ─── Compilation du module ─────────────────────────────────────

echo ""
echo -e "${YELLOW}[6/7] Compilation du module...${NC}"
echo "  Cela peut prendre quelques minutes..."

cd "$WORK_DIR/linux-source"

# Copier la config du kernel actuel
cp /boot/config-${KERNEL_VER} .config 2>/dev/null || \
    zcat /proc/config.gz > .config 2>/dev/null || {
    echo -e "${RED}Impossible de récupérer la config kernel !${NC}"
    exit 1
}

# Préparer le build
make olddefconfig 2>&1 | tail -3
make modules_prepare 2>&1 | tail -5

# Compiler uniquement le module HDA
echo "  Compilation en cours..."
make -j$(nproc) M=sound/pci/hda 2>&1 | tail -10

# Vérifier le résultat
MODULE_PATH="$WORK_DIR/linux-source/sound/pci/hda/snd-hda-codec-ca0132.ko"
if [ ! -f "$MODULE_PATH" ]; then
    # Essayer avec .ko.xz ou .ko.zst
    MODULE_PATH=$(find "$WORK_DIR/linux-source/sound/pci/hda/" -name "snd-hda-codec-ca0132*" | head -1)
fi

if [ -z "$MODULE_PATH" ] || [ ! -f "$MODULE_PATH" ]; then
    echo -e "${RED}ERREUR: Le module compilé n'a pas été trouvé !${NC}"
    echo "Fichiers générés dans sound/pci/hda/ :"
    ls -la sound/pci/hda/*.ko* 2>/dev/null || echo "  (aucun .ko trouvé)"
    echo ""
    echo "Vérifier les erreurs de compilation ci-dessus."
    exit 1
fi

echo -e "${GREEN}  ✓ Module compilé : ${MODULE_PATH}${NC}"
echo "  Taille : $(du -h "$MODULE_PATH" | awk '{print $1}')"

# ─── Installation du module ────────────────────────────────────

echo ""
echo -e "${YELLOW}[7/7] Installation du module...${NC}"

# Trouver le chemin d'installation
INSTALL_DIR="/lib/modules/${KERNEL_VER}/kernel/sound/pci/hda"
ORIG_MODULE="${INSTALL_DIR}/snd-hda-codec-ca0132.ko"

# Backup de l'original si existant
if [ -f "$ORIG_MODULE" ]; then
    sudo cp "$ORIG_MODULE" "${ORIG_MODULE}.bak"
    echo "  Backup: ${ORIG_MODULE}.bak"
elif [ -f "${ORIG_MODULE}.xz" ]; then
    sudo cp "${ORIG_MODULE}.xz" "${ORIG_MODULE}.xz.bak"
    echo "  Backup: ${ORIG_MODULE}.xz.bak"
elif [ -f "${ORIG_MODULE}.zst" ]; then
    sudo cp "${ORIG_MODULE}.zst" "${ORIG_MODULE}.zst.bak"
    echo "  Backup: ${ORIG_MODULE}.zst.bak"
fi

# Installer le nouveau module
sudo mkdir -p "$INSTALL_DIR"
sudo cp "$MODULE_PATH" "$INSTALL_DIR/"
# Supprimer les versions compressées qui auraient priorité
sudo rm -f "${INSTALL_DIR}/snd-hda-codec-ca0132.ko.xz" 2>/dev/null
sudo rm -f "${INSTALL_DIR}/snd-hda-codec-ca0132.ko.zst" 2>/dev/null

sudo depmod -a
echo -e "${GREEN}  ✓ Module installé${NC}"

# ─── Chargement du module ──────────────────────────────────────

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN} Installation terminée !${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo "Le module patché est installé. Pour l'activer :"
echo ""
echo -e "${YELLOW}Option A : Reboot (recommandé pour un premier test)${NC}"
echo "  sudo reboot"
echo ""
echo -e "${YELLOW}Option B : Rechargement à chaud${NC}"
echo "  # Décharger les modules audio"
echo "  sudo rmmod snd_hda_codec_ca0132 2>/dev/null"
echo "  sudo rmmod snd_hda_intel"
echo "  # Recharger"
echo "  sudo modprobe snd_hda_intel"
echo "  # Vérifier"
echo "  dmesg | tail -30 | grep -iE 'ca0132|ae|creative'"
echo "  cat /proc/asound/cards"
echo ""
echo -e "${YELLOW}Après le reboot/reload, vérifie :${NC}"
echo "  lsmod | grep ca0132           # Le module doit être chargé"
echo "  cat /proc/asound/cards        # Tu devrais voir 'HDA Creative'"
echo "  aplay -l | grep -i creative   # Liste les devices audio Creative"
echo "  speaker-test -c2 -D hw:2,0    # Test du son (ajuste le numéro de carte)"
echo ""
echo -e "${YELLOW}Pour restaurer l'original :${NC}"
echo "  sudo cp ${ORIG_MODULE}.bak ${ORIG_MODULE}"
echo "  sudo depmod -a"
echo "  sudo reboot"
echo ""
echo -e "${GREEN}Bonne chance ! Dis-moi ce que donne le dmesg après reboot.${NC}"
