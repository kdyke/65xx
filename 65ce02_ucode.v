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

`include "65ce02_inc.vh"

(* keep_hierarchy = "yes" *) module `microcode(
                input clk,
                input reset,
                input ready,
                input slow,
                input [7:0] ir,
                input [8:0] next_mca,
                // It's not clear yet that anything outside will actually 
                // need these yet, but it might be useful for debugging.
                output [8:0] next_mca_ucode,
                output reg [8:0] next_mca_a0,
                output reg [8:0] next_mca_a1,
                output [1:0] next_mca_sel,
                output mc_sync,
                output [2:0] alua_sel,
                output [2:0] alub_sel,
                output bit_inv,
                output [1:0] aluc_sel,
                output [1:0] dreg,
                output [1:0] dreg_do,
                output [1:0] areg,
                output [2:0] alu_sel,
                output [1:0] dbo_sel,
                output [1:0] ab_sel,
                output pc_inc,
                output [1:0] pch_sel,
                output [1:0] pcl_sel,
                output [1:0] sp_incdec,
                output sph_sel,
                output spl_sel,
                output ab_inc,
                output [1:0] abh_sel,
                output abl_sel,
                output adh_sel,
                output adl_sel,
                output [2:0] load_reg, 
                output [3:0] load_flags,
                output [4:0] test_flags,
                output test_flag0,
                output word_z,
                output write,
                output map,
                output [2:0] mc_cond);

`define SYNC          |(1 << `FIELD_SHIFT(`kSYNC_BITS))

`define AB_PCn        |(`kAB_PCn      << `FIELD_SHIFT(`kAB_BITS))
`define AB_ABn        |(`kAB_ABn      << `FIELD_SHIFT(`kAB_BITS))
`define AB_ADn        |(`kAB_ADn      << `FIELD_SHIFT(`kAB_BITS))
`define AB_SPn        |(`kAB_SPn      << `FIELD_SHIFT(`kAB_BITS))

`define ASEL_0        |(`kASEL_0      << `FIELD_SHIFT(`kASEL_BITS))
`define ASEL_AREG     |(`kASEL_AREG   << `FIELD_SHIFT(`kASEL_BITS))
`define ASEL_DREG     |(`kASEL_DREG   << `FIELD_SHIFT(`kASEL_BITS))
`define ASEL_VEC      |(`kASEL_VEC    << `FIELD_SHIFT(`kASEL_BITS))
`define ASEL_FF       |(`kASEL_FF     << `FIELD_SHIFT(`kASEL_BITS))
`define ASEL_DB       |(`kASEL_DB     << `FIELD_SHIFT(`kASEL_BITS))
`define ASEL_NDREG    |(`kASEL_NDREG  << `FIELD_SHIFT(`kASEL_BITS))
`define ASEL_NDB      |(`kASEL_NDB    << `FIELD_SHIFT(`kASEL_BITS))

`define DREG_A        |(`kDREG_A      << `FIELD_SHIFT(`kDREG_BITS))
`define DREG_X        |(`kDREG_X      << `FIELD_SHIFT(`kDREG_BITS))
`define DREG_Y        |(`kDREG_Y      << `FIELD_SHIFT(`kDREG_BITS))
`define DREG_Z        |(`kDREG_Z      << `FIELD_SHIFT(`kDREG_BITS))

`define DREG_DO_A        |(`kDREG_A      << `FIELD_SHIFT(`kDREG_DO_BITS))
`define DREG_DO_X        |(`kDREG_X      << `FIELD_SHIFT(`kDREG_DO_BITS))
`define DREG_DO_Y        |(`kDREG_Y      << `FIELD_SHIFT(`kDREG_DO_BITS))
`define DREG_DO_Z        |(`kDREG_Z      << `FIELD_SHIFT(`kDREG_DO_BITS))

`define AREG_SPL      |(`kAREG_SPL    << `FIELD_SHIFT(`kAREG_BITS))
`define AREG_SPH      |(`kAREG_SPH    << `FIELD_SHIFT(`kAREG_BITS))
`define AREG_PCL      |(`kAREG_PCL    << `FIELD_SHIFT(`kAREG_BITS))
`define AREG_PCH      |(`kAREG_PCH    << `FIELD_SHIFT(`kAREG_BITS))

`define BSEL_0        |(`kBSEL_0      << `FIELD_SHIFT(`kBSEL_BITS))
`define BSEL_DB       |(`kBSEL_DB     << `FIELD_SHIFT(`kBSEL_BITS))
`define BSEL_BIT      |(`kBSEL_BIT    << `FIELD_SHIFT(`kBSEL_BITS))
`define BSEL_B        |(`kBSEL_B      << `FIELD_SHIFT(`kBSEL_BITS))
`define BSEL_FF       |(`kBSEL_FF     << `FIELD_SHIFT(`kBSEL_BITS))
`define BSEL_NDB      |(`kBSEL_NDB    << `FIELD_SHIFT(`kBSEL_BITS))
`define BSEL_DBD      |(`kBSEL_DBD    << `FIELD_SHIFT(`kBSEL_BITS))
`define BSEL_P        |(`kBSEL_P      << `FIELD_SHIFT(`kBSEL_BITS))

`define BIT_INV       |(`kBIT_INV     << `FIELD_SHIFT(`kBIT_INV_BITS))

`define CSEL_0        |(`kCSEL_0      << `FIELD_SHIFT(`kCSEL_BITS))
`define CSEL_1        |(`kCSEL_1      << `FIELD_SHIFT(`kCSEL_BITS))
`define CSEL_P        |(`kCSEL_P      << `FIELD_SHIFT(`kCSEL_BITS))
`define CSEL_D        |(`kCSEL_D      << `FIELD_SHIFT(`kCSEL_BITS))

`define DBO_DI        |(`kDBO_DI      << `FIELD_SHIFT(`kDBO_BITS))
`define DBO_DREG      |(`kDBO_DREG    << `FIELD_SHIFT(`kDBO_BITS))
`define DBO_ALU       |(`kDBO_ALU     << `FIELD_SHIFT(`kDBO_BITS))
`define DBO_PCHn      |(`kDBO_PCHn    << `FIELD_SHIFT(`kDBO_BITS))

`undef ALU_ORA
`undef ALU_ADC
`undef ALU_AND
`undef ALU_EOR
`undef ALU_SHR
`undef ALU_ASR
`undef ALU_SHL

`define ALU_ORA       |(`kALU_ORA     << `FIELD_SHIFT(`kALU_BITS))
`define ALU_ADC       |(`kALU_ADC     << `FIELD_SHIFT(`kALU_BITS))
`define ALU_AND       |(`kALU_AND     << `FIELD_SHIFT(`kALU_BITS))
`define ALU_EOR       |(`kALU_EOR     << `FIELD_SHIFT(`kALU_BITS))
`define ALU_SHR       |(`kALU_SHR     << `FIELD_SHIFT(`kALU_BITS))
`define ALU_ASR       |(`kALU_ASR     << `FIELD_SHIFT(`kALU_BITS))
`define ALU_SHL       |(`kALU_SHL     << `FIELD_SHIFT(`kALU_BITS))

`define PC_INC        |(`kPC_INC      << `FIELD_SHIFT(`kPC_INC_BITS))

`define PCH_PCH       |(`kPCH_PCH     << `FIELD_SHIFT(`kPCH_BITS))
`define PCH_ADJ       |(`kPCH_ADJ     << `FIELD_SHIFT(`kPCH_BITS))
`define PCH_ALU       |(`kPCH_ALU     << `FIELD_SHIFT(`kPCH_BITS))

`define PCL_PCL       |(`kPCL_PCL     << `FIELD_SHIFT(`kPCL_BITS))
`define PCL_ADL       |(`kPCL_ADL     << `FIELD_SHIFT(`kPCL_BITS))
`define PCL_ALU       |(`kPCL_ALU     << `FIELD_SHIFT(`kPCL_BITS))

`define SPH_SPH       |(`kSPH_SPH     << `FIELD_SHIFT(`kSPH_SEL_BITS))
`define SPH_ALU       |(`kSPH_ALU     << `FIELD_SHIFT(`kSPH_SEL_BITS))

`define SP_INC        |(`kSP_INC      << `FIELD_SHIFT(`kSP_CNT_BITS))
`define SP_DEC        |(`kSP_DEC      << `FIELD_SHIFT(`kSP_CNT_BITS))

`define SPL_SPL       |(`kSPL_SPL     << `FIELD_SHIFT(`kSPL_SEL_BITS))
`define SPL_ALU       |(`kSPL_ALU     << `FIELD_SHIFT(`kSPL_SEL_BITS))

`define AB_INC        |(`kAB_INC      << `FIELD_SHIFT(`kAB_INC_BITS))

`define ABH_ABH       |(`kABH_ABH     << `FIELD_SHIFT(`kABH_SEL_BITS))
`define ABH_B         |(`kABH_B       << `FIELD_SHIFT(`kABH_SEL_BITS))
`define ABH_ALU       |(`kABH_ALU     << `FIELD_SHIFT(`kABH_SEL_BITS))
`define ABH_VEC       |(`kABH_VEC     << `FIELD_SHIFT(`kABH_SEL_BITS))

`define ABL_ABL       |(`kABL_ABL     << `FIELD_SHIFT(`kABL_SEL_BITS))
`define ABL_ALU       |(`kABL_ALU     << `FIELD_SHIFT(`kABL_SEL_BITS))

`undef ADH_ADH
`undef ADH_ALU

`define ADH_ADH       |(`kADH_ADH     << `FIELD_SHIFT(`kADH_SEL_BITS))
`define ADH_ALU       |(`kADH_ALU     << `FIELD_SHIFT(`kADH_SEL_BITS))

`undef ADL_ADL
`undef ADL_ALU

`define ADL_ADL       |(`kADL_ADL     << `FIELD_SHIFT(`kADL_SEL_BITS))
`define ADL_ALU       |(`kADL_ALU     << `FIELD_SHIFT(`kADL_SEL_BITS))

`undef FLAGS_DB      
`undef FLAGS_SBZN    
`undef FLAGS_ALU     
`undef FLAGS_D       
`undef FLAGS_I       
`undef FLAGS_C       
`undef FLAGS_V       
`undef FLAGS_SETI    
`undef FLAGS_CNZ     
`undef FLAGS_BIT     
`undef FLAGS_Z       
`undef FLAGS_E       
`undef FLAGS_RTI     

`define FLAGS_DB      |(`kFLAGS_DB    << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))
`define FLAGS_SBZN    |(`kFLAGS_SBZN  << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))
`define FLAGS_ALU     |(`kFLAGS_ALU   << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))
`define FLAGS_D       |(`kFLAGS_D     << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))
`define FLAGS_I       |(`kFLAGS_I     << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))
`define FLAGS_C       |(`kFLAGS_C     << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))
`define FLAGS_V       |(`kFLAGS_V     << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))
`define FLAGS_SETI    |(`kFLAGS_SETI  << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))
`define FLAGS_CNZ     |(`kFLAGS_CNZ   << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))
`define FLAGS_BIT     |(`kFLAGS_BIT   << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))
`define FLAGS_Z       |(`kFLAGS_Z     << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))
`define FLAGS_E       |(`kFLAGS_E     << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))
`define FLAGS_RTI     |(`kFLAGS_RTI   << `FIELD_SHIFT(`kLOAD_FLAGS_BITS))

`undef LOAD_A
`undef LOAD_X
`undef LOAD_Y
`undef LOAD_Z
`undef LOAD_B

`define LOAD_A        |(`kLOAD_A      << `FIELD_SHIFT(`kLOAD_REG_BITS))
`define LOAD_X        |(`kLOAD_X      << `FIELD_SHIFT(`kLOAD_REG_BITS))
`define LOAD_Y        |(`kLOAD_Y      << `FIELD_SHIFT(`kLOAD_REG_BITS))
`define LOAD_Z        |(`kLOAD_Z      << `FIELD_SHIFT(`kLOAD_REG_BITS))
`define LOAD_B        |(`kLOAD_B      << `FIELD_SHIFT(`kLOAD_REG_BITS))

`define TF_C        |(`kTF_C          << `FIELD_SHIFT(`kTEST_FLAGS_BITS))
`define TF_Z        |(`kTF_Z          << `FIELD_SHIFT(`kTEST_FLAGS_BITS))
`define TF_N        |(`kTF_N          << `FIELD_SHIFT(`kTEST_FLAGS_BITS))
`define TF_V        |(`kTF_V          << `FIELD_SHIFT(`kTEST_FLAGS_BITS))
`define TF_B        |(`kTF_B          << `FIELD_SHIFT(`kTEST_FLAGS_BITS))

`define TEST_FLAG0  |(1               << `FIELD_SHIFT(`kTEST_FLAG0_BITS))
`define WORD_Z      |(1               << `FIELD_SHIFT(`kWORD_Z_BITS))
`define WRITE       |(1               << `FIELD_SHIFT(`kWRITE_BITS))
`define MC_MAP      |(1               << `FIELD_SHIFT(`kMAP_BITS))

`define NEXT_UCODE  |(`kNEXT_UC               << `FIELD_SHIFT(`kNEXT_ADDR_SEL_BITS))    // Default
`define NEXT_A0     |(`kNEXT_A0               << `FIELD_SHIFT(`kNEXT_ADDR_SEL_BITS))    // Basically SYNC
`define NEXT_A1     |(`kNEXT_A1               << `FIELD_SHIFT(`kNEXT_ADDR_SEL_BITS))    // "Execution" phase after addressing
`define NEXT_CC     |(`kNEXT_CC               << `FIELD_SHIFT(`kNEXT_ADDR_SEL_BITS))    // "Execution" phase after addressing

`define NEXT_COND_BRANCH   |(`kNEXT_COND_BRANCH <<  `FIELD_SHIFT(`kNEXT_COND_BITS))
`define NEXT_COND_BPC      |(`kNEXT_COND_BPC    <<  `FIELD_SHIFT(`kNEXT_COND_BITS))
`define NEXT_COND_LC       |(`kNEXT_COND_LC     <<  `FIELD_SHIFT(`kNEXT_COND_BITS))

// TODO - Move all the microcode related `defines to a separate file that's not visible to the rest
// of the code, since it's supposed to be an implementation detail.

//`define Tn    3'd0        // Go to T+1 (default)
//`define T1    3'd1        // Go to T1 (sync)
//`define TKL   3'd3        // Halt CPU - Unimplemented microcode entry

// Microcode addresses in block RAM.
`include "ucode_addr.vh"

reg [8:0] a0_addr[0:511];
reg [8:0] a1_addr[0:511];
            
reg [`kMICROCODE_BITS] mc_out;

