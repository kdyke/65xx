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
                output map);

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

`define NEXT_UCODE  |(0               << `FIELD_SHIFT(`kNEXT_ADDR_SEL_BITS))    // Default
`define NEXT_A0     |(1               << `FIELD_SHIFT(`kNEXT_ADDR_SEL_BITS))    // Basically SYNC
`define NEXT_A1     |(2               << `FIELD_SHIFT(`kNEXT_ADDR_SEL_BITS))    // "Execution" phase after addressing

// TODO - Move all the microcode related `defines to a separate file that's not visible to the rest
// of the code, since it's supposed to be an implementation detail.

//`define Tn    3'd0        // Go to T+1 (default)
//`define T1    3'd1        // Go to T1 (sync)
//`define TKL   3'd3        // Halt CPU - Unimplemented microcode entry

// Microcode addresses in block RAM.

// 65CE02 microcode addresses.  Currently 246 of them.  Could probably be reduced a little bit here and there in a few spots.
localparam  kMCA_e_brk0                 = 0,
            kMCA_e_clcsec0              = 1,
            kMCA_e_cli0                 = 2,
            kMCA_e_sei0                 = 3,
            kMCA_e_clv0                 = 4,
            kMCA_e_cldsed0              = 5,
            kMCA_e_clesee0              = 6,
            
            kMCA_e_fetch0               = 7,  // Standard fetch cycle at beginning of >1 cycle instructions
          
            kMCA_e_txa0                 = 8,
            kMCA_e_tya0                 = 9,
            kMCA_e_txs0                 = 10,
            kMCA_e_tay0                 = 11,
            kMCA_e_tax0                 = 12, 
            kMCA_e_tsx0                 = 13,
            kMCA_e_tsy0                 = 14,
            kMCA_e_tys0                 = 15,
            kMCA_e_taz0                 = 16,
            kMCA_e_tza0                 = 17,
            kMCA_e_tab0                 = 18,
            kMCA_e_tba0                 = 19,
                                    
            kMCA_e_jmp0                 = 20,
            kMCA_e_jmp1                 = 21,
            
            kMCA_e_jmpind0              = 22,
            kMCA_e_jmpind1              = 23,
            kMCA_e_jmpind2              = 24,
            kMCA_e_jmpind3              = 25,

            kMCA_e_jmpindx0             = 26,
            kMCA_e_jmpindx1             = 27,
            kMCA_e_jmpindx2             = 28,
            kMCA_e_jmpindx3             = 29,
            
            kMCA_e_bpl                  = 30,
            kMCA_e_bmi                  = 31,
            kMCA_e_bvc                  = 32,
            kMCA_e_bvs                  = 33,
            kMCA_e_bra                  = 34,
            kMCA_e_bcc                  = 35,
            kMCA_e_bcs                  = 36,
            kMCA_e_bne                  = 37,
            kMCA_e_beq                  = 38,

            kMCA_e_braw0                = 39,
            
            kMCA_e_bplw1                = 40,
            kMCA_e_bmiw1                = 41,
            kMCA_e_bvcw1                = 42,
            kMCA_e_bvsw1                = 43,
            kMCA_e_braw1                = 44,
            kMCA_e_bccw1                = 45,
            kMCA_e_bcsw1                = 46,
            kMCA_e_bnew1                = 47,
            kMCA_e_beqw1                = 48,
            
            kMCA_e_deca                 = 49,
            kMCA_e_decx                 = 50,
            kMCA_e_decy                 = 51,
            kMCA_e_decz                 = 52,

            kMCA_e_inca                 = 53,
            kMCA_e_incx                 = 54,
            kMCA_e_incy                 = 55,
            kMCA_e_incz                 = 56,
            
            kMCA_e_cmpa                 = 57,
            kMCA_e_cmpx                 = 58,
            kMCA_e_cmpy                 = 59,
            kMCA_e_cmpz                 = 60,

            kMCA_e_cmpai                = 61,
            kMCA_e_cmpxi                = 62,
            kMCA_e_cmpyi                = 63,
            kMCA_e_cmpzi                = 64,
            
            kMCA_e_lda                  = 65,
            kMCA_e_ldx                  = 66,
            kMCA_e_ldy                  = 67,
            kMCA_e_ldz                  = 68,

            kMCA_e_ldai                 = 69,
            kMCA_e_ldxi                 = 70,
            kMCA_e_ldyi                 = 71,
            kMCA_e_ldzi                 = 72,
            
            kMCA_e_adc                  = 73,
            kMCA_e_adci                 = 74,
            kMCA_e_sbc                  = 75,
            kMCA_e_sbci                 = 76,
            kMCA_e_ora                  = 77,
            kMCA_e_orai                 = 78,
            kMCA_e_and                  = 79,
            kMCA_e_andi                 = 80,
            kMCA_e_eor                  = 81,
            kMCA_e_eori                 = 82,
            
            kMCA_e_bitm0                = 83,
            kMCA_e_bitm1                = 84,
            kMCA_e_biti                 = 85,
            
            kMCA_e_asl_a                = 86,
            kMCA_e_rol_a                = 87,
            kMCA_e_lsr_a                = 88,
            kMCA_e_ror_a                = 89,

            kMCA_e_asl_mem0             = 90,
            kMCA_e_rol_mem0             = 91,
            kMCA_e_lsr_mem0             = 92,
            kMCA_e_ror_mem0             = 93,
            kMCA_e_asr_mem0             = 94,

            kMCA_e_mem_fetch            = 95,
            
            kMCA_e_push_p               = 96,
            kMCA_e_push_a               = 97,
            kMCA_e_push_x               = 98,
            kMCA_e_push_y               = 99,
            kMCA_e_push_z               = 100,
            kMCA_e_push1                = 101,
            kMCA_e_pull0                = 102,
            kMCA_e_pull_p               = 103,
            kMCA_e_pull_a               = 104,
            kMCA_e_pull_x               = 105,
            kMCA_e_pull_y               = 106,
            kMCA_e_pull_z               = 107,
            
            kMCA_e_jsr0                 = 108,
            kMCA_e_jsr1                 = 109,
            kMCA_e_jsr2                 = 110,
            kMCA_e_jsr3                 = 111,
            
            kMCA_e_rts0                 = 112,
            kMCA_e_rts1                 = 113,
            kMCA_e_rts2                 = 114,
            
            kMCA_e_rti0                 = 115,
            kMCA_e_rti1                 = 116,
            kMCA_e_rti2                 = 117,
            kMCA_e_rti3                 = 118,
            kMCA_e_neg                  = 119,
            
            kMCA_e_asr_a                = 120,
            
            kMCA_e_bsr0                 = 121,
            kMCA_e_bsr1                 = 122,
            kMCA_e_bsr2                 = 123,
            kMCA_e_bsr3                 = 124,
            
            kMCA_e_jsrind0              = 125,
            kMCA_e_jsrind1              = 126,
            kMCA_e_jsrind2              = 127,
            kMCA_e_jsrind3              = 128,
            kMCA_e_jsrind4              = 129,
            kMCA_e_jsrind5              = 130,

            kMCA_e_jsrindx0             = 131,
            kMCA_e_jsrindx1             = 132,
            kMCA_e_jsrindx2             = 133,
            kMCA_e_jsrindx3             = 134,
            kMCA_e_jsrindx4             = 135,
            kMCA_e_jsrindx5             = 136,
            
            kMCA_e_rtn0                 = 137, 
            kMCA_e_rtn1                 = 138, 
            kMCA_e_rtn2                 = 139, 
            kMCA_e_rtn3                 = 140, 
            kMCA_e_rtn4                 = 141, 
            kMCA_e_rtn5                 = 142, 
            
            kMCA_e_inw0                 = 143,
            kMCA_e_inw1                 = 144,
            kMCA_e_inw2                 = 145,
            kMCA_e_inw3                 = 146,
            
            kMCA_e_dew0                 = 147,
            kMCA_e_dew1                 = 148,
            kMCA_e_dew2                 = 149,
            kMCA_e_dew3                 = 150,
            
            kMCA_e_asw0                 = 151,
            kMCA_e_asw1                 = 152,
            kMCA_e_asw2                 = 153,
            kMCA_e_asw3                 = 154,
            kMCA_e_asw4                 = 155,
            
            kMCA_e_row0                 = 156,
            kMCA_e_row1                 = 157,
            kMCA_e_row2                 = 158,
            kMCA_e_row3                 = 159,
            kMCA_e_row4                 = 160,
            
            kMCA_e_phwi0                = 161,
            kMCA_e_phwi1                = 162,
            kMCA_e_phwi2                = 163,
            kMCA_e_phwi3                = 164,
            
            kMCA_e_phw0                 = 165,
            kMCA_e_phw1                 = 166,
            kMCA_e_phw2                 = 167,
            kMCA_e_phw3                 = 168,
            kMCA_e_phw4                 = 169,
            kMCA_e_phw5                 = 170,

            kMCA_e_map0                 = 8'hAE,  // This ordering is purposely sorta whacked
            kMCA_e_map1                 = 8'hAB,
            kMCA_e_map2                 = 8'hAC,
            kMCA_e_map3                 = 8'hAD,

            kMCA_e_bbr0                 = 175,
            kMCA_e_bbr1                 = 176,
            kMCA_e_bbr2                 = 177,

            kMCA_e_bbs0                 = 178,
            kMCA_e_bbs1                 = 179,
            kMCA_e_bbs2                 = 180,

            kMCA_e_trb0                 = 181,
            kMCA_e_trb1                 = 182,
            
            kMCA_e_tsb0                 = 183,
            kMCA_e_tsb1                 = 184,
            
            kMCA_e_rmb0                 = 185,
            kMCA_e_smb0                 = 186,
            
            kMCA_e_addr_r_abs0          = 187,
            kMCA_e_addr_r_abs1          = 188,
            
            kMCA_e_addr_w_abs0          = 189,
            kMCA_e_addr_w_abs1_a        = 190,
            kMCA_e_addr_w_abs1_x        = 191,
            kMCA_e_addr_w_abs1_y        = 192,
            kMCA_e_addr_w_abs1_z        = 193,
            
            kMCA_e_addr_r_zp0           = 194,
            
            kMCA_e_addr_w_zp0_a         = 195,
            kMCA_e_addr_w_zp0_x         = 196,
            kMCA_e_addr_w_zp0_y         = 197,
            kMCA_e_addr_w_zp0_z         = 198,
            
            kMCA_e_addr_r_absx0         = 199,
            kMCA_e_addr_r_absx1         = 200,
            
            kMCA_e_addr_w_absx0         = 201,
            kMCA_e_addr_w_absx1_a       = 202,
            kMCA_e_addr_w_absx1_y       = 203,
            kMCA_e_addr_w_absx1_z       = 204,
            
            kMCA_e_addr_r_absy0         = 205,
            kMCA_e_addr_r_absy1         = 206,
            
            kMCA_e_addr_w_absy0         = 207,
            kMCA_e_addr_w_absy1_a       = 208,
            kMCA_e_addr_w_absy1_x       = 209,
            
            kMCA_e_addr_r_zpx0          = 210,
            
            kMCA_e_addr_w_zpx0_a        = 211,
            kMCA_e_addr_w_zpx0_y        = 212,  
            kMCA_e_addr_w_zpx0_z        = 213,
            
            kMCA_e_addr_r_zpy0          = 214,  
            kMCA_e_addr_w_zpy0_x        = 215,
            
            kMCA_e_addr_r_zpxind0       = 216,
            kMCA_e_addr_r_zpxind1       = 217,
            kMCA_e_addr_r_zpxind2       = 218,
            
            kMCA_e_addr_w_zpxind0       = 219,
            kMCA_e_addr_w_zpxind1       = 220,
            kMCA_e_addr_w_zpxind2       = 221,
            
            kMCA_e_addr_r_zpindy0       = 222,
            kMCA_e_addr_r_zpindy1       = 223,
            kMCA_e_addr_r_zpindy2       = 224,
            
            kMCA_e_addr_w_zpindy0       = 225,
            kMCA_e_addr_w_zpindy1       = 226,
            kMCA_e_addr_w_zpindy2       = 227,
            
            kMCA_e_addr_r_zpindz0       = 228,
            kMCA_e_addr_r_zpindz1       = 229,
            kMCA_e_addr_r_zpindz2       = 230,
            
            kMCA_e_addr_w_zpindz0       = 231, 
            kMCA_e_addr_w_zpindz1       = 232,
            kMCA_e_addr_w_zpindz2       = 233,
            
            kMCA_e_addr_spind0          = 234,
            kMCA_e_addr_spind1          = 235,
            kMCA_e_addr_spind2          = 236,
            kMCA_e_addr_r_spind3        = 237,
            kMCA_e_addr_w_spind3        = 238,
            
            kMCA_e_brk1                 = 239,
            kMCA_e_brk2                 = 240,
            kMCA_e_brk3                 = 241,
            kMCA_e_brk4                 = 242,
            kMCA_e_brk5                 = 243,
            
            kMCA_e_inc_mem0             = 244,
            kMCA_e_dec_mem0             = 245,
            
            kMCA_end = 246;
            
reg [`kMICROCODE_BITS] mc_out;
(* rom_style = "block" *) reg [`kMICROCODE_BITS] mc[0:kMCA_end];

reg [8:0] a0_addr[0:255];
reg [8:0] a1_addr[0:255];

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
   $display("init %d",i);
end
// synthesis translate on

`MICROCODE( kMCA_e_fetch0, 0, `PC_INC)

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

