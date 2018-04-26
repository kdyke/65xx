`ifndef _6502_inc_vh_
`define _6052_inc_vh_

`define none          0

`define ABUS_PCHPCL   3'd0
`define ABUS_SP       3'd1
`define ABUS_ABHABL   3'd2
`define ABUS_ABL      3'd3
`define ABUS_DL       3'd4
`define ABUS_VEC      3'd5

// Internal data bus input select
`define DB_FF       0
`define DB_A        1
`define DB_DI       2
`define DB_SB       3
`define DB_PCL      4
`define DB_PCH      5
`define DB_P        6
`define DB_BO       7       // Branch offset, 0 or FF

// Internal secondary bus input select
`define SB_A        0
`define SB_X        1
`define SB_Y        2
`define SB_SP       3
`define SB_ALU      4
`define SB_ADH      5         // Is this needed?
`define SB_DB       6         // Is this needed?
`define SB_FF       7

// Internal ADH bus input select
`define ADH_DI      0       // ADH is data bus input (not latched)
`define ADH_PCH     1       // ADH is current PCH
`define ADH_PCHS    2       // ADH is current PCHS out
`define ADH_SB      3       // ADH is current value on SB
`define ADH_0       4       // This would eventually be the base page register
`define ADH_1       5       // This would eventually be the stack page register
`define ADH_FF      6

// Internal ADL bus input select
`define ADL_DI      0       // ADL is data bus input (not latched)
//`define ADL_ABL     1       // ADL is current ABL (i.e. hold prior value)
`define ADL_PCLS    2       // ADL is current PCLS out
`define ADL_S       3       // ADL is current stack pointer
`define ADL_ALU     4       // ADL is ALU output
`define ADL_VECLO   5       // ADL is low vector address
`define ADL_VECHI   6       // ADL is high vector address

`define PCLS_PCL    0
`define PCLS_ADL    1

`define PCHS_PCH    0
`define PCHS_ADH    1

// ALU A input select - always loaded
`define ALU_A_0     0
`define ALU_A_SB    1

// ALU_B input select - 0 holds last input
`define ALU_B_DB    1  
`define ALU_B_NDB   2  
`define ALU_B_ADL   3

// ALU Carry select
`define ALU_C_0     0       // Forced to 0
`define ALU_C_1     1       // Forced to 1
`define ALU_C_P     2       // Carry from status register
`define ALU_C_AC    3       // Carry from previous accumulator carry

// ALU ops - some extra space for "illegal" ops in the future when I get to it.
`define ALU_ADC   4'b0000
`define ALU_ORA   4'b0001
`define ALU_AND   4'b0010
`define ALU_EOR   4'b0011
`define ALU_SBC   4'b0100
`define ALU_ROR   4'b0101
`define ALU_PSA   4'b1111   // Just pass A input through - Used for JSR passthrough

`define FLAGS_DB    4'h1
`define FLAGS_DBZN  4'h2
`define FLAGS_ALU   4'h3
`define FLAGS_D     4'h4
`define FLAGS_I     4'h5
`define FLAGS_C     4'h6
`define FLAGS_V     4'h7
`define FLAGS_SETI  4'h8
`define FLAGS_CNZ   4'h9
`define FLAGS_BIT   4'ha
`define FLAGS_Z     4'hb

`define ALUF_C 0
`define ALUF_Z 1
`define ALUF_V 2
`define ALUF_N 3

`define PF_C 0
`define PF_Z 1
`define PF_I 2
`define PF_D 3
`define PF_B 4
`define PF_V 6
`define PF_N 7

`define Tn    3'd0        // Go to T+1 (default)
`define T0    3'd1        // Go to T0
`define TNC   3'd2        // Go to T0 if ALU carry is 0
`define TBE   3'd3        // Go to T0 if no branch page crossing
`define TBR   3'd4        // Go to T1 if branch condition code check fails
`define TKL   3'd7        // Halt CPU - Unimplemented microcode entry

`define TNC   4'h8        // 0 if no carray
`define TBE   4'h9        // 0 if no branch page crossing
`define TBR   4'ha        // 1 if branch CC check fails
`define TKL   4'hf        // unimplemented microcode

`endif //_6502_inc_vh_
