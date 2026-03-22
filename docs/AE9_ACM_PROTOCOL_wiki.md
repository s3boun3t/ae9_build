# AE-9 ACM Protocol — Linux Driver Wiki

**Last updated:** 2026-03-22
**Status:** CA0113 handshake RESOLVED. CA0113 commands execute. Silence persists — investigating DAC/routing.

---

## 1. Hardware Architecture

### 1.1 System Overview

The Creative Sound Blaster AE-9 (PCI 1102:0010, SSID 1102:0071, codename "Malcolm")
is a two-part audio system: a half-height PCIe card and an external breakout box
called the ACM (Audio Control Module). They communicate via a proprietary HDMI cable.

```
┌─────────────────────────────────────┐
│           PCIe Card                 │
│                                     │
│  ┌──────────┐    ┌──────────────┐   │
│  │ CA0132 D1│←──→│   CA0113     │   │
│  │ (DSP+HDA)│    │ (PCI bridge) │   │
│  └──────────┘    └──────┬───────┘   │
│  ┌──────────┐           │           │
│  │ CA0132 D2│     ┌─────┴─────┐     │
│  │(ACM ctrl)│     │ ES9038PRO │     │
│  └──────────┘     │ (8ch DAC) │     │
│                   └───────────┘     │
│                         │           │
│                    HDMI connector    │
└─────────────────────┬───────────────┘
                      │ HDMI cable
                      │ (5V + I2S + I2C + HPD)
┌─────────────────────┴───────────────┐
│           ACM Breakout Box          │
│                                     │
│  ┌───────────┐   ┌──────────────┐   │
│  │ ES9038Q2M │   │ HP Amplifier │   │
│  │ (2ch DAC) │──→│(relay-switch)│──→ 3.5mm HP jack
│  └───────────┘   └──────────────┘   │
│  ┌───────────┐   ┌──────────────┐   │
│  │ Volume    │   │ OLED Display │   │
│  │ Knob+LED  │   │ (dB readout) │   │
│  └───────────┘   └──────────────┘   │
│  ┌───────────┐   ┌──────────────┐   │
│  │ SBX Btn   │   │ Mic input    │   │
│  │ + LED     │   │ (XLR+TRS)   │   │
│  └───────────┘   └──────────────┘   │
└─────────────────────────────────────┘
```

### 1.2 PCIe Card Components

The PCIe card contains these key chips:

**CA0132 D1** (HDA address 1, SSID 1102:0071) — the main SoC. Contains:
- Custom "Quartet" DSP (runs `ctefx-desktop.bin` firmware, 655856 bytes)
- Intel 8051 microcontroller ("ChipIO") — handles verb processing, stream routing,
  parameter management. Has 128K program memory, 128K external RAM
- HDA codec interface (NIDs 0x01–0x23)

**CA0132 D2** (HDA address 2, SSID 1102:0072) — secondary codec, used only for
ACM board interface diagnostics. Claimed with `is_d2_acm_only=true` spec.
No CT extensions (verb 0x70A not supported on D2).

**CA0113** — PCI-to-HDA bridge chip. Provides BAR2 MMIO registers for:
- ES9038 DAC register access (via command interface at 0x200–0x210)
- I2C bus controller (0xC00–0xC7C) for ACM communication
- GPIO pins (0x320)
- PLL/clock configuration

**ESS ES9038PRO** — 8-channel high-performance DAC on the PCIe card itself.
Used for the rear-panel RCA/6.3mm outputs (speakers, surround).
Register map differs from the ES9038Q2M in the ACM — they are NOT the same chip.
Group address 0x49 via CA0113 MMIO commands.

### 1.3 ACM Breakout Box Components

**ESS ES9038Q2M** — 2-channel DAC in the ACM. Converts I2S digital audio to
analog for the headphone output. Group address 0x48 via CA0113 MMIO commands.
Key registers: 0x01 (system/format), 0x04 (automute), 0x07 (I2S config),
0x0a (master mode), 0x0f/0x10 (volume L/R), 0x1d (mute control).

