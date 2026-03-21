# AE-9 ACM I2C Protocol — Complete Reference

## Overview

The AE-9 Audio Control Module (ACM) communicates with the CA0132 DSP via an I2C-like
bus on BAR2+0xC00. All commands use a SysEx-style framing: `0xF0 <payload> 0xF7`.

The ACM controls:
- DAC configuration (ES9038Q2M)
- Volume (hardware knob on ACM)
- SBX mode toggle (button on ACM)
- Headphone/Speaker routing
- Display text on ACM OLED

**Source:** VFIO MMIO capture of Windows driver (ae9_trace_log, 2026-03-16)

---

## Bus Protocol

Each packet is written byte-by-byte to BAR2+0xC00 using `writel()`:

```
F0 <payload bytes> F7
```

Write timing: ~1ms between bytes within a packet, ~20ms between packets.

---

## Init Phase (21 packets)

Sent once at boot, BEFORE the keepalive cycle starts:

| # | Packet | Description |
|---|--------|-------------|
| 0 | `81 00` | Status query / ACM presence check |
| 1 | `54 04 41 63 6d 31` | Handshake "Acm1" |
| 2 | `54 04 31 6d 63 41` | Reverse handshake "1mcA" |
| 3 | `d5 03 00 20 04` | Config: sample rate / format |
| 4 | `54 04 11 11 11 11` | Sync pattern |
| 5 | `54 04 41 63 6d 31` | Handshake "Acm1" (repeat) |
| 6 | `54 04 31 6d 63 41` | Reverse handshake "1mcA" (repeat) |
| 7 | `55 07 00 20 04 de c0 ad de` | Auth key (0xdeadc0de) |
| 8 | `54 04 11 11 11 11` | Sync pattern (repeat) |
| 9 | `03 03 05 03 03` | DSP config: initial mode |
| 10 | `32 03 02 b8 0b` | Audio config: sample rate (48000 = 0x0bb8) |
| 11 | `43 04 64 00 f4 01` | Audio config: buffer size (500 = 0x01f4) |
| 12 | `32 03 01 88 13` | Audio config: bit rate (5000 = 0x1388) |
| 13 | `05 03 02 01 00` | Output mode config |
| 14 | `22 02 01 01` | DAC channel config L |
| 15 | `22 02 02 01` | DAC channel config R |
| 16 | `03 03 02 00 40` | SBX mode: OFF (0x00) + flags (0x40) |
| 17 | `11 09 41 45 2d 39 00 00 00 00 00` | Display: "AE-9" |
| 18 | `21 03 02 00 00` | ACK / status update |
| 19 | `83 01 02` | DSP routing command |
| 20 | `83 01 07` | DSP routing command |

### Notes on Init
- Packets 0-8 match our existing `ae9_acm_init()` implementation
- Packets 9-20 are the **audio configuration phase** that we are currently missing
- Packet 16 (`03 03 02 00 40`) sets initial SBX state
- Packet 17 shows "AE-9" on the ACM display

---

## Keepalive Cycle (~500ms period)

After init, Windows sends this cycle every ~500ms:

| # | Packet | Description |
|---|--------|-------------|
| 0 | `81 00` | Status query / watchdog |
| 1 | `54 04 41 63 6d 31` | Handshake "Acm1" |
| 2 | `54 04 31 6d 63 41` | Reverse handshake "1mcA" |
| 3 | `d5 03 00 20 04` | Config refresh |
| 4 | `54 04 11 11 11 11` | Sync pattern |
| 5 | `c2 00` | Clock/timing sync |
| 6 | `83 01 02` | DSP routing: output L |
| 7 | `83 01 02` | DSP routing: output L (repeat) |
| 8 | `83 01 07` | DSP routing: output config |
| 9 | `85 01 02` | DSP routing: headphone amp |
| 10 | `83 01 02` | DSP routing: output L |
| 11 | `83 01 07` | DSP routing: output config |
| 12 | `b1 01 01` | DAC channel enable: ch1 |
| 13 | `b1 01 02` | DAC channel enable: ch2 |
| 14 | `b1 01 03` | DAC channel enable: ch3 |
| 15 | `21 03 02 00 00` | ACK / volume report |

**CRITICAL:** Our driver currently sends ONLY the GPIO5 watchdog (`BAR2+0x320 = 0x0105`)
every 500ms. It does NOT send this I2C keepalive cycle. The ACM may require this
full cycle to keep the DAC/amp active and the audio path open.

---

## Packet Type Reference

### 0x03 — SBX/DSP Mode Control
```
F0 03 03 <mode> <param1> <param2> F7
```
- `03 03 05 03 03` — Initial DSP mode (boot)
- `03 03 02 00 40` — SBX OFF, headphone mode (0x40 = HP flag)
- `03 03 02 40 40` — SBX ON, headphone mode

### 0x05 — Output Mode
```
F0 05 03 02 <out_type> 00 F7
```
- `05 03 02 01 00` — Headphone output
- `05 03 02 00 00` — Speaker output (speculative)

