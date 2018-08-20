`ifndef _6502_inc_vh_
`define _6052_inc_vh_

// For when I want to synthesize and keep the full internal hierarchy
`define SCHEM_KEEP 1
`ifdef SCHEM_KEEP
`define SCHEM_KEEP_HIER (* keep_hierarchy = "yes" *)
`else
`define SCHEM_KEEP_HIER
`endif

// Magic macro to extract field shift from field definition macro using ternary operator
`define FIELD_SHIFT(_x) (0?_x)

// Block RAMs are either 18 or 36 bits wide, so it's also useful to make sure those last 4 bits
// are grouped together.  Although for Artix-7 the synthesis tools really wind up generating 3
// 2K x 18bit block RAMs.  So the bit groupings really wind up being 3 groups of 18 bits.

`define SYNC_BITS     0:0
`define SYNC          |(1 << `FIELD_SHIFT(`SYNC_BITS))

// What's driving the address bus
`define AB_BITS       2:1

`define kAB_PCn       0
`define kAB_ABn       1
`define kAB_ADn       2
`define kAB_SPn       3

`define AB_PCn        |(`kAB_PCn      << `FIELD_SHIFT(`AB_BITS))
`define AB_ABn        |(`kAB_ABn      << `FIELD_SHIFT(`AB_BITS))
`define AB_ADn        |(`kAB_ADn      << `FIELD_SHIFT(`AB_BITS))
`define AB_SPn        |(`kAB_SPn      << `FIELD_SHIFT(`AB_BITS))

// ALU A select
`define ASEL_BITS     5:3

`define kASEL_0       0
`define kASEL_AREG    1
`define kASEL_DREG    2
`define kASEL_VEC     3
`define kASEL_FF      4
`define kASEL_DB      5
`define kASEL_NDREG   6
`define kASEL_NDB     7

`define ASEL_0        |(`kASEL_0      << `FIELD_SHIFT(`ASEL_BITS))
`define ASEL_AREG     |(`kASEL_AREG   << `FIELD_SHIFT(`ASEL_BITS))
`define ASEL_DREG     |(`kASEL_DREG   << `FIELD_SHIFT(`ASEL_BITS))
`define ASEL_VEC      |(`kASEL_VEC    << `FIELD_SHIFT(`ASEL_BITS))
`define ASEL_FF       |(`kASEL_FF     << `FIELD_SHIFT(`ASEL_BITS))
`define ASEL_DB       |(`kASEL_DB     << `FIELD_SHIFT(`ASEL_BITS))
`define ASEL_NDREG    |(`kASEL_NDREG  << `FIELD_SHIFT(`ASEL_BITS))
`define ASEL_NDB      |(`kASEL_NDB    << `FIELD_SHIFT(`ASEL_BITS))

// ALU D reg select
`define DREG_BITS     7:6

`define kDREG_A       0
`define kDREG_X       1
`define kDREG_Y       2
`define kDREG_Z       3

`define DREG_A        |(`kDREG_A      << `FIELD_SHIFT(`DREG_BITS))
`define DREG_X        |(`kDREG_X      << `FIELD_SHIFT(`DREG_BITS))
`define DREG_Y        |(`kDREG_Y      << `FIELD_SHIFT(`DREG_BITS))
`define DREG_Z        |(`kDREG_Z      << `FIELD_SHIFT(`DREG_BITS))

`define DREG_DO_BITS  32:31
`define DREG_DO_A        |(`kDREG_A      << `FIELD_SHIFT(`DREG_DO_BITS))
`define DREG_DO_X        |(`kDREG_X      << `FIELD_SHIFT(`DREG_DO_BITS))
`define DREG_DO_Y        |(`kDREG_Y      << `FIELD_SHIFT(`DREG_DO_BITS))
`define DREG_DO_Z        |(`kDREG_Z      << `FIELD_SHIFT(`DREG_DO_BITS))

// ALU A reg select

// Note: We don't really need both AREG and DREG fields since the ASEL mux can only source from one or the other,
// and so we could share the two select bits between the AREG and DREG muxes if we ever get really desperate for
// more microcode bits and would like to potentially save routing resources.
`define AREG_BITS     9:8

`define kAREG_SPL     2'b00
`define kAREG_SPH     2'b01
`define kAREG_PCL     2'b10
`define kAREG_PCH     2'b11

`define AREG_SPL      |(`kAREG_SPL    << `FIELD_SHIFT(`AREG_BITS))
`define AREG_SPH      |(`kAREG_SPH    << `FIELD_SHIFT(`AREG_BITS))
`define AREG_PCL      |(`kAREG_PCL    << `FIELD_SHIFT(`AREG_BITS))
`define AREG_PCH      |(`kAREG_PCH    << `FIELD_SHIFT(`AREG_BITS))

// ALU_B input select
`define BSEL_BITS     12:10
`define kBSEL_0       0
`define kBSEL_FF      1
`define kBSEL_DB      2
`define kBSEL_NDB     3
`define kBSEL_BIT     4
`define kBSEL_DBD     5
`define kBSEL_B       6
`define kBSEL_P       7

`define BSEL_0        |(`kBSEL_0      << `FIELD_SHIFT(`BSEL_BITS))
`define BSEL_DB       |(`kBSEL_DB     << `FIELD_SHIFT(`BSEL_BITS))
`define BSEL_BIT      |(`kBSEL_BIT    << `FIELD_SHIFT(`BSEL_BITS))
`define BSEL_B        |(`kBSEL_B      << `FIELD_SHIFT(`BSEL_BITS))
`define BSEL_FF       |(`kBSEL_FF     << `FIELD_SHIFT(`BSEL_BITS))
`define BSEL_NDB      |(`kBSEL_NDB    << `FIELD_SHIFT(`BSEL_BITS))
`define BSEL_DBD      |(`kBSEL_DBD    << `FIELD_SHIFT(`BSEL_BITS))
`define BSEL_P        |(`kBSEL_P      << `FIELD_SHIFT(`BSEL_BITS))

// 3:8 Decoder bit invert
`define BIT_INV_BITS  13:13

`define kBIT_INV      1
`define BIT_INV       |(`kBIT_INV     << `FIELD_SHIFT(`BIT_INV_BITS))

// ALU Carry input select
`define CSEL_BITS     15:14
`define kCSEL_0       0       // Forced to 0
`define kCSEL_1       1       // Forced to 1
`define kCSEL_P       2       // Carry from status register
`define kCSEL_D       3       // Delayed carry from previous ALU op

`define CSEL_0        |(`kCSEL_0      << `FIELD_SHIFT(`CSEL_BITS))
`define CSEL_1        |(`kCSEL_1      << `FIELD_SHIFT(`CSEL_BITS))
`define CSEL_P        |(`kCSEL_P      << `FIELD_SHIFT(`CSEL_BITS))
`define CSEL_D        |(`kCSEL_D      << `FIELD_SHIFT(`CSEL_BITS))

// Data bus output select
`define DBO_BITS      17:16
`define kDBO_ALU      0
`define kDBO_DREG     1
`define kDBO_DI       2
`define kDBO_PCHn     3

`define DBO_DI        |(`kDBO_DI      << `FIELD_SHIFT(`DBO_BITS))
`define DBO_DREG      |(`kDBO_DREG    << `FIELD_SHIFT(`DBO_BITS))
`define DBO_ALU       |(`kDBO_ALU     << `FIELD_SHIFT(`DBO_BITS))
`define DBO_PCHn      |(`kDBO_PCHn    << `FIELD_SHIFT(`DBO_BITS))

// ALU op
`define ALU_BITS      20:18
`define kALU_ORA      3'b000   // Default
`define kALU_ORA2     3'b001   // Default
`define kALU_AND      3'b010
`define kALU_EOR      3'b011

`define kALU_ADC      3'b100
`define kALU_SHL      3'b101   // Shift left (w/carry)
`define kALU_SHR      3'b110   // Shift right (w/carry)
`define kALU_ASR      3'b111   // Arithmetic shift right

`define ALU_ORA       |(`kALU_ORA     << `FIELD_SHIFT(`ALU_BITS))
`define ALU_ADC       |(`kALU_ADC     << `FIELD_SHIFT(`ALU_BITS))
`define ALU_AND       |(`kALU_AND     << `FIELD_SHIFT(`ALU_BITS))
`define ALU_EOR       |(`kALU_EOR     << `FIELD_SHIFT(`ALU_BITS))
`define ALU_SHR       |(`kALU_SHR     << `FIELD_SHIFT(`ALU_BITS))
`define ALU_ASR       |(`kALU_ASR     << `FIELD_SHIFT(`ALU_BITS))
`define ALU_SHL       |(`kALU_SHL     << `FIELD_SHIFT(`ALU_BITS))

// PC counter control
`define PC_INC_BITS   21:21
`define kPC_INC       1
`define PC_INC        |(`kPC_INC      << `FIELD_SHIFT(`PC_INC_BITS))

// PCHn source select.
`define PCH_BITS      23:22
`define kPCH_PCH      0           // +0 or +carry based on PC increment
`define kPCH_ADJ      1           // cond (ADJ) or (inc)
`define kPCH_ALU      2           // cond (ALU) or (inc)

`define PCH_PCH       |(`kPCH_PCH     << `FIELD_SHIFT(`PCH_BITS))
`define PCH_ADJ       |(`kPCH_ADJ     << `FIELD_SHIFT(`PCH_BITS))
`define PCH_ALU       |(`kPCH_ALU     << `FIELD_SHIFT(`PCH_BITS))

// PCLn source select
`define PCL_BITS      25:24
`define kPCL_PCL      0           // +0 or +1 based on PC increment
`define kPCL_ADL      1           // cond (ADL) or (inc)
`define kPCL_ALU      2           // cond (ALU) or (inc)

`define PCL_PCL       |(`kPCL_PCL     << `FIELD_SHIFT(`PCL_BITS))
`define PCL_ADL       |(`kPCL_ADL     << `FIELD_SHIFT(`PCL_BITS))
`define PCL_ALU       |(`kPCL_ALU     << `FIELD_SHIFT(`PCL_BITS))

