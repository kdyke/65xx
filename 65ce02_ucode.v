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
                input ready,
                input [7:0] ir,
                input [2:0] t,
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
                output map);

reg [`kMICROCODE_BITS] mc_out;
(* rom_style = "block" *) reg [`kMICROCODE_BITS] mc[0:2047];

// synthesis translate off
reg [12:0] i;
// synthesis translate on

initial begin

// synthesis translate off
// Init all microcode slots we haven't implemented with a state that halts
for( i = 0; i < 2048; i = i + 1 )
begin
   mc[i][`kLOAD_REG_BITS] = `kLOAD_KILL;
   //$display("init %d",i);
end
// synthesis translate on

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

// TODO - Move all the microcode related `defines to a separate file that's not visible to the rest
// of the code, since it's supposed to be an implementation detail.

//`define Tn    3'd0        // Go to T+1 (default)
//`define T1    3'd1        // Go to T1 (sync)
//`define TKL   3'd3        // Halt CPU - Unimplemented microcode entry

`define MICROCODE(_ins, _t, _bits) mc[(_ins << 3) | _t] = 0 _bits;

`define BRK(_insbyte) \
`MICROCODE( _insbyte, 2, `AB_SPn `PC_INC  `DBO_PCHn                    `WRITE   ) \
`MICROCODE( _insbyte, 3, `AB_SPn          `SP_DEC `AREG_PCL `ASEL_AREG `WRITE   ) \
`MICROCODE( _insbyte, 4, `AB_SPn          `SP_DEC `BSEL_P              `WRITE   ) \
`MICROCODE( _insbyte, 5, `AB_ABn `ABH_VEC `ABL_ALU `SP_DEC  `ASEL_VEC           ) \
`MICROCODE( _insbyte, 6, `AB_ABn `AB_INC  `ADL_ALU `BSEL_DB `FLAGS_SETI         ) \
`MICROCODE( _insbyte, 7, `AB_PCn          `BSEL_DB `PCH_ALU `PCL_ADL `SYNC      ) \
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
`MICROCODE( _insbyte,  3, `AB_SPn `SP_INC `FLAGS_RTI) \
`MICROCODE( _insbyte,  4, `AB_SPn `SP_INC `ADL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  5, `ALU_ADC `BSEL_DB `CSEL_0 `PCH_ALU `PCL_ADL `SYNC) \
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
`MICROCODE( _insbyte,  6, `AB_ABn `AB_INC `ADL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  7, `AB_PCn `PCH_ALU `BSEL_DB `PCL_ADL `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define JSRINDX(_insbyte) \
`MICROCODE( _insbyte,  2, `PC_INC `AB_SPn `ABL_ALU `ALU_ADC `ASEL_DREG `DREG_X `BSEL_DB `DBO_PCHn `WRITE) \
`MICROCODE( _insbyte,  3, `AB_SPn `SP_DEC `ASEL_AREG `AREG_PCL `WRITE) \
`MICROCODE( _insbyte,  4, `AB_PCn `SP_DEC) \
`MICROCODE( _insbyte,  5, `AB_ABn `ABH_ALU `ALU_ADC `BSEL_DB `CSEL_D ) \
`MICROCODE( _insbyte,  6, `AB_ABn `AB_INC `ADL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  7, `AB_PCn `PCH_ALU `BSEL_DB `PCL_ADL `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define RTN(_insbyte) \
`MICROCODE( _insbyte,  2, `ABL_ALU `ASEL_AREG `AREG_PCL) \
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
`MICROCODE( _insbyte,  3, `AB_ABn `PC_INC `ABH_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  4, `AB_ABn `ALU_SHL `ASEL_DB `CSEL_0 `WRITE `FLAGS_CNZ) \
`MICROCODE( _insbyte,  5, `AB_ABn `AB_INC) \
`MICROCODE( _insbyte,  6, `AB_ABn `ALU_SHL `ASEL_DB `CSEL_P `WRITE `FLAGS_CNZ `WORD_Z) \
`MICROCODE( _insbyte,  7, `SYNC) \
`MICROCODE( _insbyte,  1, `PC_INC)