`MICROCODE( kMCA_e_bpl,  kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_N `TEST_FLAG0 `SYNC)
`MICROCODE( kMCA_e_bmi,  kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_N `SYNC)
`MICROCODE( kMCA_e_bvc,  kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_V `TEST_FLAG0 `SYNC)
`MICROCODE( kMCA_e_bvs,  kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_V `SYNC)
`MICROCODE( kMCA_e_bra,  kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `SYNC)
`MICROCODE( kMCA_e_bcc,  kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_C `TEST_FLAG0 `SYNC)
`MICROCODE( kMCA_e_bcs,  kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_C `SYNC)
`MICROCODE( kMCA_e_bne,  kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_Z `TEST_FLAG0 `SYNC)
`MICROCODE( kMCA_e_beq,  kMCA_e_fetch0, `PC_INC `PCH_ADJ `PCL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `TF_Z `SYNC)

`MICROCODE( kMCA_e_braw0, 0, `PC_INC `ADL_ALU `ALU_ADC `ASEL_AREG `AREG_PCL `BSEL_DB `CSEL_1 `NEXT_A1)

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

`MICROCODE( kMCA_e_pull_p, kMCA_e_fetch0, `FLAGS_DB `SYNC)
`MICROCODE( kMCA_e_pull_a, kMCA_e_fetch0, `BSEL_DB `LOAD_A `FLAGS_SBZN `SYNC)
`MICROCODE( kMCA_e_pull_x, kMCA_e_fetch0, `BSEL_DB `LOAD_X `FLAGS_SBZN `SYNC)
`MICROCODE( kMCA_e_pull_y, kMCA_e_fetch0, `BSEL_DB `LOAD_Y `FLAGS_SBZN `SYNC)
`MICROCODE( kMCA_e_pull_z, kMCA_e_fetch0, `BSEL_DB `LOAD_Z `FLAGS_SBZN `SYNC)