(* rom_style = "block" *) reg [`kMICROCODE_BITS] mc[0:kMCA_end-1];

`define MICROCODE(_ucodeaddr, _nextaddr, _bits) mc[_ucodeaddr] = 0 _bits | (_nextaddr << `FIELD_SHIFT(`kNEXT_ADDR_BITS));

// synthesis translate off
reg [12:0] i;
// synthesis translate on

initial begin

// synthesis translate off
// Init all microcode slots we haven't implemented with a state that halts
for( i = 0; i < kMCA_end; i = i + 1 )
begin
   mc[i][`kLOAD_REG_BITS] = `kLOAD_KILL;
end
// synthesis translate on

`MICROCODE( kMCA_e_fetch0, 0, `PC_INC)

// General notes on microcode
//
// In some cases it was straightforward to emulate 6502 timings by just adding some conditional cases, such as taken branches,
// branch page crossings, or page cross boundaries for abs,x addressing modes, etc.   In those cases the 4510 and 6502 sequences
// are able to share some of the same microcode sequences.

// In other cases though where the contents of the bus cycles are more critical in nature (particularly the read/modify/write
// cases), there's a completely different sequence that gets executed to emulate exactly what the 6502 would have placed on the
// bus at each cycle.

// And for some really simplistic cases, I could get what I wanted by just adding an extra "dead" cycle at the beginning of
// the instruction by internally holding ready low for the cycle right after a fetch.  This made dealing with the 4510's single-cycle
// cases easier because I didn't have to mess with how the single cycle prefetch handling worked and could maintain the semantic
// that the 4510 single cycle instructions can't be interrupted so that MAP sequences don't get interrupted.   Another option here
// would be to allow those instructions to recognize interrupts so long as we aren't inside a MAP sequence.  This could be done
// if somehow this winds up messing with 6502 software too much (by delaying interrupts longer than they might have been otherwise).

// BRK
`MICROCODE( kMCA_e_brk0, kMCA_e_brk1, `AB_SPn `PC_INC  `DBO_PCHn                    `WRITE   )
`MICROCODE( kMCA_e_brk1, kMCA_e_brk2, `AB_SPn          `SP_DEC `AREG_PCL `ASEL_AREG `WRITE   )
`MICROCODE( kMCA_e_brk2, kMCA_e_brk3, `AB_SPn          `SP_DEC `BSEL_P              `WRITE   )
`MICROCODE( kMCA_e_brk3, kMCA_e_brk4, `AB_ABn `ABH_VEC `ABL_ALU `SP_DEC  `ASEL_VEC           )
`MICROCODE( kMCA_e_brk4, kMCA_e_brk5, `AB_ABn `AB_INC  `ADL_ALU `BSEL_DB `FLAGS_SETI         )
`MICROCODE( kMCA_e_brk5, kMCA_e_fetch0, `AB_PCn        `BSEL_DB `PCH_ALU `PCL_ADL `SYNC      )

// Single cycle instructions - implicit SYNC
`MICROCODE( kMCA_e_clcsec0, 0, `PC_INC `FLAGS_C)
`MICROCODE( kMCA_e_cli0,    0, `PC_INC `FLAGS_I)
`MICROCODE( kMCA_e_clv0,    0, `PC_INC `FLAGS_V)
`MICROCODE( kMCA_e_cldsed0, 0, `PC_INC `FLAGS_D)

`MICROCODE( kMCA_e_sei0,    kMCA_e_fetch0, `FLAGS_I `SYNC)
`MICROCODE( kMCA_e_clesee0, kMCA_e_fetch0, `FLAGS_E `SYNC)

`MICROCODE( kMCA_e_lda, kMCA_e_fetch0, `BSEL_DB `FLAGS_SBZN `SYNC `LOAD_A)
`MICROCODE( kMCA_e_ldx, kMCA_e_fetch0, `BSEL_DB `FLAGS_SBZN `SYNC `LOAD_X)
`MICROCODE( kMCA_e_ldy, kMCA_e_fetch0, `BSEL_DB `FLAGS_SBZN `SYNC `LOAD_Y)
`MICROCODE( kMCA_e_ldz, kMCA_e_fetch0, `BSEL_DB `FLAGS_SBZN `SYNC `LOAD_Z)

