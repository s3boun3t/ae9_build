# AE-9 ACM Protocol — Linux Driver Implementation

**Last updated:** 2026-03-06  
**Status:** ✅ ACM board initializes successfully — DAC display lights up,
audio output confirmed working. Volume knob and headphone output pending.

---

## Hardware overview

The Creative Sound Blaster AE-9 (PCI 1102:0010, SSID 1102:0071) contains two
CA0132 HDA codecs on a single PCI device:

| Codec | HDA addr | SSID       | Role |
|-------|----------|------------|------|
| D1    | 1        | 1102:0071  | Main CA0132 DSP + audio I/O |
| D2    | 2        | 1102:0072  | ACM board interface (diagnostic only) |

The **ACM** (Audio Control Module) is the external breakout box providing:
- CS43198 DAC with premium analog outputs
- Headphone amplifier (relay-switched)
- Front-panel volume knob with illuminated ring
- Front-panel display (shows volume level, e.g. "-15.0")

---

## MMIO register map

All ACM communication uses **BAR2** (`pci_iomap(..., 2, ...)` =
`spec->mem_base`), mapped at physical address `0xfc504000`.

### I2C controller registers (all R/W — confirmed writable)

| Offset | Name           | Role |
|--------|----------------|------|
| 0xc00  | I2C_CMD        | Command bytes, packet data |
| 0xc04  | I2C_DATA       | Data trigger register |
| 0xc08  | I2C_FIFO       | TX FIFO — writable; read between each write required |
| 0xc0c  | I2C_STATUS     | **Command register** — driver writes each state manually |
| 0xc14  | I2C_TXSTAT     | TX byte completion flag; poll for 0x41 after each CMD write |
| 0xc7c  | ACM_PRESENCE   | 0x06 = ACM present/idle, 0x07 = byte in transit, 0x0f = byte complete |
| 0x320  | I2C_GPIO_CTL   | Written 0x0105 once before first packet TX |

> ⚠️ **CRITICAL — I2C_STATUS is a COMMAND register:**  
> `0xc0c` does NOT transition automatically. The driver writes each state
> explicitly: `0x80` (reset-hold) → `0x00` (transition) → `0x03` (bus-ready).
> After the 6-second MCU boot delay, the driver also writes `0x83` explicitly.
> Confirmed from raw VFIO trace lines 68–114 and 63983–64000.

> ⚠️ **devmem2 danger:** Writing to these registers via `devmem2` while the
> driver is loaded causes a PCI bus fault (device header → 0x7f, all reads
> return 0xFFFFFFFF). Cold power-off required to recover. This is an ioremap
> conflict, NOT proof the registers are read-only.

### I2C_STATUS values