// SPHn source select
`define SPH_SEL_BITS  26:26
`define kSPH_SPH      0
`define kSPH_ALU      1

`define SPH_SPH       |(`kSPH_SPH     << `FIELD_SHIFT(`SPH_SEL_BITS))
`define SPH_ALU       |(`kSPH_ALU     << `FIELD_SHIFT(`SPH_SEL_BITS))

// SP counter control
`define SP_CNT_BITS   28:27
`define kSP_INC       1
`define kSP_DEC       2

`define SP_INC        |(`kSP_INC      << `FIELD_SHIFT(`SP_CNT_BITS))
`define SP_DEC        |(`kSP_DEC      << `FIELD_SHIFT(`SP_CNT_BITS))

// SPLn source select 
`define SPL_SEL_BITS  29:29  
`define kSPL_SPL      0
`define kSPL_ALU      1

`define SPL_SPL       |(`kSPL_SPL     << `FIELD_SHIFT(`SPL_SEL_BITS))
`define SPL_ALU       |(`kSPL_ALU     << `FIELD_SHIFT(`SPL_SEL_BITS))

// AB counter control
`define AB_INC_BITS   30:30
`define kAB_INC       1

`define AB_INC        |(`kAB_INC      << `FIELD_SHIFT(`AB_INC_BITS))

// ABHn source select
`define ABH_SEL_BITS  52:51
`define kABH_ABH      0
`define kABH_B        1
`define kABH_ALU      2
`define kABH_VEC      3

`define ABH_ABH       |(`kABH_ABH     << `FIELD_SHIFT(`ABH_SEL_BITS))
`define ABH_B         |(`kABH_B       << `FIELD_SHIFT(`ABH_SEL_BITS))
`define ABH_ALU       |(`kABH_ALU     << `FIELD_SHIFT(`ABH_SEL_BITS))
`define ABH_VEC       |(`kABH_VEC     << `FIELD_SHIFT(`ABH_SEL_BITS))