`MICROCODE( kMCA_e_ldai, kMCA_e_fetch0, `BSEL_DB `FLAGS_SBZN `SYNC `LOAD_A `PC_INC)
`MICROCODE( kMCA_e_ldxi, kMCA_e_fetch0, `BSEL_DB `FLAGS_SBZN `SYNC `LOAD_X `PC_INC)
`MICROCODE( kMCA_e_ldyi, kMCA_e_fetch0, `BSEL_DB `FLAGS_SBZN `SYNC `LOAD_Y `PC_INC)
`MICROCODE( kMCA_e_ldzi, kMCA_e_fetch0, `BSEL_DB `FLAGS_SBZN `SYNC `LOAD_Z `PC_INC)

// Single cycle instructions - implicit SYNC
`MICROCODE( kMCA_e_txa0, 0, `PC_INC `ASEL_DREG `DREG_X `LOAD_A `FLAGS_SBZN)
`MICROCODE( kMCA_e_tya0, 0, `PC_INC `ASEL_DREG `DREG_Y `LOAD_A `FLAGS_SBZN)
`MICROCODE( kMCA_e_txs0, 0, `PC_INC `ASEL_DREG `DREG_X `SPL_ALU)
`MICROCODE( kMCA_e_tay0, 0, `PC_INC `ASEL_DREG `DREG_A `LOAD_Y `FLAGS_SBZN)
`MICROCODE( kMCA_e_tax0, 0, `PC_INC `ASEL_DREG `DREG_A `LOAD_X `FLAGS_SBZN)
`MICROCODE( kMCA_e_tsx0, 0, `PC_INC `ASEL_AREG `AREG_SPL `LOAD_X `FLAGS_SBZN)
`MICROCODE( kMCA_e_tsy0, 0, `PC_INC `ASEL_AREG `AREG_SPH `LOAD_Y `FLAGS_SBZN)
`MICROCODE( kMCA_e_tys0, 0, `PC_INC `ASEL_DREG `DREG_Y `SPH_ALU)
`MICROCODE( kMCA_e_taz0, 0, `PC_INC `ASEL_DREG `DREG_A `LOAD_Z `FLAGS_SBZN)
`MICROCODE( kMCA_e_tza0, 0, `PC_INC `ASEL_DREG `DREG_Z `LOAD_A `FLAGS_SBZN)
`MICROCODE( kMCA_e_tab0, 0, `PC_INC `ASEL_DREG `DREG_A `LOAD_B)
`MICROCODE( kMCA_e_tba0, 0, `PC_INC `BSEL_B `LOAD_A `FLAGS_SBZN)

// JMP abs
`MICROCODE( kMCA_e_jmp0, kMCA_e_jmp1,   `PC_INC `BSEL_DB `ADL_ALU)
`MICROCODE( kMCA_e_jmp1, kMCA_e_fetch0, `PC_INC `BSEL_DB `PCH_ALU `PCL_ADL `SYNC)

