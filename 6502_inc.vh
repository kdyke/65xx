`ifndef _6502_inc_vh_
`define _6052_inc_vh_

// This is just the universal "don't care" or "default"
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
`define SB_ADH      5
`define SB_DB       6
`define SB_FF       7

// Internal ADH bus input select
`define ADH_DI      0       // ADH is data bus input (not latched)
`define ADH_PCHS    1       // ADH is current PCHS out
`define ADH_ALU     2       // ADH is current value from ALU
`define ADH_0       3       // This would eventually be the base page register
`define ADH_1       4       // This would eventually be the stack page register
`define ADH_FF      5

// Internal ADL bus input select
`define ADL_DI      0       // ADL is data bus input (not latched)
`define ADL_PCLS    1       // ADL is current PCLS out
`define ADL_S       2       // ADL is current stack pointer
`define ADL_ALU     3       // ADL is ALU output
`define ADL_VECLO   4       // ADL is low vector address
`define ADL_VECHI   5       // ADL is high vector address

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
`define ALU_SUM   4'b0000
`define ALU_ORA   4'b0001
`define ALU_AND   4'b0010
`define ALU_EOR   4'b0011
`define ALU_SBC   4'b0100
`define ALU_ROR   4'b0101
`define ALU_PSA   4'b1111   // Just pass A input through - Used for JSR passthrough

