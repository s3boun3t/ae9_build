**CONFIDENTIAL **

**ES9038Q2M 32-Bit Stereo Low Power Audio !!!DAC*** 

**Analog Reinvented  Datasheet**

The ***ES9038Q2M SABRE32 Reference DAC*** is a very high-performance, 32-bit, stereo audio D/A converter designed for: audiophile-grade power sensitive applications such as digital music players, Blu-ray players, audio pre-amplifiers and A/V receivers, and professional applications such as recording systems, mixer consoles and digital audio workstations. 

Using the critically acclaimed ESS patented 32-bit HyperStream® II DAC architecture and Time Domain Jitter Eliminator, the ***ES9038Q2M*** delivers a DNR of up to 128dB and THD+N of –120dB, a performance level that will satisfy the most demanding audio enthusiasts. 

The ***ES9038Q2M*** handles up to 32-bit 768kHz PCM, DSD256 via DoP and native DSD512 data in master or slave timing modes. Custom sound signature is supported via a fully programmable FIR filter with 7 presets. Residual distortion from suboptimal PCB components and layout can be minimized using ***ES9038Q2M’s*** unique THD compensation circuit, while chip-to-chip gain variation is minimized via a built-in auto gain calibration circuit. 

The ***ES9038Q2M SABRE32 Reference DAC*** sets the standard, **SABRE SOUND®**, for HD audio performance, typically consumes 40mW in normal operation mode (1.3mW in standby mode), and comes in an easy-to-use 30-QFN (3mm x 5mm) package. 

**FEATURE **

Patented 32-bit HyperStream® II DAC 

- +128dB DNR 
- –120dB THD+N 

Patented Time Domain Jitter Eliminator 64-bit accumulator & 32-bit processing 

Integrated DSP Functions 

Customizable output configuration I2C control 

30-QFN package 

40mW operating power consumption 1.3 mW standby power 

Versatile digital input  

Customizable filter characteristics THD compensation 

Dedicated HPA Control 

Auto Gain Calibration Clock Gearing 

**DESCRIPTION** 

- Industry’s highest performance 32-bit low power audio DAC with unprecedented dynamic range and ultra-low distortion 
- Supports both synchronous and ASRC (asynchronous sample rate converter) modes 
- Unmatched audio clarity free from input clock jitter 
- Distortion free signal processing 
- Click-free soft mute and volume control 
- Programmable automute 
- De-emphasis for 32kHz, 44.1kHz, and 48kHz sampling 
- Stereo or Mono output in current or voltage mode based on performance criterion 
- Allows software control of DAC features 
- Minimizes PCB footprint 
- Maximizes battery life 
- Supports SPDIF, PCM (I2S, LJ 16-32-bit), DoP or DSD input 
- Supports up to 768kHz PCM, DSD256 via DoP and native DSD1024 
- 7 presets or user programmable filters for custom sound signature 
- Bypassable oversampling filter 
- Minimize distortion from external PCB components and layout 
- Power down HPA (supports auto shutdown at zero input for lower power) 
- Selects HPA auxiliary input 
- Programmable HPA charge pump frequency 
- Minimize chip-to-chip gain variation 
- Reduce operating frequency for lower sampling rate to reduce power consumption 

ESS TECHNOLOGY, INC.  237 South Hillview Drive, Milpitas, CA 95035, USA  Tel (408) 643-8800 • Fax (408) 643-8801 

**July 17, 2019  CONFIDENTIAL Rev. 1.3 !**

**ES9038Q2M Datasheet !!!**

**APPLICATIONS** 

- Mobile phones / Tablets / Digital music players / Portable multimedia players 
- Blu-ray / SACD / DVD-Audio player 
- Audio preamplifiers and A/V receivers 
- Professional audio recording systems / Mixing consoles / Digital audio workstations 

**FUNCTIONAL BLOCK DIAGRAM** 

RESETB SDA  SCL ADDR GPIO1 GPIO2  SW  FSYNC  HPSDb  BIAS !!!!

CONTROL INTERFACE

32-bit !!!

Dynamic  !!

OVERSAMPLING FILTER Hyperstream ®IIIII  DACL, DACLB!!

PCM / 7 preset FIR filters (PCM) DAC!

ASRC Matching!

DATA[2:1] DoP / - &!!!!

DSD / De emphasis (PCM) Jitter 

DATA\_CLK Volume Control Reduction !!!

SPDIF  Soft Mute  32-bit Dyna !!!!

Interface Zero Detect DPLL Hyperstream ®II  Matchmingic  DACR, DACRB!

DAC

X Gain Core  Core & IO DAC!

X I  OSC Calibration Supply Power Supply Power Supply!!

OUT ADC!!

GPIO2

VCCA  DVDD DVCC  AVCC\_L, AVCC\_R (3.3V)!!!! (1.8/3.3V) GND (3.3V)!!

**TYPICAL APPLICATION DIAGRAM** 

L **SABRE9602**

I2S 

***SABRE*** R ***HPA*** 

Platform*  **Switch** Headphones Application

Processor I2S

Platform SPK Driver Speakers 

Codec Earpiece (phone only)

MICs

**ES9038Q2M PIN LAYOUT** 

25 24 23 22 21 20 19 18 17 16

NC 26 15 DVDD VCCA 27 14 DGND

XOUT 28 **ES9038Q2M** 13 DVCC

XI 29 12 VCCA\
AGND\_R 30 11 AGND\_L

1 2 3 4 5 6 7 8 9 10

Exposed Pad DGND

**ES9038Q2M PIN DESCRIPTIONS** 