**Headphone amplifier** — relay-switched, controlled by GPIO pin 4.
Supports impedance ranges: Low (16-31Ω), Medium (32-149Ω), High (150-600Ω).

**OLED display** — shows volume level in dB (e.g. "-15.0"), mode ("-HP-"/"-SP-"),
or "AE-9" on boot. Controlled via I2C packet type 0x11.

**Volume knob** — hardware rotary encoder with illuminated LED ring.
Generates I2C status packets read by the driver during keepalive cycle.

**SBX button + LED** — toggles SBX audio enhancement. LED state controlled
by DSP internal state (not directly via I2C — the I2C packet `03 03 02 00 40`
tells the ACM, but the LED appears to be driven by the DSP itself).

**Microphone inputs** — XLR (phantom 48V) and 1/4" TRS combo jack.
Not covered in this document.

### 1.4 HDMI Cable

The ACM connects to the PCIe card via a standard HDMI Type-A cable carrying:

| Pin function | Signal | Direction |
|-------------|--------|-----------|
| +5V power   | 5V DC  | Card → ACM |
| I2S clock   | BCLK/LRCLK | Card → ACM |
| I2S data    | SDATA  | Card → ACM |
| I2C SDA     | I2C data | Bidirectional |
| I2C SCL     | I2C clock | Card → ACM |
| HPD         | Hot Plug Detect | ACM → Card |

This is NOT standard HDMI video/audio — Creative repurposed the connector for their
proprietary bus. The HDMI cable carries power (5V from the PCIe slot, stepped down),
the digital audio stream (I2S from DSP through CA0113 to ES9038Q2M), and the control
bus (I2C for ACM commands/status).

> ⚠️ The HPD (Hot Plug Detect) signal is how the card detects ACM presence.
> Currently `Front Headphone Jack = off` in the mixer — the jack detection
> mechanism for the ACM headphone jack is not yet implemented correctly.

### 1.5 Two DACs — Critical Difference

| Property | ES9038PRO (PCIe card) | ES9038Q2M (ACM box) |
|----------|----------------------|---------------------|
| Channels | 8 | 2 |
| CA0113 group | 0x49 | 0x48 |
| Output | Rear panel RCA/6.3mm | ACM 3.5mm HP jack |
| Register map | ES9038PRO datasheet | ES9038Q2M datasheet |
| I2S interface | Direct on PCB | Via HDMI cable |

**The register maps are DIFFERENT.** Registers like 0x01, 0x02 have different
layouts between PRO and Q2M. When writing ES9038 configuration, always check
which DAC you're targeting (group 0x48 vs 0x49).

---

## 2. PCI / BAR Layout

| BAR | Physical Address | Size | Purpose |
|-----|-----------------|------|---------|
| BAR0 | 0xfc500000 | 16K | HDA controller (managed by `snd-hda-intel`) |
| BAR2 | 0xfc504000 | 4K | Creative extensions (`spec->mem_base`) |

All ACM/DAC/GPIO communication goes through BAR2.

---

## 3. CA0113 MMIO Command Interface

### 3.1 Register Map (BAR2)

| Offset | Name | Description |
|--------|------|-------------|
| 0x204 | CMD_DATA | Command data: `(value << 8) \| target_reg` |
| 0x208 | CMD_RESPONSE | Handshake/response register |
| 0x20c | CMD_STATE | State machine control (see below) |
| 0x210 | CMD_SYNC | Sync pattern (0x7e/0x5a) |
| 0x804 | CMD_GROUP | Group address (0x48=ES9038Q2M, 0x49=ES9038PRO) |
| 0x320 | GPIO_CTL | GPIO pin control |
| 0x854 | STATUS_1 | Command execution status (1=done) |
| 0x860 | STATUS_2 | Command completion flag (1=complete) |
| 0x840 | STATUS_3 | Bridge ready status |

### 3.2 State Machine (0x20c)

