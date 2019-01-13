/* 
** Copyright (c) 2018 Kenneth C. Dyke
** 
** Permission is hereby granted, free of charge, to any person obtaining a copy
** of this software and associated documentation files (the "Software"), to deal
** in the Software without restriction, including without limitation the rights
** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
** copies of the Software, and to permit persons to whom the Software is
** furnished to do so, subject to the following conditions:
** 
** The above copyright notice and this permission notice shall be included in all
** copies or substantial portions of the Software.
** 
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
** SOFTWARE.
*/

`ifdef _6052_inc_vh_
//error
`endif

`ifndef _65ce02_inc_vh_
`define _65ce02_inc_vh_

// For when I want to synthesize and keep the full internal hierarchy
//`define SCHEM_KEEP 1
`ifdef SCHEM_KEEP
`define SCHEM_KEEP_HIER (* keep_hierarchy = "yes" *)
`else
`undef SCHEM_KEEP_HIER
`define SCHEM_KEEP_HIER
`endif

// Macros to rename all CPU core sub modules to avoid conflicts in other projects
`define microcode           microcode_65ce02
`define reg_decode          reg_decode_65ce02
`define flags_decode        flags_decode_65ce02
`define cond_control        cond_control_65ce02
`define ir_next_mux         ir_next_mux_65ce02
`define dreg_mux            dreg_mux_65ce02
`define dbi_mux             dbi_mux_65ce02
`define dbo_mux             dbo_mux_65ce02  
`define predecode           predecode_65ce02
`define interrupt_control   interrupt_control_65ce02
`define timing_ctrl         tming_ctrl_65ce02
`define addrbus_mux         addrbus_mux_65ce02
`define alu_unit            alu_unit_65ce02
`define ea_adder            ea_adder_65ce02
`define ab_reg              ab_reg_65ce02
`define ad_reg              ad_reg_65ce02
`define pc_reg              pc_reg_65ce02
`define sp_reg              sp_reg_65ce02
`define sp_sel_mux          sp_sel_mux_65ce02
`define dreg_mux            dreg_mux_65ce02
`define areg_mux            areg_mux_65ce02
`define alua_mux            alua_mux_65ce02
`define alub_mux            alub_mux_65ce02
`define aluc_mux            aluc_mux_65ce02
`define clocked_reg8        clocked_reg8_65ce02
`define clocked_reset_reg8  clocked_reset_reg8_65ce02
`define z_unit              z_unit_65ce02
`define p_reg               p_reg_65ce02
`define decoder3to8         decoder3to8_65ce02
`define decadj_half_adder   decadj_half_adder_65ce02
`define alu_half_adder      alu_half_adder_65ce02
`define alu_adder           alu_adder_65ce02

// Magic macro to extract field shift from field definition macro using ternary operator
`define FIELD_SHIFT(_x) (0?_x)

// Block RAMs are either 18 or 36 bits wide, so it's also useful to make sure those last 4 bits
// are grouped together.  Although for Artix-7 the synthesis tools really wind up generating 3
// 2K x 18bit block RAMs.  So the bit groupings really wind up being 3 groups of 18 bits.

`define kSYNC_BITS     0:0

// What's driving the address bus
`define kAB_BITS       2:1

`define kAB_PCn       0
`define kAB_ABn       1
`define kAB_ADn       2
`define kAB_SPn       3

// ALU A select
`define kASEL_BITS     5:3

`define kASEL_0       0
`define kASEL_AREG    1
`define kASEL_DREG    2
`define kASEL_VEC     3
`define kASEL_FF      4
`define kASEL_DB      5
`define kASEL_NDREG   6
`define kASEL_NDB     7

// ALU D reg select
`define kDREG_BITS     7:6

`define kDREG_A       0
`define kDREG_X       1
`define kDREG_Y       2
`define kDREG_Z       3

`define kDREG_DO_BITS  32:31

// ALU A reg select

// Note: We don't really need both AREG and DREG fields since the ASEL mux can only source from one or the other,
// and so we could share the two select bits between the AREG and DREG muxes if we ever get really desperate for
// more microcode bits and would like to potentially save routing resources.
`define kAREG_BITS     9:8

`define kAREG_SPL     2'b00
`define kAREG_SPH     2'b01
`define kAREG_PCL     2'b10
`define kAREG_PCH     2'b11

// ALU_B input select
`define kBSEL_BITS     12:10
`define kBSEL_0       0
`define kBSEL_FF      1
`define kBSEL_DB      2
`define kBSEL_NDB     3
`define kBSEL_BIT     4
`define kBSEL_DBD     5
`define kBSEL_B       6
`define kBSEL_P       7

// 3:8 Decoder bit invert
`define kBIT_INV_BITS  13:13

`define kBIT_INV      1

// ALU Carry input select
`define kCSEL_BITS     15:14
`define kCSEL_0       0       // Forced to 0
`define kCSEL_1       1       // Forced to 1
`define kCSEL_P       2       // Carry from status register
`define kCSEL_D       3       // Delayed carry from previous ALU op

// Data bus output select
`define kDBO_BITS      17:16
`define kDBO_ALU      0
`define kDBO_DREG     1
`define kDBO_DI       2
`define kDBO_PCHn     3


