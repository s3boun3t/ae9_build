#!/bin/bash
#
# ae9_diag.sh — Diagnostic complet de la Sound Blaster AE-9
#
# Usage: bash ae9_diag.sh
#

echo "============================================"
echo " AE-9 Diagnostic — $(date)"
echo " Kernel: $(uname -r)"
echo "============================================"
echo ""

echo "=== 1. PCI Device ==="
lspci -nn -s 25:00.0 2>/dev/null || echo "Device 25:00.0 non trouvé"
echo ""

echo "=== 2. PCI Détails ==="
sudo lspci -vvv -nn -s 25:00.0 2>/dev/null | head -25
echo ""

echo "=== 3. Modules chargés (audio) ==="
lsmod | grep -E "snd|hda|ca0132|ae9" | sort
echo ""

echo "=== 4. Cartes son ==="
cat /proc/asound/cards
echo ""

echo "=== 5. Codecs HDA ==="
for card in /proc/asound/card*/codec*; do
    if [ -f "$card" ]; then
        echo "--- $card ---"
        head -10 "$card"
        echo ""
    fi
done

echo "=== 6. Devices ALSA ==="
aplay -l 2>/dev/null
echo ""

echo "=== 7. dmesg (ca0132/ae9/creative) ==="
dmesg | grep -iE "ca0132|ae.?9|creative|1102" | tail -20
echo ""

echo "=== 8. dmesg (HDA bus 25:00) ==="
dmesg | grep -i "25:00" | tail -10
echo ""

echo "=== 9. Module CA0132 ==="
modinfo snd-hda-codec-ca0132 2>/dev/null | head -10 || echo "Module snd-hda-codec-ca0132 non trouvé/chargé"
echo ""

echo "=== 10. Driver utilisé par 25:00.0 ==="
ls -la /sys/bus/pci/devices/0000:25:00.0/driver 2>/dev/null || echo "Aucun driver bindé"
echo ""

echo "=== 11. Config kernel CA0132 ==="
grep CA0132 /boot/config-$(uname -r) 2>/dev/null || echo "Config non trouvée"
echo ""

echo "=== 12. BAR regions ==="
sudo lspci -vv -s 25:00.0 2>/dev/null | grep -E "Region|Memory"
echo ""

echo "============================================"
echo " Fin du diagnostic"
echo "============================================"