|**Pin** |**Name** |**Pin Type** |**Reset State** |**Pin Description** |
| - | - | - | - | - |
|1 |AVCC\_R |Power |Power |DAC analog output stage reference supply for the Right Channel |
|2 |DACRB |AO |Ground |Differential Negative Output for the Right Channel |
|3 |DACR |AO |Ground |Differential Positive Output for the Right Channel |
|4 |BIAS |O |1’b0 |General Output.  Controlled by software. See[ Register 45: Low Power and Auto Calibration ](#_page38_x26.00_y92.00)for more information. |
|5 |SW |I/O |GPIO2 / Tri-stated |<p>General Output </p><p>￿  Can be used with switch input of SABRE9602. See[ Register 39: ](#_page36_x26.00_y92.00)</p><p>[General Configuration 2 ](#_page36_x26.00_y92.00)for more information. In reset state, a 120k ohm resistor connects between SW and GPIO2.   </p>|
|6 |FSYNC |O |Tri-stated |<p>General Output with output clock options. </p><p>￿  Can be used with FSYNC of SABRE9602 to set its charge pump </p><p>frequency. Se[e Register 30-31: Charge Pump Clock ](#_page33_x26.00_y92.00)for more information </p>|
|7 |HPSDb |O |1’b0 |<p>General Output. Can be used for Headphone Shutdown of SABRE9602 </p><p>Grounded through 100k ohm resistor in reset state. </p>|
|8 |DACL |AO |Ground |Differential Positive Output for the Left Channel |
|9 |DACLB |AO |Ground |Differential Negative Output for the Left Channel |
|10 |AVCC\_L |Power |Power |DAC analog output stage reference supply for the Left Channel |
|11 |AGND\_L |Ground |Ground |DAC analog output stage ground for the Left Channel |
|12 |VCCA |Power |Power |Analog +3.3V for OSC |
|13 |DVCC |Power |Power |Digital +1.8V to +3.3V |
|14 |DGND |Ground |Ground |Digital Ground |
|15 |DVDD |Power |Power |Digital Core Voltage, nominally +1.2V, supplied by an internal regulator from DVCC. |
|16 |GPIO2 |I/O |Tri-stated / SW |<p>General purpose input/output pin 2, or SPDIF Input 5 </p><p>￿  In reset state, a 120k ohm resistor connects between SW and </p><p>GPIO2 allowing GPIO2 to switch input of SABRE9602. See [Register 39: General Configuration 2 ](#_page36_x26.00_y92.00)for more information.  </p>|
|17 |GPIO1 |I/O |Tri-stated |General purpose input/output pin 1, or SPDIF Input 4. |
|18 |DATA2 |[I ](file:///C:/Documents%20and%20Settings/cawong/Desktop/Low%20Power%20DACs/Sabre%202%20Mobile%20PinOut%20130319.xls%23RANGE!A474%23RANGE!A474)|Tri-stated |DSD Data2 (R) or PCM Data CH1/CH2 or SPDIF Input 2 |
|19 |DATA1 |I/O |Tri-stated |<p>Master mode off or non-PCM mode </p><p>- Input for DSD Data1 (L) or PCM Frame Clock or SPDIF Input 3 Master mode on and PCM mode </p><p>- Output for PCM Frame Clock </p>|
|20 |DATA\_CLK |I/O |Tri-stated |<p>Master mode off </p><p>- Input for PCM Bit Clock or DSD Bit Clock or SPDIF Input 1 Master mode on </p><p>- Output for PCM or DSD Bit Clock </p>|
|21 |RESETB |I |Ground |Master Reset / Power Down (active low) |
|22 |RT1 |- |Tri-stated |Reserved, must be connected to DGND. |
|23 |SCL |I |Tri-stated |I2C Clock Input|
|24 |SDA |I/O |Tri-stated |I2C Serial Data Input/Output|
|25 |ADDR |I |Tri-stated |I2C Address Select|



|**Pin** |**Name** |**Pin Type** |**Reset State** |**Pin Description** |
| - | - | - | - | - |
|26 |NC |- |- |No Internal Connection. |
|27 |VCCA |Power |Power |Analog +3.3V for OSC |
|28 |XOUT |AO |Floating |XTAL Output |
|29 |XI |AI |Floating |XTAL Input |
|30 |AGND\_R |Ground |Ground |DAC analog output stage ground for the Right Channel |
|Exposed Pad |DGND |Ground |Ground |The exposed pad must be connected to DGND. |

Note: 

I/O = Input/Output AO = Analog Output AI = Analog Input 

I = Digital Input 

**5V Tolerant Pins (3.3V DVCC Supply Only)** 

The following pins are 5V tolerant when DVCC = 3.3V only: 

- RESETB  
- SDA 
- SCL 
- GPIO1,2 
- ADDR  
- DATA1-2 
- DATA\_CLK 
- RT1 

**System Clock and Audio Inputs**  

**Sampling Rate Notations** 

|**Mode** |<p>**FSR**  </p><p>**raw sample rate at audio interface** </p>|<p>**fs**  </p><p>**sample rate for filter specification** </p>|
| - | - | - |
|DSD |DATA\_CLK |FSR / 64 |
|DoP |Frame Clock Rate |FSR / 4 |
|Serial (PCM) Normal Mode |Frame Clock Rate |FSR |
|Serial (PCM) OSF Bypass Mode |Frame Clock Rate |FSR / 8 |
|SPDIF |SPDIF Audio Rate |FSR |

**System Clock (XI) and Audio Master Clock (MCLK)** 

The system clock (XI) can be generated with a crystal using the built-in oscillator or supplied externally. 

- The maximum XI frequency is 100MHz as specified in[ ANALOG PERFORMANCE ](#_page50_x26.00_y697.00)and[ XI Timing.](#_page49_x26.00_y711.00) 
- The audio master clock (MCLK) is divided down from XI via *clk\_gear* in[ Register 0: System Registers.](#_page14_x26.00_y114.00) 
- The minimum MCLK frequency for a given raw sample rate FSR is specified in[ ANALOG PERFORMANCE.](#_page50_x26.00_y697.00) 
- The minimum MCLK frequency for a given I2C clock is specified in the table under[ I2C Timing Table.](#_page13_x26.00_y268.00) 

**PCM Pin Connections** 

|**Pin Name** |**Description** |
| - | - |
|DATA1 |Frame clock |
|DATA2 |2-channel PCM serial data |
|DATA\_CLK |Bit clock for PCM audio format  |

Note: DATA\_CLK frequency must be (2 x *serial\_length*) x FSR. *serial\_length* can be set in[ Register 1: Input selection.](#_page15_x26.00_y92.00) 

**SPDIF Pin Connections** 

|**Pin Name** |**Description** |
| - | - |
|GPIO2~1 |SPDIF input 5~4 |
|DATA2~1 |SPDIF input 3~2 |
|DATA\_CLK |SPDIF input 1 |

An SPDIF source multiplexer allows for up to 5 SPDIF sources to be connected to the data and GPIO pins selectable via [Register 11:  SPDIF Select ](#_page24_x26.00_y92.00). SPDIF input mode can be manually selected by *input\_select* in[ Register 1: Input selection ](#_page15_x26.00_y92.00)or automatically selected if *auto\_select* i[n Register 1: Input selection ](#_page15_x26.00_y92.00)is set to a mode allowing automatic SPDIF selection. 

**DSD Pin Connections** 

|**Pin Name** |**Description** |
| - | - |
|DATA2~1 |2-channel DSD data input |
|DATA\_CLK |Bit clock for DSD data input |

Note: DATA\_CLK frequency must be FSR. 

**Master Mode** 

The DAC can become an audio timing master via *master\_mode* in[ Register 10: Master Mode and Sync Configuration.](#_page23_x26.00_y92.00) 

- The ‘input\_select’ bits in[ Register 1: Input selection ](#_page15_x26.00_y92.00)must be set to explicitly select DSD or serial master mode.  Autoselect will not produce the desired results in master mode. 

The Bit Clock frequency can be configured using one of the following two methods: 

- Set the desired *master\_div* in[ Register 10: Master Mode and Sync Configuration, ](#_page23_x26.00_y92.00)or 
- Use NCO mode to set FSR using[ Register 34-37: Programmable NCO.](#_page35_x26.00_y92.00) When in NCO mode the *master\_div* setting will be ignored. 

An available GPIO pin can be configured to output MCLK using[ Register 8: GPIO1-2 Configuration.](#_page21_x26.00_y92.00) 

**7****  ESS TECHNOLOGY, INC.  237 South Hillview Drive, Milpitas, CA 95035, USA  Tel (408) 643-8800 • Fax (408) 643-8801 !
**July 17, 2019  CONFIDENTIAL Rev. 1.3 !**

**ES9038Q2M Datasheet !!!**

SLAVE PCM MODE

BCLK (Bit Clock) DATA\_CLK LRCLK (Frame Clock) DATA1

SIN (Serial PCM Data) DATA2

SLAVE DSD MODE

DSD DATA\_CLK DATA\_CLK

DSD DATA1 (L) DATA1 DSD DATA2 (R) DATA2

MASTER PCM MODE

BCLK (Bit Clock) DATA\_CLK LRCLK (Frame Clock) DATA1

SIN (Serial PCM Data) DATA2

MCLK (Master Clock) GPIO1/2

MASTER DSD MODE

DSD DATA\_CLK DATA\_CLK DSD DATA1 (L) DATA1 DSD DATA2 (R) DATA2

MCLK (Master Clock) GPIO1/2

**  ESS TECHNOLOGY, INC.  237 South Hillview Drive, Milpitas, CA 95035, USA  Tel (408) 643-8800 • Fax (408) 643-8801 !
**July 17, 2019  CONFIDENTIAL Rev. 1.3 !**

**ES9038Q2M Datasheet !!!**

**Function Description** 

**Soft Mute (not applicable in OSF Bypass mode)** 

When Mute is asserted the output signal will ramp to the -¥ level.  When Mute is reset the attenuation level will ramp back up to the previous level set by the volume control register.  Asserting Mute will not change the value of the volume control register.  The ramp rate is set by[ Register 6: De-emphasis, DoP and Volume Ramp Rate ](#_page19_x26.00_y92.00)according to the following relationship:  

2vol\_rate ∗ FSR

rate = dB/s 512

**Automute (PCM and SPDIF modes only, not supported in DSD mode)** 

Automute is disabled by default and can be enabled by setting *automute\_time* to a non-zero value. Automute is triggered when the following conditions are met: 



|**Mode** |**Detection Condition** |**Time** |
| - | - | - |
|PCM SPDIF |Data is lower than *automute\_level* for the specified time* |<p>2096896 automute\_time ∗ FSR</p><p>` `(s)</p>|

*Automute\_time* can be set using[ Register 4: Automute Time.](#_page18_x26.00_y92.00)   *Automute\_level* can be set using[ Register 5: Automute Level.](#_page18_x26.00_y275.00) 

The automute status can be read using automute\_status in[ Register 64 (Read-Only): Chip ID and Status ](#_page41_x26.00_y92.00)or via a GPIO pin programmed as Automute Status using[ Register 8: GPIO1-2 Configuration***.***](#_page21_x26.00_y92.00) 

The triggered automute behavior can be configured using[ Register 2: Mixing, Serial Data and Automute Configuration ](#_page16_x26.00_y92.00)to one of the followings: 

- No action 
- Soft Mute 
- Ramp all channels to ground to reduce power consumption 
- Soft Mute then ramp all channels to ground 

The ramp-to-ground rate can be configured to*** 4096 ∗ 2(soft\_start\_time+1)*** using[ Register 14: Soft Start Configuration.](#_page27_x26.00_y92.00) 

MCLK

**Volume Control (not applicable in OSF Bypass mode)** 

Each channel has an independently controlled digital attenuation circuit which can be set to attenuate from 0dB to –127dB in 0.5dB steps.  When a new volume level is set, the digital attenuation circuit will ramp softly to the new level.  To ensure silent digital volume transitions each 0.5dB step can take as many as 64 intermediate steps depending on the *volume\_rate* setting in[ Register 6: De-emphasis, DoP and Volume Ramp Rate.](#_page19_x26.00_y92.00)  

**Master Trim (not applicable in OSF Bypass mode)** 

The master trim sets the 0dB reference level for the digital volume control of each DAC.  The master trim is programmable via[ Register 17-20: Master Trim.](#_page28_x26.00_y241.00)  The master trim registers store a 32bit signed number and** should never exceed the full scale signed value 32’h7FFFFFFF. 

**18dB Channel Gain** 

A +18dB gain can be applied on a per-channel based using[ Register 27: General Configuration, ](#_page31_x26.00_y92.00)in addition to volume control and master trim. Note that the output will be clipped if the +18dB gain results in larger than full scale output. 

**De-emphasis** 

The de-emphasis feature is included for audio data that has utilized the 50/15ms pre-emphasis for noise reduction.  There are three de-emphasis filters, one for 32kHz, one for 44.1kHz, and one for 48kHz selectable via *deemph\_sel* and bypassed via *deemph\_bypass* in[ Register 6: De-emphasis, DoP and Volume Ramp Rate.](#_page19_x26.00_y92.00) 

The de-emphasis filter can automatically be applied when an SPDIF stream sets the de-emphasis flag.  It will auto detect the sample rate (32k, 44.1k, 48k) in either consumer or professional formats and then apply the correct de-emphasis filter.  The automatic enabling of the de-emphasis filter can be enabled via *auto\_deemph*** in[ Register 6: De-emphasis, DoP and Volume Ramp Rate.](#_page19_x26.00_y92.00) 

**Preset Oversampling FIR Filters** 

Seven pre-programmed digital filters are selectable for SPDIF and PCM serial mode via** *filter\_shape* in[ Register 7: Filter Bandwidth and System Mute.](#_page20_x26.00_y92.00) See[ ANALOG PERFORMANCE,](#_page50_x26.00_y697.00)[ PCM FILTER FREQUENCY RESPONSE ](#_page53_x26.00_y722.00)and[ PCM FILTER IMPULSE RESPONSE ](#_page55_x26.00_y563.00)for more information.  

**Custom Oversampling FIR Filter** 

The FIR filter can also be programmed as a two-staged interpolation filter with custom coefficients to achieve unique sound signature.  Custom coefficients can be generated using MATLAB and then downloaded using a custom C code. 

*Example Source Code for Loading a Filter* 

// only accept 128 or 16 coefficients 

// Note:  The coefficients must be quantized to 24 bits for this method! 

// Note:  Stage 1 consists of 128 values (0-127 being the coefficients) 

// Note:  Stage 2 consists of 16 values (0-13 being the coefficients, 14-15 are zeros) 

// Note:  Stage 2 is symmetric about coefficient 13.  See the example filters for more information. byte fir\_badr = 40; 

byte coeff\_stage = (byte)(coeffs.Count == 128 ? 0 : 1); 

for (int i = 0; i < coeffs.Count; i++) 

{ 

`    `// stage 1 contains 128 coefficients, while stage 2 contains 16 coefficients 

`    `registers.WriteRegister(fir\_badr, (byte)((coeff\_stage << 7) + i)); 

// write the coefficient data 

registers.WriteRegister(fir\_badr+1, (byte)(coeffs[i] & 0xff)); registers.WriteRegister(fir\_badr+2, (byte)((coeffs[i] >> 8) & 0xff)); registers.WriteRegister(fir\_badr+3, (byte)((coeffs[i] >> 16) & 0xff)); 

`    `registers.WriteRegister(fir\_badr+4, 0x02);   // set the write enable bit } 

// disable the write enable bit when we’re done registers.WriteRegister(fir\_badr+5, (byte)(setEvenBit ? 0x04 : 0x00)); 

**Oversampling Filter (OSF) Bypass** 

The oversampling FIR filter can be bypassed using *bypass\_osf* in[ Register 7: Filter Bandwidth and System Mute,](#_page20_x26.00_y92.00) sourcing data directly into the IIR filter.  The audio input should be oversampled at 8 x fs rate when OSF is bypassed to have the same IIR filter bandwidth as PCM audio sampled at fs rate.  For example, a signal with 44.1kHz sample rate can be oversampled externally to 8 x 44.1kHz = 352.8kHz and then applied to the serial decoder in either I2S or LJ format.  The maximum sample rate that can be applied is 1.536MHz (8 x 192kHz). 

**DSD Filter** 

A DSD filter with cutoff at 47kHz scaled by fs/44100 is available. See[ DSD FILTER RESPONSE ](#_page57_x26.00_y570.00)for more information. 

**Channel Mapping and Mixing** 

Channel mapping, mixing and mono mode can be configured using[ Register 2: Mixing, Serial Data and Automute Configuration.](#_page16_x26.00_y92.00) 

**Time Domain Jitter Eliminator and DPLL** 

By default, the DAC works in Jitter Eliminator mode allowing the audio interface timing to be asynchronous to MCLK. A DPLL constantly updates the FSR/MCLK ratio to calculate the true 32-bit timing of the incoming audio samples allowing the ESS patented Time Domain Jitter Eliminator to remove any distortion caused by jitter. 

- The DPLL acquisition speed can be set by *lock\_speed* in[ Register 10: Master Mode and Sync Configuration.](#_page23_x26.00_y92.00) 
- The PCM/SPDIF DPLL bandwidth can be set via dpll\_bw\_serial in[ Register 12: ASRC/DPLL Bandwidth.](#_page25_x26.00_y92.00) 
- The DSD DPLL bandwidth can be set via *dpll\_bw\_dsd* in[ Register 12: ASRC/DPLL Bandwidth.](#_page25_x26.00_y92.00) 

For best performance, the DPLL bandwidth should be set to the minimum setting that will keep the DPLL reliably in lock. 

**Sample Rate Calculation** 

The raw sample rate (FSR) can be calculated from[ Register 66-69 (Read-Only): DPLL Number ](#_page42_x26.00_y218.00)using the following formula: 

(dpll\_num ∗ MCLK)

FSR = 3

2 2

**Synchronous Mode (PCM mode only)** 

The DPLL can be bypassed if the incoming PCM audio is synchronous to MCLK with the relationship MCLK=128FSR. This can be enabled via *128fs\_mode* in[ Register 10: Master Mode and Sync Configuration.](#_page23_x26.00_y92.00) 

**DAC Full-Scale Gain Calibration** 

DAC gain calibration enables uniform output level across multiple chips by compensating for chip-to-chip gain variations. It cannot be used to compensate for gain variation caused by mismatch of external components 

The DAC full-scale gain-calibration system works by comparing an internal resistor to an external precision resistor of known value.  The two resistors are set up as a voltage divider that is connected between power and ground.  The value of the internal resistor changes with semiconductor process variations so by measuring the divider’s voltage output, using an ADC, the process variation from nominal can be measured and this is used to correct the DAC gain.  As all the DAC channels are on the same monolithic chip, the channel-to-channel gain variation is very small and does not need to be trimmed. 

The ADC input can be used to drive the auto-calibration circuit.  The circuit uses the ADC value, as decimated by the internal programmable decimation filters, to scale the master\_trim value.  Master\_trim can be programmed as normal but will be scaled by the ADC value when in automatic-calibration mode.  In this mode, master\_trim can be set once by enabling automatic calibration, and the DAC output levels will be consistent across all DAC devices. 

- Full-scale gain-calibration is enabled using *calib\_en* in[ Register 45: Low Power and Auto Calibration.](#_page38_x26.00_y92.00)  
- *calib\_sel*  in[ Register 45: Low Power and Auto Calibration ](#_page38_x26.00_y92.00)selects which ADC to use 
- *calib\_latch* in[ Register 45: Low Power and Auto Calibration ](#_page38_x26.00_y92.00)determines whether to use the new ADC correction value or ignore it. 
- ADC values update at the *ADC\_CLK* rate which is also programmable in[ Register 46: ADC Configuration.](#_page39_x26.00_y92.00)   

The ADC decimation filters may also be programmed to a lower bandwidth to help smooth out any voltage transients on the divider output.   

**THD Compensation** 

THD Compensation can be used to minimize distortion from external PCB components and layout through the generation of inverse second and third harmonic components matching the target system distortion profile. 

THD compensation can be enabled via *thd\_enb* in[ Register 13: THD Bypass.](#_page26_x26.00_y92.00) 

The coefficient for manipulating second harmonic distortion is stored in[ Register 22-23: THD Compensation C2.](#_page30_x26.00_y92.00) The coefficient for manipulating third harmonic distortion is stored in[ Register 24-25: THD Compensation C3.](#_page30_x26.00_y206.00) 

*All channels use the same compensation coefficients.* 

**Standby Mode** 

For lowest power consumption, the following should be performed to enter the stand-by mode: 

- RESETB pin should be brought to low digital level to: 
  - Shut off the DACs, Oscillator and internal regulator. 
  - Force digital I/O pins (DATA\_CLK, DATA1, GPIO1, GPIO2, SDA ) into tri-state mode 
- If XI is supplied externally, it should be stopped at a logic low level 

To resume from standby mode bring RESETB to high digital level, resume XI if supplied externally, and reinitialize all registers. 

**DVDD Supply** 

The ES9038Q2M is equipped with a regulated DVDD supply powered from DVCC.  The internal DVDD regulator must be decoupled to DGND with a capacitor that maintains a minimum value of 1mF at 1.2V over the target operating temperature range.  The recommended capacitor for decoupling DVDD is a 4.7mF ±20%, X5R 6.3V 0402. 

**Headphone Amp Control (when used with SABRE9602)** 

When used with the SABRE9602 headphone amp, the following pins can be used to provide dedicated control. 

|**ES9038 pin** |**Connect to SABRE9602 pin** |**ES9038 Reset State** |**ES9038 Normal Operation** |
| :-: | :- | - | - |
|HPSDb |AMP\_PDB |HPSDb is pulled down via internal 100kΩ resistor on HPSDb |HPSDb is controlled via *amp\_pdb* and *amp\_pdb\_ss* in[ Register 39: General Configuration 2 ](#_page36_x26.00_y92.00)|
|SW |SW\_CTRL |<p>SW is controlled by GPIO2 via internal 120kΩ resistor to select AUX (GPIO2=1) or standby (GPIO2=0) mode </p><p></p>|SW is controlled via *sw\_ctrl\_en[1]* once *sw\_ctrl\_en[0]*  is programmed to be 1’b1 in[ Register 39: General Configuration 2.](#_page36_x26.00_y92.00)  |
|FSYNC |FSYNC |Tri-stated |Sets charge pump frequency via[ Register 30-31: Charge Pump Clock ](#_page33_x26.00_y92.00)|
|BIAS |- |1’b0 |General purpose output controlled via *bias\_ctrl* in [Register 45: Low Power and Auto Calibration ](#_page38_x26.00_y92.00)|

**Audio Interface Formats** 

Several digital audio transport formats are supported to allow direct connection to common audio processors.  Auto detection circuitry is enabled by default to detect the input format.  The input mode can be explicitly set using[ Register 1: Input selection.](#_page15_x26.00_y92.00)  The following diagrams outline the supported formats (using stereo 2-channel inputs as an example). 

**PCM LJ and I2S Formats** 

LRCLK LEFT RIGHT BCLK

SIN

32-bit 31 30 29 2 1 0 31 30 29 2 1 0 31 30

MSB LSB MSB LSB MSB

SIN

24-bit 23 22 21 2 1 0 23 22 21 2 1 0 23 22

MSB LSB MSB LSB MSB

SIN

16-bit 15 14 13 2 1 0 15 14 13 2 1 0 15 14

MSB LSB MSB LSB MSB

**LEFT JUSTIFIED FORMAT**

LRCLK LEFT RIGHT BCLK

SIN

32-bit 31 30 29 2 1 0 31 30 29 2 1 0 31 30

MSB LSB MSB LSB MSB

SIN

24-bit 23 22 21 2 1 0 23 22 21 2 1 0 23 22

MSB LSB MSB LSB MSB

SIN

16-bit 15 14 13 2 1 0 15 14 13 2 1 0 15 14

MSB LSB MSB LSB MSB

**I2S FORMAT**

**Note:** for Left-Justified and I2S formats, the following number of BCLKs is present per (left plus right) frame: 

- 16-bit mode: 32 BCLKs 
- 24-bit mode: 48 BCLKs 
- 32-bit mode: 64 BCLKs 

**DoP (DSD over PCM) Audio Format** 

The DoP format packs DSD data into PCM frames.  The incoming data is identified as DoP if the DSD Markers 0x05 and 0xFA alternating each frame clock cycle are present as illustrated below. 

Left Channel Right Channel

 

0  31 30 2   1   0  31  30 2   1   0  31  30

BCK ................ ................

WS

DATA 8-bit DSD Marker 16 Bits of DSD Audio 8 Bits of 0 Padding 8-bit DSD Marker 16 Bits of DSD Audio 8 Bits of 0 Padding



|Frame Cycle |1 Left |1 Right |2 Left |2 Right |3 Left |3 Right |
| - | - | - | - | - | - | - |
|DSD Marker |0x05 |0x05 |0xFA |0xFA |0x05 |0x05 |

Note: DoP requires 24-bit or 32-bit PCM mode and is not supported in 16-bit PCM mode. 

- 24-bit mode: DoP data consists of 8-bit marker in the MSB followed by 16-bit DSD data 
- 32-bit mode: DoP data consists of 8-bit marker in the MSB followed by 16-bit DSD data and 8-bit padding 

<a name="_page12_x26.00_y412.00"></a>**Native DSD Format** 

DCLK 

DSD1 DSD2

|D..|D0|D1|D2|D3|D4|
| - | - | - | - | - | - |

**DSD NORMAL MODE**

DCLK 

DSD1 

DSD2 D.. D.. D0 D0 D1 D1 D2 D2 D3 D3 D4 D4

**DSD PHASE MODE**

**Serial Control Interface** 

The registers inside the chip are programmed via an I2C interface.  The diagram below shows the timing for this interface.  The chip address can be set to 2 different settings via the ADDR pin. 



|**ADDR** |**CHIP ADDRESS** |
| - | - |
|0 |0x90 |
|1 |0x92 |

**Note:** 

- Multi-byte reads are not supported and may cause the I2C decoder to become unresponsive until a reset occurs. 

<a name="_page13_x26.00_y268.00"></a>**I2C Timing Table** 

Start Start Stop Start



|**Parameter** |**Symbol** |**MCLK Constraint** |**Standard-Mode** |**Fast-Mode** |**Unit** |||
| - | - | :- | - | - | - | :- | :- |
||||**MIN** |**MAX** |**MIN** |**MAX** ||
|SCL Clock Frequency |<p>f</p><p>SCL</p>|< MCLK/20 |0 |100 |0 |400 |kHz |
|START condition hold time |<p>t</p><p>HD,STA</p>||4\.0 |- |0\.6 |- |ms |
|LOW period of SCL  |<p>t</p><p>LOW</p>|>10/MCLK |4\.7 |- |1\.3 |- |ms |
|HIGH period of SCL (>10/MCLK) |<p>t</p><p>HIGH</p>|>10/MCLK |4\.0 |- |0\.6 |- |ms |
|START condition setup time (repeat) |<p>t</p><p>SU,STA</p>||4\.7 |- |0\.6 |- |ms |
|<p>SDA hold time from SCL falling </p><p>- All except NACK read </p><p>- NACK read only </p>|tHD,DAT||0 2/MCLK |- |0 2/MCLK |- |ms s |
|SDA setup time from SCL rising |<p>t</p><p>SU,DAT</p>||250 |- |100 |- |ns |
|Rise time of SDA and SCL |tr ||- |1000 ||300 |ns |
|Fall time of SDA and SCL |tf ||- |300 ||300 |ns |
|STOP condition setup time |<p>t</p><p>SU,STO</p>||4 |- |0\.6 |- |ms |
|Bus free time between transmissions |<p>t</p><p>BUF</p>||4\.7 |- |1\.3 |- |ms |
|Capacitive load for each bus line |Cb ||- |400 |- |400 |pF |

**REGISTER SETTINGS** 

<a name="_page14_x26.00_y114.00"></a>**Register 0: System Registers** 



|Bits |[7:4] |[3:2] |[1] |[0] |
| - | - | - | - | - |
|Mnemonic |osc\_drv |clk\_gear |reserved |soft\_reset |
|Default |4’b0000 |2’b00 |1’b0 |1’b0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:4] |osc\_drv |<p>Oscillator drive specifies the bias current to the oscillator pad. </p><p>- 4’b0000: full bias (default) </p><p>- 4’b1000: ¾ bias </p><p>- 4’b1100: ½ bias </p><p>- 4’b1110: ¼ bias </p><p>- 4’b1111: shut down the oscillator </p>|
|[3:2] |clk\_gear |<p>Configures a clock divider network that can reduce the power consumption of the chip by reducing the clock frequency supplied to both the digital core and analog stages. </p><p>- 2’b00: MCLK = XI (default) </p><p>- 2’b01: MCLK = XI / 2 </p><p>- 2’b10: MCLK = XI / 4 </p><p>- 2’b11: MCLK = XI / 8 </p>|
|[1] |reserved ||
|[0] |soft\_reset |<p>Software configurable hardware reset with the ability to reset the design to its initial power-on configuration. </p><p>- 1’b0: normal operation (default) </p><p>- 1’b1: resets the Sabre to its power-on defaults </p><p>Note:  This register will always read as “1’b0” as the power-on default for this register is “1’b0”.  A reset can be verified by checking the status of </p><p>other modified registers. </p>|

<a name="_page15_x26.00_y92.00"></a>**Register 1: Input selection** 



|Bits |[7:6] |[5:4] |[3:2] |[1:0] |
| - | - | - | - | - |
|Mnemonic |serial\_length |serial\_mode |auto\_select |input\_select |
|Default |2’b11 |2’b00 |2’b11 |2’b00 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:6] |serial\_length |<p>Selects how many DATA\_CLK pulses exist per data word. </p><p>- 2’b00: 16-bit data words </p><p>- 2’b01: 24-bit data words </p><p>- 2’b10: 32-bit data words </p><p>- 2’b11: 32-bit data words (default) </p>|
|[5:4] |serial\_mode |<p>Configures the type of serial data. </p><p>- 2’b00:  I2S mode (default) </p><p>- 2’b01:  left-justified mode </p><p>- 2’b11 or 2’b10:  right-justified mode </p>|
|[3:2] |auto\_select |<p>Allows the Sabre to automatically select between either serial (I2S) or DSD input formats. </p><p>- 2’b00: disable automatic input decoder and instead use the information provided by register 1[1:0] </p><p>- 2’b01: automatically select between DSD or serial data </p><p>- 2’b10: automatically select between SPDIF or serial data </p><p>- 2’b11: automatically select between DSD, SPDIF or serial data (default) </p>|
|[1:0] |input\_select |<p>Configures the Sabre to use a particular input decoder if auto\_select is disabled. </p><p>- 2’b00: serial (default) </p><p>- 2'b01: SPDIF </p><p>- 2'b10: reserved </p><p>- 2’b11: DSD </p><p>Note:  Register 1[3:2] must be set to 2’b00 for input\_select to function. </p>|

<a name="_page16_x26.00_y92.00"></a>**Register 2: Mixing, Serial Data and Automute Configuration** 



|Bits |[7:6] |[5:4] |[3:2] |[1:0] |
| - | - | - | - | - |
|Mnemonic |automute\_config |reserved |ch2\_mix\_sel |ch1\_mix\_sel |
|Default |2’b00 |2’b11 |2’b01 |2’b00 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:6] |automute config |<p>Configures the automute state machine, which allows the Sabre 2M to perform different power saving and sound optimizations. </p><p>- 2’b00: normal operation (default) </p><p>￿ </p><p>2’b01: perform a mute when an automute condition is asserted 2’b10: ramp all channels to ground when an automute condition </p><p>￿ </p><p>is asserted </p><p>- 2’b11: perform a mute and then ramp all channels to ground when an automute condition is asserted </p><p>Note:  Ramping DAC outputs to ground can reduce the power consumption of the Sabre 2M in some situations. </p><p>Note:  This process can be sped up by using the automute\_time, volume\_rate and soft\_start\_time registers.  </p>|
|[5:4] |reserved ||
|[3:2] |ch2\_mix\_sel |<p>Selects which data is mapped to DAC 2. </p><p>- 2’b00: ch1 </p><p>- 2’b01: ch2 (default) </p><p>- 2’b10: reserved </p><p>- 2’b11: reserved </p>|
|[1:0] |ch1\_mix\_sel |<p>Selects which data is mapped to DAC 1. </p><p>- 2’b00: ch1 (default) </p><p>- 2’b01: ch2 </p><p>- 2’b10: reserved </p><p>- 2’b11: reserved </p>|

**Register 3: SPDIF Configuration** 



|Bits |[7:4] |[3] |[2] |[1] |[0] |
| - | - | - | - | - | - |
|Mnemonic |reserved |spdif\_user\_bits |spdif\_ig\_data |spdif\_ig\_valid |reserved |
|Default |4’d4 |1’b0 |1’b0 |1’b0 |1’b0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:4] |reserved ||
|[3] |spdif\_user\_bits |<p>Both SPDIF channel status bits and SPDIF user bits are available for readback via the I2C interface.  To reduce register count the channel status bits and user bits occupy the same register space.  Setting user\_bits will present the SPDIF user bits on the read-only register interface instead of the default channel status bits. </p><p>- 1’b1: presents the SPDIF user bits on the read-only register interface </p><p>- 1’b0: presents the SPDIF channel status bits on the read-only register interface (default) </p>|
|[2] |spdif\_ig\_data |<p>Configures the SPDIF decoder to ignore the ‘data’ flag in the channel status bits. </p><p>- 1’b1: ignore the data flag in the channel status bits and continue to process the decoded SPDIF data </p><p>- 1’b0: mute the SPDIF data when the data flag is set (default) </p><p>Note:  Enabling the SPDIF output when data is present could cause undesirable noise if the SPDIF data is compressed audio or a non- standard format. </p>|
|[1] |spdif\_ig\_valid |<p>Configures the SPDIF decoder to ignore the ‘valid’ flag in the SPDIF stream. </p><p>- 1’b1: ignore the valid flag and continue to process the decoded SPDIF data </p><p>- 1’b0: mute the SPDIF data when the valid flag is invalid (default) </p>|
|[0] |reserved ||
<a name="_page18_x26.00_y92.00"></a>**Register 4: Automute Time** 



|Bits |[7:0] |
| - | - |
|Mnemonic |automute\_time |
|Default |8’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7] |automute time |<p>Configures the amount of time the audio data must remain below the automute\_level before an automute condition is flagged.  Defaults to 0 which disables automute. </p><p>2096896</p><p>Time in seconds  =</p><p>automute\_time ∗ FSR</p>|

<a name="_page18_x26.00_y275.00"></a>**Register 5: Automute Level** 



|Bits |[7] |[6:0] |
| - | - | - |
|Mnemonic |reserved |automute\_level |
|Default |1’b0 |7’d104 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7] |reserved |Not connected in digital core. |
|[6:0] |automute level |<p>Configures the threshold which the audio must be below before an automute condition is flagged.  The level is measured in decibels (dB) and defaults to -104dB. </p><p>Note:  This register works in tandem with automute\_time to create the automute condition. </p>|

<a name="_page19_x26.00_y92.00"></a>**Register 6: De-emphasis, DoP and Volume Ramp Rate** 



|Bits |[7] |[6] |[5:4] |[3] |[2:0] |
| - | - | - | - | - | - |
|Mnemonic |auto\_deemph |deemph\_bypass |deemph\_sel |dop\_enable |volume\_rate |
|Default |1’b0 |1’b1 |2’b00 |1’b0 |2’b010 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7] |auto\_deemph |<p>Automatically engages the de-emphasis filters when SPDIF data is provides and the SPDIF channel status bits contains valid de-emphasis settings. </p><p>- 1’b1: enables automatic de-emphasis </p><p>- 1’b0: disables automatic de-emphasis (default)</p>|
|[6] |deemph\_bypass |<p>Enables or disables the built-in de-emphasis filters. </p><p>- 1'b1 disabled de-emphasis filters (default) </p><p>- 1'b0 enables de-emphasis filters </p>|
|[5:4] |deemph\_sel |<p>Selects which de-emphasis filter is used. </p><p>- 2’b11: reserved </p><p>- 2’b10: 48kHz </p><p>- 2’b01: 44.1kHz </p><p>- 2’b00: 32kHz (default)</p>|
|[3] |dop\_enable |<p>Selects whether the DSD over PCM (DoP) logic is enabled. </p><p>- 1’b0: disables the DoP logic </p><p>- 1’b1: enables the DoP logic </p>|
|[2:0] |volume\_rate |<p>Selects a volume ramp rate to use when transitioning between different volume levels.  The volume ramp rate is measured in decibels per second (dB/s). </p><p>2vol\_rate ∗ FSR</p><p>rate = dB/s </p><p>512</p>|

<a name="_page20_x26.00_y92.00"></a>**Register 7: Filter Bandwidth and System Mute** 



|Bits |[7:5] |[4] |[3] |[2:1] |[0] |
| - | - | - | - | - | - |
|Mnemonic |filter\_shape |reserved |bypass\_osf |reserved |mute |
|Default |3’b100 |1’b0 |1’b0 |2’b00 |1’b0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:5] |filter\_shape |<p>Selects the type of filter to use during the 8x FIR interpolation phase. </p><p>- 3’b111: brick wall filter </p><p>- 3’b110: corrected minimum phase fast roll-off filter </p><p>- 3’b101: reserved </p><p>- 3’b100: apodizing fast roll-off filter (default) </p><p>- 3’b011: minimum phase slow roll-off filter </p><p>- 3’b010: minimum phase fast roll-off filter  </p><p>- 3’b001: linear phase slow roll-off filter </p><p>- 3’b000: linear phase fast roll-off filter </p>|
|[4] |reserved ||
|[3] |bypass\_osf |<p>Allows the use of an external 8x upsampling filter, bypassing the internal interpolating FIR filter. </p><p>- 1’b0: uses the built-in oversampling filter (default) </p><p>- 1’b1: uses an external upsampling filter, which requires data oversampled by 8x externally </p>|
|[2:1] |reserved ||
|[0] |mute |<p>Mutes all 2 channels of the Sabre DAC. </p><p>- 1’b0: normal operation (default) </p><p>- 1’b1: mute both channels </p>|

<a name="_page21_x26.00_y92.00"></a>**Register 8: GPIO1-2 Configuration** 



|Bits |[7:4] |[3:0] |
| - | - | - |
|Mnemonic |gpio2\_cfg |gpio1\_cfg |
|Default |4’d13 |4’d13 |

**GPIO Table** 

The GPIO can each be configured in one of several ways. 

The table below is for programming each independent GPIO configuration value. 



|gpioX\_cfg |Name |I/O Direction |Details |
| - | - | :- | - |
|4’d 0 |Automute Status |Output |Output is high when an automute has been triggered.  This signal is analogous to the automute\_status register (register 64). |
|4’d 1 |Lock Status |Output |Output is high when lock is triggered.  This signal is analogous to the lock\_status register (register 64). |
|4’d 2 |Volume Min |Output |Output is high when all digital volume controls have been ramped to minus full scale.  This can occur, for example, if automute is enabled and set to mute the volume. |
|4’d 3 |CLK |Output |Output is a buffered MCLK signal which can be used to synchronize other devices.  |
|4’d 4 |Automute/Lock Interrupt |Output |Output is high when the contents of register 64 have been modified (meaning that the lock\_status or automute\_status register have been changed).  Reading register 64 will clear this interrupt. |
|4’d 5 |Amplifier\_PDB |Output |Output the state of Reg 39[6].  If Reg 39[6] is 1, the GPIO will output high, if Reg 39[6] is 0, the GPIO will output low. |
|4’d 6 |Charge Pump Clock |Output |Outputs a clock on the GPIO that is divided down from the MCLK.  Reg 30:31 will control this output clock frequency |
|4’d 7 |ADC Data |Input |Use this bit to enable the calibration function |
|4’d 8 |Standard Input |Input |Places the GPIO into a high impedance state, allowing the customer to provide a digital signal and then read that signal back via the I2C register 65. |
|4’d 9 |Input Select |Input |Places the GPIO into a high impedance state and allows the customer to toggle the input selection between two modes using the GPIO.  See register 21 for more information. |
|4’d 10 |Mute All |Input |Places the GPIO into a high impedance state and allows the customer to force a mute condition by applying a logic high signal to the GPIO.  When a logic low signal is applied the DAC will exhibit normal operation. |
|4’d 11 |Reserved |||
|4’d 12 |Reserved |||
|4’d 13 |Analog Input |Shutdown |In this mode the GPIO can be tied high to shutdown the ES9038Q2M|
|4’d 14 |Soft Start Complete |Output |Output is high when the DAC output is ramped to ground.  |
|4’d 15 |Output 1’b1 |Output |Output is forced high |

**Register 9: Reserved** 



|Bits |[7:4] |[3:0] |
| - | - | - |
|Mnemonic |reserved |reserved |
|Default |4’d2 |4’d2 |

<a name="_page23_x26.00_y92.00"></a>**Register 10: Master Mode and Sync Configuration** 



|Bits |[7] |[6:5] |[4] |[3:0] |
| - | - | - | - | - |
|Mnemonic |master\_mode |master\_div |128fs\_mode |lock\_speed |
|Default |1’b0 |2’b00 |1’b0 |4’d2 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7] |master\_mode |<p>Enables master mode which causes the Sabre to drive the DATA\_CLK and DATA1 signals when in I2S mode.  Can also be enabled when in DSD mode to enable DATA\_CLK only. </p><p>- 1’b0: disables master mode (default) </p><p>- 1’b1: enables master mode </p>|
|[6:5] |master\_div |<p>Sets the frame clock (DATA1) and DATA\_CLK frequencies when in master mode.  This register is used when in normal synchronous operation. </p><p>- 2’b00: DATA\_CLK frequency = MCLK/2 (default) </p><p>- 2’b01: DATA\_CLK frequency = MCLK/4 </p><p>- 2’b10: DATA\_CLK frequency = MCLK/8 </p><p>- 2’b11: DATA\_CLK frequency = MCLK/16 </p>|
|[4] |128fs\_mode |<p>Enables operation of the DAC while in synchronous mode with a 128\*FSR MCLK in PCM normal or OSF bypass mode only. </p><p>- 1’b1: enables MCLK = 128\*FSR mode </p><p>- 1’b0: disables MCLK = 128\*FSR mode (default) </p>|
|[3:0] |lock\_speed |<p>Sets the number of audio samples required before the DPLL and ASRC lock to the incoming signal.  More audio samples gives a better initial estimate of the MCLK/FSR ratio at the expense of a longer locking interval. </p><p>- 4’d0: 16384 FSL edges  </p><p>- 4’d1: 8192 FSL edges </p><p>- 4’d2: 5461 FSL edges (default) </p><p>- 4’d3: 4096 FSL edges </p><p>- 4’d4: 3276 FSL edges </p><p>- 4’d5: 2730 FSL edges </p><p>- 4’d6: 2340 FSL edges </p><p>- 4’d7: 2048 FSL edges </p><p>- 4’d8: 1820 FSL edges </p><p>- 4’d9: 1638 FSL edges </p><p>- 4’d10: 1489 FSL edges </p><p>- 4’d11: 1365 FSL edges </p><p>- 4’d12: 1260 FSL edges </p><p>- 4’d13: 1170 FSL edges </p><p>- 4’d14: 1092 FSL edges </p><p>- 4’d15: 1024 FSL edges </p><p>Note: FSL=FSR except in DSD Mode FSL=FSR\*64</p>|

<a name="_page24_x26.00_y92.00"></a>**Register 11:  SPDIF Select** 



|Bits |[7:4] |[3:0] |
| - | - | - |
|Mnemonic |spdif\_sel |reserved |
|Default |4’d0 |4’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:4] |spdif\_sel |<p>Selects which input to use when decoding SPDIF data.  Note:  If using a GPIO the GPIO configuration must be set to an input. </p><p>- 4’d0: DATA\_CLK (default) </p><p>- 4’d1: DATA1 </p><p>- 4’d2: DATA2 </p><p>- 4’d3: GPIO1 </p><p>- 4’d4: GPIO2 </p><p>- 4’d5-4’d15: Reserved </p>|
|[3:0] |reserved ||
<a name="_page25_x26.00_y92.00"></a>**Register 12: ASRC/DPLL Bandwidth** 



|Bits |[7:4] |[3:0] |
| - | - | - |
|Mnemonic |dpll\_bw\_serial |dpll\_bw\_dsd |
|Default |4’d5 |4’d10 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:4] |dpll\_bw\_serial |<p>Sets the bandwidth of the DPLL when operating in I2S mode. </p><p>- 4’d0: DPLL Off </p><p>- 4’d1: Lowest Bandwidth </p><p>- 4’d2:   </p><p>- 4’d3:   </p><p>- 4’d4:   </p><p>- 4’d5: (default)  </p><p>- 4’d6:   </p><p>- 4’d7:   </p><p>- 4’d8:  </p><p>- 4’d9:  </p><p>- 4’d10:  </p><p>- 4’d11:  </p><p>- 4’d12:  </p><p>- 4’d13:  </p><p>- 4’d14:  </p><p>- 4’d15: Highest Bandwidth </p>|
|[3:0] |dpll\_bw\_dsd |<p>Sets the bandwidth of the DPLL when operating in DSD mode. </p><p>- 4’d0: DPLL Off </p><p>- 4’d1: Lowest Bandwidth </p><p>- 4’d2:   </p><p>- 4’d3:   </p><p>- 4’d4:   </p><p>- 4’d5:   </p><p>- 4’d6:   </p><p>- 4’d7:   </p><p>- 4’d8:  </p><p>- 4’d9:  </p><p>- 4’d10: (default)  </p><p>- 4’d11:  </p><p>- 4’d12:  </p><p>- 4’d13:  </p><p>- 4’d14:  </p><p>- 4’d15: Highest Bandwidth </p>|

<a name="_page26_x26.00_y92.00"></a>**Register 13: THD Bypass** 



|Bits |[7] |[6] |[5:0] |
| - | - | - | - |
|Mnemonic |reserved |thd\_enb |reserved |
|Default |1’b0 |1’b1 |6’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7] |reserved ||
|[6] |thd\_enb |<p>Selects whether to enable the THD compensation logic.  THD compensation is disabled by default. When enabled, it can be configured to correct for second and third harmonic distortion. </p><p>- 1’b0: enable THD compensation </p><p>- 1’b1: disable THD compensation (default) </p>|
|[5:0] |reserved ||
<a name="_page27_x26.00_y92.00"></a>**Register 14: Soft Start Configuration** 



|Bits |[7] |[6] |[5] |[4:0] |
| - | - | - | - | - |
|Mnemonic |soft\_start |soft\_start\_on\_lock |reserved |soft\_start\_time |
|Default |1’b0 |1’b0 |1’b0 |5’d10 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7] |soft\_start |<p>The Sabre DAC initializes both DAC and DACB to GND and then ramps up the output to AVCC/2.  DAC and DACB remain in phase until the ramp is complete.  Soft\_start controls the ramp operation and defaults to 1’b0.  This bit must be set to 1’b1 in order for the DAC to have analog outputs. </p><p>- 1’b0: Ramps the output stream to ground (default) </p><p>- 1’b1: Normal Operation, will ramp the output to AVCC/2</p>|
|[6] |soft\_start\_on\_l ock |<p>Automatically ramps the output to AVCC/2.  </p><p>- 1’b0: Always soft start (default) </p><p>- 1’b1: Soft start and output ramps to AVCC/2 when locked.  When the DAC is unlocked the outputs will ramp to GND. The output will not ramp to AVCC/2 if Reg 14 [7] is set to 1’b0.  </p>|
|[5] |reserved ||
|[4:0] |soft start time |<p>Sets the amount of time that it takes to perform a soft start ramp.  This time affects both ramp to ground and ramp to AVCC/2.  This value is valid from 0 to 20 (inclusive). </p><p>2(soft\_start\_time+1)</p><p>time (s) = 4096 ∗</p><p>MCLK (Hz)</p>|

**Register 15-16: Volume Control** 



|Bits |[7:0] |
| - | - |
|Register 15 |volume1 |
|Register 16 |volume2 |
|Default |8’d80 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:0] |volume1 |<p>Default of 8’d80 (-40dB) </p><p>-0dB to -127.5dB with 0.5dB steps </p>|
|[7:0] |volume2 |<p>Default of 8’d80 (-40dB) </p><p>-0dB to -127.5dB with 0.5dB steps </p>|

<a name="_page28_x26.00_y241.00"></a>**Register 17-20: Master Trim** 



|Bits |[31:0] |
| - | - |
|Mnemonic |master\_trim |
|Default |32’h7fffffff |



|Bit |Mnemonic |Description |
| - | - | - |
|[31:0] |master\_trim |A 32 bit signed value that sets the 0dB level for all volume controls.  Defaults to full-scale (32’h7FFFFFFF). |

**Register 21: GPIO Input Selection** 



|Bits |[7:6] |[5:4] |[3:0] |
| - | - | - | - |
|Mnemonic |gpio\_sel2 |gpio\_sel1 |reserved |
|Default |2’b00 |2’b00 |4’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:6] |gpio\_sel2 |<p>Selects which input type will be selected when GPIO2 = Input Select </p><p>- 2’d0: serial data (I2S/LJ) (default) </p><p>- 2’d1: SPDIF </p><p>- 2’d2: reserved </p><p>- 2’d3: DSD data </p>|
|[5:4] |gpio\_sel1 |<p>Selects which input type will be selected when GPIO1 = Input Select </p><p>- 2’d0: serial data (I2S/LJ) (default) </p><p>- 2’d1: SPDIF </p><p>- 2’d2: reserved </p><p>- 2’d3: DSD data </p>|
|[3:0] |reserved ||
<a name="_page30_x26.00_y92.00"></a>**Register 22-23: THD Compensation C2** 



|Bits |[15:0] |
| - | - |
|Mnemonic |thd\_comp\_c2 |
|Default |16’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[15:0] |thd\_comp\_c2 |A 16-bit signed coefficient for correcting for the second harmonic distortion.  Defaults to 16’d0. |

<a name="_page30_x26.00_y206.00"></a>**Register 24-25: THD Compensation C3** 



|Bits |[15:0] |
| - | - |
|Mnemonic |thd\_comp\_c3 |
|Default |16’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[15:0] |thd\_comp\_c3 |A 16-bit signed coefficient for correcting for the third harmonic distortion.  Defaults to 16’d0. |

**Register 26: Reserved** 



|Bits |[7:0] |
| - | - |
|Mnemonic |reserved |
|Default |8’d98 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:0] |reserved ||
<a name="_page31_x26.00_y92.00"></a>**Register 27: General Configuration** 



|Bits |[7] |[6:5] |[4] |[3] |[2] |[1:0] |
| - | - | - | - | - | - | - |
|Mnemonic |asrc\_en |reserved |reserved |ch1\_volume |latch\_vol |18db\_gain |
|Default |1’b1 |2’b10 |1’b1 |1’b0 |1’b1 |2’b00 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7] |asrc\_en |<p>Selects whether the ASRC is enabled. </p><p>- 1’b0: ASRC is disabled and the output from the THD compensation block is piped directly into the modulators. </p><p>- 1’b1: The ASRC is used as normal, providing a first order correction on the sample rate converted data. </p>|
|[6:5] |reserved ||
|[4] |reserved ||
|[3] |ch1\_volume |<p>Allows channel 2 to share the channel 1 volume control.  This allows for perfectly syncing up the two channel gains. </p><p>- 1’b0: Allow independent control of both channel 1 and channel volume controls (default) </p><p>- 1’b1: Use the channel 1 volume control for both channel 1 and channel 2  </p><p>This bit can only be used for PCM audio data  </p>|
|[2] |latch\_volume |<p>Keeps the volume coefficients in synchronization with the programmed volume register. </p><p>- 1’b0: Disables updates of the internal volume coefficients (useful for updating each channel volume independently and then moving the volume coefficients in tandem) </p><p>- 1’b1: The internal volume coefficient is kept in synchronization with the volume registers </p>|
|[1:0] |18db\_gain |<p>Applies +18dB gain to the DAC datapath. </p><p>- 2’b00: No gain on either channels </p><p>- 2’b01: Normal gain on channel 2, +18dB gain on channel 1 </p><p>- 2’b10: +18dB gain on channel 2, normal gain on channel 1 </p><p>- 2’b11: +18dB gain on both channel 2 and channel 1 </p>|

**Register 28: Reserved** 



|Bits |[7:0] |
| - | - |
|Mnemonic |reserved |
|Default |8’d11110000 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:0] |reserved ||
**Register 29: GPIO Configuration** 



|Bits |[7:6] |[5:0] |
| - | - | - |
|Mnemonic |invert\_gpio |reserved |
|Default |2’b00 |6’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:6] |invert\_gpio |<p>Allows each GPIO output to be inverted independently. </p><p>- 2’b00: Normal GPIO operation (default) </p><p>- 2’b01: Invert GPIO1 output only </p><p>- 2’b10: Invert GPIO2 output only </p><p>- 2’b11: Invert both GPIO outputs </p>|
|[5:0] |reserved ||
<a name="_page33_x26.00_y92.00"></a>**Register 30-31: Charge Pump Clock** 



|Bits |[15:14] |[13:12] |[11:0] |
| - | - | - | - |
|Mnemonic |cp\_clk\_sel |cp\_clk\_en |cp\_clk\_div |
|Default |2’b00 |2’b00 |12’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[15:14] |cp\_clk\_sel |<p>Selects which clock will be used as the reference clock (f ) for the charge pump clock. </p><p>CLK</p><p>- 2’b00: fCLK = XI (default) </p><p>- 2’b01: reserved </p><p>- 2’b10: reserved </p><p>- 2’b11: reserved </p>|
|[13:12] |cp\_clk\_en |<p>Sets the state of the charge pump clock. </p><p>- 2’b00: Tristate output (default) </p><p>- 2’b01: Tied to GND </p><p>- 2’b10: Tied to DVDD </p><p>- 2’b11: Active </p>|
|[11:0] |cp\_clk\_div |<p>Sets the divider ratio for the charge pump clock.  f is the frequency of the clock selected by cp\_clk\_sel. </p><p>CLK</p><p>fCLK</p><p>fc =</p><p>p cp\_clk\_div ∗ 2</p>|

**Register 32: Reserved** 



|Bits |[7:0] |
| - | - |
|Mnemonic |reserved |
|Default |8’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:0] |reserved ||
**Register 33: Interrupt Mask** 



|Bits |[7:6] |[5:2] |[1] |[0] |
| - | - | - | - | - |
|Mnemonic |reserved |reserved |automute\_mask |lock\_mask |
|Default |2’b00 |4’b1111 |1’b0 |1’b0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:6] |reserved ||
|[5:2] |reserved ||
|[1] |automute\_mask |Masks the automute bit from flagging an interrupt. |
|[0] |lock\_mask |Masks the lock status bit from flagging an interrupt. |

<a name="_page35_x26.00_y92.00"></a>**Register 34-37: Programmable NCO** 



|Bits |[31:0] |
| - | - |
|Mnemonic |nco\_num |
|Default |32’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[31:0] |nco\_num |<p>An unsigned 32-bit quantity that provides the ratio between MCLK and DATA\_CLK.  This value can be used to generate arbitrary DATA\_CLK frequencies in master mode.  A value of 0 disables this operating mode. Note:  Master mode must still be enabled for the Sabre to drive the DATA\_CLK and DATA1 pins.  You must also select either serial mode or DSD mode in the input\_select register to determine whether DATA\_CLK should be driven alone (DSD mode) or both DATA\_CLK and DATA1 should be driven (serial mode). </p><p>- 32’d0: disables NCO mode (default) </p><p>- 32’d?: enables NCO mode </p><p>Note: NCO is determined by the following equation (nco\_num ∗ MCLK)</p><p>FSR = 232</p>|

**Register 38: Reserved** 



|Bits |[7:0] |
| - | - |
|Mnemonic |Reserved |
|Default |8’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:0] |Reserved ||
<a name="_page36_x26.00_y92.00"></a>**Register 39: General Configuration 2** 



|Bits |[7] |[6] |[5:2] |[1:0] |
| - | - | - | - | - |
|Mnemonic |amp\_pdb\_ss |amp\_pdb |reserved |sw\_ctrl\_en |
|Default |1’b0 |1’b0 |2’b00 |2’b00 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7] |amp\_pdb\_ss |<p>Powers the amplifier stage down when the digital core ramps to ground.  This is useful when powering down the amplifier when in automute mode. </p><p>- 1’b0: Amplifier PDB is controlled by the amp\_pdb (default) </p><p>- 1’b1: Shuts the amplifier down when the DAC is ramped to ground </p>|
|[6] |amp\_pdb |<p>Enables of disables the headphone amplifier. </p><p>- 1’b0: Disables the headphone amplifier (default) </p><p>- 1’b1: Enables the headphone amplifier </p>|
|[5:2] |reserved ||
|[1:0] |sw\_ctrl\_en |<p>Selects the operating mode of the external switch control. </p><p>- 2’b00: Switch control override is disabled and the switch is controlled externally (default) </p><p>- 2’b01: Switch control override is enabled and the switch control is set to 0 </p><p>- 2’b10: Reserved </p><p>- 2’b11: Switch control override is enabled and the switch control is set to 1 </p>|

**Register 40: Programmable FIR RAM Address** 



|Bits |[7:0] |
| - | - |
|Mnemonic |prog\_coeff\_addr |
|Default |8’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7] |coeff\_stage |<p>Selects which stage of the filter to write. </p><p>- 1’b0: selects stage 1 of the oversampling filter (default) </p><p>- 1’b1: selects stage 2 of the oversampling filter </p>|
|[6:0] |coeff\_addr |Selects the coefficient address when writing custom coefficients for the oversampling filter. |

**Register 41-43: Programmable FIR RAM Data** 



|Bits |[23:0] |
| - | - |
|Mnemonic |prog\_coeff\_data |
|Default |24’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[23:0] |coeff\_data |A 24bit signed filter coefficient that will be written to the address defined in prog\_coeff\_addr. |

**Register 44: Programmable FIR Configuration** 



|Bits |[7:3] |[2] |[1] |[0] |
| - | - | - | - | - |
|Mnemonic |reserved |stage2\_even |prog\_we |prog\_en |
|Default |5’b00000 |1’b0 |1’b0 |1’b0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:3] |reserved |Not connected in the digital core. |
|[2] |stage2\_even |<p>Selects the symmetry of the stage 2 oversampling filter. </p><p>- 1’b0: Uses a sine symmetric filter (27 coefficients) (default) </p><p>- 1’b1: Uses a cosine symmetric filter (28 coefficients) </p>|
|[1] |prog\_we |<p>Enables writing to the programmable coefficient RAM. </p><p>- 1’b0: Disables write signal to the coefficient RAM (default) </p><p>- 1’b1: Enables write signal to the coefficient RAM </p>|
|[0] |prog\_en |<p>Enables the custom oversampling filter coefficients. </p><p>- 1’b0: Uses a built-in filter selected by filter\_shape (default) </p><p>- 1’b1: Uses the coefficients programmed via prog\_coeff\_data </p>|

<a name="_page38_x26.00_y92.00"></a>**Register 45: Low Power and Auto Calibration** 



|Bits |[7] |[6] |[5] |[4] |[3:1] |[0] |
| - | - | - | - | - | - | - |
|Mnemonic |reserved |reserved |calib\_en |calib\_latch |reserved |bias\_ctrl |
|Default |1’b0 |1’b0 |1’b0 |1’b0 |3’b010 |1’b0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7] |reserved ||
|[6] |reserved ||
|[5] |calib\_en |<p>Enables master trim calibration via the ADC input. </p><p>- 1’b0: Disables master trim auto calibration (default) </p><p>- 1’b1: Enables master trim auto calibration </p>|
|[4] |calib\_latch |Continues updating the calibration routine while set to 1’b1. |
|[3:1] |reserved ||
|[0] |bias\_ctrl |Sets the state of the BIAS pin |

<a name="_page39_x26.00_y92.00"></a>**Register 46: ADC Configuration** 



|Bits |[7] |[6] |[5:4] |[3] |[2] |[1] |[0] |
| - | - | - | - | - | - | - | - |
|Mnemonic |reserved |adc\_order |adc\_clk |reserved |adc\_ditherb |reserved |adc\_pdb |
|Default |1’b0 |1’b0 |2’b00 |1’b0 |1’b0 |1’b0 |1’b0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7] |reserved ||
|[6] |adc\_order |<p>Selects whether the ADC uses a first order modulator or a second order modulator in the analog section. </p><p>- 1’b0: uses a first order modulator providing the best performance (default) </p><p>- 1’b1: uses a second order modulator (recommended for better performance) </p>|
|[5:4] |adc\_clk |<p>Sets the clock dividing ratio for the ADC analog section.  This also affects the decimation filter stages. </p><p>- 2’d0: ADC\_CLK = CLK </p><p>- 2’d1: ADC\_CLK = CLK/2 </p><p>- 2’d2: ADC\_CLK = CLK/4 </p><p>- 2’d3: ADC\_CLK = CLK/8 </p>|
|[3] |reserved ||
|[2] |adc\_ditherb |<p>Allows the ADC dither to be disabled on a per ADC basis. </p><p>- 1’b0: uses TPDF shaped dither providing the best performance (default) </p><p>- 1’b1: disabled dither </p>|
|[1] |reserved ||
|[0] |adc\_pdb |<p>Shuts down the ADC.  Note:  GPIO must be configured as ADC input for the ADC to function correctly. </p><p>- 1’b0: shuts down the ADC (default) </p><p>- 1’b1: enables the ADC analog stage </p>|

**Register 47-52: ADC Filter Configuration** 

The Sabre contains two decimation filters for filtering the ADC data.  These filters are configurable via the ADC filter configuration registers.  They are set as a low pass filter by default. 

Register 47-48: ADC Filter Configuration (ftr\_scale) 

|Bits |[15:0] |
| - | - |
|Mnemonic |adc\_ftr\_scale |
|Default |16’d992 |

**Register 49-50: ADC Filter Configuration (fbq\_scale)** 



|Bits |[15:0] |
| - | - |
|Mnemonic |adc\_fbq\_scale1 |
|Default |16’d1024 |

**Register 51-52: ADC Filter Configuration (fbq\_scale)** 



|Bits |[15:0] |
| - | - |
|Mnemonic |adc\_fbq\_scale2 |
|Default |16’d1024 |

**Register 53-54: Reserved** 



|Bits |[15:12] |[11:0] |
| - | - | - |
|Mnemonic |reserved |reserved |
|Default |4’d0 |12’d3866 |



|Bit |Mnemonic |Description |
| - | - | - |
|[15:0] |reserved ||
<a name="_page41_x26.00_y92.00"></a>**Register 64 (Read-Only): Chip ID and Status** 



|Bits |[7:2] |[1] |[0] ||
| - | - | - | - | :- |
|Mnemonic |chip\_id |automute\_status |lock\_status ||
|Default |6’b01110000 |1’b0 |1’b0 ||


|Bit |Mnemonic |Description |
| - | - | - |
|[7:2] |chip\_id |Determines the chip identification. |
|[1] |automute\_status |<p>Indicator for when automute has become active. </p><p>- 1’b0: Automute condition is inactive. </p><p>- 1’b1: Automute condition has been flagged and is active. </p>|
|[0] |lock\_status |<p>Indicator for when the DPLL is locked (when in slave mode) or 1’b1 when the Sabre is the master. </p><p>- 1’b0: DPLL is not locked to the incoming audio sample rate (which could mean that no audio input is present, the lock has not completed, or the Sabre is unable to lock due to clock jitter or drift). </p><p>- 1’b1: DPLL is locked to the incoming audio sample rate, or the Sabre is in master mode, 128\*fs mode or NCO mode </p>|

**Register 65 (Read-Only): GPIO Readback** 



|Bits |[7:2] |[1] |[0] |
| - | - | - | - |
|Mnemonic |reserved |gpio2 |gpio1 |
|Default |6’d0 |1’b0 |1’b0 |



|Bit |Mnemonic |Description |
| - | - | - |
|7:2] |reserved |Hard coded to 6’d0. |
|[1] |gpio2 |Contains the state of the GPIO2 pin. |
|[0] |gpio1 |Contains the state of the GPIO1 pin. |

<a name="_page42_x26.00_y218.00"></a>**Register 66-69 (Read-Only): DPLL Number** 



|Bits |[31:0] |
| - | - |
|Mnemonic |dpll\_num |
|Default |32’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[31:0] |dpll\_num |<p>Contains the ratio between the MCLK and the audio clock rate once the DPLL has acquired lock.  This value is latched on reading the LSB, so register 66 must be read first to acquire the latest DPLL value.  The value is latched on LSB because the DPLL number can be changing as the I2C transactions are performed. </p><p>(dpll\_num ∗ MCLK) FSR =</p><p>232</p>|

**Register 70-93 (Read-Only): SPDIF Channel Status/User Status** 



|Bits |[191:0] |
| - | - |
|Mnemonic |spdif\_status |
|Default |192’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[191:0] |spdif\_status |Contains either the SPDIF channel status (table shown below) or the SPDIF user bits.  This selection can be made via register 1 (spdif\_load\_user\_bits). |



|SPDIF CHANNEL STATUS – Consumer configuration |||||||||
| - | :- | :- | :- | :- | :- | :- | :- | :- |
|Address Offset |[7] |[6] |[5] |[4] |[3] |[2] |[1] |[0] |
|0 |Reserved |Reserved |0:2Channel 1:4Channel |Reserved |0:No-Preemph 1:Preemph |0:CopyRight 1:Non-CopyRight |0:Audio 1:Data |0:Consumer 1:Professional |
|1 |<p>Category Code    </p><p>0x00: General 0x01:Laser-Optical 0x02:D/D Converter 0x03:Magnetic </p><p>0x04:Digital Broadcast 0x05:Musical Instrument 0x06:Present A/D Converter 0x08:Solid State Memory 0x16:Future A/D Converter 0x19:DVD 0x40:Experimental </p>||||||||
|2 |<p>Channel Number 0x0: Don’t Care 0x1: A (Left) 0x2: B (Right) 0x3: C </p><p>0x4: D </p><p>0x5: E </p><p>0x6: F </p><p>0x7: G </p><p>0x8: H </p><p>0x9: I </p><p>0xA: J </p><p>0xB: K </p><p>0xC: L </p><p>0xD: M </p><p>0xE: N </p><p>0xF: O </p>|<p>Source Number 0x0:Don’t Care 0x1: 1 </p><p>0x2: 2 </p><p>0x3: 3 </p><p>0x4: 4 </p><p>0x5: 5 </p><p>0x6: 6 </p><p>0x7: G </p><p>0x8: 8 </p><p>0x9: 9 </p><p>0xA: 10 </p><p>0xB: 11 </p><p>0xC: 12 </p><p>0xD: 13 </p><p>0xE: 14 </p><p>0xF: 15 </p>|||||||
|3 |Reserved |Reserved |<p>Clock Accuracy </p><p>0x0:Level 2   ±1000ppm 0x1:Level 1   ±50ppm </p><p>0x2:Level 3   variable pitch shifted </p>|<p>Sample Frequency 0x0: 44.1k </p><p>0x2: 48k </p><p>0x3: 32k </p><p>0x4: 22.05k </p><p>0x6: 24k </p><p>0x8: 88.2k </p><p>0xA: 96k </p><p>0xC: 176.4k </p><p>0xE: 192k </p>|||||
|4 |Reserved |Reserved |Reserved |Reserved |<p>Word Length: </p><p>If Word Field Size=0 |If Word Field Size = 1 000=Not indicated    |000=Not indicated 100 = 23bits            |100 = 19bits </p><p>010 = 22bits            |010 = 18bits </p><p>110 = 21bits            |110 = 17bits </p><p>001 = 20bits            |001 = 16bits </p><p>101 = 24bits            |101 = 20bits </p>|Word Field Size 0:Max 20bits 1:Max 24bits |||
|5-23 |Reserved ||||||||



|SPDIF CHANNEL STATUS – Professional configuration |||||||||
| - | :- | :- | :- | :- | :- | :- | :- | :- |
|Address Offset |[7] |[6] |[5] |[4] |[3] |[2] |[1] |[0] |
|0 |<p>sampling frequency: </p><p>00: not indicated (or see byte 4) </p><p>10: 48 kHz </p><p>01: 44.1 kHz </p><p>11: 32 kHz </p>|<p>lock: </p><p>0: locked 1: unlocked </p>|<p>emphasis: </p><p>000: Emphasis not indicated 001: No emphasis </p><p>011: CD-type emphasis 111: J-17 emphasis </p>|0:Audio 1:Non-audio |0:Consumer 1:Professional ||||
|1 |<p>User bit management: </p><p>0000: no indication </p><p>1000: 192-bit block as channel status 0100: As defined in AES18 </p><p>1100: user-defined </p><p>0010: As in IEC60958-3 (consumer) </p>|<p>Channel mode: </p><p>0000: not indicated (default to 2 ch) 1000: 2 channel </p><p>0100: 1 channel (monophonic) </p><p>1100: primary / secondary </p><p>0010: stereo </p><p>1010: reserved for user applications 0110: reserved for user applications 1110: SCDSR (see byte 3 for ID) 0001: SCDSR (stereo left) </p><p>1001: SCDSR (stereo right) </p><p>1111: Multichannel (see byte 3 for ID) </p>|||||||
|2 |alignment level: 00: not indicated 10: –20dB FS 01: –18.06dB FS |<p>Source Word Length: </p><p>If max = 20bits           |If max = 24bits 000=Not indicated    |000=Not indicated </p><p>100 = 23bits            |100 = 19bits 010 = 22bits            |010 = 18bits 110 = 21bits            |110 = 17bits 001 = 20bits            |001 = 16bits 101 = 24bits            |101 = 20bits </p>|<p>Use of aux sample word: </p><p>000: not defined, audio max 20 bits 100: used for main audio, max 24 bits 010: used for coord, audio max 20 bits 110: reserved </p>||||||
|3 |<p>Channel identification: </p><p>if bit 7 = 0 then channel number is 1 plus the numeric value of bits 0-6 (bit reversed). </p><p>if bit 7 = 1 then bits 4–6 define a multichannel mode and bits 0–3 (bit reversed) give the channel number within that mode. </p>||||||||
|4 |<p>fs scaling: </p><p>0: no scaling </p><p>1: apply factor of  </p><p>`    `1 / 1.001 to value </p>|<p>Sample frequency (fs): 0000: not indicated 0001:  24kHz </p><p>0010:  96kHz </p><p>1001:  22.05kHz 1010:  88.2kHz </p><p>1011: 176.4kHz </p><p>0011: 192kHz </p><p>1111: User defined </p>|Reserved |<p>DARS (Digital audio reference signal): </p><p>00: not a DARS </p><p>01: DARS grade 2 (±10ppm) 10: DARS grade 1 (±1ppm) 11: Reserved </p>|||||
|5 |Reserved ||||||||
|6-9 |alphanumerical channel origin: four-character label using 7-bit ASCII with no parity. Bits 55, 63, 71, 79 = 0. ||||||||
|10-13 |alphanumerical channel destination: four-character label using 7-bit ASCII with no parity. Bits 87, 95, 103, 111 = 0. ||||||||
|14-17 |local sample address code: 32-bit binary number representing the sample count of the first sample of the channel status block. ||||||||
|18-21 |time of day code: 32-bit binary number representing time of source encoding in samples since midnight ||||||||
|22 |<p>reliability flags </p><p>0: data in byte range is reliable 1: data in byte range is unreliable </p>||||||||
|23 |<p>CRCC </p><p>00000000: not implemented </p><p>X: error check code for bits 0–183 </p>||||||||

**Register 94 (Read-Only): Reserved** 



|Bits |[7:0] |
| - | - |
|Mnemonic |reserved |
|Default |8’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:0] |Reserved ||
**Register 95 (Read-Only): Reserved** 



|Bits |[7:0] |
| - | - |
|Mnemonic |reserved |
|Default |8’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:0] |Reserved ||
**Register 96 (Read-Only): Input Selection and Automute Status** 



|Bits |[7:6] |[5:4] |[3] |[2] |[1] |[0] |
| - | - | - | - | - | - | - |
|Mnemonic |Reserved |reserved |dop\_valid |spdif\_valid |i2s\_select |dsd\_select |
|Default |2’b00 |2’b00 |1’b0 |1’b0 |1’b0 |1’b0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[7:6] |reserved ||
|[5:4] |reserved ||
|[3] |dop\_valid |<p>Contains the status of the DoP decoder. </p><p>- 1’b0: The DoP decoder has not detected a valid DoP signal. </p><p>- 1’b1: The DoP decoder has detected a valid DoP signal on the I2S input. </p>|
|[2] |spdif\_valid |<p>Contains the status of the SPDIF decoder. </p><p>- 1’b0: The SPDIF decoder has not found a valid SPDIF signal. </p><p>- 1’b1: The SPDIF decoder has detected a valid SPDIF signal. </p>|
|[1] |i2s\_select |<p>Contains the status of the I2S decoder. </p><p>- 1’b0: The I2S decoder has not found a valid frame clock or bit clock. </p><p>- 1’b1: The I2S decoder has detected a valid frame clock and bit clock arrangement. </p>|
|[0] |dsd\_select |<p>Contains the status of the DSD decoder. </p><p>- 1’b0: The DSD decoder is not being used. </p><p>- 1’b1: The DSD decoder is being used as a fallback option if I2S has failed to decode their respective input signals. </p>|

**Register 97-99 (Read-Only): Reserved Register 100-102 (Read-Only): ADC Readback** 



|Bits |[23:0] |
| - | - |
|Mnemonic |adc\_ch1 |
|Default |24’d0 |



|Bit |Mnemonic |Description |
| - | - | - |
|[23:0] |adc\_ch1 |A signed 24-bit number for ADC channel 1.  This value is latched on the reading of the LSBs (register 100). |

**RECOMMENDED POWER-UP SEQUENCE** 

Before or after VCCA as long as RESETB is asserted (i.e. held low) until all external power supplies are stable

DVCC VCCA 

AVCC\_L, AVCC\_R Same time as VCCA or later XI  (if externally supplied)

RESETB

At power up, assert RESETB until at least  Subsequent reset(s), if 1ms after all external power supplies (and XI  necessary, should be 

if supplied externally) are stabilized asserted for 10ns or longer

**ABSOLUTE MAXIMUM RATINGS** 



|**PARAMETER** |**RATING** |
| - | - |
|Positive Supply Voltage (VCCA, AVCC\_L, AVCC\_R, DVCC) |+4.7V with respect to GND |
|Positive Supply Voltage (DVDD) |+1.8V with respect to GND |
|Output Voltage Range (DACL, DACR, DACLB, DACRB) |GND < Vout < AVCC\_L/R |
|Storage Temperature Range |–65°C to +150°C |
|Operating Junction Temperature |+125°C |
|Voltage range for Digital Input Pins (non 5V tolerant) Voltage range for Digital Input Pins (5V tolerant) |–0.3V to DVCC+ 0.3V –0.3V to +5.3V |
|<p>ESD Protection </p><p>Human Body Model (HBM) Charged Device Model (CDM) </p>|2000V 500V |

**WARNING:** Stresses beyond those listed under “Absolute Maximum Ratings” may cause permanent damage to the device.  These are stress ratings only and 

functional operation of the device at these or any other conditions beyond those indicated under “recommended operating conditions” is not implied. Exposure to absolute–maximum–rated conditions for extended periods may affect device reliability.

**WARNING:** Electrostatic Discharge (ESD) can damage this device.  Proper procedures must be followed to avoid ESD when handling this device. 

**RECOMMENDED OPERATING CONDITIONS** 



|**PARAMETER** |**SYMBOL** |**CONDITIONS** |
| - | - | - |
|Operating temperature |TA |–20°C to +70°C |



|**Power Supply** |**Symbol** |**Voltage** |**Nominal current / power consumption** ||
| - | - | - | - | :- |
||||**Normal Mode (Note 1)** |**Standby Mode (Notes 2)** |
|Analog core |VCCA |+3.3V ±5% |2 mA |900 uA |
|Analog power |AVCC\_L AVCC\_R |+3.3V ±5% |6 mA ||
|Internal digital core  |DVDD |+1.2V (typical) |Internally supplied ||
|Low-power / 1.8V logic system |||||
|Digital power |DVCC |+1.8V ±5% |7 mA |4 uA  |
|Total power ||DVCC=1.8V |40 mW |1\.3 mW |
|General purpose / 3.3V logic system |||||
|Digital power |DVCC |+3.3V ±5% |8 mA |1\.2 mA  |
|Total power ||DVCC=3.3V |53 mW |5 mW |

**Notes** 

1) fs = 44.1kHz, XI = 38MHz, MCLK=9.5MHz, 0dB 1kHz output, I2S input, output unloaded, internal DVDD, all external supply voltages at nominal center values 
1) Measured with RESETB held low, XI and I2S interface held low 

**DC ELECTRICAL CHARACTERISTICS** 



|Symbol<a name="_page49_x26.00_y711.00"></a>** |Parameter** |Minimum** |Maximum** |Unit** |Comments** |
| - | - | - | - | - | - |
|VIH |High-level input voltage |DVCC / 2 + 0.4 ||V ||
|VIL |Low-level input voltage ||0\.4 |V ||
|VOH |High-level output voltage |DVCC - 0.2 ||V |IOH = 100mA |
|VOL |Low-level output voltage ||0\.2 |V |IOL = 100mA |

**XI Timing** 

tMCH

**XI**

tMCL

tMCY



|**Parameter** |**Symbol** |**Min** |**Max** |**Unit** |
| - | - | - | - | - |
|XI pulse width high |<p>T</p><p>MCH</p>|4\.5 ||ns |
|XI pulse width low |<p>T</p><p>MCL</p>|4\.5 ||ns |
|XI cycle time |<p>T</p><p>MCY</p>|10 ||ns |
|XI duty cycle ||45:55 |55:45 ||
**Audio Interface Timing** 

tDCY

DATA\_CLK 

tDCH tDCL

tDH tDS DATA[2:1]  Valid Invalid Valid



|**Parameter** |**Symbol** |**Min** |**Max** |**Unit** |
| - | - | - | - | - |
|DATA\_CLK pulse width high |<p>t</p><p>DCH</p>|4\.5 ||ns |
|DATA\_CLK pulse width low |<p>t</p><p>DCL</p>|4\.5 ||ns |
|DATA\_CLK cycle time |<p>t</p><p>DCY</p>|10 ||ns |
|DATA\_CLK duty cycle ||45:55 |55:45 ||
|DATA set-up time to DATA\_CLK rising edge |<p>t</p><p>DS</p>|4\.1 ||ns |
|DATA hold time to DATA\_CLK rising edge |<p>t</p><p>DH</p>|2 ||ns |

**Notes:** 

- Audio data on DATA[2:1] are sampled at the rising edges of DATA\_CLK and must satisfy the setup and hold time requirements relative to the rising edge of DATA\_CLK 
- For DSD Phase mode [(Native DSD Format)](#_page12_x26.00_y412.00), the normal data (D0, D1, D2... in) must satisfy the setup and hold time requirements<a name="_page50_x26.00_y697.00"></a> relative to the rising edge of DATA\_CLK. The complimentary data (D0, D1, etc.) will be ignored. 

**51****  ESS TECHNOLOGY, INC.  237 South Hillview Drive, Milpitas, CA 95035, USA  Tel (408) 643-8800 • Fax (408) 643-8801 !
**July 17, 2019  CONFIDENTIAL Rev. 1.3 !**

**ANALOG PERFORMANCE** 

**Test Conditions (unless otherwise stated)** 

1. TA = 25oC, AVCC = VCCA = DVCC = +3.3V, internal DVDD with 4.7mF ±20% decoupling, fs = 44.1kHz, MCLK = 27MHz & 32-bit data 
1. SNR/DNR: A-weighted over 20Hz-20kHz in averaging mode 

`        `THD+N: un-weighted over 20Hz-20kHz bandwidth



|**PARAMETER** ||**CONDITIONS** |**MIN** |**TYP** |**MAX** |**UNIT** |
| - | :- | - | - | - | - | - |
|Resolution ||||32 ||Bits |
|XI Frequency |||||100M |Hz |
|MCLK (PCM normal mode) ||Custom FIR mode Asynchronous mode Synchronous mode |256FSR 192FSR 128FSR ||2 \_|Hz |
|MCLK (PCM OSF bypass mode)  ||Asynchronous mode Synchronous mode |24FSR  16FSR ||||
|MCLK (DSD mode) ||Asynchronous mode Synchronous mode |3FSR  2FSR ||||
|MCLK (SPDIF mode) |||386FSR  ||||
|FSR (PCM normal mode) ||Asynchronous mode Synchronous mode |||384k 768k |Hz |
|FSR (PCM OSF bypass mode)  |||||1\.536M |Hz |
|FSR (DSD mode) ||Asynchronous mode Synchronous mode |||11\.3M 22.6M |Hz |
|FSR (SPDIF mode) |||||192k |Hz |
|**DYNAMIC PERFORMANCE** |||||||
|DNR (differential current mode) ||–60dBFS ||128 ||dB-A |
|THD+N (differential current mode) ||0dBFS ||–120 ||dB |
|**ANALOG OUTPUT (per + or – pin of each differential DAC output pair)** |||||||
|Output impedance (RDAC) ||||774 ± 11% ||W |
|Voltage mode output range (VOPP) ||Full-scale out ||0\.906 x AVCC ||Vp-p |
|Voltage mode output offset (VOCM) ||Bipolar zero out ||AVCC / 2 ||V |
|Current mode output range ||Full-scale out ||1000 x VOPP / RDAC||mAp-p |
|Current mode output offset ||Bipolar zero out to virtual ground at voltage VG (V) ||<p>1000 x (VOPP - VG) / R</p><p>DAC</p>||mA |
|**Digital Filter Performance** |||||||
|De-emphasis error |||||±0.2 |dB |
|Mute Attenuation ||||–127 | |dB |

**ES9038Q2M Datasheet !!!**



|**PARAMETER** ||**CONDITIONS** |**MIN** |**TYP** |**MAX** |**UNIT** |
| - | :- | - | - | - | - | - |
|**PCM Filter Characteristics (Linear Phase Fast Roll Off)** |||||||
|Pass band ||±0.002dB |||0\.453 x fs |Hz |
|||–3dB |||0\.484 x fs |Hz |
|Stop band ||< –120dB |0\.55 x fs || |Hz |
|Group Delay ||||35 / fs ||s |
|**PCM Filter Characteristics (Linear Phase Slow Roll Off)** |||||||
|Pass band ||±0.01dB |||0\.357 x fs |Hz |
|||–3dB |||0\.450 x fs |Hz |
|Stop band ||< –82dB |0\.639 x fs || |Hz |
|Group Delay ||||8\.75 / fs ||s |
|**PCM Filter Characteristics (Minimum Phase Fast Roll Off)** |||||||
|Pass band ||±0.005dB |||0\.453 x fs |Hz |
|||–3dB |||0\.491 x fs |Hz |
|Stop band ||< –100dB |0\.547 x fs || |Hz |
|Group Delay ||||5\.4 / fs ||s |
|**PCM Filter Characteristics (Minimum Phase Slow Roll Off)** |||||||
|Pass band ||±0.015dB |||0\.363 x fs |Hz |
|||–3dB |||0\.435 x fs |Hz |
|Stop band ||< -97dB |0\.634 x fs || |Hz |
|Group Delay ||||3\.5 / fs ||s |
|**PCM Filter Characteristics (Apodizing Fast Roll Off)** |||||||
|Pass band ||±0.075dB |||0\.409 x fs |Hz |
|||–3dB |||0\.461 x fs |Hz |
|Stop band ||<p>- -80dB </p><p>- -100dB </p>|<p>0\.5 x fs </p><p>0\.66 x fs </p>|| |Hz |
|Group Delay ||||35 / fs ||s |
|**PCM Filter Characteristics (Hybrid Fast Roll Off)** |||||||
|Pass band ||±0.01dB |||0\.404 x fs |Hz |
|||–3dB |||0\.430 x fs |Hz |
|Stop band ||<p>- -94.5dB </p><p>- -106dB </p>|<p>0\.504 x fs </p><p>0\.513 x fs </p>|| |Hz |
|Group Delay ||||18\.5 / fs ||s |
|**PCM Filter Characteristics (Brick Wall)** |||||||
|Pass band ||±0.015dB |||0\.435 x fs |Hz |
|||–3dB |||0\.451 x fs |Hz |
|Stop band ||< -100dB |0\.5 x fs || |Hz |
|Group Delay ||||35 / fs ||s |

**53****  ESS TECHNOLOGY, INC.  237 South Hillview Drive, Milpitas, CA 95035, USA  Tel (408) 643-8800 • Fax (408) 643-8801 !
**July 17, 2019  CONFIDENTIAL Rev. 1.3 !**

**ES9038Q2M Datasheet !!!**

**PCM DE-EMPHASIS FILTER RESPONSE (32kHz)** 



|||
| - | - |

**PCM DE-EMPHASIS FILTER RESPONSE (44.1kHz)** 



|||
| - | - |

**PCM DE-EMPHASIS FILTER RESPONSE (48kHz)** 



|||
| - | - |



<a name="_page53_x26.00_y722.00"></a>**PCM FILTER FREQUENCY RESPONSE** 



|**Linear phase fast roll-off filter (dB)** ||
| :- | - |
|**Linear phase slow roll-off filter (dB)** ||
|**Minimum phase fast roll-off filter (dB)** ||
|**Minimum phase slow roll-off filter (dB)** ||
|**Apodizing fast roll-off filter (default, dB)** ||
|**Hybrid fast roll-off filter (dB)** ||
|**Brick wall filter (dB)** ||

Unit:<a name="_page55_x26.00_y563.00"></a> fs (Hz) / 48000 

**PCM FILTER IMPULSE RESPONSE** 



|**Linear phase fast roll-off filter** ||
| - | - |
|**Linear phase slow roll-off filter** ||
|**Minimum phase fast roll-off filter** ||
|**minimum phase slow roll-off filter** ||
|**Apodizing fast roll-off filter (default)** ||
|**Hybrid fast roll-off filter** ||
|**Brick wall filter** ||

Unit:<a name="_page57_x26.00_y570.00"></a> 1/fs (s) 

**DSD FILTER RESPONSE** 

dB 

Unit: DATA\_CLK (Hz) / 2822400 

**59****  ESS TECHNOLOGY, INC.  237 South Hillview Drive, Milpitas, CA 95035, USA  Tel (408) 643-8800 • Fax (408) 643-8801 !
**July 17, 2019  CONFIDENTIAL Rev. 1.3 !**

**30-Pin QFN Mechanical Dimensions** 



**ES9038Q2M Datasheet !!!ES9038Q2M Marking Specification** 

**ESS**  Logo 

**ES9038Q2M**  ESS P/N 

`     `TTTTLLLLLL      Trace & Lot code PIDin 1  RWWY  Revision & Date 

**61****  ESS TECHNOLOGY, INC.  237 South Hillview Drive, Milpitas, CA 95035, USA  Tel (408) 643-8800 • Fax (408) 643-8801 !
**July 17, 2019  CONFIDENTIAL Rev. 1.3 !**

**ES9038Q2M Datasheet !!!**

**Reflow Process Considerations** 

For lead-free soldering, the characterization and optimization of the reflow process is the most important factor you need to consider.  

The lead-free alloy solder has a melting point of 217°C.  This alloy requires a minimum reflow temperature of 235°C to ensure good wetting.  The maximum reflow temperature is in the 245°C to 260°C range, depending on the package size *(Table RPC-2)*.  This narrows the process window for lead-free soldering to 10°C to 20°C. 

The increase in peak reflow temperature in combination with the narrow process window makes the development of an optimal reflow profile a critical factor for ensuring a successful lead-free assembly process.  The major factors contributing to the development of an optimal thermal profile are the size and weight of the assembly, the density of the components, the mix of large and small components, and the paste chemistry being used. 

Reflow profiling needs to be performed by attaching calibrated thermocouples well adhered to the device as well as other critical locations on the board to ensure that all components are heated to temperatures above the minimum reflow temperatures and that smaller components do not exceed the maximum temperature limits *(Table RPC-2)*.  

To ensure that all packages can be successfully and reliably assembled, the reflow profiles studied and recommended by ESS are based on the JEDEC/IPC standard J-STD-020 revision D.1.

**Figure RPC-1.** IR/Convection Reflow Profile (IPC/JEDEC J-STD-020D.1)



**Note: Reflow is allowed 3 times. Caution must be taken to ensure time between re-flow runs does not exceed the allowed time by the moisture sensitivity label. If the time elapsed between the re-flows exceeds the moisture sensitivity time bake the board according to the moisture sensitivity label instructions.** 

**Manual Soldering:** 

Allowed up to 2 times with maximum temperature of 350 degrees no longer than 3 seconds.   

**Table RPC-1 Classification reflow profile** 



|**Profile Feature** |**Pb-Free Assembly** |
| - | - |
|<p>**Preheat/Soak** </p><p>Temperature Min (Tsmin) Temperature Max (Tsmax) Time (ts) from (Tsmin to Tsmax) </p>|<p>150°C </p><p>200°C </p><p>60-120 seconds** </p>|
|Ramp-up rate (TL to Tp)** |3°C / second max.** |
|Liquidous temperature (TL) Time (tL) maintained above TL |<p>217°C </p><p>60-150 seconds </p>|
|Peak package body temperature (Tp)** |<p>For users Tp must not exceed the classification temp in Table RPC-2. </p><p>For suppliers Tp must equal or exceed the Classification temp in Table RPC-2. </p>|
|<p>Time (tp)\* within 5°C of the specified classification temperature (Tc), </p><p>see Figure RPC-1 </p>|30\* seconds** |
|Ramp-down rate (Tp to TL)** |6°C / second max.** |
|Time 25°C to peak temperature** |8 minutes max. |
|\* Tolerance for peak profile temperature (Tp) is defined as a supplier minimum and a user maximum. ||

**Note 1:** All temperatures refer to the center of the package, measured on the package body surface that is facing up during assembly reflow (e.g., live-bug). 

If parts are reflowed in other than the normal live-bug assembly reflow orientation (i.e., dead-bug), Tp **shall** be within ±2°C of the live-bug Tp and still meet the Tc requirements, otherwise, the profile **shall** be adjusted to achieve the latter.  To accurately measure actual peak package body temperatures refer to JEP140 for recommended thermocouple use. 

**Note 2:** Reflow profiles in this document are for classification/preconditioning and are not meant to specify board assembly profiles.  Actual board assembly 

profiles should be developed based on specific process needs and board designs and should not exceed the parameters in Table RPC-1. 

For example, if Tc is 260°C and time tp is 30 seconds, this means the following for the supplier and the user.  

For a supplier: The peak temperature must be at least 260°C.  The time above 255°C must be at least 30 seconds.  

For a user: The peak temperature must not exceed 260°C.  The time above 255°C must not exceed 30 seconds. 

**Note 3:** All components in the test load **shall** meet the classification profile requirements. 

**Table RPC-2 Pb-Free Process – Classification Temperatures (Tc)** 



|**Package Thickness** |**Volume mm3,  <350** |**Volume mm3,  350 to 2000** |**Volume mm3,  >2000** |
| - | - | - | - |
|<1.6 mm |260°C |260°C |260°C |
|1\.6 mm – 2.5 mm |260°C |250°C |245°C |
|>2.5 mm |250°C |245°C |245°C |

**Note 1:** At the discretion of the device manufacturer, but not the board assembler/user, the maximum peak package body temperature (Tp) can exceed the 

values specified in Table RPC-2.  The use of a higher Tp does not change the classification temperature (Tc). 

**Note 2:** Package volume excludes external terminals (e.g., balls, bumps, lands, leads) and/or non-integral heat sinks. 

**Note 3:** The maximum component temperature reached during reflow depends on package thickness and volume.  The use of convection reflow processes 

reduces the thermal gradients between packages.  However, thermal gradients due to differences in thermal mass of SMD packages may still exist.

**63****  ESS TECHNOLOGY, INC.  237 South Hillview Drive, Milpitas, CA 95035, USA  Tel (408) 643-8800 • Fax (408) 643-8801 !
**July 17, 2019  CONFIDENTIAL Rev. 1.3 !**

**ORDERING INFORMATION** 



|**Part Number** |**Description** |**Package** |
| - | - | - |
|ES9038Q2M |Sabre32 Reference 32-Bit, 2-Channel, Low Power Audio DAC |30-pin QFN |

The letter Q identifies the package type QFN 