// ALU op
`define kALU_BITS      20:18
`define kALU_ORA      3'b000   // Default
`define kALU_ORA2     3'b001   // Default
`define kALU_AND      3'b010
`define kALU_EOR      3'b011

`define kALU_ADC      3'b100
`define kALU_SHL      3'b101   // Shift left (w/carry)
`define kALU_SHR      3'b110   // Shift right (w/carry)
`define kALU_ASR      3'b111   // Arithmetic shift right

// PC counter control
`define kPC_INC_BITS   21:21
`define kPC_INC       1

// PCHn source select.
`define kPCH_BITS      23:22
`define kPCH_PCH      0           // +0 or +carry based on PC increment
`define kPCH_ADJ      1           // cond (ADJ) or (inc)
`define kPCH_ALU      2           // cond (ALU) or (inc)

// PCLn source select
`define kPCL_BITS      25:24
`define kPCL_PCL      0           // +0 or +1 based on PC increment
`define kPCL_ADL      1           // cond (ADL) or (inc)
`define kPCL_ALU      2           // cond (ALU) or (inc)

// SPHn source select
`define kSPH_SEL_BITS  26:26
`define kSPH_SPH      0
`define kSPH_ALU      1

// SP counter control
`define kSP_CNT_BITS   28:27
`define kSP_INC       1
`define kSP_DEC       2

// SPLn source select 
`define kSPL_SEL_BITS  29:29  
`define kSPL_SPL      0
`define kSPL_ALU      1

// AB counter control
`define kAB_INC_BITS   30:30
`define kAB_INC       1

// ABHn source select
`define kABH_SEL_BITS  52:51
`define kABH_ABH      0
`define kABH_B        1
`define kABH_ALU      2
`define kABH_VEC      3

// ABLn source select
`define kABL_SEL_BITS  33:33
`define kABL_ABL      0
`define kABL_ALU      1

// ADHn source select
`define kADH_SEL_BITS  34:34
`define kADH_ADH      0
`define kADH_ALU      1

// ADLn source select
`define kADL_SEL_BITS  35:35
`define kADL_ADL      0
`define kADL_ALU      1

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
`define kLF_E_RTI     16

`define kLM_C_DB0      (1 << `kLF_C_DB0)
`define kLM_C_IR5      (1 << `kLF_C_IR5)
`define kLM_C_ACR      (1 << `kLF_C_ACR)
`define kLM_Z_SBZ      (1 << `kLF_Z_SBZ)
`define kLM_Z_DB1      (1 << `kLF_Z_DB1)
`define kLM_I_DB2      (1 << `kLF_I_DB2)
`define kLM_I_IR5      (1 << `kLF_I_IR5)
`define kLM_D_DB3      (1 << `kLF_D_DB3)
`define kLM_D_IR5      (1 << `kLF_D_IR5)
`define kLM_V_DB6      (1 << `kLF_V_DB6)
`define kLM_V_AVR      (1 << `kLF_V_AVR)
`define kLM_V_0        (1 << `kLF_V_0  )
`define kLM_N_SBN      (1 << `kLF_N_SBN)
`define kLM_N_DB7      (1 << `kLF_N_DB7)
`define kLM_I_1        (1 << `kLF_I_1  )
`define kLM_E_IR0      (1 << `kLF_E_IR0)
`define kLM_E_RTI      (1 << `kLF_E_RTI)

// Encoded flag update field
`define kLOAD_FLAGS_BITS   39:36
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
`define kFLAGS_RTI    4'hd

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
`define kLOAD_REG_BITS   42:40

`define kLOAD_A      1
`define kLOAD_X      2
`define kLOAD_Y      3
`define kLOAD_Z      4
`define kLOAD_B      5
`define kLOAD_KILL   7    // Currently known bad value.

// Decoded load bits
`define kLR_A        0
`define kLR_X        1
`define kLR_Y        2
`define kLR_Z        3
`define kLR_B        4

`define kLM_A        (1 << `kLR_A)
`define kLM_X        (1 << `kLR_X)
`define kLM_Y        (1 << `kLR_Y)
`define kLM_Z        (1 << `kLR_Z)
`define kLM_B        (1 << `kLR_B)

// Flag test bit numbers (internal decoded)
`define kF_C        0
`define kF_Z        1
`define kF_N        2
`define kF_V        3
`define kF_B        4

// Flag test bit masks - could be done as a 3-bit bitfield + decoder to save two more microcode bits.
`define kTF_C       (1 << `kF_C)
`define kTF_Z       (1 << `kF_Z)
`define kTF_N       (1 << `kF_N)
`define kTF_V       (1 << `kF_V)
`define kTF_B       (1 << `kF_B)

`define kNEXT_UC      0
`define kNEXT_A0      1
`define kNEXT_A1      2
`define kNEXT_CC      3

// Microcode test masks
`define kTEST_FLAGS_BITS   47:43

`define kTEST_FLAG0_BITS   48:48

`define kWORD_Z_BITS       49:49

`define kWRITE_BITS        50:50

`define kMAP_BITS          53:53

`define kNEXT_ADDR_BITS    62:54          // Currently 9 bits of microcode address

`define kNEXT_ADDR_SEL_BITS 64:63

`define kNEXT_COND_BITS     67:65

`define kNEXT_COND_BRANCH   1               // 8-bit branch condition met, go to ucode+1
`define kNEXT_COND_BPC      2               // 8-bit branch page crossing, go to ucode+1
`define kNEXT_COND_LC       3               // If slow & last ALU carry out, go to ucode+1

`define kMICROCODE_BITS    67:0

`endif //_65ce02_inc_vh_