`MICROCODE( kMCA_e_jsr0, kMCA_e_jsr1, `PC_INC `AB_SPn `BSEL_DB `ADL_ALU `DBO_PCHn `WRITE)
`MICROCODE( kMCA_e_jsr1, kMCA_e_jsr2, `AB_SPn `SP_DEC `ASEL_AREG `AREG_PCL `WRITE)
`MICROCODE( kMCA_e_jsr2, kMCA_e_jsr3, `AB_PCn `SP_DEC)
`MICROCODE( kMCA_e_jsr3, kMCA_e_fetch0, `BSEL_DB `PCH_ALU `PCL_ADL `SYNC)

// Cycle 2 - Incrementing SP /reading low byte of PCL
// Cycle 3 - Fetching low byte of JSR PC to ADL, Incrementing SP to read high byte of PC
// Cycle 4 - Extra cycle to increment PC (dummy re-read of original JSR address high byte)
// Cycle 5/1 - Fetch next instruction
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

// The other thing that has to happen when a MAP instruction is encountered is that interrupts get disabled
// until a NOP is executed.  Again, I think this could have been done with external logic since if they
// were sniffing the instruction stream to detect MAP, also detecting a NOP would have been easy.
`MICROCODE( kMCA_e_map0, kMCA_e_map1, `DBO_DREG `DREG_DO_A `MC_MAP)
`MICROCODE( kMCA_e_map1, kMCA_e_map2, `DBO_DREG `DREG_DO_X `MC_MAP)
`MICROCODE( kMCA_e_map2, kMCA_e_map3, `DBO_DREG `DREG_DO_Y `MC_MAP)
`MICROCODE( kMCA_e_map3, kMCA_e_fetch0, `DBO_DREG `DREG_DO_Z `MC_MAP `SYNC)

// Read absolute
`MICROCODE( kMCA_e_addr_r_abs0,     kMCA_e_addr_r_abs1, `PC_INC `ABL_ALU `BSEL_DB)
`MICROCODE( kMCA_e_addr_r_abs1,     0, `PC_INC `AB_ABn `ABH_ALU `DBO_DREG `BSEL_DB `NEXT_A1)

// Write variants for absolute addressing
`MICROCODE( kMCA_e_addr_w_abs0,     0, `PC_INC `ABL_ALU `BSEL_DB `NEXT_A1)
`MICROCODE( kMCA_e_addr_w_abs1_a,   kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `DBO_DREG `BSEL_DB `WRITE `DREG_DO_A)
`MICROCODE( kMCA_e_addr_w_abs1_x,   kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `DBO_DREG `BSEL_DB `WRITE `DREG_DO_X)
`MICROCODE( kMCA_e_addr_w_abs1_y,   kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `DBO_DREG `BSEL_DB `WRITE `DREG_DO_Y)
`MICROCODE( kMCA_e_addr_w_abs1_z,   kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_ALU `DBO_DREG `BSEL_DB `WRITE `DREG_DO_Z)

// Read zero (base) page
`MICROCODE( kMCA_e_addr_r_zp0,      0, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB `NEXT_A1)

// Write variants for zero page addressing
`MICROCODE( kMCA_e_addr_w_zp0_a,    kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB  `WRITE `DREG_DO_A)
`MICROCODE( kMCA_e_addr_w_zp0_x,    kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB  `WRITE `DREG_DO_X)
`MICROCODE( kMCA_e_addr_w_zp0_y,    kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB  `WRITE `DREG_DO_Y)
`MICROCODE( kMCA_e_addr_w_zp0_z,    kMCA_e_mem_fetch, `PC_INC `AB_ABn `ABH_B `ABL_ALU `DBO_DREG `BSEL_DB  `WRITE `DREG_DO_Z)

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

`define A0_A1_ADDR(_opcode, _addr0, _addr1) a0_addr[_opcode] = _addr0; a1_addr[_opcode] = _addr1;

  // Primary and secondary (if required) microcode addresses for all 256 65CE02 opcodes
  `A0_A1_ADDR(8'h00, kMCA_e_brk0               , 0                     ) // 00 BRK
  `A0_A1_ADDR(8'h01, kMCA_e_addr_r_zpxind0     , kMCA_e_ora            ) // 01 ORA (zp,x)
  `A0_A1_ADDR(8'h02, kMCA_e_clesee0            , 0                     ) // 02 CLE 
  `A0_A1_ADDR(8'h03, kMCA_e_clesee0            , 0                     ) // 03 SEE 
  `A0_A1_ADDR(8'h04, kMCA_e_addr_r_zp0         , kMCA_e_tsb0           ) // 04 TSB zp
  `A0_A1_ADDR(8'h05, kMCA_e_addr_r_zp0         , kMCA_e_ora            ) // 05 ORA zp
  `A0_A1_ADDR(8'h06, kMCA_e_addr_r_zp0         , kMCA_e_asl_mem0       ) // 06 ASL zp
  `A0_A1_ADDR(8'h07, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 07 RMB0 zp
  `A0_A1_ADDR(8'h08, kMCA_e_push_p             , 0                     ) // 08 PHP
  `A0_A1_ADDR(8'h09, kMCA_e_orai               , kMCA_e_orai           ) // 09 ORA #
  `A0_A1_ADDR(8'h0A, kMCA_e_asl_a              , kMCA_e_asl_a          ) // 0A ASL
  `A0_A1_ADDR(8'h0B, kMCA_e_tsy0               , 0                     ) // 0B TSY
  `A0_A1_ADDR(8'h0C, kMCA_e_addr_r_abs0        , kMCA_e_tsb0           ) // 0C TSB abs
  `A0_A1_ADDR(8'h0D, kMCA_e_addr_r_abs0        , kMCA_e_ora            ) // 0D ORA abs
  `A0_A1_ADDR(8'h0E, kMCA_e_addr_r_abs0        , kMCA_e_asl_mem0       ) // 0E ASL abs
  `A0_A1_ADDR(8'h0F, kMCA_e_addr_r_zp0         , kMCA_e_bbr0           ) // 0F BBR0 zp
                                                                      
  `A0_A1_ADDR(8'h10, kMCA_e_bpl                , 0                     ) // 10 BPL rel
  `A0_A1_ADDR(8'h11, kMCA_e_addr_r_zpindy0     , kMCA_e_ora            ) // 11 ORA (zp),y
  `A0_A1_ADDR(8'h12, kMCA_e_addr_r_zpindz0     , kMCA_e_ora            ) // 12 ORA (zp),z
  `A0_A1_ADDR(8'h13, kMCA_e_braw0              , kMCA_e_bplw1          ) // 13 BPL wrel
  `A0_A1_ADDR(8'h14, kMCA_e_addr_r_zp0         , kMCA_e_trb0           ) // 14 TRB zp
  `A0_A1_ADDR(8'h15, kMCA_e_addr_r_zpx0        , kMCA_e_ora            ) // 15 ORA zp,x
  `A0_A1_ADDR(8'h16, kMCA_e_addr_r_zpx0        , kMCA_e_asl_mem0       ) // 16 ASL zp,x
  `A0_A1_ADDR(8'h17, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 17 RMB1 zp
  `A0_A1_ADDR(8'h18, kMCA_e_clcsec0            , 0                     ) // 18 CLC
  `A0_A1_ADDR(8'h19, kMCA_e_addr_r_absy0       , kMCA_e_ora            ) // 19 ORA abs,y
  `A0_A1_ADDR(8'h1A, kMCA_e_inca               , 0                     ) // 1A INC
  `A0_A1_ADDR(8'h1B, kMCA_e_incz               , 0                     ) // 1B INZ
  `A0_A1_ADDR(8'h1C, kMCA_e_addr_r_abs0        , kMCA_e_trb0           ) // 1C TRB abs
  `A0_A1_ADDR(8'h1D, kMCA_e_addr_r_absx0       , kMCA_e_ora            ) // 1D ORA abs,x
  `A0_A1_ADDR(8'h1E, kMCA_e_addr_r_absx0       , kMCA_e_asl_mem0       ) // 1E ASL abs,x
  `A0_A1_ADDR(8'h1F, kMCA_e_addr_r_zp0         , kMCA_e_bbr0           ) // 1F BBR1 zp
                                                                      
  `A0_A1_ADDR(8'h20, kMCA_e_jsr0               , 0                     ) // 20 JSR abs
  `A0_A1_ADDR(8'h21, kMCA_e_addr_r_zpxind0     , kMCA_e_and            ) // 21 AND (zp,x)
  `A0_A1_ADDR(8'h22, kMCA_e_jsrind0            , 0                     ) // 22 JSR (ind)
  `A0_A1_ADDR(8'h23, kMCA_e_jsrindx0           , 0                     ) // 23 JSR (ind,x)
  `A0_A1_ADDR(8'h24, kMCA_e_addr_r_zp0         , kMCA_e_bitm0          ) // 24 BIT zp
  `A0_A1_ADDR(8'h25, kMCA_e_addr_r_zp0         , kMCA_e_and            ) // 25 AND zp
  `A0_A1_ADDR(8'h26, kMCA_e_addr_r_zp0         , kMCA_e_rol_mem0       ) // 26 ROL zp
  `A0_A1_ADDR(8'h27, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 27 RMB2 zp
  `A0_A1_ADDR(8'h28, kMCA_e_pull0              , kMCA_e_pull_p         ) // 28 PLP
  `A0_A1_ADDR(8'h29, kMCA_e_andi               , 0                     ) // 29 AND #
  `A0_A1_ADDR(8'h2A, kMCA_e_rol_a              , 0                     ) // 2A ROL
  `A0_A1_ADDR(8'h2B, kMCA_e_tys0               , 0                     ) // 2B TYS
  `A0_A1_ADDR(8'h2C, kMCA_e_addr_r_abs0        , kMCA_e_bitm0          ) // 2C BIT abs
  `A0_A1_ADDR(8'h2D, kMCA_e_addr_r_abs0        , kMCA_e_and            ) // 2D AND abs
  `A0_A1_ADDR(8'h2E, kMCA_e_addr_r_abs0        , kMCA_e_rol_mem0       ) // 2E ROL abs
  `A0_A1_ADDR(8'h2F, kMCA_e_addr_r_zp0         , kMCA_e_bbr0           ) // 2F BBR2 zp
                                                                      
  `A0_A1_ADDR(8'h30, kMCA_e_bmi                , 0                     ) // 30 BMI rel
  `A0_A1_ADDR(8'h31, kMCA_e_addr_r_zpindy0     , kMCA_e_and            ) // 31 AND (zp),y
  `A0_A1_ADDR(8'h32, kMCA_e_addr_r_zpindz0     , kMCA_e_and            ) // 32 AND (zp),z
  `A0_A1_ADDR(8'h33, kMCA_e_braw0              , kMCA_e_bmiw1          ) // 33 BMI wrel
  `A0_A1_ADDR(8'h34, kMCA_e_addr_r_zpx0        , kMCA_e_bitm0          ) // 34 BIT zp,x
  `A0_A1_ADDR(8'h35, kMCA_e_addr_r_zpx0        , kMCA_e_and            ) // 35 AND zp,x
  `A0_A1_ADDR(8'h36, kMCA_e_addr_r_zpx0        , kMCA_e_rol_mem0       ) // 36 ROL zp,x
  `A0_A1_ADDR(8'h37, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 37 RMB3 zp
  `A0_A1_ADDR(8'h38, kMCA_e_clcsec0            , 0                     ) // 38 SEC
  `A0_A1_ADDR(8'h39, kMCA_e_addr_r_absy0       , kMCA_e_and            ) // 39 AND abs,y
  `A0_A1_ADDR(8'h3A, kMCA_e_deca               , 0                     ) // 3A DEC
  `A0_A1_ADDR(8'h3B, kMCA_e_decz               , 0                     ) // 3B DEZ
  `A0_A1_ADDR(8'h3C, kMCA_e_addr_r_absx0       , kMCA_e_bitm0          ) // 3C BIT abs,x
  `A0_A1_ADDR(8'h3D, kMCA_e_addr_r_absx0       , kMCA_e_and            ) // 3D AND abs,x
  `A0_A1_ADDR(8'h3E, kMCA_e_addr_r_absx0       , kMCA_e_rol_mem0       ) // 3E ROL abs,x
  `A0_A1_ADDR(8'h3F, kMCA_e_addr_r_zp0         , kMCA_e_bbr0           ) // 3F BBR3 zp
                                                                      
  `A0_A1_ADDR(8'h40, kMCA_e_rti0               , 0                     ) // 40 RTI
  `A0_A1_ADDR(8'h41, kMCA_e_addr_r_zpxind0     , kMCA_e_eor            ) // 41 EOR (zp,x)
  `A0_A1_ADDR(8'h42, kMCA_e_neg                , 0                     ) // 42 NEG
  `A0_A1_ADDR(8'h43, kMCA_e_asr_a              , kMCA_e_asr_a          ) // 43 ASR
  `A0_A1_ADDR(8'h44, kMCA_e_addr_r_zp0         , kMCA_e_asr_mem0       ) // 44 ASR zp
  `A0_A1_ADDR(8'h45, kMCA_e_addr_r_zp0         , kMCA_e_eor            ) // 45 EOR zp
  `A0_A1_ADDR(8'h46, kMCA_e_addr_r_zp0         , kMCA_e_lsr_mem0       ) // 46 LSR zp
  `A0_A1_ADDR(8'h47, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 47 RMB4 zp
  `A0_A1_ADDR(8'h48, kMCA_e_push_a             , 0                     ) // 48 PHA
  `A0_A1_ADDR(8'h49, kMCA_e_eori               , 0                     ) // 49 EOR #
  `A0_A1_ADDR(8'h4A, kMCA_e_lsr_a              , 0                     ) // 4A LSR
  `A0_A1_ADDR(8'h4B, kMCA_e_taz0               , 0                     ) // 4B TAZ
  `A0_A1_ADDR(8'h4C, kMCA_e_jmp0               , 0                     ) // 4C JMP abs
  `A0_A1_ADDR(8'h4D, kMCA_e_addr_r_abs0        , kMCA_e_eor            ) // 4D EOR abs
  `A0_A1_ADDR(8'h4E, kMCA_e_addr_r_abs0        , kMCA_e_lsr_mem0       ) // 4E LSR abs
  `A0_A1_ADDR(8'h4F, kMCA_e_addr_r_zp0         , kMCA_e_bbr0           ) // 4F BBR4 zp
                                                                      
  `A0_A1_ADDR(8'h50, kMCA_e_bvc                , 0                     ) // 50 BVC rel
  `A0_A1_ADDR(8'h51, kMCA_e_addr_r_zpindy0     , kMCA_e_eor            ) // 51 EOR (zp),y
  `A0_A1_ADDR(8'h52, kMCA_e_addr_r_zpindz0     , kMCA_e_eor            ) // 52 EOR (zp),z
  `A0_A1_ADDR(8'h53, kMCA_e_braw0              , kMCA_e_bmiw1          ) // 53 BMI wrel
  `A0_A1_ADDR(8'h54, kMCA_e_addr_r_zpx0        , kMCA_e_asr_mem0       ) // 54 ASR zp,x
  `A0_A1_ADDR(8'h55, kMCA_e_addr_r_zpx0        , kMCA_e_eor            ) // 55 EOR zp,x
  `A0_A1_ADDR(8'h56, kMCA_e_addr_r_zpx0        , kMCA_e_lsr_mem0       ) // 56 LSR zp,x
  `A0_A1_ADDR(8'h57, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 57 RMB5 zp
  `A0_A1_ADDR(8'h58, kMCA_e_cli0               , 0                     ) // 58 CLI
  `A0_A1_ADDR(8'h59, kMCA_e_addr_r_absy0       , kMCA_e_eor            ) // 59 EOR abs,y
  `A0_A1_ADDR(8'h5A, kMCA_e_push_y             , 0                     ) // 5A PHY
  `A0_A1_ADDR(8'h5B, kMCA_e_tab0               , 0                     ) // 5B TAB
  `A0_A1_ADDR(8'h5C, kMCA_e_map0               , 0                     ) // 5C MAP
  `A0_A1_ADDR(8'h5D, kMCA_e_addr_r_absx0       , kMCA_e_eor            ) // 5D EOR abs,x
  `A0_A1_ADDR(8'h5E, kMCA_e_addr_r_absx0       , kMCA_e_lsr_mem0       ) // 5E LSR abs,x
  `A0_A1_ADDR(8'h5F, kMCA_e_addr_r_zp0         , kMCA_e_bbr0           ) // 5F BBR5 zp
                                                                      
  `A0_A1_ADDR(8'h60, kMCA_e_rts0               , 0                     ) // 60 RTS
  `A0_A1_ADDR(8'h61, kMCA_e_addr_r_zpxind0     , kMCA_e_adc            ) // 61 ADC (zp,x)
  `A0_A1_ADDR(8'h62, kMCA_e_rtn0               , 0                     ) // 62 RTN imm
  `A0_A1_ADDR(8'h63, kMCA_e_bsr0               , 0                     ) // 63 BSR
  `A0_A1_ADDR(8'h64, kMCA_e_addr_w_zp0_z       , 0                     ) // 64 STZ zp
  `A0_A1_ADDR(8'h65, kMCA_e_addr_r_zp0         , kMCA_e_adc            ) // 65 ADC zp
  `A0_A1_ADDR(8'h66, kMCA_e_addr_r_zp0         , kMCA_e_ror_mem0       ) // 66 ROR zp
  `A0_A1_ADDR(8'h67, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 67 RMB6 zp
  `A0_A1_ADDR(8'h68, kMCA_e_pull0              , kMCA_e_pull_a         ) // 68 PLA
  `A0_A1_ADDR(8'h69, kMCA_e_adci               , 0                     ) // 69 ADC #
  `A0_A1_ADDR(8'h6A, kMCA_e_ror_a              , 0                     ) // 6A ROR
  `A0_A1_ADDR(8'h6B, kMCA_e_tza0               , 0                     ) // 6B TZA
  `A0_A1_ADDR(8'h6C, kMCA_e_jmpind0            , 0                     ) // 69 JMP (ind)
  `A0_A1_ADDR(8'h6D, kMCA_e_addr_r_abs0        , kMCA_e_adc            ) // 6D ADC abs
  `A0_A1_ADDR(8'h6E, kMCA_e_addr_r_abs0        , kMCA_e_ror_mem0       ) // 6E ROR abs
  `A0_A1_ADDR(8'h6F, kMCA_e_addr_r_zp0         , kMCA_e_bbr0           ) // 6F BBR6 zp
                                                                      
  `A0_A1_ADDR(8'h70, kMCA_e_bvs                , 0                     ) // 70 BVS rel
  `A0_A1_ADDR(8'h71, kMCA_e_addr_r_zpindy0     , kMCA_e_adc            ) // 71 ADC (zp),y
  `A0_A1_ADDR(8'h72, kMCA_e_addr_r_zpindz0     , kMCA_e_adc            ) // 72 ADC (zp),z
  `A0_A1_ADDR(8'h73, kMCA_e_braw0              , kMCA_e_bvsw1          ) // 73 BVS wrel
  `A0_A1_ADDR(8'h74, kMCA_e_addr_w_zpx0_z      , 0                     ) // 74 STZ zp,x
  `A0_A1_ADDR(8'h75, kMCA_e_addr_r_zpx0        , kMCA_e_adc            ) // 75 ADC zp,x
  `A0_A1_ADDR(8'h76, kMCA_e_addr_r_zpx0        , kMCA_e_ror_mem0       ) // 76 ROR zp,x
  `A0_A1_ADDR(8'h77, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 77 RMB7 zp
  `A0_A1_ADDR(8'h78, kMCA_e_sei0               , 0                     ) // 78 SEI
  `A0_A1_ADDR(8'h79, kMCA_e_addr_r_absy0       , kMCA_e_adc            ) // 79 ADC abs,y
  `A0_A1_ADDR(8'h7A, kMCA_e_pull0              , kMCA_e_pull_y         ) // 7A PLY
  `A0_A1_ADDR(8'h7B, kMCA_e_tba0               , 0                     ) // 7B TBA
  `A0_A1_ADDR(8'h7C, kMCA_e_jmpindx0           , 0                     ) // 7C JMP (ind,x)
  `A0_A1_ADDR(8'h7D, kMCA_e_addr_r_absx0       , kMCA_e_adc            ) // 7D ADC abs,x
  `A0_A1_ADDR(8'h7E, kMCA_e_addr_r_absx0       , kMCA_e_ror_mem0       ) // 7E ROR abs,x
  `A0_A1_ADDR(8'h7F, kMCA_e_addr_r_zp0         , kMCA_e_bbr0           ) // 7F BBR7 zp
                                                                      
  `A0_A1_ADDR(8'h80, kMCA_e_bra                , 0                     ) // 80 BRA rel
  `A0_A1_ADDR(8'h81, kMCA_e_addr_w_zpxind0     , 0                     ) // 81 STA (zp,x)
  `A0_A1_ADDR(8'h82, kMCA_e_addr_spind0        , kMCA_e_addr_w_spind3  ) // 82 STA (d,SP),Y
  `A0_A1_ADDR(8'h83, kMCA_e_braw0              , kMCA_e_braw1          ) // 83 BRA wrel
  `A0_A1_ADDR(8'h84, kMCA_e_addr_w_zp0_y       , 0                     ) // 84 STZ zp
  `A0_A1_ADDR(8'h85, kMCA_e_addr_w_zp0_a       , 0                     ) // 85 STA zp
  `A0_A1_ADDR(8'h86, kMCA_e_addr_w_zp0_x       , 0                     ) // 86 STX zp
  `A0_A1_ADDR(8'h87, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // 87 SMB0 zp
  `A0_A1_ADDR(8'h88, kMCA_e_decy               , 0                     ) // 88 DEY
  `A0_A1_ADDR(8'h89, kMCA_e_biti               , 0                     ) // 89 BIT #
  `A0_A1_ADDR(8'h8A, kMCA_e_txa0               , 0                     ) // 8A TXA
  `A0_A1_ADDR(8'h8B, kMCA_e_addr_w_absx0       , kMCA_e_addr_w_absx1_y ) // 8B STY abs,x
  `A0_A1_ADDR(8'h8C, kMCA_e_addr_w_abs0        , kMCA_e_addr_w_abs1_y  ) // 8C STY abs
  `A0_A1_ADDR(8'h8D, kMCA_e_addr_w_abs0        , kMCA_e_addr_w_abs1_a  ) // 8D STA abs
  `A0_A1_ADDR(8'h8E, kMCA_e_addr_w_abs0        , kMCA_e_addr_w_abs1_x  ) // 8E STX abs
  `A0_A1_ADDR(8'h8F, kMCA_e_addr_r_zp0         , kMCA_e_bbs0           ) // 8F BBS0 zp
  
  `A0_A1_ADDR(8'h90, kMCA_e_bcc                , 0                     ) // 90 BCC rel
  `A0_A1_ADDR(8'h91, kMCA_e_addr_w_zpindy0     , 0                     ) // 91 STA (zp),y
  `A0_A1_ADDR(8'h92, kMCA_e_addr_w_zpindz0     , 0                     ) // 92 STA (zp),z
  `A0_A1_ADDR(8'h93, kMCA_e_braw0              , kMCA_e_bccw1          ) // 93 BCC wrel
  `A0_A1_ADDR(8'h94, kMCA_e_addr_w_zpx0_y      , 0                     ) // 94 STY zp,x
  `A0_A1_ADDR(8'h95, kMCA_e_addr_w_zpx0_a      , 0                     ) // 95 STA zp,x
  `A0_A1_ADDR(8'h96, kMCA_e_addr_w_zpy0_x      , 0                     ) // 96 STX zp,y
  `A0_A1_ADDR(8'h97, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // 97 SMB1 zp
  `A0_A1_ADDR(8'h98, kMCA_e_tya0               , 0                     ) // 98 TYA
  `A0_A1_ADDR(8'h99, kMCA_e_addr_w_absy0       , kMCA_e_addr_w_absy1_a ) // 99 STA abs,y
  `A0_A1_ADDR(8'h9A, kMCA_e_txs0               , 0                     ) // 9A TXS
  `A0_A1_ADDR(8'h9B, kMCA_e_addr_w_absy0       , kMCA_e_addr_w_absy1_x ) // 9B STX abs,y
  `A0_A1_ADDR(8'h9C, kMCA_e_addr_w_abs0        , kMCA_e_addr_w_abs1_z  ) // 9C STZ abs
  `A0_A1_ADDR(8'h9D, kMCA_e_addr_w_absx0       , kMCA_e_addr_w_absx1_a ) // 9D STA abs,x
  `A0_A1_ADDR(8'h9E, kMCA_e_addr_w_absx0       , kMCA_e_addr_w_absx1_z ) // 9E STZ abs,x
  `A0_A1_ADDR(8'h9F, kMCA_e_addr_r_zp0         , kMCA_e_bbs0           ) // 9F BBS1 zp
  
  `A0_A1_ADDR(8'hA0, kMCA_e_ldyi               , 0                     ) // A0 LDY #
  `A0_A1_ADDR(8'hA1, kMCA_e_addr_r_zpxind0     , kMCA_e_lda            ) // A1 LDA (zp,x)
  `A0_A1_ADDR(8'hA2, kMCA_e_ldxi               , 0                     ) // A2 LDX #
  `A0_A1_ADDR(8'hA3, kMCA_e_ldzi               , 0                     ) // A3 LDZ #
  `A0_A1_ADDR(8'hA4, kMCA_e_addr_r_zp0         , kMCA_e_ldy            ) // A4 LDY zp
  `A0_A1_ADDR(8'hA5, kMCA_e_addr_r_zp0         , kMCA_e_lda            ) // A5 LDA zp
  `A0_A1_ADDR(8'hA6, kMCA_e_addr_r_zp0         , kMCA_e_ldx            ) // A6 LDX zp
  `A0_A1_ADDR(8'hA7, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // A7 SMB2 zp
  `A0_A1_ADDR(8'hA8, kMCA_e_tay0               , 0                     ) // A8 TAY
  `A0_A1_ADDR(8'hA9, kMCA_e_ldai               , 0                     ) // A9 LDA #
  `A0_A1_ADDR(8'hAA, kMCA_e_tax0               , 0                     ) // AA TAX
  `A0_A1_ADDR(8'hAB, kMCA_e_addr_r_abs0        , kMCA_e_ldz            ) // AB LDZ abs
  `A0_A1_ADDR(8'hAC, kMCA_e_addr_r_abs0        , kMCA_e_ldy            ) // AC LDY abs
  `A0_A1_ADDR(8'hAD, kMCA_e_addr_r_abs0        , kMCA_e_lda            ) // AD LDA abs
  `A0_A1_ADDR(8'hAE, kMCA_e_addr_r_abs0        , kMCA_e_ldx            ) // AE LDX abs
  `A0_A1_ADDR(8'hAF, kMCA_e_addr_r_zp0         , kMCA_e_bbs0           ) // AF BBS2 zp
  
  `A0_A1_ADDR(8'hB0, kMCA_e_bcs                , 0                     ) // B0 BCS rel
  `A0_A1_ADDR(8'hB1, kMCA_e_addr_r_zpindy0     , kMCA_e_lda            ) // B1 LDA (zp),y
  `A0_A1_ADDR(8'hB2, kMCA_e_addr_r_zpindz0     , kMCA_e_lda            ) // B2 LDA (zp),z
  `A0_A1_ADDR(8'hB3, kMCA_e_braw0              , kMCA_e_bcsw1          ) // B3 BCS wrel
  `A0_A1_ADDR(8'hB4, kMCA_e_addr_r_zpx0        , kMCA_e_ldy            ) // B4 LDY zp,x
  `A0_A1_ADDR(8'hB5, kMCA_e_addr_r_zpx0        , kMCA_e_lda            ) // B5 LDA zp,x
  `A0_A1_ADDR(8'hB6, kMCA_e_addr_r_zpy0        , kMCA_e_ldx            ) // B6 LDX zp,y
  `A0_A1_ADDR(8'hB7, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // B7 SMB3 zp
  `A0_A1_ADDR(8'hB8, kMCA_e_clv0               , 0                     ) // B8 CLV
  `A0_A1_ADDR(8'hB9, kMCA_e_addr_r_absy0       , kMCA_e_lda            ) // B9 LDA abs,y
  `A0_A1_ADDR(8'hBA, kMCA_e_tsx0               , 0                     ) // BA TSX
  `A0_A1_ADDR(8'hBB, kMCA_e_addr_r_absx0       , kMCA_e_ldz            ) // BB LDZ abs,x
  `A0_A1_ADDR(8'hBC, kMCA_e_addr_r_absx0       , kMCA_e_ldy            ) // BC LDY abs,x
  `A0_A1_ADDR(8'hBD, kMCA_e_addr_r_absx0       , kMCA_e_lda            ) // BD LDA abs,x
  `A0_A1_ADDR(8'hBE, kMCA_e_addr_r_absy0       , kMCA_e_ldx            ) // BE LDX abs,y
  `A0_A1_ADDR(8'hBF, kMCA_e_addr_r_zp0         , kMCA_e_bbs0           ) // BF BBS3 zp

  `A0_A1_ADDR(8'hC0, kMCA_e_cmpyi              , 0                     ) // C0 CPY #
  `A0_A1_ADDR(8'hC1, kMCA_e_addr_r_zpxind0     , kMCA_e_cmpa           ) // C1 CPA (zp,x)
  `A0_A1_ADDR(8'hC2, kMCA_e_cmpzi              , 0                     ) // C2 CPZ #
  `A0_A1_ADDR(8'hC3, kMCA_e_dew0               , 0                     ) // C3 DEW
  `A0_A1_ADDR(8'hC4, kMCA_e_addr_r_zp0         , kMCA_e_cmpy           ) // C4 CPY zp
  `A0_A1_ADDR(8'hC5, kMCA_e_addr_r_zp0         , kMCA_e_cmpa           ) // C5 CMP zp
  `A0_A1_ADDR(8'hC6, kMCA_e_addr_r_zp0         , kMCA_e_dec_mem0       ) // C6 DEC zp
  `A0_A1_ADDR(8'hC7, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // C7 SMB4 zp
  `A0_A1_ADDR(8'hC8, kMCA_e_incy               , 0                     ) // C8 INY
  `A0_A1_ADDR(8'hC9, kMCA_e_cmpai              , 0                     ) // C9 CMP #
  `A0_A1_ADDR(8'hCA, kMCA_e_decx               , 0                     ) // CA DEX
  `A0_A1_ADDR(8'hCB, kMCA_e_asw0               , 0                     ) // CB ASW abs
  `A0_A1_ADDR(8'hCC, kMCA_e_addr_r_abs0        , kMCA_e_cmpy           ) // CC CPY abs
  `A0_A1_ADDR(8'hCD, kMCA_e_addr_r_abs0        , kMCA_e_cmpa           ) // CD CMP abs
  `A0_A1_ADDR(8'hCE, kMCA_e_addr_r_abs0        , kMCA_e_dec_mem0       ) // CE DEC abs
  `A0_A1_ADDR(8'hCF, kMCA_e_addr_r_zp0         , kMCA_e_bbs0           ) // CF BBS4 zp

  `A0_A1_ADDR(8'hD0, kMCA_e_bne                , 0                     ) // D0 BNE rel
  `A0_A1_ADDR(8'hD1, kMCA_e_addr_r_zpindy0     , kMCA_e_cmpa           ) // D1 CMP (zp),y
  `A0_A1_ADDR(8'hD2, kMCA_e_addr_r_zpindz0     , kMCA_e_cmpa           ) // D2 CMP (zp),z
  `A0_A1_ADDR(8'hD3, kMCA_e_braw0              , kMCA_e_bnew1          ) // D3 BNE wrel
  `A0_A1_ADDR(8'hD4, kMCA_e_addr_r_zp0         , kMCA_e_cmpz           ) // D4 CPZ zp
  `A0_A1_ADDR(8'hD5, kMCA_e_addr_r_zpx0        , kMCA_e_cmpa           ) // D5 CMP zp,x
  `A0_A1_ADDR(8'hD6, kMCA_e_addr_r_zpx0        , kMCA_e_dec_mem0       ) // D6 DEC zp,x
  `A0_A1_ADDR(8'hD7, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // D7 SMB5 zp
  `A0_A1_ADDR(8'hD8, kMCA_e_cldsed0            , 0                     ) // D8 CLD
  `A0_A1_ADDR(8'hD9, kMCA_e_addr_r_absy0       , kMCA_e_cmpa           ) // D9 CMP abs,y
  `A0_A1_ADDR(8'hDA, kMCA_e_push_x             , 0                     ) // DA PHX
  `A0_A1_ADDR(8'hDB, kMCA_e_push_z             , 0                     ) // DA PHZ
  `A0_A1_ADDR(8'hDC, kMCA_e_addr_r_abs0        , kMCA_e_cmpz           ) // DC CPZ abs
  `A0_A1_ADDR(8'hDD, kMCA_e_addr_r_absx0       , kMCA_e_cmpa           ) // DD CMP abs,x
  `A0_A1_ADDR(8'hDE, kMCA_e_addr_r_absx0       , kMCA_e_dec_mem0       ) // DE DEC abs,x
  `A0_A1_ADDR(8'hDF, kMCA_e_addr_r_zp0         , kMCA_e_bbs0           ) // DF BBS5 zp

  `A0_A1_ADDR(8'hE0, kMCA_e_cmpxi              , 0                     ) // E0 CPX #
  `A0_A1_ADDR(8'hE1, kMCA_e_addr_r_zpxind0     , kMCA_e_sbc            ) // E1 SBC (zp,x)
  `A0_A1_ADDR(8'hE2, kMCA_e_addr_spind0        , kMCA_e_addr_r_spind3  ) // E2 LDA (d,SP),Y
  `A0_A1_ADDR(8'hE3, kMCA_e_inw0               , 0                     ) // E3 INW
  `A0_A1_ADDR(8'hE4, kMCA_e_addr_r_zp0         , kMCA_e_cmpx           ) // E4 CPX zp
  `A0_A1_ADDR(8'hE5, kMCA_e_addr_r_zp0         , kMCA_e_sbc            ) // E5 SBC zp
  `A0_A1_ADDR(8'hE6, kMCA_e_addr_r_zp0         , kMCA_e_inc_mem0       ) // E6 INC zp
  `A0_A1_ADDR(8'hE7, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // E7 SMB6 zp
  `A0_A1_ADDR(8'hE8, kMCA_e_incx               , 0                     ) // E8 INX
  `A0_A1_ADDR(8'hE9, kMCA_e_sbci               , 0                     ) // E9 SBC #
  `A0_A1_ADDR(8'hEA, kMCA_e_fetch0             , 0                     ) // EA NOP
  `A0_A1_ADDR(8'hEB, kMCA_e_row0               , 0                     ) // EB ROW abs
  `A0_A1_ADDR(8'hEC, kMCA_e_addr_r_abs0        , kMCA_e_cmpx           ) // EC CPX abs
  `A0_A1_ADDR(8'hED, kMCA_e_addr_r_abs0        , kMCA_e_sbc            ) // ED SBC abs
  `A0_A1_ADDR(8'hEE, kMCA_e_addr_r_abs0        , kMCA_e_inc_mem0       ) // EE INC abs
  `A0_A1_ADDR(8'hEF, kMCA_e_addr_r_zp0         , kMCA_e_bbs0           ) // EF BBS6 zp

  `A0_A1_ADDR(8'hF0, kMCA_e_beq                , 0                     ) // F0 BEQ rel
  `A0_A1_ADDR(8'hF1, kMCA_e_addr_r_zpindy0     , kMCA_e_sbc            ) // F1 SBC (zp),y
  `A0_A1_ADDR(8'hF2, kMCA_e_addr_r_zpindz0     , kMCA_e_sbc            ) // F2 SBC (zp),z
  `A0_A1_ADDR(8'hF3, kMCA_e_braw0              , kMCA_e_beqw1          ) // F3 BEQ wrel
  `A0_A1_ADDR(8'hF4, kMCA_e_phwi0              , 0                     ) // F4 PHD imm
  `A0_A1_ADDR(8'hF5, kMCA_e_addr_r_zpx0        , kMCA_e_sbc            ) // F5 SBC zp,x
  `A0_A1_ADDR(8'hF6, kMCA_e_addr_r_zpx0        , kMCA_e_inc_mem0       ) // F6 INC zp,x
  `A0_A1_ADDR(8'hF7, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // F7 SMB7 zp
  `A0_A1_ADDR(8'hF8, kMCA_e_cldsed0            , 0                     ) // F8 CLD
  `A0_A1_ADDR(8'hF9, kMCA_e_addr_r_absy0       , kMCA_e_sbc            ) // F9 SBC abs,y
  `A0_A1_ADDR(8'hFA, kMCA_e_pull0              , kMCA_e_pull_x         ) // FA PLX
  `A0_A1_ADDR(8'hFB, kMCA_e_pull0              , kMCA_e_pull_z         ) // FB PLZ
  `A0_A1_ADDR(8'hFC, kMCA_e_phw0               , 0                     ) // FC PHD abs
  `A0_A1_ADDR(8'hFD, kMCA_e_addr_r_absx0       , kMCA_e_sbc            ) // FD SBC abs,x
  `A0_A1_ADDR(8'hFE, kMCA_e_addr_r_absx0       , kMCA_e_inc_mem0       ) // FE INC abs,x
  `A0_A1_ADDR(8'hFF, kMCA_e_addr_r_zp0         , kMCA_e_bbs0           ) // FF BBS7 zp

end

always @(*) begin
  next_mca_a0 = a0_addr[ir];
  next_mca_a1 = a1_addr[ir];
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

always @(posedge clk)
begin
  //$display("mc[%03x] ir: %02x next: %03x mc_sync: %01d alu: %03b bits: %065b",next_mca,ir,mc[next_mca][`kNEXT_ADDR_BITS],mc[next_mca][`kSYNC_BITS],mc[next_mca][`kALU_BITS],mc[next_mca]);
  if(reset) begin
    mc_out <= mc[0];
  end else if(ready)
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