// ABLn source select
`define ABL_SEL_BITS  33:33
`define kABL_ABL      0
`define kABL_ALU      1

`define ABL_ABL       |(`kABL_ABL     << `FIELD_SHIFT(`ABL_SEL_BITS))
`define ABL_ALU       |(`kABL_ALU     << `FIELD_SHIFT(`ABL_SEL_BITS))

// ADHn source select
`define ADH_SEL_BITS  34:34
`define kADH_ADH      0
`define kADH_ALU      1

`define ADH_ADH       |(`kADH_ADH     << `FIELD_SHIFT(`ADH_SEL_BITS))
`define ADH_ALU       |(`kADH_ALU     << `FIELD_SHIFT(`ADH_SEL_BITS))

// ADLn source select
`define ADL_SEL_BITS  35:35
`define kADL_ADL      0
`define kADL_ALU      1

`define ADL_ADL       |(`kADL_ADL     << `FIELD_SHIFT(`ADL_SEL_BITS))
`define ADL_ALU       |(`kADL_ALU     << `FIELD_SHIFT(`ADL_SEL_BITS))

// Decoded flag update
`define kLF_C_DB0     0
`define kLF_C_IR5     1
`define kLF_C_ACR     2
`define kLF_Z_SBZ     3
`define kLF_Z_DB1     4
`define kLF_I_DB2     5
`define kLF_I_IR5     6
`define kLF_D_DB3     7
`define kLF_D_IR5     8
`define kLF_V_DB6     9
`define kLF_V_AVR     10
`define kLF_V_0       11
`define kLF_N_SBN     12
`define kLF_N_DB7     13
`define kLF_I_1       14
`define kLF_E_IR0     15

`define LM_C_DB0      (1 << `kLF_C_DB0)
`define LM_C_IR5      (1 << `kLF_C_IR5)
`define LM_C_ACR      (1 << `kLF_C_ACR)
`define LM_Z_SBZ      (1 << `kLF_Z_SBZ)
`define LM_Z_DB1      (1 << `kLF_Z_DB1)
`define LM_I_DB2      (1 << `kLF_I_DB2)
`define LM_I_IR5      (1 << `kLF_I_IR5)
`define LM_D_DB3      (1 << `kLF_D_DB3)
`define LM_D_IR5      (1 << `kLF_D_IR5)
`define LM_V_DB6      (1 << `kLF_V_DB6)
`define LM_V_AVR      (1 << `kLF_V_AVR)
`define LM_V_0        (1 << `kLF_V_0  )
`define LM_N_SBN      (1 << `kLF_N_SBN)
`define LM_N_DB7      (1 << `kLF_N_DB7)
`define LM_I_1        (1 << `kLF_I_1  )
`define LM_E_IR0      (1 << `kLF_E_IR0)

// Encoded flag update field
`define LOAD_FLAGS_BITS   39:36
`define kFLAGS_DB     4'h1
`define kFLAGS_SBZN   4'h2
`define kFLAGS_ALU    4'h3
`define kFLAGS_D      4'h4
`define kFLAGS_I      4'h5
`define kFLAGS_C      4'h6
`define kFLAGS_V      4'h7
`define kFLAGS_SETI   4'h8
`define kFLAGS_CNZ    4'h9
`define kFLAGS_BIT    4'ha
`define kFLAGS_Z      4'hb
`define kFLAGS_E      4'hc

`define FLAGS_DB      |(`kFLAGS_DB    << `FIELD_SHIFT(`LOAD_FLAGS_BITS))
`define FLAGS_SBZN    |(`kFLAGS_SBZN  << `FIELD_SHIFT(`LOAD_FLAGS_BITS))
`define FLAGS_ALU     |(`kFLAGS_ALU   << `FIELD_SHIFT(`LOAD_FLAGS_BITS))
`define FLAGS_D       |(`kFLAGS_D     << `FIELD_SHIFT(`LOAD_FLAGS_BITS))
`define FLAGS_I       |(`kFLAGS_I     << `FIELD_SHIFT(`LOAD_FLAGS_BITS))
`define FLAGS_C       |(`kFLAGS_C     << `FIELD_SHIFT(`LOAD_FLAGS_BITS))
`define FLAGS_V       |(`kFLAGS_V     << `FIELD_SHIFT(`LOAD_FLAGS_BITS))
`define FLAGS_SETI    |(`kFLAGS_SETI  << `FIELD_SHIFT(`LOAD_FLAGS_BITS))
`define FLAGS_CNZ     |(`kFLAGS_CNZ   << `FIELD_SHIFT(`LOAD_FLAGS_BITS))
`define FLAGS_BIT     |(`kFLAGS_BIT   << `FIELD_SHIFT(`LOAD_FLAGS_BITS))
`define FLAGS_Z       |(`kFLAGS_Z     << `FIELD_SHIFT(`LOAD_FLAGS_BITS))
`define FLAGS_E       |(`kFLAGS_E     << `FIELD_SHIFT(`LOAD_FLAGS_BITS))

// Flags bit definitions
`define kPF_C        0
`define kPF_Z        1
`define kPF_I        2
`define kPF_D        3
`define kPF_B        4
`define kPF_E        5
`define kPF_V        6
`define kPF_N        7