| Value | Meaning |
|-------|---------|
| 0x00  | Transition / idle (written by driver) |
| 0x03  | Bus ready (written by driver) |
| 0x80  | Reset-hold (written by driver) |
| 0x83  | ACM MCU signaled ready (written by driver ~6s after TX #1) |

### I2C_TXSTAT / ACM_PRESENCE byte-ack pattern

After each byte written to I2C_CMD, the controller signals completion:

```
poll 0xc14 + 0xc7c until c14=0x41 AND c7c=0x0f  → byte forwarded to I2C bus
read 0xc00  → echoed byte (RX from ACM MCU)
0xc7c returns 0x06 (idle) or 0x07 (busy) between bytes
```

> **Note:** In practice the ACM responds and the DAC initializes correctly
> even when the `c14=0x41/c7c=0x0f` condition times out. The poll is a
> best-effort synchronization from the Windows driver; the Linux driver
> logs a warning and continues.

---

## Boot sequence (driver flow)

```
t=0s    ca0132_mmio_init_ae5()
          indices 0–22 + 36 executed (normal MMIO init)
          indices 23–35 SKIPPED for AE-9 (I2C regs — done after GPIO)

t=+1s   ca0132_download_dsp()       D1 DSP running

t=+2s   ae9_setup_defaults()
          ca0113_mmio_gpio_set(5, true)  ← ACM board powered (GPIO5)
          ca0113_mmio_gpio_set(4, true)  ← headphone amp on (GPIO4)
          schedule_delayed_work(5s)

t=+7s   ae9_acm_delayed_worker() fires
          ae9_acm_bus_init() starts — TX #1

t=+7s   ae9_acm_bus_init(): TX #1 executes (~1ms)
          STATUS: 0x80 → 0x00 → 0x03 (written manually)
          FIFO loaded, DATA=0x80 sent, GPIO pulse on 0x1c
          msleep(7000)  ← wait for ACM MCU async boot

t=+14s  ae9_acm_bus_init() resumes
          STATUS=0x83 written by driver
          CMD=0x0d, DATA=0x00 sent
          STATUS reverted to 0x03
          0x320 = 0x0105 written

t=+14s  ae9_acm_init(): TX #2–#30 sent
          DAC display lights up, shows "-15.0"
```

---

## TX #1 — Exact sequence (VFIO confirmed, lines 68–114)

Source of truth: `ae9_mmio_capture.txt` (raw VFIO trace, 179 MB, 37103 MMIO
operations, captured under QEMU/KVM + Windows 11 VM on Linux Mint).

```
READ  0xc7c         → 0x06   ACM presence check
READ  0xc0c         → 0x00   observe initial state
WRITE 0xc0c = 0x80           reset-hold
READ  0xc0c         → 0x80   confirm (no auto-transition — NORMAL)
WRITE 0xc00 = 0x30           clock divider / bus enable
READ  0xc00         → 0x30
WRITE 0xc04 = 0x00           data kick
READ  0xc04         → 0x00
READ  0xc0c         → 0x80   still reset-hold
WRITE 0xc0c = 0x00           force transition to 0x00
READ  0xc0c         → 0x00
READ  0xc7c         → 0x06
READ  0xc0c         → 0x00
WRITE 0xc0c = 0x03           force bus-ready
READ  0xc0c         → 0x03
  (×3 confirm: READ 0xc7c / READ+WRITE 0xc0c=0x03)
READ  0xc08         → 0x01   read FIFO before loading
WRITE 0xc08 = 0x01  ; READ ×2 (returns 0xc1)
WRITE 0xc08 = 0xf1  ; READ ×2
WRITE 0xc08 = 0x01  ; READ ×2
WRITE 0xc08 = 0xc7  ; READ ×2
WRITE 0xc08 = 0xc1  ; READ ×1
READ  0xc04         → 0x00
WRITE 0xc04 = 0x80           commit FIFO — releases ACM MCU from reset
READ  0xc04         → 0x80
READ  0x01c         → 0x880480
WRITE 0x01c = 0x480           GPIO pulse: clear bit 23
READ  0x01c         → 0x480   (×2)
WRITE 0x01c = 0x880480        GPIO restore
READ  0x01c         → 0x880480
```

### TX #2 preamble — 6.14 seconds later (VFIO lines 63983–64000)

```
READ  0xc7c         → 0x06
READ  0xc0c         → 0x03   (MCU still has NOT set this — still 0x03)
WRITE 0xc0c = 0x83           driver writes 0x83 explicitly
READ  0xc0c         → 0x83   confirm
WRITE 0xc00 = 0x0d           reset command to MCU
READ  0xc00
WRITE 0xc04 = 0x00
READ  0xc04
READ  0xc0c         → 0x83
WRITE 0xc0c = 0x03           revert to ready
READ  0xc0c         → 0x03
WRITE 0x320 = 0x0105         I2C GPIO control, written once
```

---

## TX #2–#30 — ACM command packets

### Packet format (per-byte ACK required)

```
WRITE CMD = 0xf0              start-of-packet
  poll 0xc14/0xc7c until 0x41/0x0f, then READ CMD (RX echo)
WRITE CMD = byte0 .. byteN    payload
  (same poll + read after each byte)
WRITE CMD = 0xf7              end-of-transaction (6083× in full capture)
  (same poll + read)
```

The `0xc7c` value changes during transit: `0x06` (idle) → `0x07` (byte
in transit) → `0x0f` (byte complete, CMD echo available) → `0x06` (idle).

### Full packet table

| TX  | Label     | Payload (between 0xf0 and 0xf7) |
|-----|-----------|----------------------------------|
| #2  | reset     | `81 00` |
| #3  | hs_fwd    | `54 04 41 63 6d 31` |
| #4  | hs_rev    | `54 04 31 6d 63 41` |
| #5  | cfg       | `d5 03 00 20 04` |
| #6  | stchk     | `54 04 11 11 11 11` |
| #7  | key       | `55 07 00 20 04 de c0 ad de` |
| #8  | gpio1     | `03 03 05 03 03` |
| #9  | sr48      | `32 03 02 b8 0b` |
| #10 | vol       | `43 04 64 00 f4 01` |
| #11 | sr96      | `32 03 01 88 13` |
| #12 | ch        | `05 03 02 01 00` |
| #13 | unmute    | `22 02 01 00` |
| #14 | mute2     | `22 02 02 01` |
| #15 | gpio2     | `03 03 02 00 40` |
| #16 | name      | `11 09 41 45 2d 39 00 00 00 00 00` ("AE-9") |
| #17 | pwr       | `21 03 02 00 00` |
| #18 | out1      | `83 01 02` |
| #19 | out2      | `83 01 07` |
| #20 | reset2    | `81 00` |
| #21 | query     | `c2 00` |
| #22 | insel     | `85 01 02` |
| #23 | dac1      | `b1 01 01` |
| #24 | dac2      | `b1 01 02` |
| #25 | dac3      | `b1 01 03` |
| #26 | label_hp  | `11 09 2d 48 50 2d 00 00 00 00 00` ("-HP-") |
| #27 | label_24  | `11 09 2d 32 34 2e 35 00 00 00 00` ("-24.5") |
| #28 | gpio3     | `03 03 02 40 40` |
| #29 | label_15  | `11 09 2d 31 35 2e 30 00 00 00 00` ("-15.0") |
| #30 | unmute2   | `22 02 01 01` |

---

## D2 codec — diagnostic reads

D2 (addr=2) is claimed with `is_d2_acm_only=true`. Not part of init path.
The following HDA verbs can be read for diagnostics:

| Verb  | Expected   | Description |
|-------|------------|-------------|
| 0xf07 | 0xd1       | Firmware constant |
| 0xf0f | 0x01c31fd9 | Firmware build ID |

```bash
# Requires hda-verb package
hda-verb /dev/snd/hwC0D2 0x15 0xf07 0
hda-verb /dev/snd/hwC0D2 0x15 0xf0f 0
```

---

## GPIO — DAC power

GPIO is controlled via `ca0113_mmio_gpio_set()` (BAR2 MMIO, offset `0x1c`).

| GPIO | Pin name        | Value | Effect |
|------|-----------------|-------|--------|
| 5    | ExternalDACReset| true  | Power ACM board ON |
| 4    | HPAMP_SHDN      | true  | Headphone amp ON |

Normal value of `0x1c`: `0x880480`.  
TX #1 GPIO pulse: `0x880480 → 0x480 → 0x880480` (bit 23 cleared/restored).

---

## Why indices 23–35 are skipped in ca0132_mmio_init_ae5()

The AE-5 MMIO init table indices 23–35 contain an early I2C sequence.
For the AE-9 these are skipped because:
1. GPIO 5 (ACM power) is not yet asserted at `ca0132_mmio_init_ae5()` time
2. The ACM MCU cannot respond without power
3. `ae9_acm_bus_init()` re-executes this sequence 7+ seconds later

---

## Known false leads (do not repeat)

| Hypothesis | Why wrong |
|-----------|-----------|
| STATUS (0xc0c) is read-only | devmem2 fault = ioremap conflict, not hardware protection |
| STATUS transitions automatically | Driver writes each state explicitly |
| STATUS=0x83 appears automatically after DATA=0x80 | It appears 6.14s later and is WRITTEN by driver |
| FIFO loaded via CMD (0xc00) | FIFO loaded via 0xc08 directly |
| Poll STATUS until 0x03 | STATUS is written, not polled |
| 0xc14/0xc7c must reach 0x41/0x0f to proceed | Packets succeed even on poll timeout |

---

## Pending / next steps

- **Volume knob:** front-panel knob does not control system volume yet.
  Requires reading knob encoder events from ACM and routing to ALSA mixer.
- **Headphone output:** not exposed as separate ALSA device yet.
- **Microphone input:** not exposed yet.
- **Spam reduction:** `byte-ack timeout` warnings fill dmesg — consider
  reducing to `codec_dbg` or removing the poll entirely.
- **Init delay:** 7s `msleep` in `ae9_acm_bus_init()` adds ~14s to boot.
  Could be replaced with a completion + interrupt or a shorter poll loop.

---

## References

- `ae9_mmio_capture.txt` — VFIO trace, 179 MB, 37103 MMIO ops, 2026-02-25
- `ae9_init_unique_transactions.txt` — extracted I2C transactions
- Connor McAdams AE-5/AE-7 patches (mainlined Linux 5.10)
- Project repo: https://github.com/s3boun3t/ae9_build