// JMP ind
`MICROCODE( kMCA_e_jmpind0, kMCA_e_jmpind1, `PC_INC `BSEL_DB `ADL_ALU)
`MICROCODE( kMCA_e_jmpind1, kMCA_e_jmpind2, `PC_INC `BSEL_DB `PCH_ALU `PCL_ADL)
`MICROCODE( kMCA_e_jmpind2, kMCA_e_jmpind3, `PC_INC `BSEL_DB `ADL_ALU)
`MICROCODE( kMCA_e_jmpind3, kMCA_e_fetch0,  `PC_INC `BSEL_DB `PCH_ALU `PCL_ADL `SYNC)

// JMP ind,x
`MICROCODE( kMCA_e_jmpindx0, kMCA_e_jmpindx1, `PC_INC `ADL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB )
`MICROCODE( kMCA_e_jmpindx1, kMCA_e_jmpindx2, `PC_INC `PCH_ALU `ALU_ADC `BSEL_DB `CSEL_D `PCL_ADL)
`MICROCODE( kMCA_e_jmpindx2, kMCA_e_jmpindx3, `PC_INC `BSEL_DB `ADL_ALU)
`MICROCODE( kMCA_e_jmpindx3, kMCA_e_fetch0,   `PC_INC `BSEL_DB `PCH_ALU `PCL_ADL `SYNC)

// Branches could probably be collapsed to a single sequence.   We'd just need a TF_x bit that says to infer the
// condition code to be tested from the instruction register bits directly.  We're not currently short on microcode
// space, though since we're already down to two 18Kbit block RAMs.   The smallest address size is 9 bits anyway, so
// we don't gain much by trying to squeeze into 8 bits.

`MICROCODE( kMCA_e_bra,  kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `SYNC)

`MICROCODE( kMCA_e_bpl0, kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_N `TEST_FLAG0 `SYNC `NEXT_COND_BRANCH)
`MICROCODE( kMCA_e_bpl1, kMCA_e_fetch0, `SYNC `NEXT_COND_BPC)
`MICROCODE( kMCA_e_bpl2, kMCA_e_fetch0, `SYNC)
`MICROCODE( kMCA_e_bmi0, kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_N `SYNC `NEXT_COND_BRANCH)
`MICROCODE( kMCA_e_bmi1, kMCA_e_fetch0, `SYNC `NEXT_COND_BPC)
`MICROCODE( kMCA_e_bmi2, kMCA_e_fetch0, `SYNC)
`MICROCODE( kMCA_e_bvc0, kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_V `TEST_FLAG0 `SYNC `NEXT_COND_BRANCH)
`MICROCODE( kMCA_e_bvc1, kMCA_e_fetch0, `SYNC `NEXT_COND_BPC)
`MICROCODE( kMCA_e_bvc2, kMCA_e_fetch0, `SYNC)
`MICROCODE( kMCA_e_bvs0, kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_V `SYNC `NEXT_COND_BRANCH)
`MICROCODE( kMCA_e_bvs1, kMCA_e_fetch0, `SYNC `NEXT_COND_BPC)
`MICROCODE( kMCA_e_bvs2, kMCA_e_fetch0, `SYNC)
`MICROCODE( kMCA_e_bcc0, kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_C `TEST_FLAG0 `SYNC `NEXT_COND_BRANCH)
`MICROCODE( kMCA_e_bcc1, kMCA_e_fetch0, `SYNC `NEXT_COND_BPC)
`MICROCODE( kMCA_e_bcc2, kMCA_e_fetch0, `SYNC)
`MICROCODE( kMCA_e_bcs0, kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_C `SYNC `NEXT_COND_BRANCH)
`MICROCODE( kMCA_e_bcs1, kMCA_e_fetch0, `SYNC `NEXT_COND_BPC)
`MICROCODE( kMCA_e_bcs2, kMCA_e_fetch0, `SYNC)
`MICROCODE( kMCA_e_bne0, kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_Z `TEST_FLAG0 `SYNC `NEXT_COND_BRANCH)
`MICROCODE( kMCA_e_bne1, kMCA_e_fetch0, `SYNC `NEXT_COND_BPC)
`MICROCODE( kMCA_e_bne2, kMCA_e_fetch0, `SYNC)
`MICROCODE( kMCA_e_beq0, kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_Z `SYNC `NEXT_COND_BRANCH)
`MICROCODE( kMCA_e_beq1, kMCA_e_fetch0, `SYNC `NEXT_COND_BPC)
`MICROCODE( kMCA_e_beq2, kMCA_e_fetch0, `SYNC)

`MICROCODE( kMCA_e_braw0, 0, `PC_INC `ADL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `NEXT_A1)

// These could probably be collapsed. The flag to test can be inferred from IR
`MICROCODE( kMCA_e_bplw1, kMCA_e_fetch0, `PC_INC `PCH_ALU `ALU_ADC `ASEL_AREG `AREG_PCH `BSEL_DB `CSEL_D `PCL_ADL `TF_N `TEST_FLAG0 `SYNC)
`MICROCODE( kMCA_e_bmiw1, kMCA_e_fetch0, `PC_INC `PCH_ALU `ALU_ADC `ASEL_AREG `AREG_PCH `BSEL_DB `CSEL_D `PCL_ADL `TF_N `SYNC)
`MICROCODE( kMCA_e_bvcw1, kMCA_e_fetch0, `PC_INC `PCH_ALU `ALU_ADC `ASEL_AREG `AREG_PCH `BSEL_DB `CSEL_D `PCL_ADL `TF_V `TEST_FLAG0 `SYNC)
`MICROCODE( kMCA_e_bvsw1, kMCA_e_fetch0, `PC_INC `PCH_ALU `ALU_ADC `ASEL_AREG `AREG_PCH `BSEL_DB `CSEL_D `PCL_ADL `TF_V `SYNC)
`MICROCODE( kMCA_e_braw1, kMCA_e_fetch0, `PC_INC `PCH_ALU `ALU_ADC `ASEL_AREG `AREG_PCH `BSEL_DB `CSEL_D `PCL_ADL `SYNC)
`MICROCODE( kMCA_e_bccw1, kMCA_e_fetch0, `PC_INC `PCH_ALU `ALU_ADC `ASEL_AREG `AREG_PCH `BSEL_DB `CSEL_D `PCL_ADL `TF_C `TEST_FLAG0 `SYNC)
`MICROCODE( kMCA_e_bcsw1, kMCA_e_fetch0, `PC_INC `PCH_ALU `ALU_ADC `ASEL_AREG `AREG_PCH `BSEL_DB `CSEL_D `PCL_ADL `TF_C `SYNC)
`MICROCODE( kMCA_e_bnew1, kMCA_e_fetch0, `PC_INC `PCH_ALU `ALU_ADC `ASEL_AREG `AREG_PCH `BSEL_DB `CSEL_D `PCL_ADL `TF_Z `TEST_FLAG0 `SYNC)
`MICROCODE( kMCA_e_beqw1, kMCA_e_fetch0, `PC_INC `PCH_ALU `ALU_ADC `ASEL_AREG `AREG_PCH `BSEL_DB `CSEL_D `PCL_ADL `TF_Z `SYNC)

// Single cycle instructions - implicit SYNC
`MICROCODE( kMCA_e_deca, 0, `PC_INC `ALU_ADC `BSEL_FF `FLAGS_SBZN `ASEL_DREG `DREG_A `LOAD_A)
`MICROCODE( kMCA_e_decx, 0, `PC_INC `ALU_ADC `BSEL_FF `FLAGS_SBZN `ASEL_DREG `DREG_X `LOAD_X)
`MICROCODE( kMCA_e_decy, 0, `PC_INC `ALU_ADC `BSEL_FF `FLAGS_SBZN `ASEL_DREG `DREG_Y `LOAD_Y)
`MICROCODE( kMCA_e_decz, 0, `PC_INC `ALU_ADC `BSEL_FF `FLAGS_SBZN `ASEL_DREG `DREG_Z `LOAD_Z)

// Single cycle instructions - implicit SYNC
`MICROCODE( kMCA_e_inca, 0, `PC_INC `ALU_ADC `CSEL_1 `FLAGS_SBZN `ASEL_DREG `DREG_A `LOAD_A)
`MICROCODE( kMCA_e_incx, 0, `PC_INC `ALU_ADC `CSEL_1 `FLAGS_SBZN `ASEL_DREG `DREG_X `LOAD_X)
`MICROCODE( kMCA_e_incy, 0, `PC_INC `ALU_ADC `CSEL_1 `FLAGS_SBZN `ASEL_DREG `DREG_Y `LOAD_Y)
`MICROCODE( kMCA_e_incz, 0, `PC_INC `ALU_ADC `CSEL_1 `FLAGS_SBZN `ASEL_DREG `DREG_Z `LOAD_Z)

`MICROCODE( kMCA_e_cmpa, kMCA_e_fetch0, `ALU_ADC `ASEL_DREG `DREG_A `BSEL_NDB `CSEL_1 `FLAGS_CNZ `SYNC)
`MICROCODE( kMCA_e_cmpx, kMCA_e_fetch0, `ALU_ADC `ASEL_DREG `DREG_X `BSEL_NDB `CSEL_1 `FLAGS_CNZ `SYNC)
`MICROCODE( kMCA_e_cmpy, kMCA_e_fetch0, `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_NDB `CSEL_1 `FLAGS_CNZ `SYNC)
`MICROCODE( kMCA_e_cmpz, kMCA_e_fetch0, `ALU_ADC `ASEL_DREG `DREG_Z `BSEL_NDB `CSEL_1 `FLAGS_CNZ `SYNC)

`MICROCODE( kMCA_e_cmpai, kMCA_e_fetch0, `ALU_ADC `ASEL_DREG `DREG_A `BSEL_NDB `CSEL_1 `FLAGS_CNZ `PC_INC `SYNC)
`MICROCODE( kMCA_e_cmpxi, kMCA_e_fetch0, `ALU_ADC `ASEL_DREG `DREG_X `BSEL_NDB `CSEL_1 `FLAGS_CNZ `PC_INC `SYNC)
`MICROCODE( kMCA_e_cmpyi, kMCA_e_fetch0, `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_NDB `CSEL_1 `FLAGS_CNZ `PC_INC `SYNC)
`MICROCODE( kMCA_e_cmpzi, kMCA_e_fetch0, `ALU_ADC `ASEL_DREG `DREG_Z `BSEL_NDB `CSEL_1 `FLAGS_CNZ `PC_INC `SYNC)

`MICROCODE( kMCA_e_adc,  kMCA_e_fetch0, `ALU_ADC `ASEL_DREG `DREG_A `BSEL_DB `CSEL_P `FLAGS_ALU `LOAD_A `SYNC)
`MICROCODE( kMCA_e_adci, kMCA_e_fetch0, `ALU_ADC `ASEL_DREG `DREG_A `BSEL_DB `CSEL_P `FLAGS_ALU `LOAD_A `SYNC `PC_INC)

`MICROCODE( kMCA_e_sbc,  kMCA_e_fetch0, `ALU_ADC `ASEL_DREG `DREG_A `BSEL_NDB `CSEL_P `FLAGS_ALU `LOAD_A `SYNC)
`MICROCODE( kMCA_e_sbci, kMCA_e_fetch0, `ALU_ADC `ASEL_DREG `DREG_A `BSEL_NDB `CSEL_P `FLAGS_ALU `LOAD_A `SYNC `PC_INC)

`MICROCODE( kMCA_e_ora,  kMCA_e_fetch0, `ALU_ORA `ASEL_DREG `DREG_A `BSEL_DB `FLAGS_SBZN `LOAD_A `SYNC)
`MICROCODE( kMCA_e_orai, kMCA_e_fetch0, `ALU_ORA `ASEL_DREG `DREG_A `BSEL_DB `FLAGS_SBZN `LOAD_A `SYNC `PC_INC)

`MICROCODE( kMCA_e_and,  kMCA_e_fetch0, `ALU_AND `ASEL_DREG `DREG_A `BSEL_DB `FLAGS_SBZN `LOAD_A `SYNC)
`MICROCODE( kMCA_e_andi, kMCA_e_fetch0, `ALU_AND `ASEL_DREG `DREG_A `BSEL_DB `FLAGS_SBZN `LOAD_A `SYNC `PC_INC)

`MICROCODE( kMCA_e_eor,  kMCA_e_fetch0, `ALU_EOR `ASEL_DREG `DREG_A `BSEL_DB `FLAGS_SBZN `LOAD_A `SYNC)
`MICROCODE( kMCA_e_eori, kMCA_e_fetch0, `ALU_EOR `ASEL_DREG `DREG_A `BSEL_DB `FLAGS_SBZN `LOAD_A `SYNC `PC_INC)

`MICROCODE( kMCA_e_bitm0, kMCA_e_bitm1,  `AB_ABn `BSEL_DB `FLAGS_BIT)
`MICROCODE( kMCA_e_bitm1, kMCA_e_fetch0, `ALU_AND `ASEL_DREG `DREG_A `BSEL_DB `CSEL_0 `FLAGS_Z `SYNC)

`MICROCODE( kMCA_e_biti,  kMCA_e_fetch0, `PC_INC `ALU_AND `ASEL_DREG `DREG_A `BSEL_DB `CSEL_0 `FLAGS_Z `SYNC)

// Single cycle instructions, implicit SYNC
`MICROCODE( kMCA_e_asl_a, 0, `PC_INC `ASEL_DREG `DREG_A `LOAD_A `FLAGS_CNZ `ALU_SHL `CSEL_0)
`MICROCODE( kMCA_e_rol_a, 0, `PC_INC `ASEL_DREG `DREG_A `LOAD_A `FLAGS_CNZ `ALU_SHL `CSEL_P)
`MICROCODE( kMCA_e_lsr_a, 0, `PC_INC `ASEL_DREG `DREG_A `LOAD_A `FLAGS_CNZ `ALU_SHR `CSEL_0)
`MICROCODE( kMCA_e_ror_a, 0, `PC_INC `ASEL_DREG `DREG_A `LOAD_A `FLAGS_CNZ `ALU_SHR `CSEL_P)

`MICROCODE( kMCA_e_asl_mem0, kMCA_e_mem_fetch, `AB_ABn `ASEL_DB `FLAGS_CNZ `ALU_SHL `CSEL_0 `WRITE)
`MICROCODE( kMCA_e_rol_mem0, kMCA_e_mem_fetch, `AB_ABn `ASEL_DB `FLAGS_CNZ `ALU_SHL `CSEL_P `WRITE)
`MICROCODE( kMCA_e_lsr_mem0, kMCA_e_mem_fetch, `AB_ABn `ASEL_DB `FLAGS_CNZ `ALU_SHR `CSEL_0 `WRITE)
`MICROCODE( kMCA_e_ror_mem0, kMCA_e_mem_fetch, `AB_ABn `ASEL_DB `FLAGS_CNZ `ALU_SHR `CSEL_P `WRITE)
`MICROCODE( kMCA_e_asr_mem0, kMCA_e_mem_fetch, `AB_ABn `ASEL_DB `FLAGS_CNZ `ALU_ASR `WRITE)
`MICROCODE( kMCA_e_inc_mem0, kMCA_e_mem_fetch, `AB_ABn `ALU_ADC `BSEL_DB `CSEL_1 `FLAGS_SBZN `WRITE)
`MICROCODE( kMCA_e_dec_mem0, kMCA_e_mem_fetch, `AB_ABn `ALU_ADC `ASEL_FF `BSEL_DB `CSEL_0 `FLAGS_SBZN `WRITE)

`MICROCODE( kMCA_e_mem_fetch, kMCA_e_fetch0,   `SYNC)

`MICROCODE( kMCA_e_push_p,  kMCA_e_push1, `AB_SPn `WRITE `BSEL_P)
`MICROCODE( kMCA_e_push_a,  kMCA_e_push1, `AB_SPn `WRITE `ASEL_DREG `DREG_A)
`MICROCODE( kMCA_e_push_x,  kMCA_e_push1, `AB_SPn `WRITE `ASEL_DREG `DREG_X)
`MICROCODE( kMCA_e_push_y,  kMCA_e_push1, `AB_SPn `WRITE `ASEL_DREG `DREG_Y)
`MICROCODE( kMCA_e_push_z,  kMCA_e_push1, `AB_SPn `WRITE `ASEL_DREG `DREG_Z)

`MICROCODE( kMCA_e_push1, kMCA_e_fetch0, `SP_DEC `SYNC)

`MICROCODE( kMCA_e_pull0, 0, `AB_SPn `SP_INC `NEXT_A1)

// 6502 RTS has extra dummy stack read
`MICROCODE( kMCA_n_pull0, kMCA_n_pull1, `AB_SPn)
`MICROCODE( kMCA_n_pull1, 0, `AB_SPn `SP_INC `NEXT_A1)

`MICROCODE( kMCA_e_pull_p, kMCA_e_fetch0, `FLAGS_DB `SYNC)
`MICROCODE( kMCA_e_pull_a, kMCA_e_fetch0, `BSEL_DB `LOAD_A `FLAGS_SBZN `SYNC)
`MICROCODE( kMCA_e_pull_x, kMCA_e_fetch0, `BSEL_DB `LOAD_X `FLAGS_SBZN `SYNC)
`MICROCODE( kMCA_e_pull_y, kMCA_e_fetch0, `BSEL_DB `LOAD_Y `FLAGS_SBZN `SYNC)
`MICROCODE( kMCA_e_pull_z, kMCA_e_fetch0, `BSEL_DB `LOAD_Z `FLAGS_SBZN `SYNC)

`MICROCODE( kMCA_e_jsr0, kMCA_e_jsr1, `PC_INC `AB_SPn `BSEL_DB `ADL_ALU `DBO_PCHn `WRITE)
`MICROCODE( kMCA_e_jsr1, kMCA_e_jsr2, `AB_SPn `SP_DEC `ASEL_AREG `AREG_PCL `WRITE)
`MICROCODE( kMCA_e_jsr2, kMCA_e_jsr3, `AB_PCn `SP_DEC)
`MICROCODE( kMCA_e_jsr3, kMCA_e_fetch0, `BSEL_DB `PCH_ALU `PCL_ADL `SYNC)

// 6502 JSR.  Extra dummy stack read.  The rest is the same.
`MICROCODE( kMCA_n_jsr0, kMCA_n_jsr1, `PC_INC `AB_SPn `BSEL_DB `ADL_ALU )
`MICROCODE( kMCA_n_jsr1, kMCA_e_jsr1, `AB_SPn `DBO_PCHn `WRITE)

`MICROCODE( kMCA_e_rts0, kMCA_e_rts1, `AB_SPn `SP_INC)
`MICROCODE( kMCA_e_rts1, kMCA_e_rts2, `AB_SPn `SP_INC `ALU_ADC `BSEL_DB `CSEL_1 `PCL_ALU)
`MICROCODE( kMCA_e_rts2, kMCA_e_fetch0, `ALU_ADC `BSEL_DB `CSEL_D `PCH_ALU `SYNC)

`MICROCODE( kMCA_e_rti0, kMCA_e_rti1, `AB_SPn `SP_INC)
`MICROCODE( kMCA_e_rti1, kMCA_e_rti2, `AB_SPn `SP_INC `FLAGS_RTI)
`MICROCODE( kMCA_e_rti2, kMCA_e_rti3, `AB_SPn `SP_INC `ADL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_rti3, kMCA_e_fetch0, `ALU_ADC `BSEL_DB `CSEL_0 `PCH_ALU `PCL_ADL `SYNC)

`MICROCODE( kMCA_e_neg, kMCA_e_fetch0, `ALU_ADC `ASEL_NDREG `DREG_A `CSEL_1 `LOAD_A `FLAGS_SBZN `SYNC)

`MICROCODE( kMCA_e_asr_a, kMCA_e_fetch0, `ALU_ASR `ASEL_DREG `DREG_A `LOAD_A `FLAGS_CNZ `SYNC)

`MICROCODE( kMCA_e_bsr0, kMCA_e_bsr1, `PC_INC `AB_SPn `ADL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `DBO_PCHn `WRITE)
`MICROCODE( kMCA_e_bsr1, kMCA_e_bsr2, `AB_SPn `SP_DEC `ASEL_AREG `AREG_PCL `WRITE)
`MICROCODE( kMCA_e_bsr2, kMCA_e_bsr3, `AB_PCn `SP_DEC)
`MICROCODE( kMCA_e_bsr3, kMCA_e_fetch0, `PCH_ALU `ALU_ADC `ASEL_AREG `AREG_PCH `BSEL_DB `CSEL_D `PCL_ADL `SYNC)

`MICROCODE( kMCA_e_jsrind0, kMCA_e_jsrind1, `PC_INC `AB_SPn `ABL_ALU `BSEL_DB `DBO_PCHn `WRITE)
`MICROCODE( kMCA_e_jsrind1, kMCA_e_jsrind2, `AB_SPn `SP_DEC `ASEL_AREG `AREG_PCL `WRITE)
`MICROCODE( kMCA_e_jsrind2, kMCA_e_jsrind3, `AB_PCn `SP_DEC)
`MICROCODE( kMCA_e_jsrind3, kMCA_e_jsrind4, `AB_ABn `ABH_ALU `BSEL_DB)
`MICROCODE( kMCA_e_jsrind4, kMCA_e_jsrind5, `AB_ABn `AB_INC `ADL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_jsrind5, kMCA_e_fetch0, `AB_PCn `PCH_ALU `BSEL_DB `PCL_ADL `SYNC)

`MICROCODE( kMCA_e_jsrindx0, kMCA_e_jsrindx1, `PC_INC `AB_SPn `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB `DBO_PCHn `WRITE)
`MICROCODE( kMCA_e_jsrindx1, kMCA_e_jsrindx2, `AB_SPn `SP_DEC `ASEL_AREG `AREG_PCL `WRITE)
`MICROCODE( kMCA_e_jsrindx2, kMCA_e_jsrindx3, `AB_PCn `SP_DEC)
`MICROCODE( kMCA_e_jsrindx3, kMCA_e_jsrindx4, `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DB `CSEL_D )
`MICROCODE( kMCA_e_jsrindx4, kMCA_e_jsrindx5, `AB_ABn `AB_INC `ADL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_jsrindx5, kMCA_e_fetch0, `AB_PCn `PCH_ALU `BSEL_DB `PCL_ADL `SYNC)

`MICROCODE( kMCA_e_rtn0, kMCA_e_rtn1, `ABL_ALU `ASEL_AREG `AREG_PCL)
`MICROCODE( kMCA_e_rtn1, kMCA_e_rtn2, `AB_SPn `SP_INC `ABH_ALU `ASEL_AREG `AREG_PCH)
`MICROCODE( kMCA_e_rtn2, kMCA_e_rtn3, `AB_SPn `SP_INC `PCL_ALU `ALU_ADC `BSEL_DB `CSEL_1)
`MICROCODE( kMCA_e_rtn3, kMCA_e_rtn4, `AB_ABn `PCH_ALU `ALU_ADC `BSEL_DB `CSEL_D)
`MICROCODE( kMCA_e_rtn4, kMCA_e_rtn5, `AB_ABn `SPL_ALU `ALU_ADC `ASEL_AREG `AREG_SPL `BSEL_DB `CSEL_0)
`MICROCODE( kMCA_e_rtn5, kMCA_e_fetch0, `AB_PCn `SPH_ALU `ALU_ADC `ASEL_AREG `AREG_SPH `CSEL_D `SYNC)

`MICROCODE( kMCA_e_inw0, kMCA_e_inw1, `AB_ABn `PC_INC `ABH_B `ABL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_inw1, kMCA_e_inw2, `AB_ABn `ALU_ADC `BSEL_DB `CSEL_1 `WRITE `FLAGS_SBZN)
`MICROCODE( kMCA_e_inw2, kMCA_e_inw3, `AB_ABn `AB_INC)
`MICROCODE( kMCA_e_inw3, kMCA_e_mem_fetch, `AB_ABn `ALU_ADC `BSEL_DB `CSEL_D `WRITE `FLAGS_SBZN `WORD_Z)

`MICROCODE( kMCA_e_dew0, kMCA_e_dew1, `AB_ABn `PC_INC `ABH_B `ABL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_dew1, kMCA_e_dew2, `AB_ABn `ALU_ADC `ASEL_FF `BSEL_DB `CSEL_0 `WRITE `FLAGS_SBZN)
`MICROCODE( kMCA_e_dew2, kMCA_e_dew3, `AB_ABn `AB_INC)
`MICROCODE( kMCA_e_dew3, kMCA_e_mem_fetch, `AB_ABn `ALU_ADC `ASEL_FF `BSEL_DB `CSEL_D `WRITE `FLAGS_SBZN `WORD_Z)

`MICROCODE( kMCA_e_asw0, kMCA_e_asw1, `AB_PCn `PC_INC `ABL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_asw1, kMCA_e_asw2, `AB_ABn `PC_INC `ABH_ALU `BSEL_DB)
`MICROCODE( kMCA_e_asw2, kMCA_e_asw3, `AB_ABn `ALU_SHL `ASEL_DB `CSEL_0 `WRITE `FLAGS_CNZ)
`MICROCODE( kMCA_e_asw3, kMCA_e_asw4, `AB_ABn `AB_INC)
`MICROCODE( kMCA_e_asw4, kMCA_e_mem_fetch, `AB_ABn `ALU_SHL `ASEL_DB `CSEL_P `WRITE `FLAGS_CNZ `WORD_Z)

`MICROCODE( kMCA_e_row0, kMCA_e_row1, `AB_PCn `PC_INC `ABL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_row1, kMCA_e_row2, `AB_ABn `PC_INC `ABH_ALU `BSEL_DB)
`MICROCODE( kMCA_e_row2, kMCA_e_row3, `AB_ABn `ALU_SHL `ASEL_DB `CSEL_P `WRITE `FLAGS_CNZ)
`MICROCODE( kMCA_e_row3, kMCA_e_row4, `AB_ABn `AB_INC)
`MICROCODE( kMCA_e_row4, kMCA_e_mem_fetch, `AB_ABn `ALU_SHL `ASEL_DB `CSEL_P `WRITE `FLAGS_CNZ `WORD_Z)

`MICROCODE( kMCA_e_phwi0, kMCA_e_phwi1, `AB_SPn `PC_INC `DBO_DI `WRITE)
`MICROCODE( kMCA_e_phwi1, kMCA_e_phwi2, `AB_PCn `SP_DEC)
`MICROCODE( kMCA_e_phwi2, kMCA_e_phwi3, `AB_SPn `PC_INC `DBO_DI `WRITE)
`MICROCODE( kMCA_e_phwi3, kMCA_e_fetch0, `AB_PCn `SP_DEC `SYNC)

`MICROCODE( kMCA_e_phw0, kMCA_e_phw1, `PC_INC `ABL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_phw1, kMCA_e_phw2, `PC_INC `AB_ABn `ABH_ALU `BSEL_DB)
`MICROCODE( kMCA_e_phw2, kMCA_e_phw3, `AB_SPn `AB_INC `DBO_DI `WRITE)
`MICROCODE( kMCA_e_phw3, kMCA_e_phw4, `AB_ABn `SP_DEC)
`MICROCODE( kMCA_e_phw4, kMCA_e_phw5, `AB_SPn `DBO_DI `WRITE)
`MICROCODE( kMCA_e_phw5, kMCA_e_fetch0, `AB_PCn `SP_DEC `SYNC)


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

// Alas, nothing is visible externally on the memory bus, but it does appear that the MAP instruction
// takes 5 cycles total, so I think my theory is probably pretty close to how it works on the real 4510.

// The other thing that has to happen when a MAP instruction is encountered is that interrupts get disabled
// until a NOP is executed.  Again, I think this could have been done with external logic since if they
// were sniffing the instruction stream to detect MAP, also detecting a NOP would have been easy.
`MICROCODE( kMCA_e_map0, kMCA_e_map1, `DBO_DREG `DREG_DO_A `MC_MAP)
`MICROCODE( kMCA_e_map1, kMCA_e_map2, `DBO_DREG `DREG_DO_X `MC_MAP)
`MICROCODE( kMCA_e_map2, kMCA_e_map3, `DBO_DREG `DREG_DO_Y `MC_MAP)
`MICROCODE( kMCA_e_map3, kMCA_e_fetch0, `DBO_DREG `DREG_DO_Z `MC_MAP `SYNC)

// Read zero (base) page
`MICROCODE( kMCA_e_addr_r_zp0,      0, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB `NEXT_A1)

// Write variants for zero page addressing
`MICROCODE( kMCA_e_addr_w_zp0_a,    kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB  `WRITE `DREG_DO_A)
`MICROCODE( kMCA_e_addr_w_zp0_x,    kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB  `WRITE `DREG_DO_X)
`MICROCODE( kMCA_e_addr_w_zp0_y,    kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB  `WRITE `DREG_DO_Y)
`MICROCODE( kMCA_e_addr_w_zp0_z,    kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB  `WRITE `DREG_DO_Z)

// Read absolute
`MICROCODE( kMCA_e_addr_r_abs0,     kMCA_e_addr_r_abs1, `PC_INC `ABL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_addr_r_abs1,     0, `PC_INC `AB_ABn `ABH_ALU `DBO_DREG `BSEL_DB `NEXT_A1)

// Write variants for absolute addressing
`MICROCODE( kMCA_e_addr_w_abs0,     0, `PC_INC `ABL_ALU `BSEL_DB `NEXT_A1)
`MICROCODE( kMCA_e_addr_w_abs1_a,   kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `DBO_DREG `BSEL_DB `WRITE `DREG_DO_A)
`MICROCODE( kMCA_e_addr_w_abs1_x,   kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `DBO_DREG `BSEL_DB `WRITE `DREG_DO_X)
`MICROCODE( kMCA_e_addr_w_abs1_y,   kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `DBO_DREG `BSEL_DB `WRITE `DREG_DO_Y)
`MICROCODE( kMCA_e_addr_w_abs1_z,   kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `DBO_DREG `BSEL_DB `WRITE `DREG_DO_Z)

// Read absolute,x
`MICROCODE( kMCA_e_addr_r_absx0,    kMCA_e_addr_r_absx1, `PC_INC `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB)
`MICROCODE( kMCA_e_addr_r_absx1,    0, `PC_INC `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG `NEXT_A1)

// Write absolute,x variants
`MICROCODE( kMCA_e_addr_w_absx0,    0, `PC_INC `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB `NEXT_A1)
`MICROCODE( kMCA_e_addr_w_absx1_a,  kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG `WRITE `DREG_DO_A)
`MICROCODE( kMCA_e_addr_w_absx1_y,  kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG `WRITE `DREG_DO_Y)
`MICROCODE( kMCA_e_addr_w_absx1_z,  kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG `WRITE `DREG_DO_Z)

// Read absolute,y
`MICROCODE( kMCA_e_addr_r_absy0,    kMCA_e_addr_r_absy1, `PC_INC `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB)
`MICROCODE( kMCA_e_addr_r_absy1,    0, `PC_INC `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG `NEXT_A1)

// Write absolute,y variants
`MICROCODE( kMCA_e_addr_w_absy0,    0, `PC_INC `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB `NEXT_A1)
`MICROCODE( kMCA_e_addr_w_absy1_a,  kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG `WRITE `DREG_DO_A)
`MICROCODE( kMCA_e_addr_w_absy1_x,  kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG `WRITE `DREG_DO_X)

// Read zp,x
`MICROCODE( kMCA_e_addr_r_zpx0,     0, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB `DBO_DREG `NEXT_A1)

// Write zp,x variants
`MICROCODE( kMCA_e_addr_w_zpx0_a,   kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB `DBO_DREG `WRITE `DREG_DO_A)
`MICROCODE( kMCA_e_addr_w_zpx0_y,   kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB `DBO_DREG `WRITE `DREG_DO_Y)
`MICROCODE( kMCA_e_addr_w_zpx0_z,   kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB `DBO_DREG `WRITE `DREG_DO_Z)

// Read zp,y
`MICROCODE( kMCA_e_addr_r_zpy0,     0, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB `DBO_DREG `NEXT_A1)

// Write zp,y variant
`MICROCODE( kMCA_e_addr_w_zpy0_x,   kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB `DBO_DREG `WRITE `DREG_DO_X)

// Read (zp,x)
`MICROCODE( kMCA_e_addr_r_zpxind0,  kMCA_e_addr_r_zpxind1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB)
`MICROCODE( kMCA_e_addr_r_zpxind1,  kMCA_e_addr_r_zpxind2, `AB_ABn `AB_INC `ADL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_addr_r_zpxind2,  0, `AB_ADn `ADH_ALU `BSEL_DB `DBO_DREG `NEXT_A1)

// Write (zp,x) - This only supports STA and so no microcode branching required
`MICROCODE( kMCA_e_addr_w_zpxind0,  kMCA_e_addr_w_zpxind1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB)
`MICROCODE( kMCA_e_addr_w_zpxind1,  kMCA_e_addr_w_zpxind2, `AB_ABn `AB_INC `ADL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_addr_w_zpxind2,  kMCA_e_mem_fetch, `AB_ADn `ADH_ALU `BSEL_DB `DBO_DREG `WRITE `DREG_DO_A)

// Note: (zp),y and (zp),z could share their final microcode sequences since they are identical after cycle 1
// Read (zp),y
`MICROCODE( kMCA_e_addr_r_zpindy0,  kMCA_e_addr_r_zpindy1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB)
`MICROCODE( kMCA_e_addr_r_zpindy1,  kMCA_e_addr_r_zpindy2, `AB_ABn `AB_INC `ADL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB)
`MICROCODE( kMCA_e_addr_r_zpindy2,  0, `AB_ADn `ADH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG `NEXT_A1)

// Write (zp),y - This only supports STA and so no microcode branching required
`MICROCODE( kMCA_e_addr_w_zpindy0,  kMCA_e_addr_w_zpindy1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB)
`MICROCODE( kMCA_e_addr_w_zpindy1,  kMCA_e_addr_w_zpindy2, `AB_ABn `AB_INC `ADL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB)
`MICROCODE( kMCA_e_addr_w_zpindy2,  kMCA_e_mem_fetch, `AB_ADn `ADH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG `WRITE `DREG_DO_A)

// Read (zp),z
`MICROCODE( kMCA_e_addr_r_zpindz0,  kMCA_e_addr_r_zpindz1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB)
`MICROCODE( kMCA_e_addr_r_zpindz1,  kMCA_e_addr_r_zpindz2, `AB_ABn `AB_INC `ADL_ALU `ALU_ADC `ASEL_DREG `DREG_Z `BSEL_DB)
`MICROCODE( kMCA_e_addr_r_zpindz2,  0, `AB_ADn `ADH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG `NEXT_A1)

// Write (zp),z - This only supports STA and so no microcode branching required
`MICROCODE( kMCA_e_addr_w_zpindz0,  kMCA_e_addr_w_zpindz1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB)
`MICROCODE( kMCA_e_addr_w_zpindz1,  kMCA_e_addr_w_zpindz2, `AB_ABn `AB_INC `ADL_ALU `ALU_ADC `ASEL_DREG `DREG_Z `BSEL_DB)
`MICROCODE( kMCA_e_addr_w_zpindz2,  kMCA_e_mem_fetch, `AB_ADn `ADH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG `WRITE `DREG_DO_A)

// stack indirect only supports STA and LDA and so microcode branching is just used to choose between those two after cycle 2
`MICROCODE( kMCA_e_addr_spind0,     kMCA_e_addr_spind1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_AREG `AREG_SPL `BSEL_DB)
`MICROCODE( kMCA_e_addr_spind1,     kMCA_e_addr_spind2, `AB_ABn `ABH_ALU `ALU_ADC `ASEL_AREG `AREG_SPH `CSEL_D)
`MICROCODE( kMCA_e_addr_spind2,     0, `AB_ABn `AB_INC `ADL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB `NEXT_A1)
`MICROCODE( kMCA_e_addr_r_spind3,   kMCA_e_lda, `AB_ADn `ADH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG)
`MICROCODE( kMCA_e_addr_w_spind3,   kMCA_e_mem_fetch, `AB_ADn `ADH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG `WRITE `DREG_DO_A)

`MICROCODE( kMCA_e_bbr0, kMCA_e_bbr1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_bbr1, kMCA_e_bbr2, `ALU_AND `ASEL_NDB `BSEL_BIT)
`MICROCODE( kMCA_e_bbr2, kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_B `TEST_FLAG0 `SYNC)

`MICROCODE( kMCA_e_bbs0, kMCA_e_bbs1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_bbs1, kMCA_e_bbs2, `ALU_AND `ASEL_DB `BSEL_BIT)
`MICROCODE( kMCA_e_bbs2, kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_B `TEST_FLAG0 `SYNC)

`MICROCODE( kMCA_e_trb0, kMCA_e_trb1, `AB_ABn `ALU_AND `ASEL_NDREG `DREG_A `BSEL_DB `WRITE)
`MICROCODE( kMCA_e_trb1, kMCA_e_fetch0, `ALU_AND `ASEL_DREG `DREG_A `BSEL_DBD `FLAGS_Z `SYNC)

`MICROCODE( kMCA_e_tsb0, kMCA_e_tsb1, `AB_ABn `ALU_ORA `ASEL_DREG `DREG_A `BSEL_DB `WRITE)
`MICROCODE( kMCA_e_tsb1, kMCA_e_fetch0, `ALU_AND `ASEL_DREG `DREG_A `BSEL_DBD `FLAGS_Z `SYNC)

`MICROCODE( kMCA_e_rmb0, kMCA_e_mem_fetch, `AB_ABn `ALU_AND `ASEL_DB `BSEL_BIT `BIT_INV `WRITE)
`MICROCODE( kMCA_e_smb0, kMCA_e_mem_fetch, `AB_ABn `ALU_ORA `ASEL_DB `BSEL_BIT `WRITE)

// 6502 Addressing mode variants.  These use the 4510 data path but try to emulate what's on the bus at the same cycles as would
// happen on a real 6502, including the extra dummy read and write cycles.  The most often used trick is to make use of the BSEL_DBD
// selection to use the data available read the previous cycle to complete the addressing operation.

// 6502 read variant of zp,x
`MICROCODE( kMCA_n_addr_r_zpx0,     kMCA_n_addr_r_zpx1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ORA `BSEL_DB `DBO_DREG)
`MICROCODE( kMCA_n_addr_r_zpx1,     0, `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DBD `DBO_DREG `NEXT_A1)

// 6502 read variant of zp,y
`MICROCODE( kMCA_n_addr_r_zpy0,     kMCA_n_addr_r_zpy1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ORA `BSEL_DB `DBO_DREG)
`MICROCODE( kMCA_n_addr_r_zpy1,     0, `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DBD `DBO_DREG `NEXT_A1)

// 6502 write zp,x variants
`MICROCODE( kMCA_n_addr_w_zpx0,     0, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ORA `BSEL_DB `DBO_DREG `NEXT_A1)
`MICROCODE( kMCA_n_addr_w_zpx1_a,   kMCA_e_mem_fetch, `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DBD `DBO_DREG `WRITE `DREG_DO_A)
`MICROCODE( kMCA_n_addr_w_zpx1_y,   kMCA_e_mem_fetch, `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DBD `DBO_DREG `WRITE `DREG_DO_Y)

// 6502 write zp,y variants.
`MICROCODE( kMCA_n_addr_w_zpy0,     0, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ORA `BSEL_DB `DBO_DREG `NEXT_A1)
`MICROCODE( kMCA_n_addr_w_zpy1_x,   kMCA_e_mem_fetch, `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DBD `DBO_DREG `WRITE `DREG_DO_X)

// 6502 RMW variant of zp,x
`MICROCODE( kMCA_n_addr_m_zpx0,     kMCA_n_addr_m_zpx1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ORA `BSEL_DB `DBO_DREG)
`MICROCODE( kMCA_n_addr_m_zpx1,     kMCA_n_rmw_mem0, `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DBD `DBO_DREG)

// 6502 read variant of read absolute,x.  This will add an extra cycle to increment the high address if there was a carry.
`MICROCODE( kMCA_n_addr_r_absx0,    kMCA_n_addr_r_absx1, `PC_INC `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB)
`MICROCODE( kMCA_n_addr_r_absx1,    kMCA_n_addr_r_absx2, `PC_INC `AB_ABn `ABH_ALU `ALU_ORA `BSEL_DB `CSEL_0 `DBO_DREG `NEXT_A1 `NEXT_COND_LC)
`MICROCODE( kMCA_n_addr_r_absx2,    0, `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DBD `CSEL_1 `DBO_DREG `NEXT_A1)

// 6502 read variant of read absolute,y.  This will add an extra cycle to increment the high address if there was a carry.
`MICROCODE( kMCA_n_addr_r_absy0,    kMCA_n_addr_r_absy1, `PC_INC `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB)
`MICROCODE( kMCA_n_addr_r_absy1,    kMCA_n_addr_r_absy2, `PC_INC `AB_ABn `ABH_ALU `ALU_ORA `BSEL_DB `CSEL_0 `DBO_DREG `NEXT_A1 `NEXT_COND_LC)
`MICROCODE( kMCA_n_addr_r_absy2,    0, `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DBD `CSEL_1 `DBO_DREG `NEXT_A1)

// 6502 write absolute,x variants.  Always executes an extra dummy read with possibly uncorrected upper address byte
`MICROCODE( kMCA_n_addr_w_absx0,    kMCA_n_addr_w_absx1, `PC_INC `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB)
`MICROCODE( kMCA_n_addr_w_absx1,    0, `PC_INC `AB_ABn `ABH_ALU `ALU_ORA `BSEL_DB `NEXT_A1)
`MICROCODE( kMCA_n_addr_w_absx2_a,  kMCA_e_mem_fetch, `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DBD `CSEL_D `DBO_DREG `WRITE `DREG_DO_A)
`MICROCODE( kMCA_n_addr_w_absx2_y,  kMCA_e_mem_fetch, `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DBD `CSEL_D `DBO_DREG `WRITE `DREG_DO_Y)
`MICROCODE( kMCA_n_addr_w_absx2_z,  kMCA_e_mem_fetch, `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DBD `CSEL_D `DBO_DREG `WRITE `DREG_DO_Z)

// 6502 write absolute,y variants.  Always executes an extra dummy read with possibly uncorrected upper address byte
`MICROCODE( kMCA_n_addr_w_absy0,    kMCA_n_addr_w_absy1, `PC_INC `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB)
`MICROCODE( kMCA_n_addr_w_absy1,    0, `PC_INC `AB_ABn `ABH_ALU `ALU_ORA `BSEL_DB `NEXT_A1)
`MICROCODE( kMCA_n_addr_w_absy2_a,  kMCA_e_mem_fetch, `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DBD `CSEL_D `DBO_DREG `WRITE `DREG_DO_A)
`MICROCODE( kMCA_n_addr_w_absy2_x,  kMCA_e_mem_fetch, `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DBD `CSEL_D `DBO_DREG `WRITE `DREG_DO_X)

// 6502 RMW variant of zp
`MICROCODE( kMCA_n_addr_m_zp0,      kMCA_n_rmw_mem0, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB)

// 6502 RMW variant of abs
`MICROCODE( kMCA_n_addr_m_abs0,     kMCA_n_addr_m_abs1, `PC_INC `ABL_ALU `BSEL_DB)
`MICROCODE( kMCA_n_addr_m_abs1,     kMCA_n_rmw_mem0, `PC_INC `AB_ABn `ABH_ALU `DBO_DREG `BSEL_DB)

// 6502 RMW variant of absolute,x.  Uses extra cycle to ensure proper address generation after a carry.
`MICROCODE( kMCA_n_addr_m_absx0,    kMCA_n_addr_m_absx1, `PC_INC `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB)         // Carry generated here
`MICROCODE( kMCA_n_addr_m_absx1,    kMCA_n_addr_m_absx2, `PC_INC `AB_ABn `ABH_ALU `ALU_ORA `BSEL_DB `CSEL_0 `DBO_DREG)
`MICROCODE( kMCA_n_addr_m_absx2,    kMCA_n_rmw_mem0, `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DBD `CSEL_D `DBO_DREG)             // Carry used here

// 6502 RMW variant of absolute,y.  Uses extra cycle to ensure proper address generation after a carry.
`MICROCODE( kMCA_n_addr_m_absy0,    kMCA_n_addr_m_absy1, `PC_INC `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB)         // Carry generated here
`MICROCODE( kMCA_n_addr_m_absy1,    kMCA_n_addr_m_absy2, `PC_INC `AB_ABn `ABH_ALU `ALU_ORA `BSEL_DB `CSEL_0 `DBO_DREG)
`MICROCODE( kMCA_n_addr_m_absy2,    kMCA_n_rmw_mem0, `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DBD `CSEL_D `DBO_DREG)             // Carry used here

// First real cycle of 6502 RMW instruction just writes back whatever came in from the bus.  Then we go do the real work.
`MICROCODE( kMCA_n_rmw_mem0,        0, `AB_ABn `DBO_DI `WRITE `NEXT_A1)

// 6502 read (zp,x)
`MICROCODE( kMCA_n_addr_r_zpxind0,  kMCA_n_addr_r_zpxind1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ORA `BSEL_DB)
`MICROCODE( kMCA_n_addr_r_zpxind1,  kMCA_n_addr_r_zpxind2, `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DBD)
`MICROCODE( kMCA_n_addr_r_zpxind2,  kMCA_n_addr_r_zpxind3, `AB_ABn `AB_INC `ADL_ALU `BSEL_DB)
`MICROCODE( kMCA_n_addr_r_zpxind3,  0, `AB_ADn `ADH_ALU `BSEL_DB `DBO_DREG `NEXT_A1)

// 6502 write (zp,x) - This only supports STA and so no microcode branching required
`MICROCODE( kMCA_n_addr_w_zpxind0,  kMCA_n_addr_w_zpxind1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `ALU_ORA `BSEL_DB)
`MICROCODE( kMCA_n_addr_w_zpxind1,  kMCA_n_addr_w_zpxind2, `AB_ABn `ABH_B `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DBD)
`MICROCODE( kMCA_n_addr_w_zpxind2,  kMCA_n_addr_w_zpxind3, `AB_ABn `AB_INC `ADL_ALU `BSEL_DB)
`MICROCODE( kMCA_n_addr_w_zpxind3,  kMCA_e_mem_fetch, `AB_ADn `ADH_ALU `BSEL_DB `DBO_DREG `WRITE `DREG_DO_A)

// 6502 read (zp),y - Uses extra cycle to deal with address generation after carry (if needed)
`MICROCODE( kMCA_n_addr_r_zpindy0,  kMCA_n_addr_r_zpindy1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB)
`MICROCODE( kMCA_n_addr_r_zpindy1,  kMCA_n_addr_r_zpindy2, `AB_ABn `AB_INC `ADL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB)
`MICROCODE( kMCA_n_addr_r_zpindy2,  kMCA_n_addr_r_zpindy3, `AB_ADn `ADH_ALU `ALU_ORA `BSEL_DB `CSEL_0 `DBO_DREG `NEXT_A1 `NEXT_COND_LC)
`MICROCODE( kMCA_n_addr_r_zpindy3,  0, `AB_ADn `ADH_ALU `ALU_ADC `BSEL_DBD `CSEL_1 `DBO_DREG `NEXT_A1)

// 6502 Write (zp),y - This only supports STA and so no microcode branching required
`MICROCODE( kMCA_n_addr_w_zpindy0,  kMCA_n_addr_w_zpindy1, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB)
`MICROCODE( kMCA_n_addr_w_zpindy1,  kMCA_n_addr_w_zpindy2, `AB_ABn `AB_INC `ADL_ALU `ALU_ADC `ASEL_DREG `DREG_Y `BSEL_DB)
`MICROCODE( kMCA_n_addr_w_zpindy2,  kMCA_n_addr_w_zpindy3, `AB_ADn `ADH_ALU `ALU_ORA `BSEL_DB `CSEL_0 `DBO_DREG)
`MICROCODE( kMCA_n_addr_w_zpindy3,  kMCA_e_mem_fetch, `AB_ADn `ADH_ALU `ALU_ADC `BSEL_DBD `CSEL_D `DBO_DREG `WRITE `DREG_DO_A)

`define A0_A1_ADDR_4510(_opcode, _addr0, _addr1) a0_addr[{1'b0,_opcode}] = _addr0; a1_addr[{1'b0,_opcode}] = _addr1;
`define A0_A1_ADDR_6502(_opcode, _addr0, _addr1) a0_addr[{1'b1,_opcode}] = _addr0; a1_addr[{1'b1,_opcode}] = _addr1;

`include "4510_table.vh"
`include "6502_table.vh"

end

always @(*) begin
  next_mca_a0 = a0_addr[{slow,ir}];
  next_mca_a1 = a1_addr[{slow,ir}];
end

// microcode outputs wired to specific bits
assign mc_sync   = mc_out[`kSYNC_BITS];
assign next_mca_ucode = mc_out[`kNEXT_ADDR_BITS];
assign next_mca_sel = mc_out[`kNEXT_ADDR_SEL_BITS];
assign alua_sel  = mc_out[`kASEL_BITS];
assign alub_sel  = mc_out[`kBSEL_BITS];
assign aluc_sel  = mc_out[`kCSEL_BITS];
assign dreg      = mc_out[`kDREG_BITS];
assign dreg_do   = mc_out[`kDREG_DO_BITS];
assign bit_inv   = mc_out[`kBIT_INV_BITS];
assign areg      = mc_out[`kAREG_BITS];
assign alu_sel   = mc_out[`kALU_BITS];
assign dbo_sel   = mc_out[`kDBO_BITS];
assign ab_sel    = mc_out[`kAB_BITS];
assign pc_inc    = mc_out[`kPC_INC_BITS];
assign pch_sel   = mc_out[`kPCH_BITS];
assign pcl_sel   = mc_out[`kPCL_BITS];
assign sp_incdec = mc_out[`kSP_CNT_BITS];
assign sph_sel   = mc_out[`kSPH_SEL_BITS];
assign spl_sel   = mc_out[`kSPL_SEL_BITS];
assign ab_inc    = mc_out[`kAB_INC_BITS];
assign abh_sel   = mc_out[`kABH_SEL_BITS];
assign abl_sel   = mc_out[`kABL_SEL_BITS];
assign adh_sel   = mc_out[`kADH_SEL_BITS];
assign adl_sel   = mc_out[`kADL_SEL_BITS];
assign load_reg  = mc_out[`kLOAD_REG_BITS];
assign load_flags = mc_out[`kLOAD_FLAGS_BITS];
assign word_z     = mc_out[`kWORD_Z_BITS];
assign write      = mc_out[`kWRITE_BITS];
assign test_flags = mc_out[`kTEST_FLAGS_BITS];
assign test_flag0 = mc_out[`kTEST_FLAG0_BITS];
assign map        = mc_out[`kMAP_BITS];
assign mc_cond      = mc_out[`kNEXT_COND_BITS];

always @(posedge clk)
begin
  //$display("mc[%03x] ir: %02x next: %03x mc_sync: %01d alu: %03b bits: %065b",next_mca,ir,mc[next_mca][`kNEXT_ADDR_BITS],mc[next_mca][`kSYNC_BITS],mc[next_mca][`kALU_BITS],mc[next_mca]);
  if(ready | reset)
  begin
    mc_out <= mc[next_mca];
    if(mc[next_mca][`kLOAD_REG_BITS] == `kLOAD_KILL)
    begin
      $display("unimplemented microcode insn: %03x",next_mca);
      $finish;
    end
  end
//  if(write == 1)
//  begin
//      $display("mc write!");
//        $finish;
//  end
end

endmodule


`undef MICROCODE

`undef BRK
`undef ADDR_zp_
`undef ADDR_zp_x_ind_
`undef ADDR_abs_
`undef ADDR_abs_x_
`undef ADDR_abs_y_
`undef ADDR_zp_ind_y_
`undef ADDR_zp_ind_
`undef ADDR_zp_x_
`undef ADDR_zp_y_
`undef ADDR_jmp_abs
`undef ADDR_jmp_abs_x

`undef ADDR_zp
`undef ADDR_zp_w
`undef ADDR_zp_x_ind
`undef ADDR_zp_x_ind_w
`undef ADDR_abs
`undef ADDR_abs_w
`undef ADDR_abs_x
`undef ADDR_abs_x_w
`undef ADDR_abs_y
`undef ADDR_abs_y_w
`undef ADDR_zp_ind_y
`undef ADDR_zp_ind_y_w
`undef ADDR_zp_ind
`undef ADDR_zp_ind_w
`undef ADDR_zp_x
`undef ADDR_zp_x_w
`undef ADDR_zp_y
`undef ADDR_zp_y_w

`undef ALUA
`undef BIT
`undef STx
`undef LDx
`undef BRA

// BBx
`undef BBR
`undef BBS

`undef SHIFT_MEM

`undef SHIFT_A
`undef FLAG_OP

`undef Txx

`undef DEC_REG
`undef INC_REG
`undef DEC_MEM
`undef INC_MEM

`undef PUSH
`undef PULL

`undef JSR
`undef RTI
`undef JMP
`undef RTS
`undef TRB
`undef TSB
`undef RMB
`undef SMB

`undef NOP1_1
`undef NOP1_2
`undef NOP2_2
`undef NOP2_3
`undef NOP2_4
`undef NOP3_4
`undef NOP3_8

`undef ORA
`undef AND
`undef EOR
`undef ADC
`undef SBC
`undef CMP
`undef CPX
`undef CPY


`undef LDA
`undef LDX
`undef LDY

`undef ASL_MEM
`undef ROL_MEM
`undef LSR_MEM
`undef ROR_MEM

`undef ASL_A
`undef ROL_A
`undef LSR_A
`undef ROR_A