### 0x11 — Display Text
```
F0 11 09 <11 bytes text, null-padded> F7
```
- `11 09 41 45 2d 39 ...` — "AE-9"
- `11 09 2d 48 50 2d ...` — "-HP-"
- `11 09 2d 53 50 2d ...` — "-SP-"
- `11 09 20 2d 39 2e 30 ...` — " -9.0" (volume in dB)

### 0x21 — Status/ACK
```
F0 21 03 02 00 00 F7
```
Sent after display updates and as keepalive response.

### 0x22 — DAC Channel Config
```
F0 22 02 <channel> <enable> F7
```
- `22 02 01 01` — Channel 1 (Left) enable
- `22 02 02 01` — Channel 2 (Right) enable

### 0x32 — Audio Format Config
```
F0 32 03 <param> <value_hi> <value_lo> F7
```
- `32 03 02 b8 0b` — Sample rate 48000 Hz (0x0BB8)
- `32 03 01 88 13` — Bit rate 5000 (0x1388)

### 0x43 — Buffer Config
```
F0 43 04 <size_hi> <size_lo> <param_hi> <param_lo> F7
```
- `43 04 64 00 f4 01` — Buffer: 100 (0x64), period: 500 (0x01F4)

### 0x54 — Handshake/Sync
```
F0 54 04 <4 bytes> F7
```
- `54 04 41 63 6d 31` — "Acm1" (forward handshake)
- `54 04 31 6d 63 41` — "1mcA" (reverse handshake)
- `54 04 11 11 11 11` — Sync pattern

### 0x55 — Auth Key
```
F0 55 07 00 20 04 de c0 ad de F7
```
Authentication key `0xDEADC0DE`. Sent once during init.

### 0x81 — Status Query / Watchdog
```
F0 81 00 F7
```
Sent at the start of every keepalive cycle (~500ms).

### 0x83 — DSP Routing
```
F0 83 01 <target> F7
```
- `83 01 02` — Route to output pair (L/R)
- `83 01 07` — Route config/enable

### 0x85 — Headphone Amp Control
```
F0 85 01 02 F7
```
Enable headphone amplifier routing.

### 0xB1 — DAC Channel Enable
```
F0 b1 01 <channel> F7
```
- `b1 01 01` — Enable DAC channel 1
- `b1 01 02` — Enable DAC channel 2
- `b1 01 03` — Enable DAC channel 3

### 0xC2 — Clock Sync
```
F0 c2 00 F7
```
Sent at the start of each keepalive cycle, after handshake.

### 0xD5 — Config Refresh
```
F0 d5 03 00 20 04 F7
```
Config refresh, sent every keepalive cycle.

---

## Volume Control (from hardware knob)

When the user turns the volume knob on the ACM, Windows sends:
```
F0 11 09 20 2d 39 2e 30 00 00 00 00 F7    (" -9.0" dB)
F0 21 03 02 00 00 F7                        (ACK)
```
Plus CA0113 MMIO commands to set ES9038 volume registers:
```
ca0113_mmio_command_set(0x48, 0x0f, <vol>)  — Left channel
ca0113_mmio_command_set(0x48, 0x10, <vol>)  — Right channel
ca0113_mmio_command_set(0x49, 0x04, <vol>)  — DAC B ch1
ca0113_mmio_command_set(0x49, 0x05, <vol>)  — DAC B ch2
ca0113_mmio_command_set(0x49, 0x02, <vol>)  — DAC B ch3
ca0113_mmio_command_set(0x49, 0x03, <vol>)  — DAC B ch4
```
Volume values observed: 0x0c, 0x0d, 0x0e, 0x12, 0x1e, 0x31, 0x35, 0x36, 0x37

---

## SBX Toggle

When SBX is toggled, the keepalive cycle changes the `0x03` packet:
- **SBX OFF:** `03 03 02 00 40`
- **SBX ON:** `03 03 02 40 40`

The second byte (0x40 vs 0x00) is the SBX enable flag.

---

## Critical Findings

### CA0113 MMIO Command Interface (BAR2+0x200)
The CA0113 command interface (`BAR2+0x208` response register) returns `0xFFFFFFFF`
under Linux. All ES9038 register writes via `ca0113_mmio_command_set()` are
silently lost. This interface may require firmware support that is not present
in the Linux DSP firmware (`ctefx.bin`).

### Missing Keepalive
Our driver sends only GPIO5 watchdog (`BAR2+0x320`). The full Windows keepalive
includes 15 I2C packets per cycle. Without these packets, the ACM may:
- Deactivate the headphone amplifier
- Mute the DAC
- Disable the audio routing

### Missing Init Packets
Our `ae9_acm_init()` sends packets 0-8 (handshake + auth). Packets 9-20
(audio config, SBX mode, display, DSP routing) are not sent. These may be
required to activate the audio path.

---

## Implementation Priority

1. **Add init packets 9-20** to `ae9_acm_init()`
2. **Implement full keepalive cycle** (replace GPIO5-only watchdog)
3. **Add SBX control** via packet `03 03 02 <sbx> 40`
4. **Investigate CA0113 command interface** separately