| Value | Mode | Description |
|-------|------|-------------|
| 0x800000 | Reset | Initial state after PCI reset |
| 0x800001 | Enable | After PLL/clock init. Handshake possible |
| 0x800002 | End handshake | Written after handshake token exchange |
| 0x800003 | Mode 3 | Type2 trigger / intermediate mode |
| 0x800004 | End command | Written to end each command |
| 0x800005 | Mode 5 | Type1 write trigger |

> ⚠️ **CRITICAL RULE:** NEVER use read-modify-write on 0x20c.
> Always write absolute values. Connor's original code propagated bit 16
> (8051 ACK) which permanently corrupts the state machine.

### 3.3 Command Protocol — Type1 (RESOLVED ✅ — 22 mars 2026)

Type1 commands write a register value to the ES9038 DAC.

```
Sync:    writel(0x7e, 0x210); readl(0x210)
         writel(0x5a, 0x210); readl(0x210); readl(0x210)

Mode 3:  readl(0x20c); writel(0x800003, 0x20c); readl(0x20c)
Group:   readl(0x804); writel(group, 0x804);     readl(0x804)
Mode 5:  readl(0x20c); writel(0x800005, 0x20c); readl(0x20c)
Data:    writel((val << 8) | reg, 0x204);        readl(0x204)

Wait:    poll bit 23 of 0x20c = 1 (response ready)

End:     writel(0x800004, 0x20c); readl(0x20c)
         writel(0x00, 0x210);     readl(0x210)
```

Key points:
- Every `writel` is followed by a `readl` (PCI posting barrier)
- Mode is set BEFORE group and data (mode3 → group → mode5 → data)
- The sync (0x7e/0x5a) only works after the handshake at boot; subsequent
  commands still do the sync write but the 0x210 register reads 0x00 (not 0xaa)
  — this appears to be normal after the initial handshake

### 3.4 Command Protocol — Type2

Type2 commands use mode 1 → mode 3 sequence:

```
Sync:    (same as type1)
Mode 1:  readl(0x20c); writel(0x800001, 0x20c); readl(0x20c)
Group:   readl(0x804); writel(group, 0x804);     readl(0x804)
Mode 3:  readl(0x20c); writel(0x800003, 0x20c); readl(0x20c)
Data:    writel((val << 8) | reg, 0x204);        readl(0x204)
Wait:    poll bit 23
End:     (same as type1)
```

### 3.5 Boot Handshake (RESOLVED ✅ — 22 mars 2026)

The CA0113 handshake must be performed ONCE at boot, AFTER the DSP firmware
download completes but BEFORE any `ca0113_mmio_command_set` call.
At this point `0x20c` must be at `0x800001`.

Full sequence decoded from Windows MMIO capture (lines 4907–4970):

```
Phase 1 — Sync
  GPIO 0x320 = 0x100 (pin 0 only, not 0x105)
  0x210 = 0x7e, read → 0x00
  0x210 = 0x5a, read → 0xaa          ← SYNC OK

Phase 2 — Initial command (group=0x48, target=0x07)
  0x20c = 0x800001 (rewrite), readback
  0x804 = 0x48 (group), readback
  0x20c = 0x800003 (mode 3), readback
  0x204 = 0x07 (target), readback
  Wait 16ms
  Read 0x20c → 0x810003 (bit 16 = 8051 ACK)
  Read 0x860=1, 0x854=1, 0x840=1     ← COMMAND EXECUTED

Phase 3 — Handshake token
  0x20c = 0x800003 (rewrite), readback
  0x208 = 0xffff (token write)
  Read 0x208 → 0xffffffff (immediate)
  Wait 16ms
  Read 0x208 → 0xffffff00            ← TOKEN ACKNOWLEDGED

Phase 4 — End handshake + re-sync
  0x20c = 0x800002 (end), readback
  0x210 = 0x00 (clear sync)
  0x210 = 0x7e, read → 0x00
  0x210 = 0x5a, read → 0xaa          ← RE-SYNC OK

Phase 5 — First real type1 command (verify bridge works)
  0x20c = 0x800003, readback
  0x804 = 0x48, readback
  0x20c = 0x800005, readback
  0x204 = 0x0107 (reg=0x07, val=0x01, ES9038 I2S config)
  Wait 16ms
  Read 0x860 = 1                      ← COMMAND EXECUTED
  0x20c = 0x800004, readback
  0x210 = 0x00

Phase 6 — Restore GPIO
  0x320 = 0x0105 (GPIO5 for DAC power)
```