`define ROW(_insbyte) \
`MICROCODE( _insbyte,  2, `AB_PCn `PC_INC `ABL_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  3, `AB_ABn `PC_INC `ABH_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  4, `AB_ABn `ALU_SHL `ASEL_DB `CSEL_P `WRITE `FLAGS_CNZ) \
`MICROCODE( _insbyte,  5, `AB_ABn `AB_INC) \
`MICROCODE( _insbyte,  6, `AB_ABn `ALU_SHL `ASEL_DB `CSEL_P `WRITE `FLAGS_CNZ `WORD_Z) \
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
`MICROCODE( _insbyte,  3, `PC_INC `AB_ABn `ABH_ALU `BSEL_DB) \
`MICROCODE( _insbyte,  4, `AB_SPn `AB_INC `DBO_DI `WRITE) \
`MICROCODE( _insbyte,  5, `AB_ABn `SP_DEC) \
`MICROCODE( _insbyte,  6, `AB_SPn `DBO_DI `WRITE) \
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
`MICROCODE( _insbyte,  2, `DBO_DREG `DREG_DO_A `MC_MAP) \
`MICROCODE( _insbyte,  3, `DBO_DREG `DREG_DO_X `MC_MAP) \
`MICROCODE( _insbyte,  4, `DBO_DREG `DREG_DO_Y `MC_MAP) \
`MICROCODE( _insbyte,  5, `DBO_DREG `DREG_DO_Z `MC_MAP `SYNC) \
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
`MICROCODE( _insbyte,  5, `AB_ADn `ADH_ALU `ALU_ADC `BSEL_DB `CSEL_D `DBO_DREG _args) \

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

                                    `BRK(8'h00)       // BRK

                                    `FLAG_OP(8'h18, `FLAGS_C) // CLC
                                    `FLAG_OP(8'h38, `FLAGS_C) // SEC
                                    `FLAG_OP(8'h58, `FLAGS_I) // CLI
                                    `FLAG_OP2(8'h78, `FLAGS_I) // SEI
                                    `FLAG_OP(8'hB8, `FLAGS_V) // CLV
                                    `FLAG_OP(8'hD8, `FLAGS_D) // CLD
                                    `FLAG_OP(8'hF8, `FLAGS_D) // SED

                                    `Txx(8'h8A, `ASEL_DREG `DREG_X `LOAD_A `FLAGS_SBZN)   // TXA
                                    `Txx(8'h98, `ASEL_DREG `DREG_Y `LOAD_A `FLAGS_SBZN)   // TYA
                                    `Txx(8'h9A, `ASEL_DREG `DREG_X `SPL_ALU)              // TXS
                                    `Txx(8'hA8, `ASEL_DREG `DREG_A `LOAD_Y `FLAGS_SBZN)   // TAY
                                    `Txx(8'hAA, `ASEL_DREG `DREG_A `LOAD_X `FLAGS_SBZN)   // TAX
                                    `Txx(8'hBA, `ASEL_AREG `AREG_SPL `LOAD_X `FLAGS_SBZN) // TSX

`ADDR_zp_x_ind(8'h01)               `ORA(8'h01,5,|0)        // ORA (zp,x)
`ADDR_zp(8'h05)                     `ORA(8'h05,3,|0)        // ORA zp
                                    `ORA(8'h09,2,`PC_INC)   // ORA #
`ADDR_abs(8'h0D)                    `ORA(8'h0D,4,|0)        // ORA abs
`ADDR_zp_ind_y(8'h11)               `ORA(8'h11,5,|0)        // ORA (zp),y
`ADDR_zp_x(8'h15)                   `ORA(8'h15,3,|0)        // ORA zp,x
`ADDR_abs_y(8'h19)                  `ORA(8'h19,4,|0)        // ORA abs,y
`ADDR_abs_x(8'h1D)                  `ORA(8'h1D,4,|0)        // ORA abs,x

`ADDR_zp_x_ind(8'h21)               `AND(8'h21,5,|0)        // AND (zp,x)
`ADDR_zp(8'h25)                     `AND(8'h25,3,|0)        // AND zp
                                    `AND(8'h29,2,`PC_INC)   // AND #
`ADDR_abs(8'h2D)                    `AND(8'h2D,4,|0)        // AND abs
`ADDR_zp_ind_y(8'h31)               `AND(8'h31,5,|0)        // AND (zp),y
`ADDR_zp_x(8'h35)                   `AND(8'h35,3,|0)        // AND zp,x
`ADDR_abs_y(8'h39)                  `AND(8'h39,4,|0)        // AND abs,y
`ADDR_abs_x(8'h3D)                  `AND(8'h3D,4,|0)        // AND abs,x

`ADDR_zp_x_ind(8'h41)               `EOR(8'h41,5,|0)        // EOR (zp,x)
`ADDR_zp(8'h45)                     `EOR(8'h45,3,|0)        // EOR zp
                                    `EOR(8'h49,2,`PC_INC)   // EOR #
`ADDR_abs(8'h4D)                    `EOR(8'h4D,4,|0)        // EOR abs
`ADDR_zp_ind_y(8'h51)               `EOR(8'h51,5,|0)        // EOR (zp),y
`ADDR_zp_x(8'h55)                   `EOR(8'h55,3,|0)        // EOR zp,x
`ADDR_abs_y(8'h59)                  `EOR(8'h59,4,|0)        // EOR abs,y
`ADDR_abs_x(8'h5D)                  `EOR(8'h5D,4,|0)        // EOR abs,x

`ADDR_zp_x_ind(8'h61)               `ADC(8'h61,5,|0)        // ADC (zp,x)
`ADDR_zp(8'h65)                     `ADC(8'h65,3,|0)        // ADC zp
                                    `ADC(8'h69,2,`PC_INC)   // ADC #
`ADDR_abs(8'h6D)                    `ADC(8'h6D,4,|0)        // ADC abs
`ADDR_zp_ind_y(8'h71)               `ADC(8'h71,5,|0)        // ADC (zp),y
`ADDR_zp_x(8'h75)                   `ADC(8'h75,3,|0)        // ADC zp,x
`ADDR_abs_y(8'h79)                  `ADC(8'h79,4,|0)        // ADC abs,y
`ADDR_abs_x(8'h7D)                  `ADC(8'h7D,4,|0)        // ADC abs,x

`ADDR_zp_x_ind_w(8'h81,`DREG_DO_A)  `STx(8'h81,5)           // STA (zp,x)
`ADDR_zp_w(8'h84, `DREG_DO_Y)       `STx(8'h84,3)           // STY zp
`ADDR_zp_w(8'h85, `DREG_DO_A)       `STx(8'h85,3)           // STA zp
`ADDR_zp_w(8'h86, `DREG_DO_X)       `STx(8'h86,3)           // STX zp
`ADDR_abs_w(8'h8C, `DREG_DO_Y)      `STx(8'h8C,4)           // STY abs
`ADDR_abs_w(8'h8D, `DREG_DO_A)      `STx(8'h8D,4)           // STA abs
`ADDR_abs_w(8'h8E, `DREG_DO_X)      `STx(8'h8E,4)           // STX abs
`ADDR_zp_ind_y_w(8'h91, `DREG_DO_A) `STx(8'h91,5)           // STA (zp),y
`ADDR_zp_x_w(8'h94, `DREG_DO_Y)     `STx(8'h94,3)           // STY zp,x
`ADDR_zp_x_w(8'h95, `DREG_DO_A)     `STx(8'h95,3)           // STA zp,x
`ADDR_zp_y_w(8'h96, `DREG_DO_X)     `STx(8'h96,3)           // STX zp,y
`ADDR_abs_y_w(8'h99, `DREG_DO_A)    `STx(8'h99,4)           // STA abs,y
`ADDR_abs_x_w(8'h9D, `DREG_DO_A)    `STx(8'h9D,4)           // STA abs,x

                                    `LDY(8'hA0,2,`PC_INC)     // LDY #
`ADDR_zp_x_ind(8'hA1)               `LDA(8'hA1,5,|0)          // LDA (zp,x)
                                    `LDX(8'hA2,2,`PC_INC)     // LDX #
`ADDR_zp(8'hA4)                     `LDY(8'hA4,3,|0)          // LDY zp
`ADDR_zp(8'hA5)                     `LDA(8'hA5,3,|0)          // LDA zp
`ADDR_zp(8'hA6)                     `LDX(8'hA6,3,|0)          // LDX zp
                                    `LDA(8'hA9,2,`PC_INC)     // LDA #
`ADDR_abs(8'hAC)                    `LDY(8'hAC,4,|0)          // LDY abs
`ADDR_abs(8'hAD)                    `LDA(8'hAD,4,|0)          // LDA abs
`ADDR_abs(8'hAE)                    `LDX(8'hAE,4,|0)          // LDX abs
`ADDR_zp_ind_y(8'hB1)               `LDA(8'hB1,5,|0)          // LDA (zp),y
`ADDR_zp_x(8'hB4)                   `LDY(8'hB4,3,|0)          // LDY zp,x
`ADDR_zp_x(8'hB5)                   `LDA(8'hB5,3,|0)          // LDA zp,x
`ADDR_zp_y(8'hB6)                   `LDX(8'hB6,3,|0)          // LDX zp,y
`ADDR_abs_x(8'hBC)                  `LDY(8'hBC,4,|0)          // LDY abs,x
`ADDR_abs_y(8'hB9)                  `LDA(8'hB9,4,|0)          // LDA abs,y
`ADDR_abs_x(8'hBD)                  `LDA(8'hBD,4,|0)          // LDA abs,x
`ADDR_abs_y(8'hBE)                  `LDX(8'hBE,4,|0)          // LDA abs,x

                                    `CPY(8'hC0,2,`PC_INC)     // CPY #
`ADDR_zp_x_ind(8'hC1)               `CMP(8'hC1,5,|0)          // CMP (zp,x)
`ADDR_zp(8'hC4)                     `CPY(8'hC4,3,|0)          // CPY zp
`ADDR_zp(8'hC5)                     `CMP(8'hC5,3,|0)          // CMP zp
                                    `CMP(8'hC9,2,`PC_INC)     // CMP #
`ADDR_abs(8'hCC)                    `CPY(8'hCC,4,|0)          // CPY abs
`ADDR_abs(8'hCD)                    `CMP(8'hCD,4,|0)          // CMP abs
`ADDR_zp_ind_y(8'hD1)               `CMP(8'hD1,5,|0)          // CMP (zp),y
`ADDR_zp_x(8'hD5)                   `CMP(8'hD5,3,|0)          // CMP zp,x
`ADDR_abs_y(8'hD9)                  `CMP(8'hD9,4,|0)          // CMP abs,y
`ADDR_abs_x(8'hDD)                  `CMP(8'hDD,4,|0)          // CMP abs,x
                                    `CPX(8'hE0,2,`PC_INC)     // CPX #
`ADDR_zp(8'hE4)                     `CPX(8'hE4,3,|0)          // CPX zp
`ADDR_abs(8'hEC)                    `CPX(8'hEC,4,|0)          // CPX abs

`ADDR_zp_x_ind(8'hE1)               `SBC(8'hE1,5,|0)          // SBC (zp,x)
`ADDR_zp(8'hE5)                     `SBC(8'hE5,3,|0)          // SBC zp
                                    `SBC(8'hE9,2,`PC_INC)     // SBC #
`ADDR_abs(8'hED)                    `SBC(8'hED,4,|0)          // SBC abs
`ADDR_zp_ind_y(8'hF1)               `SBC(8'hF1,5,|0)          // SBC (zp),y
`ADDR_zp_x(8'hF5)                   `SBC(8'hF5,3,|0)          // SBC zp,x
`ADDR_abs_y(8'hF9)                  `SBC(8'hF9,4,|0)          // SBC abs,y
`ADDR_abs_x(8'hFD)                  `SBC(8'hFD,4,|0)          // SBC abs,x

`ADDR_zp(8'h24)                     `BIT(8'h24,3,`FLAGS_BIT)  // BIT zp
`ADDR_abs(8'h2C)                    `BIT(8'h2C,4,`FLAGS_BIT)  // BIT abs

                                    `BPL(8'h10) // BPL
                                    `BMI(8'h30) // BMI
                                    `BVC(8'h50) // BVC
                                    `BVS(8'h70) // BVS
                                    `BRA(8'h80) // BRA
                                    `BCC(8'h90) // BCC
                                    `BCS(8'hB0) // BCS
                                    `BNE(8'hD0) // BNE
                                    `BEQ(8'hF0) // BEQ

                                    `DEC_REG(8'h88, `ASEL_DREG `DREG_Y `LOAD_Y) // DEY
                                    `DEC_REG(8'hCA, `ASEL_DREG `DREG_X `LOAD_X) // DEX

                                    `INC_REG(8'hC8, `ASEL_DREG `DREG_Y `LOAD_Y) // INY
                                    `INC_REG(8'hE8, `ASEL_DREG `DREG_X `LOAD_X) // INX

                                    `NOP(8'hEA)         // NOP/ENDM

                                    `PUSH(8'h08, `BSEL_P)           // PHP
                                    `PUSH(8'h48, `ASEL_DREG `DREG_A)           // PHA
                                    `PUSH(8'hDA, `ASEL_DREG `DREG_X)           // PHX
                                    `PUSH(8'h5A, `ASEL_DREG `DREG_Y)           // PHY

                                    `PULL(8'h28, `FLAGS_DB)                     // PLP
                                    `PULL(8'h68, `BSEL_DB `LOAD_A `FLAGS_SBZN)  // PLA
                                    `PULL(8'hFA, `BSEL_DB `LOAD_X `FLAGS_SBZN)  // PLX
                                    `PULL(8'h7A, `BSEL_DB `LOAD_Y `FLAGS_SBZN)  // PLY

                                    `JMP(8'h4C)         // JMP abs
                                    `JMPIND(8'h6C)      // JMP (abs)

                                    `JSR(8'h20)       // JSR
                                    `RTS(8'h60)       // RTS
                                    `RTI(8'h40)       // RTI

`ADDR_zp(8'h06)                     `ASL_MEM(8'h06, 3, `AB_ABn)     // ASL zp
                                    `ASL_A(8'h0A)                   // ASL a
`ADDR_abs(8'h0E)                    `ASL_MEM(8'h0E, 4, `AB_ABn)     // ASL abs
`ADDR_zp_x(8'h16)                   `ASL_MEM(8'h16, 3, `AB_ABn)     // ASL zp,x
`ADDR_abs_x(8'h1E)                  `ASL_MEM(8'h1E, 4, `AB_ABn)     // ASL abs,x

`ADDR_zp(8'h26)                     `ROL_MEM(8'h26, 3, `AB_ABn)     // ROL zp
                                    `ROL_A(8'h2A)                   // ROL a
`ADDR_abs(8'h2E)                    `ROL_MEM(8'h2E, 4, `AB_ABn)     // ROL abs
`ADDR_zp_x(8'h36)                   `ROL_MEM(8'h36, 3, `AB_ABn)     // ROL zp,x
`ADDR_abs_x(8'h3E)                  `ROL_MEM(8'h3E, 4, `AB_ABn)     // ROL abs,x

`ADDR_zp(8'h46)                     `LSR_MEM(8'h46, 3, `AB_ABn)     // LSR zp
                                    `LSR_A(8'h4A)                   // LSR a
`ADDR_abs(8'h4E)                    `LSR_MEM(8'h4E, 4, `AB_ABn)     // LSR abs
`ADDR_zp_x(8'h56)                   `LSR_MEM(8'h56, 3, `AB_ABn)     // LSR zp,x
`ADDR_abs_x(8'h5E)                  `LSR_MEM(8'h5E, 4, `AB_ABn)     // LSR abs,x

`ADDR_zp(8'h66)                     `ROR_MEM(8'h66, 3, `AB_ABn)     // ROR zp
                                    `ROR_A(8'h6A)                   // ROR a
`ADDR_abs(8'h6E)                    `ROR_MEM(8'h6E, 4, `AB_ABn)     // ROR abs
`ADDR_zp_x(8'h76)                   `ROR_MEM(8'h76, 3, `AB_ABn)     // ROR zp,x
`ADDR_abs_x(8'h7E)                  `ROR_MEM(8'h7E, 4, `AB_ABn)     // ROR abs,x

`ADDR_zp(8'hC6)                     `DEC_MEM(8'hC6, 3, `AB_ABn)     // DEC zp
`ADDR_abs(8'hCE)                    `DEC_MEM(8'hCE, 4, `AB_ABn)     // DEC abs
`ADDR_zp_x(8'hD6)                   `DEC_MEM(8'hD6, 3, `AB_ABn)     // DEC zp,x
`ADDR_abs_x(8'hDE)                  `DEC_MEM(8'hDE, 4, `AB_ABn)     // DEC abs,x

`ADDR_zp(8'hE6)                     `INC_MEM(8'hE6, 3, `AB_ABn)     // INC zp
`ADDR_abs(8'hEE)                    `INC_MEM(8'hEE, 4, `AB_ABn)     // INC abs
`ADDR_zp_x(8'hF6)                   `INC_MEM(8'hF6, 3, `AB_ABn)     // INC zp,x
`ADDR_abs_x(8'hFE)                  `INC_MEM(8'hFE, 4, `AB_ABn)     // INC abs,x

                                    // "Standard" CMOS Extensions
                                    `JMPINDX(8'h7C)    // JMP (abs,x)

                                    `DEC_REG(8'h3A, `ASEL_DREG `DREG_A `LOAD_A) // DEY
                                    `INC_REG(8'h1A, `ASEL_DREG `DREG_A `LOAD_A) // INX

                                    // (zp),z
`ADDR_zp_ind_z(8'h12)               `ORA(8'h12,5,|0)
`ADDR_zp_ind_z(8'h32)               `AND(8'h32,5,|0)
`ADDR_zp_ind_z(8'h52)               `EOR(8'h52,5,|0)
`ADDR_zp_ind_z(8'h72)               `ADC(8'h72,5,|0)
`ADDR_zp_ind_z_w(8'h92, `DREG_DO_A) `STx(8'h92,5)
`ADDR_zp_ind_z(8'hB2)               `LDA(8'hB2,5,|0)
`ADDR_zp_ind_z(8'hD2)               `CMP(8'hD2,5,|0)
`ADDR_zp_ind_z(8'hF2)               `SBC(8'hF2,5,|0)

                                    // STZ
`ADDR_zp_w(8'h64, `DREG_DO_Z)       `STx(8'h64,3)             // STZ zp
`ADDR_zp_x_w(8'h74, `DREG_DO_Z)     `STx(8'h74,3)             // STZ zp,x
`ADDR_abs_w(8'h9C, `DREG_DO_Z)      `STx(8'h9C,4)             // STZ abs
`ADDR_abs_x_w(8'h9E, `DREG_DO_Z)    `STx(8'h9E,4)             // STZ abs,x

                                    `BITIMM(8'h89)            // BIT #
`ADDR_zp_x(8'h34)                   `BIT(8'h34,3,`FLAGS_BIT)  // BIT zp
`ADDR_abs_x(8'h3C)                  `BIT(8'h3C,4,`FLAGS_BIT)  // BIT abs

                                    `BBR(8'h0F)               // BBR 0
                                    `BBR(8'h1F)               // BBR 0
                                    `BBR(8'h2F)               // BBR 0
                                    `BBR(8'h3F)               // BBR 0
                                    `BBR(8'h4F)               // BBR 0
                                    `BBR(8'h5F)               // BBR 0
                                    `BBR(8'h6F)               // BBR 0
                                    `BBR(8'h7F)               // BBR 0
                                    `BBS(8'h8F)               // BBR 0
                                    `BBS(8'h9F)               // BBR 0
                                    `BBS(8'hAF)               // BBR 0
                                    `BBS(8'hBF)               // BBR 0
                                    `BBS(8'hCF)               // BBR 0
                                    `BBS(8'hDF)               // BBR 0
                                    `BBS(8'hEF)               // BBR 0
                                    `BBS(8'hFF)               // BBR 0

`ADDR_zp(8'h14)                     `TRB(8'h14, 3)            // TRB zp
`ADDR_abs(8'h1C)                    `TRB(8'h1C, 4)            // TRB abs

`ADDR_zp(8'h04)                     `TSB(8'h04, 3)            // TSB zp
`ADDR_abs(8'h0C)                    `TSB(8'h0C, 4)            // TSB abs

                            // WDC65C02 and Rockwell extensions
`ADDR_zp(8'h07)                     `RMB(8'h07)     // RMB0 zp
`ADDR_zp(8'h17)                     `RMB(8'h17)     // RMB1 zp
`ADDR_zp(8'h27)                     `RMB(8'h27)     // RMB2 zp
`ADDR_zp(8'h37)                     `RMB(8'h37)     // RMB3 zp
`ADDR_zp(8'h47)                     `RMB(8'h47)     // RMB4 zp
`ADDR_zp(8'h57)                     `RMB(8'h57)     // RMB5 zp
`ADDR_zp(8'h67)                     `RMB(8'h67)     // RMB6 zp
`ADDR_zp(8'h77)                     `RMB(8'h77)     // RMB7 zp

`ADDR_zp(8'h87)                     `SMB(8'h87)     // SMB0 zp
`ADDR_zp(8'h97)                     `SMB(8'h97)     // SMB1 zp
`ADDR_zp(8'hA7)                     `SMB(8'hA7)     // SMB2 zp
`ADDR_zp(8'hB7)                     `SMB(8'hB7)     // SMB3 zp
`ADDR_zp(8'hC7)                     `SMB(8'hC7)     // SMB4 zp
`ADDR_zp(8'hD7)                     `SMB(8'hD7)     // SMB5 zp
`ADDR_zp(8'hE7)                     `SMB(8'hE7)     // SMB6 zp
`ADDR_zp(8'hF7)                     `SMB(8'hF7)     // SMB7 zp

                                    // 65CE02/4510 opcodes
                                    `FLAG_OP2(8'h02, `FLAGS_E) // CLE
                                    `FLAG_OP2(8'h03, `FLAGS_E) // SEE

                                    `Txx(8'h0B, `ASEL_AREG `AREG_SPH `LOAD_Y `FLAGS_SBZN)   // TSY
                                    `Txx(8'h2B, `ASEL_DREG `DREG_Y `SPH_ALU)                // TYS
                                    `Txx(8'h4B, `ASEL_DREG `DREG_A `LOAD_Z `FLAGS_SBZN)     // TAZ
                                    `Txx(8'h6B, `ASEL_DREG `DREG_Z `LOAD_A `FLAGS_SBZN)     // TZA
                                    `Txx(8'h5B, `ASEL_DREG `DREG_A `LOAD_B )                // TAB
                                    `Txx(8'h7B, `BSEL_B `LOAD_A `FLAGS_SBZN)                // TBA

                                    `NEG(8'h42)       // NEG acc
                                    `ASR_A(8'h43)     // ASR acc

                                    `LDZ(8'hA3,2,`PC_INC)     // LDZ #
`ADDR_abs(8'hAB)                    `LDZ(8'hAB,4,|0)          // LDZ abs
`ADDR_abs_x(8'hBB)                  `LDZ(8'hBB,4,|0)          // LDZ abs,x

                                    `CPZ(8'hC2,2,`PC_INC)     // CPZ #
`ADDR_zp(8'hD4)                     `CPZ(8'hD4,3,|0)          // CPZ zp
`ADDR_abs(8'hDC)                    `CPZ(8'hDC,4,|0)          // CPZ abs
                                    
`ADDR_zp(8'h44)                     `ASR_MEM(8'h44, 3, `AB_ABn)     // ROR zp
`ADDR_zp_x(8'h54)                   `ASR_MEM(8'h54, 3, `AB_ABn)     // ROR zp,x

`ADDR_abs_x_w(8'h8B, `DREG_DO_Y)    `STx(8'h8B,4)           // STY abs,x
`ADDR_abs_y_w(8'h9B, `DREG_DO_X)    `STx(8'h9B,4)           // STX abs,y

                                    `INC_REG(8'h1B, `ASEL_DREG `DREG_Z `LOAD_Z) // INZ
                                    `DEC_REG(8'h3B, `ASEL_DREG `DREG_Z `LOAD_Z) // DEZ

                                    `PUSH(8'hDB, `ASEL_DREG `DREG_Z)            // PHZ
                                    `PULL(8'hFB, `BSEL_DB `LOAD_Z `FLAGS_SBZN)  // PLZ

                                    `BPLW(8'h13)      // Word relative
                                    `BMIW(8'h33)      // Word relative
                                    `BVCW(8'h53)      // Word relative
                                    `BVSW(8'h73)      // Word relative
                                    `BRAW(8'h83)      // Word relative
                                    `BCCW(8'h93)      // Word relative
                                    `BCSW(8'hB3)      // Word relative
                                    `BNEW(8'hD3)      // Word relative
                                    `BEQW(8'hF3)      // Word relative

                                    `BSR(8'h63)       // Word relative

                                    `JSRIND(8'h22)    // JSR (abs)
                                    `JSRINDX(8'h23)   // JSR (abs,x)

                                    `RTN(8'h62)       // RTN imm

`ADDR_sp_ind_y_w(8'h82,`DREG_DO_A)  `STx(8'h82,6)     // STA (d,SP),Y
`ADDR_sp_ind_y(8'hE2)               `LDA(8'hE2,6,|0)  // LDA (d,SP),Y

                                    `DEW(8'hC3)       // DEW zp
                                    `INW(8'hE3)       // INW zp

                                    `ASW(8'hCB)       // ASW abs
                                    `ROW(8'hEB)       // ROW abs

                                    `PHWIMM(8'hF4)    // PHW imm
                                    `PHWABS(8'hFC)    // PHW abs

                                    `MAP(8'h5C)       // 65CE02 AUG, 4510 MAP

end

// microcode outputs wired to specific bits
assign mc_sync   = mc_out[`kSYNC_BITS];
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

always @(posedge clk)
begin
  //$display("mc[%02x|%d] sync: %01d alu: %03b bits: %051b",ir,t,mc[{ir, t}][`SYNC_BITS],mc[{ir, t}][`ALU_BITS],mc[{ir, t}]);
  if(ready)
  begin
    mc_out <= mc[{ir, t}];
    if(mc[{ir, t}][`kLOAD_REG_BITS] == `kLOAD_KILL)
    begin
      $display("unimplemented microcode insn: %02x cycle: %d",ir,t);
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
