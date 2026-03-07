# AE-9 Stream Descriptor DSP - Séquence d'init (region2 0xC00-0xC14)

## Découverte par analyse MMIO capture (2026-03-08)

### Séquence complète

W [0xc0c] = 0x80 # Reset stream (SRST bit7)
W [0xc00] = 0x30 # SDnCTL : priority + IOCE
W [0xc04] = 0x00 # Clear LPIB
W [0xc0c] = 0x00 # Clear reset
W [0xc0c] = 0x03 # LVI = 3 (4 BDL entries, index 0-3)
W [0xc08] = 0xc1 # Flags DSP (bits 7+6 hardwired 0xC0, bit0=1)
W [0xc04] = 0x80 # LPIB position initiale
--- attendre firmware DSP chargé (~6 sec en Windows) ---

W [0xc0c] = 0x83 # RUN : LVI=3 + bit7 = trigger démarrage stream

text

### Notes importantes
- 0xc08 n'est PAS CBL standard HDA — bits 7+6 forcés HW à 0xC0
- 0xc0c bit7 = trigger start (pas un SDnCTL séparé)
- 0xc14 = status : 0x40=FIFO ready, 0x41=BCIS pulse (2.3ms/chunk, 435/sec)
- 0xc7c = BDL status : stable à 0x6 en fonctionnement normal
- D2 répond à tous les verbs CORB (6655 total, 25 wraps, 1:1 avec RIRB)