// Encoded field to load register from ALU output
`define LOAD_REG_BITS   42:40

`define kLOAD_A      1
`define kLOAD_X      2
`define kLOAD_Y      3
`define kLOAD_Z      4
`define kLOAD_B      5
`define kLOAD_KILL   7    // Currently known bad value.

`define LOAD_A        |(`kLOAD_A      << `FIELD_SHIFT(`LOAD_REG_BITS))
`define LOAD_X        |(`kLOAD_X      << `FIELD_SHIFT(`LOAD_REG_BITS))
`define LOAD_Y        |(`kLOAD_Y      << `FIELD_SHIFT(`LOAD_REG_BITS))
`define LOAD_Z        |(`kLOAD_Z      << `FIELD_SHIFT(`LOAD_REG_BITS))
`define LOAD_B        |(`kLOAD_B      << `FIELD_SHIFT(`LOAD_REG_BITS))

// Decoded load bits
`define kLR_A        0
`define kLR_X        1
`define kLR_Y        2
`define kLR_Z        3
`define kLR_B        4

`define LR_A        (1 << `kLR_A)
`define LR_X        (1 << `kLR_X)
`define LR_Y        (1 << `kLR_Y)
`define LR_Z        (1 << `kLR_Z)
`define LR_B        (1 << `kLR_B)

// Flag test bit numbers (internal decoded)
`define kF_C        0
`define kF_Z        1
`define kF_N        2
`define kF_V        3
`define kF_B        4

// Flag test bit masks
`define kTF_C       (1 << `kF_C)
`define kTF_Z       (1 << `kF_Z)
`define kTF_N       (1 << `kF_N)
`define kTF_V       (1 << `kF_V)
`define kTF_B       (1 << `kF_B)

// Microcode test masks
`define TEST_FLAGS_BITS   47:43
`define TF_C        |(`kTF_C          << `FIELD_SHIFT(`TEST_FLAGS_BITS))
`define TF_Z        |(`kTF_Z          << `FIELD_SHIFT(`TEST_FLAGS_BITS))
`define TF_N        |(`kTF_N          << `FIELD_SHIFT(`TEST_FLAGS_BITS))
`define TF_V        |(`kTF_V          << `FIELD_SHIFT(`TEST_FLAGS_BITS))
`define TF_B        |(`kTF_B          << `FIELD_SHIFT(`TEST_FLAGS_BITS))

`define TEST_FLAG0_BITS   48:48
`define TEST_FLAG0  |(1               << `FIELD_SHIFT(`TEST_FLAG0_BITS))

`define WORD_Z_BITS       49:49
`define WORD_Z      |(1               << `FIELD_SHIFT(`WORD_Z_BITS))

`define WRITE_BITS        50:50
`define WRITE       |(1               << `FIELD_SHIFT(`WRITE_BITS))

`define MICROCODE_BITS    52:0

// TODO - Move all the microcode related `defines to a separate file that's not visible to the rest
// of the code, since it's supposed to be an implementation detail.

//`define Tn    3'd0        // Go to T+1 (default)
//`define T1    3'd1        // Go to T1 (sync)
//`define TKL   3'd3        // Halt CPU - Unimplemented microcode entry

`define MICROCODE(_ins, _t, _bits) mc[(_ins << 3) | _t] = 0 _bits;

`define BRK(_insbyte) \
`MICROCODE( _insbyte, 2, `AB_SPn `PC_INC  `DBO_PCHn            `WRITE           ) \
`MICROCODE( _insbyte, 3, `AB_SPn          `SP_DEC `AREG_PCL `ASEL_AREG `WRITE   ) \
`MICROCODE( _insbyte, 4, `AB_SPn          `SP_DEC `BSEL_P              `WRITE   ) \
`MICROCODE( _insbyte, 5, `AB_ABn `ABH_VEC `ABL_ALU `SP_DEC           `ASEL_VEC           ) \
`MICROCODE( _insbyte, 6, `AB_ABn `AB_INC  `BSEL_DB `PCL_ALU `FLAGS_SETI         ) \
`MICROCODE( _insbyte, 7, `AB_PCn          `BSEL_DB `PCH_ALU              `SYNC  ) \
`MICROCODE( _insbyte, 1, `AB_PCn `PC_INC                                        )

`define FLAG_OP(_insbyte, _flag) \
`MICROCODE( _insbyte,  1, `PC_INC _flag)

`define FLAG_OP2(_insbyte, _flag) \
`MICROCODE( _insbyte,  2, _flag `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define LDx(_insbyte, _t, _load, _i) \
`MICROCODE( _insbyte, _t, _i  `BSEL_DB _load `FLAGS_SBZN `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC )

`define LDA(_insbyte, _t, _inc) `LDx(_insbyte, _t, `LOAD_A, _inc)
`define LDX(_insbyte, _t, _inc) `LDx(_insbyte, _t, `LOAD_X, _inc)
`define LDY(_insbyte, _t, _inc) `LDx(_insbyte, _t, `LOAD_Y, _inc)
`define LDZ(_insbyte, _t, _inc) `LDx(_insbyte, _t, `LOAD_Z, _inc)