`define LF_C_DB0      0
`define LF_C_IR5      1
`define LF_C_ACR      2
`define LF_Z_SBZ      3
`define LF_Z_DB1      4
`define LF_I_DB2      5
`define LF_I_IR5      6
`define LF_D_DB3      7
`define LF_D_IR5      8
`define LF_V_DB6      9
`define LF_V_AVR      10
`define LF_V_0        11
`define LF_N_SBN      12
`define LF_N_DB7      13
`define LF_I_1        14

`define LM_C_DB0      (1 << `LF_C_DB0)
`define LM_C_IR5      (1 << `LF_C_IR5)
`define LM_C_ACR      (1 << `LF_C_ACR)
`define LM_Z_SBZ      (1 << `LF_Z_SBZ)
`define LM_Z_DB1      (1 << `LF_Z_DB1)
`define LM_I_DB2      (1 << `LF_I_DB2)
`define LM_I_IR5      (1 << `LF_I_IR5)
`define LM_D_DB3      (1 << `LF_D_DB3)
`define LM_D_IR5      (1 << `LF_D_IR5)
`define LM_V_DB6      (1 << `LF_V_DB6)
`define LM_V_AVR      (1 << `LF_V_AVR)
`define LM_V_0        (1 << `LF_V_0  )
`define LM_N_SBN      (1 << `LF_N_SBN)
`define LM_N_DB7      (1 << `LF_N_DB7)
`define LM_I_1        (1 << `LF_I_1  )

`define DECODED_LOAD_FLAGS 1
`ifdef DECODED_LOAD_FLAGS
`define FLAGS_DB        (`LM_C_DB0 | `LM_Z_DB1 | `LM_I_DB2 | `LM_D_DB3 | `LM_V_DB6 | `LM_N_DB7)
`define FLAGS_DBZN      (`LM_Z_SBZ | `LM_N_SBN)
`define FLAGS_D         (`LM_D_IR5)
`define FLAGS_I         (`LM_I_IR5)
`define FLAGS_C         (`LM_C_IR5)
`define FLAGS_V         (`LM_V_0)
`define FLAGS_Z         (`LM_Z_SBZ)
`define FLAGS_CNZ       (`LM_C_ACR | `LM_Z_SBZ | `LM_N_SBN)
`define FLAGS_ALU       (`LM_C_ACR | `LM_V_AVR | `LM_Z_SBZ | `LM_N_SBN)
`define FLAGS_BIT       (`LM_V_DB6 | `LM_N_DB7)
`define FLAGS_SETI      (`LM_I_1)
`else
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
`endif

`define ALUF_C 0
`define ALUF_Z 1
`define ALUF_V 2
`define ALUF_N 3

`define PF_C 0
`define PF_Z 1
`define PF_I 2
`define PF_D 3
`define PF_B 4
`define PF_U 5
`define PF_V 6
`define PF_N 7

`define Tn    3'd0        // Go to T+1 (default)
`define T0    3'd1        // Go to T0
`define TNC   3'd2        // Go to T0 if ALU carry is 0
`define TBE   3'd3        // Go to T0 if no branch page crossing
`define TBR   3'd4        // Go to T1 if branch condition code check fails
`define TKL   3'd7        // Halt CPU - Unimplemented microcode entry

`define TNEXT_BITS      2:0
`define WRITE_BITS      3:3
`define PCHS_BITS       4:4
`define ADH_BITS        7:5
`define PCLS_BITS       8:8
`define ADL_BITS        11:9
`define DB_BITS         14:12
`define SB_BITS         17:15
`define PC_INC_BITS     18:18
`define ALU_BITS        22:19
`define ALU_A_BITS      23:23
`define ALU_B_BITS      26:24
`define ALU_C_BITS      28:27
`define LOAD_REG_BITS   32:29
`define LOAD_A_BITS     29:29
`define LOAD_X_BITS     30:30
`define LOAD_Y_BITS     31:31
`define LOAD_SP_BITS    32:32
`define LOAD_ABH_BITS   33:33
`define LOAD_ABL_BITS   34:34

`define LOAD_FLAGS_BITS 50:36

`define MICROCODE_BITS  50:0

`define FIELD_SHIFT(_x) (0?_x)

`define LOAD_A 4'b0001
`define LOAD_X 4'b0010
`define LOAD_Y 4'b0100
`define LOAD_S 4'b1000

`define MICROCODE(_ins, _t, _tnext, _adh_sel, _adl_sel, _db_sel, _sb_sel, _pchs_sel, _pcls_sel, _alu_sel, _alu_a, _alu_b, _alu_c, _load_reg, _load_abh, _load_abl, _load_flags, _write, _pc_inc) \
mc[(_ins << 3) | _t] = ( \
  (_tnext << `FIELD_SHIFT(`TNEXT_BITS)) | \
  (_adh_sel << `FIELD_SHIFT(`ADH_BITS)) | \
  (_adl_sel << `FIELD_SHIFT(`ADL_BITS)) | \
  (_db_sel << `FIELD_SHIFT(`DB_BITS)) | \
  (_sb_sel << `FIELD_SHIFT(`SB_BITS)) | \
  (_pchs_sel << `FIELD_SHIFT(`PCHS_BITS)) | \
  (_pcls_sel << `FIELD_SHIFT(`PCLS_BITS)) | \
  (_alu_sel << `FIELD_SHIFT(`ALU_BITS)) | \
  (_alu_a << `FIELD_SHIFT(`ALU_A_BITS)) | \
  (_alu_b << `FIELD_SHIFT(`ALU_B_BITS)) | \
  (_alu_c << `FIELD_SHIFT(`ALU_C_BITS)) | \
  (_load_reg << `FIELD_SHIFT(`LOAD_REG_BITS)) | \
  (_load_abh << `FIELD_SHIFT(`LOAD_ABH_BITS)) | \
  (_load_abl << `FIELD_SHIFT(`LOAD_ABL_BITS)) | \
  (_load_flags << `FIELD_SHIFT(`LOAD_FLAGS_BITS)) | \
  (_write << `FIELD_SHIFT(`WRITE_BITS)) | \
  (_pc_inc << `FIELD_SHIFT(`PC_INC_BITS)) \
  );

`define ADDR_zp(_insbyte, tn) \
`MICROCODE(  _insbyte,  2,  tn, `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  `none,  1,  1,       `none, 0, 1)

`define ADDR_zp_x_ind(_insbyte) \
`MICROCODE(  _insbyte,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  `none,  1,  1,       `none, 0, 1) \
`MICROCODE(  _insbyte,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  `none,  1,  1,       `none, 0, 0) \
`MICROCODE(  _insbyte,  4, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_1,  `none,  1,  1,       `none, 0, 0) \
`MICROCODE(  _insbyte,  5, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  `none,  1,  1,       `none, 0, 0)

`define ADDR_abs(_insbyte, tn) \
`MICROCODE(  _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  `none,  1,  1,       `none, 0, 1) \
`MICROCODE(  _insbyte,  3,  tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  `none,  1,  1,       `none, 0, 1)

`define ADDR_abs_x(_insbyte, t1, t2) \
`MICROCODE(  _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  `none,  1,  1,       `none, 0, 1) \
`MICROCODE(  _insbyte,  3,  t1,  `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  `none,  1,  1,       `none, 0, 1) \
`MICROCODE(  _insbyte,  4,  t2,  `ADH_ALU,  `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  `none,  1,  0,       `none, 0, 0)

`define ADDR_abs_y(_insbyte) \
`MICROCODE(  _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  `none,  1,  1,       `none, 0, 1) \
`MICROCODE(  _insbyte,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  `none,  1,  1,       `none, 0, 1) \
`MICROCODE(  _insbyte,  4, `T0 , `ADH_ALU,  `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  `none,  1,  0,       `none, 0, 0)

`define ADDR_zp_ind_y(_insbyte) \
`MICROCODE(  _insbyte,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  `none,  1,  1,       `none, 0, 1) \
`MICROCODE(  _insbyte,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_SB,`ALU_B_DB, `ALU_C_1,  `none,  1,  1,       `none, 0, 0) \
`MICROCODE(  _insbyte,  4, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_0,  `none,  1,  1,       `none, 0, 0) \
`MICROCODE(  _insbyte,  5, `T0 , `ADH_ALU,  `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  `none,  1,  0,       `none, 0, 0)

`define ADDR_zp_x(_insbyte, tn) \
`MICROCODE(  _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  `none,  1,  1,       `none, 0, 1) \
`MICROCODE(  _insbyte,  3,  tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  `none,  1,  1,       `none, 0, 0)

`define ADDR_zp_y(_insbyte) \
`MICROCODE(  _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  `none,  1,  1,       `none, 0, 1) \
`MICROCODE(  _insbyte,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  `none,  1,  1,       `none, 0, 0)

`define ALUA(_insbyte, _aluop, _alub, _sb, _alucarry, _load, _flags, _inc) \
  `MICROCODE(  _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, _sb,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,   _alub,      `none,  `none,  1,  1,       `none, 0, _inc) \
  `MICROCODE(  _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  _aluop,    `none,     `none, _alucarry, _load,  1,  1,      _flags, 0, 1)

`define ORA(_insbyte,_inc) `ALUA(_insbyte, `ALU_ORA, `ALU_B_DB, `SB_A, `ALU_C_0, `LOAD_A, `FLAGS_DBZN, _inc)
`define AND(_insbyte,_inc) `ALUA(_insbyte, `ALU_AND, `ALU_B_DB, `SB_A, `ALU_C_0, `LOAD_A, `FLAGS_DBZN, _inc)
`define EOR(_insbyte,_inc) `ALUA(_insbyte, `ALU_EOR, `ALU_B_DB, `SB_A, `ALU_C_0, `LOAD_A, `FLAGS_DBZN, _inc)
`define ADC(_insbyte,_inc) `ALUA(_insbyte, `ALU_ADC, `ALU_B_DB, `SB_A, `ALU_C_P, `LOAD_A, `FLAGS_ALU, _inc)
`define CMP(_insbyte,_inc) `ALUA(_insbyte, `ALU_SUM, `ALU_B_NDB, `SB_A, `ALU_C_1, `none, `FLAGS_CNZ, _inc)
`define CPX(_insbyte,_inc) `ALUA(_insbyte, `ALU_SUM, `ALU_B_NDB, `SB_X, `ALU_C_1, `none, `FLAGS_CNZ, _inc)
`define CPY(_insbyte,_inc) `ALUA(_insbyte, `ALU_SUM, `ALU_B_NDB, `SB_Y, `ALU_C_1, `none, `FLAGS_CNZ, _inc)
`define SBC(_insbyte,_inc) `ALUA(_insbyte, `ALU_SBC, `ALU_B_NDB, `SB_A, `ALU_C_P, `LOAD_A, `FLAGS_ALU, _inc)

`define BIT(_insbyte) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  `none,  1,  1,  `FLAGS_BIT, 0, 0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_AND,    `none,     `none, `ALU_C_0,  `none,  1,  1,    `FLAGS_Z, 0, 1)

`define STx(_insbyte, _reg) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB,  _reg,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  `none,  1,  1,       `none, 1, 0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  `none,  1,  1,       `none, 0, 1)

`define STA(_insbyte) `STx(_insbyte, `SB_A)
`define STX(_insbyte) `STx(_insbyte, `SB_X)
`define STY(_insbyte) `STx(_insbyte, `SB_Y)

`define LDx(_insbyte, _load, _inc) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  _load,  1,  1, `FLAGS_DBZN, 0, _inc) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  `none,  1,  1,       `none, 0, 1)

`define LDA(_insbyte, _inc) `LDx(_insbyte, `LOAD_A, _inc)
`define LDX(_insbyte, _inc) `LDx(_insbyte, `LOAD_X, _inc)
`define LDY(_insbyte, _inc) `LDx(_insbyte, `LOAD_Y, _inc)

`define BRA(_insbyte) \
`MICROCODE( _insbyte,  2, `TBR, `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_ADL,    `none,  `none,  1,  1,       `none, 0, 1) \
`MICROCODE( _insbyte,  3, `TBE, `ADH_PCHS, `ADL_ALU,  `DB_BO, `SB_ADH, `PCHS_PCH, `PCLS_ADL,  `ALU_SUM,`ALU_A_SB, `ALU_B_DB, `ALU_C_0,  `none,  1,  1,       `none, 0, 0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_ALU,  `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_ADH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  `none,  1,  1,       `none, 0, 0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  `none,  1,  1,       `none, 0, 1)

`define SHIFT_MEM(_insbyte, c1, c2, _aluop, _alucarry) \
`MICROCODE( _insbyte,  c1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  `none,  0,  0,       `none, 0, 0) \
`MICROCODE( _insbyte,  c2, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  _aluop, `ALU_A_0,`ALU_B_ADL,_alucarry,    `none,  0,  0,  `FLAGS_CNZ, 0, 0) \
`MICROCODE( _insbyte,   0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  `none,  1,  1,       `none, 1, 0) \
`MICROCODE( _insbyte,   1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  `none,  1,  1,       `none, 0, 1)

`define ASL_MEM(_insbyte, c1, c2) `SHIFT_MEM(_insbyte, c1, c2, `ALU_SUM, `ALU_C_0)
`define ROL_MEM(_insbyte, c1, c2) `SHIFT_MEM(_insbyte, c1, c2, `ALU_SUM, `ALU_C_P)
`define LSR_MEM(_insbyte, c1, c2) `SHIFT_MEM(_insbyte, c1, c2, `ALU_ROR, `ALU_C_0)
`define ROR_MEM(_insbyte, c1, c2) `SHIFT_MEM(_insbyte, c1, c2, `ALU_ROR, `ALU_C_P)

`define SHIFT_A(_insbyte, _aluop, _alucarry) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_A,  `SB_A,   `PCHS_PCH, `PCLS_PCL,   `none,`ALU_A_SB, `ALU_B_DB,      `none,  `none,  1,  1,       `none, 0, 0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  _aluop,    `none,     `none, _alucarry, `LOAD_A,  1,  1,  `FLAGS_CNZ, 0, 1)

`define ASL_A(_insbyte) `SHIFT_A(_insbyte, `ALU_SUM, `ALU_C_0)
`define ROL_A(_insbyte) `SHIFT_A(_insbyte, `ALU_SUM, `ALU_C_P)
`define LSR_A(_insbyte) `SHIFT_A(_insbyte, `ALU_ROR, `ALU_C_0)
`define ROR_A(_insbyte) `SHIFT_A(_insbyte, `ALU_ROR, `ALU_C_P)

`define FLAG_OP(_insbyte, _flag) \
`MICROCODE(  _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  `none,  1,  1,    _flag, 0, 0) \
`MICROCODE(  _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  `none,  1,  1,    `none, 0, 1)

`define Txx(_insbyte, _sb, _load, _flags) \
`MICROCODE(  _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB,   _sb,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  _load,  1,  1,      _flags, 0, 0) \
`MICROCODE(  _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  `none,  1,  1,       `none, 0, 1)

`define DEC_REG(_insbyte, _reg, _load) \
`MICROCODE(  _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_FF,   _reg,  `PCHS_PCH, `PCLS_PCL, `none,   `ALU_A_SB,  `ALU_B_DB,    `none,  `none,  1,  1,       `none, 0, 0) \
`MICROCODE(  _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  _load,  1,  1, `FLAGS_DBZN, 0, 1)

`define INC_REG(_insbyte, _reg, _load) \
`MICROCODE(  _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_FF,    _reg, `PCHS_PCH, `PCLS_PCL,     `none,`ALU_A_SB,`ALU_B_NDB,    `none,  `none,  1,  1,       `none, 0, 0) \
`MICROCODE(  _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  _load,  1,  1, `FLAGS_DBZN, 0, 1)

`define DEC_MEM(_insbyte, c1, c2) \
`MICROCODE(  _insbyte,  c1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_FF,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  `none,  0,  0,       `none, 0, 0) \
`MICROCODE(  _insbyte,  c2, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU ,`PCHS_PCH, `PCLS_PCL,  `ALU_SUM,`ALU_A_0, `ALU_B_ADL, `ALU_C_0,  `none,  0,  0, `FLAGS_DBZN, 0, 0) \
`MICROCODE(  _insbyte,   0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU ,`PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  `none,  1,  1,       `none, 1, 0) \
`MICROCODE(  _insbyte,   1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU ,`PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  `none,  1,  1,       `none, 0, 1)

`define INC_MEM(_insbyte, c1, c2) \
`MICROCODE(  _insbyte,  c1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  `none,  0,  0,       `none, 0, 0) \
`MICROCODE(  _insbyte,  c2, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_1,  `none,  0,  0, `FLAGS_DBZN, 0, 0) \
`MICROCODE(  _insbyte,   0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  `none,  1,  1,       `none, 1, 0) \
`MICROCODE(  _insbyte,   1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  `none,  1,  1,       `none, 0, 1)

`define PUSH(_insbyte, _reg) \
`MICROCODE(  _insbyte,  2, `T0 , `ADH_1,    `ADL_S,    `DB_FF, `SB_FF,  `PCHS_PCH, `PCLS_PCL,     `none, `ALU_A_SB,`ALU_B_ADL,   `none,   `none,  1,  1,       `none, 0, 0) \
`MICROCODE(  _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,   _reg, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0, `LOAD_S,  1,  1,       `none, 1, 0) \
`MICROCODE(  _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,    `none,     `none,    `none,   `none,  1,  1,       `none, 0, 1)

`define PULL(_insbyte, _load, flags) \
`MICROCODE(  _insbyte,  2, `Tn , `ADH_1,    `ADL_S,    `DB_FF, `SB_FF,  `PCHS_PCH, `PCLS_PCL,     `none, `ALU_A_0,`ALU_B_ADL,    `none,   `none,  1,  1,       `none, 0, 0) \
`MICROCODE(  _insbyte,  3, `T0 , `ADH_1,    `ADL_ALU,  `DB_FF, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1, `LOAD_S,  1,  1,       `none, 0, 0) \
`MICROCODE(  _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,     `none,    `none,     `none,    `none,   _load,  1,  1,       flags, 0, 0) \
`MICROCODE(  _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,    `none,     `none,    `none,   `none,  1,  1,       `none, 0, 1)

`endif //_6502_inc_vh_