**Current Linux status:** Phases 1–4 implemented, sync=0xaa OK,
token=0xffffff80 (partial — Windows gets 0xffffff00).
Phase 5 works: 0x860=1 after re-sync + first command.
All subsequent CA0113 commands pass with bit 23 ACK.

---

## 4. I2C Bus Protocol (ACM Communication)

### 4.1 Physical Interface

The I2C bus is accessed via BAR2+0xC00:

| Offset | Register | Description |
|--------|----------|-------------|
| 0xC00 | I2C_CMD | Write command/data bytes |
| 0xC04 | I2C_DATA | Data trigger |
| 0xC08 | I2C_FIFO | TX FIFO |
| 0xC0C | I2C_STATUS | Command state machine (driver writes each state) |
| 0xC7C | ACM_PRESENCE | 0x06=idle, 0x07=busy, 0x0f=byte complete |

Each packet is SysEx-style framed: `0xF0 <payload bytes> 0xF7`

### 4.2 ACM Init (21 packets at boot)

| # | Packet | Status | Description |
|---|--------|--------|-------------|
| 0 | `81 00` | ✅ | Status query / presence check |
| 1 | `54 04 41 63 6d 31` | ✅ | Handshake "Acm1" |
| 2 | `54 04 31 6d 63 41` | ✅ | Reverse "1mcA" |
| 3 | `d5 03 00 20 04` | ✅ | Config |
| 4 | `54 04 11 11 11 11` | ✅ | Sync pattern |
| 5 | `55 07 00 20 04 de c0 ad de` | ✅ | Auth key 0xDEADC0DE |
| 6 | `03 03 05 03 03` | ✅ | DSP mode init |
| 7 | `32 03 02 b8 0b` | ✅ | Sample rate 48kHz |
| 8 | `43 04 64 00 f4 01` | ✅ | Buffer config |
| 9 | `32 03 01 88 13` | ✅ | Bit rate |
| 10 | `05 03 02 01 00` | ✅ | Output: headphone |
| 11 | `22 02 01 01` | ✅ | DAC ch L enable |
| 12 | `22 02 02 01` | ✅ | DAC ch R enable |
| 13 | `03 03 02 00 40` | ✅ | SBX OFF |
| 14 | `11 09 41 45 2d 39 00...` | ✅ | Display "AE-9" |
| 15 | `21 03 02 00 00` | ✅ | ACK |
| 16 | `83 01 02` | ✅ | DSP routing |
| 17 | `83 01 07` | ✅ | DSP routing |

All packets implemented in `ae9_acm_init()`.

### 4.3 Keepalive Cycle (~500ms)

15 I2C packets + GPIO5 watchdog, implemented in `ae9_keepalive_timer_fn`. ✅

| # | Packet | Description |
|---|--------|-------------|
| 0 | `81 00` | Watchdog |
| 1 | `54 04 41 63 6d 31` | Handshake |
| 2 | `54 04 31 6d 63 41` | Reverse |
| 3 | `d5 03 00 20 04` | Config refresh |
| 4 | `54 04 11 11 11 11` | Sync |
| 5 | `c2 00` | Clock sync |
| 6-7 | `83 01 02` | Output routing L |
| 8 | `83 01 07` | Output config |
| 9 | `85 01 02` | HP amp routing |
| 10 | `83 01 02` | Output routing |
| 11 | `83 01 07` | Output config |
| 12 | `b1 01 01` | DAC ch1 enable |
| 13 | `b1 01 02` | DAC ch2 enable |
| 14 | `b1 01 03` | DAC ch3 enable |
| 15 | `21 03 02 00 00` | ACK/volume |