`define Txx(_insbyte, _args) \
`MICROCODE( _insbyte,  1, `PC_INC _args)

`define STx(_insbyte, _t) \
`MICROCODE( _insbyte, _t, `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define JMP(_insbyte) \
`MICROCODE( _insbyte,  2, `PC_INC `BSEL_DB `ADL_ALU) \
`MICROCODE( _insbyte,  3, `PC_INC `BSEL_DB `PCH_ALU `PCL_ADL `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define JMPIND(_insbyte) \
`MICROCODE( _insbyte,  2, `PC_INC `BSEL_DB `ADL_ALU) \
`MICROCODE( _insbyte,  3, `PC_INC `BSEL_DB `PCH_ALU `PCL_ADL) \
`MICROCODE( _insbyte,  4, `PC_INC `BSEL_DB `ADL_ALU) \
`MICROCODE( _insbyte,  5, `PC_INC `BSEL_DB `PCH_ALU `PCL_ADL `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define JMPINDX(_insbyte) \
`MICROCODE( _insbyte,  2, `PC_INC `ADL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB ) \
`MICROCODE( _insbyte,  3, `PC_INC `PCH_ALU `ALU_ADC `BSEL_DB `CSEL_D `PCL_ADL) \
`MICROCODE( _insbyte,  4, `PC_INC `BSEL_DB `ADL_ALU) \
`MICROCODE( _insbyte,  5, `PC_INC `BSEL_DB `PCH_ALU `PCL_ADL `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define Bcc(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 _args `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define BPL(_insbyte) `Bcc(_insbyte, `TF_N `TEST_FLAG0)
`define BMI(_insbyte) `Bcc(_insbyte, `TF_N)
`define BVC(_insbyte) `Bcc(_insbyte, `TF_V `TEST_FLAG0)
`define BVS(_insbyte) `Bcc(_insbyte, `TF_V)
`define BRA(_insbyte) `Bcc(_insbyte, |0)
`define BCC(_insbyte) `Bcc(_insbyte, `TF_C `TEST_FLAG0)
`define BCS(_insbyte) `Bcc(_insbyte, `TF_C)
`define BNE(_insbyte) `Bcc(_insbyte, `TF_Z `TEST_FLAG0)
`define BEQ(_insbyte) `Bcc(_insbyte, `TF_Z)

`define BccW(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `PC_INC `ADL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1) \
`MICROCODE( _insbyte,  3, `PC_INC `PCH_ALU `ALU_ADC `ASEL_AREG `AREG_PCH `BSEL_DB `CSEL_D `PCL_ADL _args `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define BPLW(_insbyte) `BccW(_insbyte, `TF_N `TEST_FLAG0)
`define BMIW(_insbyte) `BccW(_insbyte, `TF_N)
`define BVCW(_insbyte) `BccW(_insbyte, `TF_V `TEST_FLAG0)
`define BVSW(_insbyte) `BccW(_insbyte, `TF_V)
`define BRAW(_insbyte) `BccW(_insbyte, |0)
`define BCCW(_insbyte) `BccW(_insbyte, `TF_C `TEST_FLAG0)
`define BCSW(_insbyte) `BccW(_insbyte, `TF_C)
`define BNEW(_insbyte) `BccW(_insbyte, `TF_Z `TEST_FLAG0)
`define BEQW(_insbyte) `BccW(_insbyte, `TF_Z)

`define DEC_REG(_insbyte, _reg) \
`MICROCODE( _insbyte,  1, `PC_INC `ALU_ADC `BSEL_FF `FLAGS_SBZN _reg)

`define INC_REG(_insbyte, _reg) \
`MICROCODE( _insbyte,  1, `PC_INC `ALU_ADC `CSEL_1 `FLAGS_SBZN _reg)

`define CMP(_insbyte, _t, _inc) \
`MICROCODE( _insbyte, _t, `ALU_ADC `ASEL_DREG `DREG_A `BSEL_NDB `CSEL_1 `FLAGS_CNZ _inc `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define CPX(_insbyte, _t, _inc) \
`MICROCODE( _insbyte, _t, `ALU_ADC `ASEL_DREG `DREG_X `BSEL_NDB `CSEL_1 `FLAGS_CNZ _inc `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define CPY(_insbyte, _t, _inc) \
`MICROCODE( _insbyte, _t, `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_NDB `CSEL_1 `FLAGS_CNZ _inc `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define CPZ(_insbyte, _t, _inc) \
`MICROCODE( _insbyte, _t, `ALU_ADC `ASEL_DREG `DREG_Z `BSEL_NDB `CSEL_1 `FLAGS_CNZ _inc `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define ADC(_insbyte, _t, _inc) \
`MICROCODE( _insbyte, _t, `ALU_ADC `ASEL_DREG `DREG_A `BSEL_DB `CSEL_P `FLAGS_ALU `LOAD_A _inc `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define SBC(_insbyte, _t, _inc) \
`MICROCODE( _insbyte, _t, `ALU_ADC `ASEL_DREG `DREG_A `BSEL_NDB `CSEL_P `FLAGS_ALU `LOAD_A _inc `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define ORA(_insbyte, _t, _inc) \
`MICROCODE( _insbyte, _t, `ALU_ORA `ASEL_DREG `DREG_A `BSEL_DB `FLAGS_SBZN `LOAD_A _inc `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define AND(_insbyte, _t, _inc) \
`MICROCODE( _insbyte, _t, `ALU_AND `ASEL_DREG `DREG_A `BSEL_DB `FLAGS_SBZN `LOAD_A _inc `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define EOR(_insbyte, _t, _inc) \
`MICROCODE( _insbyte, _t, `ALU_EOR `ASEL_DREG `DREG_A `BSEL_DB `FLAGS_SBZN `LOAD_A _inc `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define BIT(_insbyte, _t, _flags) \
`MICROCODE( _insbyte, _t+0, `AB_ABn `BSEL_DB _flags) \
`MICROCODE( _insbyte, _t+1, `ALU_AND `ASEL_DREG `DREG_A `BSEL_DB `CSEL_0 `FLAGS_Z `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define BITIMM(_insbyte) \
`MICROCODE( _insbyte,  2, `PC_INC `ALU_AND `ASEL_DREG `DREG_A `BSEL_DB `CSEL_0 `FLAGS_Z `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define SHIFT_A(_insbyte, _args) \
`MICROCODE( _insbyte,  1, `PC_INC `ASEL_DREG `DREG_A `LOAD_A `FLAGS_CNZ _args) \

`define ASL_A(_insbyte) `SHIFT_A(_insbyte, `ALU_SHL `CSEL_0)
`define ROL_A(_insbyte) `SHIFT_A(_insbyte, `ALU_SHL `CSEL_P)
`define LSR_A(_insbyte) `SHIFT_A(_insbyte, `ALU_SHR `CSEL_0)
`define ROR_A(_insbyte) `SHIFT_A(_insbyte, `ALU_SHR `CSEL_P)

`define SHIFT_MEM(_insbyte, _t, _ab, _args) \
`MICROCODE( _insbyte, _t+0, _ab `ASEL_DB `FLAGS_CNZ _args `WRITE) \
`MICROCODE( _insbyte, _t+1, `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define ASL_MEM(_insbyte, _t, _ab) `SHIFT_MEM(_insbyte, _t, _ab, `ALU_SHL `CSEL_0)
`define ROL_MEM(_insbyte, _t, _ab) `SHIFT_MEM(_insbyte, _t, _ab, `ALU_SHL `CSEL_P)
`define LSR_MEM(_insbyte, _t, _ab) `SHIFT_MEM(_insbyte, _t, _ab, `ALU_SHR `CSEL_0)
`define ROR_MEM(_insbyte, _t, _ab) `SHIFT_MEM(_insbyte, _t, _ab, `ALU_SHR `CSEL_P)
`define ASR_MEM(_insbyte, _t, _ab) `SHIFT_MEM(_insbyte, _t, _ab, `ALU_ASR)

`define INC_MEM(_insbyte, _t, _ab) \
`MICROCODE( _insbyte, _t+0, _ab `ALU_ADC `BSEL_DB `CSEL_1 `FLAGS_SBZN `WRITE) \
`MICROCODE( _insbyte, _t+1, `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define DEC_MEM(_insbyte, _t, _ab) \
`MICROCODE( _insbyte, _t+0, _ab `ALU_ADC `ASEL_FF `BSEL_DB `CSEL_0 `FLAGS_SBZN `WRITE) \
`MICROCODE( _insbyte, _t+1, `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define NOP(_insbyte) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define PUSH(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `AB_SPn `WRITE _args) \
`MICROCODE( _insbyte,  3, `SP_DEC `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define PULL(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `AB_SPn `SP_INC) \
`MICROCODE( _insbyte,  3, _args `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define JSR(_insbyte) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_SPn `BSEL_DB `ADL_ALU `DBO_PCHn `WRITE) \
`MICROCODE( _insbyte,  3, `AB_SPn `SP_DEC `ASEL_AREG `AREG_PCL `WRITE) \
`MICROCODE( _insbyte,  4, `AB_PCn `SP_DEC) \
`MICROCODE( _insbyte,  5, `BSEL_DB `PCH_ALU `PCL_ADL `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

// Cycle 2 - Incrementing SP /reading low byte of PCL
// Cycle 3 - Fetching low byte of JSR PC to ADL, Incrementing SP to read high byte of PC
// Cycle 4 - Extra cycle to increment PC (dummy re-read of original JSR address high byte)
// Cycle 5/1 - Fetch next instruction
`define RTS(_insbyte) \
`MICROCODE( _insbyte,  2, `AB_SPn `SP_INC) \
`MICROCODE( _insbyte,  3, `AB_SPn `SP_INC `ALU_ADC `BSEL_DB `CSEL_1 `PCL_ALU) \
`MICROCODE( _insbyte,  4, `ALU_ADC `BSEL_DB `CSEL_D `PCH_ALU `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define RTI(_insbyte) \
`MICROCODE( _insbyte,  2, `AB_SPn `SP_INC) \
`MICROCODE( _insbyte,  3, `AB_SPn `SP_INC `FLAGS_DB) \
`MICROCODE( _insbyte,  4, `AB_SPn `SP_INC `ALU_ADC `BSEL_DB `CSEL_0 `PCL_ALU) \
`MICROCODE( _insbyte,  5, `ALU_ADC `BSEL_DB `CSEL_D `PCH_ALU `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define NEG(_insbyte) \
`MICROCODE( _insbyte,  2, `ALU_ADC `ASEL_NDREG `DREG_A `CSEL_1 `LOAD_A `FLAGS_SBZN `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define ASR_A(_insbyte) \
`MICROCODE( _insbyte,  2, `ALU_ASR `ASEL_DREG `DREG_A `LOAD_A `FLAGS_CNZ `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define BSR(_insbyte) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_SPn `ADL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `DBO_PCHn `WRITE) \
`MICROCODE( _insbyte,  3, `AB_SPn `SP_DEC `ASEL_AREG `AREG_PCL `WRITE) \
`MICROCODE( _insbyte,  4, `AB_PCn `SP_DEC) \
`MICROCODE( _insbyte,  5, `PCH_ALU `ALU_ADC `ASEL_AREG `AREG_PCH `BSEL_DB `CSEL_D `PCL_ADL `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define JSRIND(_insbyte) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_SPn `ABL_ALU `BSEL_DB `DBO_PCHn `WRITE) \
`MICROCODE( _insbyte,  3, `AB_SPn `SP_DEC `ASEL_AREG `AREG_PCL `WRITE) \
`MICROCODE( _insbyte,  4, `AB_PCn `SP_DEC) \
`MICROCODE( _insbyte,  5, `AB_ABn `ABH_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  6, `AB_ABn `AB_INC `PCL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  7, `AB_PCn `PCH_ALU `BSEL_DB `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define JSRINDX(_insbyte) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_SPn `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB `DBO_PCHn `WRITE) \
`MICROCODE( _insbyte,  3, `AB_SPn `SP_DEC `ASEL_AREG `AREG_PCL `WRITE) \
`MICROCODE( _insbyte,  4, `AB_PCn `SP_DEC) \
`MICROCODE( _insbyte,  5, `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DB `CSEL_D ) \
`MICROCODE( _insbyte,  6, `AB_ABn `AB_INC `PCL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  7, `AB_PCn `PCH_ALU `BSEL_DB `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define RTN(_insbyte) \
`MICROCODE( _insbyte,  2, `SP_INC `ABL_ALU `ASEL_AREG `AREG_PCL) \
`MICROCODE( _insbyte,  3, `AB_SPn `SP_INC `ABH_ALU `ASEL_AREG `AREG_PCH) \
`MICROCODE( _insbyte,  4, `AB_SPn `SP_INC `PCL_ALU `ALU_ADC `BSEL_DB `CSEL_1) \
`MICROCODE( _insbyte,  5, `AB_ABn `PCH_ALU `ALU_ADC `BSEL_DB `CSEL_D) \
`MICROCODE( _insbyte,  6, `AB_ABn `SPL_ALU `ALU_ADC `ASEL_AREG `AREG_SPL `BSEL_DB `CSEL_0) \
`MICROCODE( _insbyte,  7, `AB_PCn `SPH_ALU `ALU_ADC `ASEL_AREG `AREG_SPH `CSEL_D `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define INW(_insbyte) \
`MICROCODE( _insbyte,  2, `AB_ABn `PC_INC `ABH_B `ABL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  3, `AB_ABn `ALU_ADC `BSEL_DB `CSEL_1 `WRITE `FLAGS_SBZN) \
`MICROCODE( _insbyte,  4, `AB_ABn `AB_INC) \
`MICROCODE( _insbyte,  5, `AB_ABn `ALU_ADC `BSEL_DB `CSEL_D `WRITE `FLAGS_SBZN `WORD_Z) \
`MICROCODE( _insbyte,  6, `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define DEW(_insbyte) \
`MICROCODE( _insbyte,  2, `AB_ABn `PC_INC `ABH_B `ABL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  3, `AB_ABn `ALU_ADC `ASEL_FF `BSEL_DB `CSEL_0 `WRITE `FLAGS_SBZN) \
`MICROCODE( _insbyte,  4, `AB_ABn `AB_INC) \
`MICROCODE( _insbyte,  5, `AB_ABn `ALU_ADC `ASEL_FF `BSEL_DB `CSEL_D `WRITE `FLAGS_SBZN `WORD_Z) \
`MICROCODE( _insbyte,  6, `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define ASW(_insbyte) \
`MICROCODE( _insbyte,  2, `AB_PCn `PC_INC `ABL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  2, `AB_ABn `PC_INC `ABH_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  4, `AB_ABn `ALU_SHL `BSEL_DB `CSEL_0 `WRITE `FLAGS_CNZ) \
`MICROCODE( _insbyte,  5, `AB_ABn `AB_INC) \
`MICROCODE( _insbyte,  6, `AB_ABn `ALU_SHL `BSEL_DB `CSEL_P `WRITE `FLAGS_CNZ `WORD_Z) \
`MICROCODE( _insbyte,  7, `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define ROW(_insbyte) \
`MICROCODE( _insbyte,  2, `AB_PCn `PC_INC `ABL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  2, `AB_ABn `PC_INC `ABH_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  4, `AB_ABn `ALU_SHL `BSEL_DB `CSEL_P `WRITE `FLAGS_CNZ) \
`MICROCODE( _insbyte,  5, `AB_ABn `AB_INC) \
`MICROCODE( _insbyte,  6, `AB_ABn `ALU_SHL `BSEL_DB `CSEL_P `WRITE `FLAGS_CNZ `WORD_Z) \
`MICROCODE( _insbyte,  7, `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define PHWIMM(_insbyte) \
`MICROCODE( _insbyte,  2, `AB_SPn `PC_INC `DBO_DI `WRITE) \
`MICROCODE( _insbyte,  3, `AB_PCn `SP_DEC) \
`MICROCODE( _insbyte,  4, `AB_SPn `PC_INC `DBO_DI `WRITE) \
`MICROCODE( _insbyte,  5, `AB_PCn `SP_DEC `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define PHWABS(_insbyte) \
`MICROCODE( _insbyte,  2, `PC_INC `ABL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  3, `AB_ABn `ABH_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  4, `AB_SPn `AB_INC `DBO_DI) \
`MICROCODE( _insbyte,  5, `AB_ABn `SP_DEC) \
`MICROCODE( _insbyte,  6, `AB_SPn `DBO_DI) \
`MICROCODE( _insbyte,  7, `AB_PCn `SP_DEC `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

// I'm taking a wild guess that the 4510's mapper didn't involve major changes to the 65CE02 datapath, and
// instead was handled largely externally to the CPU core.  The only change that would have been needed
// to the CPU core would have been a microcode sequence that placed all of the required registers onto
// externally visible signals.  The "AUG" instruction from the original 65CE02 docs was spec'd to take
// 4 cycles but based on the original 65CE02 ROM contents doesn't really do anything interesting.  For now
// I'm going to just have the core place the 4 registers on the data bus in sequence and let the external
// mapper "sniff" the data bus.

// If/when I ever get my real C65 back it might be interesting to wire up a logic analyzer and see if
// anything interesting shows up on the external pins of the 4510 when its executing a map sequence.  It
// might shed some light on how it was done.

// The other thing that has to happen when a MAP instruction is encountered is that interrupts get disabled
// until a NOP is executed.  Again, I think this could have been done with external logic since if they
// were sniffing the instruction stream to detect MAP, also detecting a NOP would have been easy.

`define MAP(_insbyte) \
`MICROCODE( _insbyte,  2, `DBO_DREG `DREG_DO_A) \
`MICROCODE( _insbyte,  3, `DBO_DREG `DREG_DO_X) \
`MICROCODE( _insbyte,  4, `DBO_DREG `DREG_DO_Y) \
`MICROCODE( _insbyte,  5, `DBO_DREG `DREG_DO_Z `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define ADDR_abs_(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `PC_INC `ABL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  3, `PC_INC `AB_ABn `ABH_ALU `DBO_DREG `BSEL_DB _args)

`define ADDR_zp_(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB _args)

`define ADDR_abs_x_(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `PC_INC `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB) \
`MICROCODE( _insbyte,  3, `PC_INC `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG _args)

`define ADDR_abs_y_(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `PC_INC `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB) \
`MICROCODE( _insbyte,  3, `PC_INC `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG _args)

`define ADDR_zp_x_(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB `DBO_DREG _args)

`define ADDR_zp_y_(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB `DBO_DREG _args)

`define ADDR_zp_x_ind_(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB) \
`MICROCODE( _insbyte,  3, `AB_ABn `AB_INC `ADL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  4, `AB_ADn `ADH_ALU `BSEL_DB `DBO_DREG _args)

`define ADDR_zp_ind_y_(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB) \
`MICROCODE( _insbyte,  3, `AB_ABn `AB_INC `ADL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB) \
`MICROCODE( _insbyte,  4, `AB_ADn `ADH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG _args)

`define ADDR_zp_ind_z_(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB) \
`MICROCODE( _insbyte,  3, `AB_ABn `AB_INC `ADL_ALU `ALU_ADC `ASEL_DREG `DREG_Z `BSEL_DB) \
`MICROCODE( _insbyte,  4, `AB_ADn `ADH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG _args)

`define ADDR_sp_ind_y_(_insbyte, _args) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_AREG `AREG_SPL `BSEL_DB) \
`MICROCODE( _insbyte,  3, `AB_ABn `ABH_ALU `ALU_ADC `ASEL_AREG `AREG_SPH `CSEL_D) \
`MICROCODE( _insbyte,  4, `AB_ABn `AB_INC `ADL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB) \
`MICROCODE( _insbyte,  5, `AB_ADn `ADH_ALU `ALU_ADC `BSEL_DB `CSEL_D _args) \

`define ADDR_abs(_insbyte)                `ADDR_abs_(_insbyte, |0)
`define ADDR_abs_w(_insbyte, _args)       `ADDR_abs_(_insbyte, _args `WRITE)
`define ADDR_zp(_insbyte)                 `ADDR_zp_(_insbyte, |0)
`define ADDR_zp_w(_insbyte, _args)        `ADDR_zp_(_insbyte, _args `WRITE)
`define ADDR_abs_x(_insbyte)              `ADDR_abs_x_(_insbyte, |0)
`define ADDR_abs_x_w(_insbyte, _args)     `ADDR_abs_x_(_insbyte, _args `WRITE)
`define ADDR_abs_y(_insbyte)              `ADDR_abs_y_(_insbyte, |0)
`define ADDR_abs_y_w(_insbyte, _args)     `ADDR_abs_y_(_insbyte, _args `WRITE)
`define ADDR_zp_x(_insbyte)               `ADDR_zp_x_(_insbyte, |0)
`define ADDR_zp_x_w(_insbyte, _args)      `ADDR_zp_x_(_insbyte, _args `WRITE)
`define ADDR_zp_x_ind(_insbyte)           `ADDR_zp_x_ind_(_insbyte, |0)
`define ADDR_zp_x_ind_w(_insbyte, _args)  `ADDR_zp_x_ind_(_insbyte, _args `WRITE)
`define ADDR_zp_y(_insbyte)               `ADDR_zp_y_(_insbyte, |0)
`define ADDR_zp_y_w(_insbyte, _args)      `ADDR_zp_y_(_insbyte, _args `WRITE)
`define ADDR_zp_ind_y(_insbyte)           `ADDR_zp_ind_y_(_insbyte, |0)
`define ADDR_zp_ind_y_w(_insbyte, _args)  `ADDR_zp_ind_y_(_insbyte, _args `WRITE)
`define ADDR_zp_ind_z(_insbyte)           `ADDR_zp_ind_z_(_insbyte, |0)
`define ADDR_zp_ind_z_w(_insbyte, _args)  `ADDR_zp_ind_z_(_insbyte, _args `WRITE)
`define ADDR_sp_ind_y(_insbyte)           `ADDR_sp_ind_y_(_insbyte, |0)
`define ADDR_sp_ind_y_w(_insbyte, _args)  `ADDR_sp_ind_y_(_insbyte, _args `WRITE)

// BBx
`define BBR(_insbyte) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_ABn `ABH_B `ABL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  3, `ALU_AND `ASEL_NDB `BSEL_BIT) \
`MICROCODE( _insbyte,  4, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_B `TEST_FLAG0 `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define BBS(_insbyte) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_ABn `ABH_B `ABL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  3, `ALU_AND `ASEL_DB `BSEL_BIT) \
`MICROCODE( _insbyte,  4, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_B `TEST_FLAG0 `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define TRB(_insbyte, _t) \
`MICROCODE( _insbyte, _t+0, `AB_ABn `ALU_AND `ASEL_NDREG `DREG_A `BSEL_DB `WRITE) \
`MICROCODE( _insbyte, _t+1, `ALU_AND `ASEL_DREG `DREG_A `BSEL_DBD `FLAGS_Z `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define TSB(_insbyte, _t) \
`MICROCODE( _insbyte, _t+0, `AB_ABn `ALU_ORA `ASEL_DREG `DREG_A `BSEL_DB `WRITE) \
`MICROCODE( _insbyte, _t+1, `ALU_AND `ASEL_DREG `DREG_A `BSEL_DBD `FLAGS_Z `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define RMB(_insbyte) \
`MICROCODE( _insbyte, 3, `AB_ABn `ALU_AND `ASEL_DB `BSEL_BIT `BIT_INV `WRITE) \
`MICROCODE( _insbyte, 4, `SYNC) \
`MICROCODE( _insbyte, 1, `PC_INC)

`define SMB(_insbyte) \
`MICROCODE( _insbyte, 3, `AB_ABn `ALU_ORA `ASEL_DB `BSEL_BIT `WRITE) \
`MICROCODE( _insbyte, 4, `SYNC) \
`MICROCODE( _insbyte, 1, `PC_INC)

`endif //_6502_inc_vh_