Plus: `BAR2+0x320 = 0x0105` (GPIO5 DAC power watchdog)

### 4.4 Packet Type Reference

| Type | Format | Examples |
|------|--------|---------|
| 0x03 | `03 03 <mode> <p1> <p2>` | SBX OFF: `03 03 02 00 40`, SBX ON: `03 03 02 40 40` |
| 0x05 | `05 03 02 <out> 00` | HP: `05 03 02 01 00` |
| 0x11 | `11 09 <9 bytes text>` | Display "AE-9": `11 09 41 45 2d 39 00 00 00 00 00` |
| 0x21 | `21 03 02 00 00` | ACK / status |
| 0x22 | `22 02 <ch> <en>` | Ch1 enable: `22 02 01 01` |
| 0x32 | `32 03 <p> <hi> <lo>` | 48kHz: `32 03 02 b8 0b` |
| 0x43 | `43 04 <4 bytes>` | Buffer: `43 04 64 00 f4 01` |
| 0x54 | `54 04 <4 bytes>` | Handshake: `54 04 41 63 6d 31` ("Acm1") |
| 0x55 | `55 07 <7 bytes>` | Auth: `55 07 00 20 04 de c0 ad de` |
| 0x81 | `81 00` | Watchdog query |
| 0x83 | `83 01 <target>` | DSP routing |
| 0x85 | `85 01 02` | HP amp enable |
| 0xB1 | `b1 01 <ch>` | DAC channel enable |
| 0xC2 | `c2 00` | Clock sync |
| 0xD5 | `d5 03 00 20 04` | Config refresh |

---

## 5. GPIO Pins (BAR2+0x320)

| Value | Pin | Effect |
|-------|-----|--------|
| 0x0100 | 0 | Used during CA0113 handshake only |
| 0x0103 | 3 | Init sequence |
| 0x0104 | 4 | Headphone amplifier power ON |
| 0x0105 | 5 | DAC board power ON (keepalive every 500ms) |

---

## 6. 8051 Firmware / ChipIO

### 6.1 Confirmed state via 8051 console (`ca0132-8051-command-line`)

| Command | Value | Meaning |
|---------|-------|---------|
| `ctrl 0x0d` ("dac2port") | 0xa1 | Headphone output ✅ |
| `ctrl 0x17` ("asi") | 0x0f | Direct Mode, 6ch ✅ |
| `ctrl 0x0e` ("mpce0") | 0x00 | Play enhancement OFF ✅ |
| `ctrl 0x06` ("gdout") | 0x00 | Global digital output |
| `flag 0x01` ("dma") | ON | DMA active ✅ |
| `flag 0x02` ("idle") | OFF | Not idle ✅ |
| `flag 0x09` ("dsp96k") | ON | DSP 96kHz mode |
| `hci 0x189000` | 0x0001F100 | I2S config ✅ |
| `hci 0x189024` | 0x00008005 | Stream config ✅ |

### 6.2 Connor's tools

- `ca0132-tools` (`~/ca0132-tools/`): 8051 console, exram dump, stream data
- `chipio-simulator` (`~/chipio-simulator/`): full 8051 emulator with verb injection
- Live dump created: `save-states/ae9-live`

---

## 7. Boot Sequence (driver flow)

```
t=0s      ca0132_mmio_init_ae9()          0x20c=0x800000, 0x1c=0x880480
          ae5_register_set()              0x20c=0x800001 (PLL/clock)
          ca0132_ca0113_init_ae9()        GPIO5 power
          init_params/flags               ~85 HDA verbs
          base_init_verbs
          ca0132_alt_init()

t+0.6s    ca0132_download_dsp()           DSP firmware loaded

t+1s      ae9_setup_defaults()
            ae9_post_dsp_mmio_commands()  I2S clock ramp
            *** CA0113 HANDSHAKE ***      sync(0xaa) + token + re-sync + first cmd
            ca0132_alt_init_analog_mics()
            ca0132_alt_start_dsp_audio_streams()
            ca0113_mmio_command_set()     ES9038 register writes
            ae9_acm_bus_init()            I2C init (STATUS=0x03)
            ae9_acm_init()               21 I2C packets
            ca0132_alt_select_out()       dac2port=0xa1, unmute
            keepalive start               I2C + GPIO5 every 500ms

t+5s      init_output/init_input
          alt_select_out/in
          jack_report_sync
```

---

## 8. Current Problem: Silence

### Confirmed working ✅
- DSP downloaded and running
- CA0113 handshake: sync=0xaa, token=0xffffff80, re-sync=0xaa
- CA0113 first command: 0x860=1 (executed)
- All subsequent CA0113 commands pass (bit 23 ack, no errors)
- ACM init complete (STATUS=0x03, PRESENCE=0x0f)
- HDA DMA running (SD4, LPIB advances)
- All I2C keepalive packets sent
- Mixer unmuted (Front=100%, Master=100%, Output=Headphone)
- 8051 state confirmed correct via console

### Not working ❌
- Silence total on headphone
- 0x854=0, 0x860=0 DURING playback (OK at boot, reverts)
- 0x208=0xffffff80 (not 0xffffff00 like Windows) — partial handshake
- SBX LED stays on
- Front Headphone Jack = off (ACM jack detection not working)
- CA0113 sync fails after boot (0x210 returns 0x00 instead of 0xaa)

### Eliminated hypotheses

| Hypothesis | When eliminated | How |
|-----------|----------------|-----|
| Read-modify-write on 0x20c | 21 mars | Absolute writes fix |
| CA0113 commands silently lost | 21 mars | wait_response succeeds |
| IOCE stalls DSP DMA | 20 mars | Bit 2 cleared in pcm_prepare |
| I2C keepalive missing | 19 mars | Full 15-packet cycle implemented |
| DAC chip = CS43198 | 18 mars | Hardware confirmed ES9038Q2M |
| CA0113 handshake impossible | 22 mars | Sync + token + re-sync all work |
| CA0113 never executes commands | 22 mars | 0x860=1 confirmed |
| GCTL reset from codec driver | 20 mars | Kills 8051, don't do this |

### Active hypotheses

| # | Hypothesis | Level | Test |
|---|-----------|-------|------|
| 1 | CA0113 sync fails after boot → commands pass via bit23 but don't reach DAC | Probable | Compare MMIO trace of playback commands |
| 2 | Headphone Jack = off → driver mutes output | Possible | Force jack on or bypass detection |
| 3 | SBX active in DSP → wrong routing path | Possible | Find SBX disable command |
| 4 | 0x208 partial (0x80 vs 0x00) → ES9038 not fully init | Possible | Compare ES9038 register state |
| 5 | ES9038 volume registers at max attenuation | Possible | Read back via type1 read cmd |

---

## 9. References

| Resource | Location |
|----------|----------|
| Driver source | `~/ae9_build/build/ca0132.c` |
| MMIO capture (2.2M lines) | `~/Téléchargements/ae9_mmio_capture.txt` |
| CORB boot dumps | `~/ae9_build/docs/corb_boot_1-5.txt` |
| BAR2 dumps | `~/ae9_build/docs/bar2_windows.txt`, `bar2_linux.txt` |
| CORB analysis | `~/ae9_build/docs/ae9_corb_boot_analysis.md` |
| Fernando RE document | Project: `Creative_Sound_Blaster_-_Reverse_Engineering_Fernando.md` |
| ES9038Q2M datasheet | Project: `ES9038Q2M.PDF` |
| ES9038PRO datasheet | Project: `ES9038PRO.PDF` |
| Connor's ca0132-tools | `~/ca0132-tools/` |
| Connor's 8051 simulator | `~/chipio-simulator/` |
| GitHub | https://github.com/s3boun3t/ae9_build |
