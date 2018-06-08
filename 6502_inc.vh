`ifndef _6502_inc_vh_
`define _6052_inc_vh_

// For when I want to synthesize and keep the full internal hierarchy
`define SCHEM_KEEP 1
`ifdef SCHEM_KEEP
`define SCHEM_KEEP_HIER (* keep_hierarchy = "yes" *)
`else
`define SCHEM_KEEP_HIER
`endif

// This is just the universal "don't care" or "default"
`define none          0

// What's driving the address bus
`define AB_PC   3'd0
`define AB_AB   3'd1
`define AB_AD   3'd2
`define AB_S    3'd3

// ALU A input select
`define ALUA_REG   0
`define ALUA_NREG  1
`define ALUA_VEC   2

// ALU A bus select
`define ABUS_0      0
`define ABUS_A      1
`define ABUS_X      2
`define ABUS_Y      3
`define ABUS_Z      4
`define ABUS_P      5
`define ABUS_B      6
`define ABUS_PCH    7
`define ABUS_SPH    8
`define ABUS_PCL    9
`define ABUS_SPL    10

// ALU_B input select
`define ALUB_0     0
`define ALUB_DB    1
`define ALUB_BIT   2
`define ALUB_INV   4
// Helpful aliases
`define ALUB_FF    4
`define ALUB_NDB   5
`define ALUB_NBIT  6

// ALU Carry input select
`define ALUC_0     0       // Forced to 0
`define ALUC_1     1       // Forced to 1
`define ALUC_P     2       // Carry from status register
`define ALUC_A     3       // Carry from previous accumulator carry

// ALU ops - some extra space for "illegal" ops in the future when I get to it.
`define ALU_ORA   3'b000   // Default
`define ALU_ADC   3'b001
`define ALU_AND   3'b010
`define ALU_EOR   3'b011
`define ALU_SBC   3'b100  // Not Really needed?
`define ALU_ROR   3'b101
`define ALU_ASR   3'b110

// Decoded flag update
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
`define LF_E_IR0      15

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
`define LM_E_IR0      (1 << `LF_E_IR0)

// Encoded flag update field
`define FLAGS_DB    4'h1
`define FLAGS_SBZN  4'h2
`define FLAGS_ALU   4'h3
`define FLAGS_D     4'h4
`define FLAGS_I     4'h5
`define FLAGS_C     4'h6
`define FLAGS_V     4'h7
`define FLAGS_SETI  4'h8
`define FLAGS_CNZ   4'h9
`define FLAGS_BIT   4'ha
`define FLAGS_Z     4'hb
`define FLAGS_E     4'hc

// Flags bit definitions
`define PF_C 0
`define PF_Z 1
`define PF_I 2
`define PF_D 3
`define PF_B 4
`define PF_E 5
`define PF_V 6
`define PF_N 7

// Encoded field to load register from ALUY
`define ALUY_A      1
`define ALUY_X      2
`define ALUY_Y      3
`define ALUY_Z      4
`define ALUY_P      5
`define ALUY_B      6
`define ALUY_ABH    7
`define ALUY_ADH    8
`define ALUY_PCH    9
`define ALUY_SPH    10
`define ALUY_ABL    11
`define ALUY_ADL    12
`define ALUY_PCL    13
`define ALUY_SPL    14

`define LR_A      0
`define LR_X      1
`define LR_Y      2
`define LR_Z      3
`define LR_P      4
`define LR_B      5
`define LR_ABH    6
`define LR_ADH    7
`define LR_PCH    8
`define LR_SPH    9
`define LR_ABL    10
`define LR_ADL    11
`define LR_PCL    12
`define LR_SPL    13

`define LOAD_A    (1 << `LR_A)
`define LOAD_X    (1 << `LR_X)
`define LOAD_Y    (1 << `LR_Y)
`define LOAD_Z    (1 << `LR_Z)
`define LOAD_P    (1 << `LR_P)
`define LOAD_B    (1 << `LR_B)
`define LOAD_ABH  (1 << `LR_ABH)
`define LOAD_ADH  (1 << `LR_ADH)
`define LOAD_PCH  (1 << `LR_PCH)
`define LOAD_SPH  (1 << `LR_SPH)
`define LOAD_ABL  (1 << `LR_ABL)
`define LOAD_ADL  (1 << `LR_ADL)
`define LOAD_PCL  (1 << `LR_PCL)
`define LOAD_SPL  (1 << `LR_SPL)

`define ABH_KEEP    0
`define ABH_B       1
`define ABH_ALU     2
`define ABH_ADJ     3         // Update based on ABL counter update

`define AB_INC      1
`define AB_DEC      2

`define SP_INC      1
`define SP_DEC      2

// TODO - Move all the microcode related `defines to a separate file that's not visible to the rest
// of the code, since it's supposed to be an implementation detail.

`define Tn    3'd0        // Go to T+1 (default)
`define T1    3'd1        // Go to T1 (sync)
//`define TNC   3'd2        // Go to T0 if ALU carry is 0
//`define TBE   3'd3        // Go to T0 if no branch page crossing
//`define TBR   3'd4        // Go to T1 if branch condition code check fails
//`define TBT   3'd5        // Go to T1 if branch bit test check fails
`define TKL   3'd7        // Halt CPU - Unimplemented microcode entry

// Note: Try not to have any signals span 8 bit boundaries, which gives the synthesis more options
// in choosing which signals go with which block rams.  Still to do: Figure out if there are better
// groupings for signals that are likely to go to similar places.

// Also... block RAMs are really 36 bits wide, so it's also useful to make sure those last 4 bits
// are grouped together.  Although for Artix-7 the synthesis tools really wind up generating 3
// 2K x 18bit block RAMs.  So the bit groupings really wind up being 3 groups of 18 bits.

// 7:0
`define TNEXT_BITS      2:0
`define AB_BITS         4:3
`define PC_INC_BITS     5:5
`define SP_INCDEC_BITS  7:6

// 15:8
`define ABH_BITS        9:8
`define AB_INCDEC_BITS  11:10
`define LOAD_FLAGS_BITS 15:12

// 23:16
`define PCL_ADL_BITS    16:16
`define ALU_A_BITS      19:17
`define ALU_B_BITS      21:20
`define ALU_C_BITS      23:22

// 31:24
`define WRITE_BITS      24:24
`define ALU_BITS        27:25
`define LOAD_ALUY_BITS  31:28

// 35:32
`define ABUS_BITS       35:32

// 42:39
`define MICROCODE_BITS  35:0

`define FIELD_SHIFT(_x) (0?_x)

`define MICROCODE(_ins, _t, _tnext, _ab_sel, _abh_sel, _ab_incdec, _sp_incdec, _pc_inc, _pcl_adl, _alu_sel, _alu_a, _abus, _alu_b, _alu_c, _load_reg, _load_flags, _write) \
mc[(_ins << 3) | _t] = ( \
  (_tnext << `FIELD_SHIFT(`TNEXT_BITS)) | \
  (_ab_sel << `FIELD_SHIFT(`AB_BITS)) | \
  (_abh_sel << `FIELD_SHIFT(`ABH_BITS)) | \
  (_ab_incdec << `FIELD_SHIFT(`AB_INCDEC_BITS)) | \
  (_sp_incdec << `FIELD_SHIFT(`SP_INCDEC_BITS)) | \
  (_pc_inc << `FIELD_SHIFT(`PC_INC_BITS)) | \
  (_pcl_adl << `FIELD_SHIFT(`PCL_ADL_BITS)) | \
  (_alu_sel << `FIELD_SHIFT(`ALU_BITS)) | \
  (_alu_a << `FIELD_SHIFT(`ALU_A_BITS)) | \
  (_abus << `FIELD_SHIFT(`ABUS_BITS)) | \
  (_alu_b << `FIELD_SHIFT(`ALU_B_BITS)) | \
  (_alu_c << `FIELD_SHIFT(`ALU_C_BITS)) | \
  (_load_reg << `FIELD_SHIFT(`LOAD_ALUY_BITS)) | \
  (_load_flags << `FIELD_SHIFT(`LOAD_FLAGS_BITS)) | \
  (_write << `FIELD_SHIFT(`WRITE_BITS)) \
  );

//                                                                                                                                      Register Loads
//                 INS  T  Tn   Ab      Abh         Ab       Sp      PC   PCL/  Alu_op  Alu_a       Abus       Alu_b       Alu_c     Load       Flags      WC
//                                                  Cnt      Cnt     Inc  ADL                                  Alu_b       Alu_c     Load       Flags      WC

`define BRK(_insbyte) \
`MICROCODE( _insbyte,  2, `Tn , `AB_S,  `ABH_KEEP,  `none,   `none,   1, `none, `none,  `ALUA_REG, `ABUS_PCH, `ALUB_0,    `ALUC_0, `none,     `none,       1) \
`MICROCODE( _insbyte,  3, `Tn , `AB_S,  `ABH_KEEP,  `none,   `SP_DEC, 0, `none, `none,  `ALUA_REG, `ABUS_PCL, `ALUB_0,    `ALUC_0, `none,     `none,       1) \
`MICROCODE( _insbyte,  4, `Tn , `AB_S,  `ABH_KEEP,  `none,   `SP_DEC, 0, `none, `none,  `ALUA_REG, `ABUS_P,   `ALUB_0,    `ALUC_0, `none,     `none,       1) \
`MICROCODE( _insbyte,  5, `Tn , `AB_AB, `ABH_KEEP,  `none,   `SP_DEC, 0, `none, `none,  `ALUA_VEC, `ABUS_0,   `ALUB_0,    `ALUC_0, `ALUY_ABL, `none,       0) \
`MICROCODE( _insbyte,  6, `Tn , `AB_AB, `ABH_KEEP,  `AB_INC, `none,   0, `none, `none,  `none,     `ABUS_0,   `ALUB_DB,   `ALUC_0, `ALUY_PCL, `FLAGS_SETI, 0) \
`MICROCODE( _insbyte,  7, `T1 , `AB_PC, `ABH_KEEP,  `none,   `none,   0, `none, `none,  `none,     `ABUS_0,   `ALUB_DB,   `ALUC_0, `ALUY_PCH, `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `AB_PC, `ABH_KEEP,  `none,   `none,   1, `none, `none,  `none,     `ABUS_0,   `ALUB_DB,   `ALUC_0, `none,     `none,       0) \

`define FLAG_OP(_insbyte, _flag) \
`MICROCODE( _insbyte,  1, `Tn , `AB_PC, `ABH_KEEP,  `none,   `none,   1, `none, `none,  `none,     `ABUS_0,   `ALUB_DB,   `ALUC_0, `none,     _flag,       0)

`define FLAG_OP2(_insbyte, _flag) \
`MICROCODE( _insbyte,  2, `T1 , `AB_PC, `ABH_KEEP,  `none,   `none,   0, `none, `none,  `none,     `ABUS_0,   `ALUB_DB,   `ALUC_0, `none,     _flag,       0) \
`MICROCODE( _insbyte,  1, `Tn , `AB_PC, `ABH_KEEP,  `none,   `none,   1, `none, `none,  `none,     `ABUS_0,   `ALUB_DB,   `ALUC_0, `none,     `none,       0)

`define LDx(_insbyte, _load, _i) \
`MICROCODE( _insbyte,  2, `T1 , `AB_PC, `ABH_KEEP,  `none,   `none,  _i, `none, `none,  `none,     `none,     `ALUB_DB,   `ALUC_0, _load,     `FLAGS_SBZN, 0) \
`MICROCODE( _insbyte,  1, `Tn , `AB_PC, `ABH_KEEP,  `none,   `none,   1, `none, `none,  `none,     `none,     `none,      `none,    `none,    `none,       0)

`define LDA(_insbyte, _inc) `LDx(_insbyte, `LOAD_A, _inc)
`define LDX(_insbyte, _inc) `LDx(_insbyte, `LOAD_X, _inc)
`define LDY(_insbyte, _inc) `LDx(_insbyte, `LOAD_Y, _inc)
`define LDZ(_insbyte, _inc) `LDx(_insbyte, `LOAD_Z, _inc)

`define Txx(_insbyte, _reg, _load, _flags) \
`MICROCODE( _insbyte,  1, `Tn , `AB_PC, `ABH_KEEP,  `none,   `none,   1, `none, `none,  `ALUA_REG, _reg,      `ALUB_0,   `ALUC_0, _load,     _flags,      0)

`ifdef NOTYET

`define BRK(_insbyte) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_1,    `ADL_S,     1,  1, `PCHPCL,  1, `DB_PCH,`SB_FF,  `none,    `ALU_A_SB, `ALU_B_ADL, `none,    `none,   `none,       1) \
`MICROCODE( _insbyte,  3, `Tn , `ADH_1,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_PCL,`SB_FF,  `ALU_SUM, `ALU_A_SB, `ALU_B_ADL, `ALU_C_0, `none,   `none,       1) \
`MICROCODE( _insbyte,  4, `Tn , `ADH_1,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_P,  `SB_FF,  `ALU_SUM, `ALU_A_SB, `ALU_B_ADL, `ALU_C_0, `none,   `none,       1) \
`MICROCODE( _insbyte,  5, `Tn , `ADH_FF,   `ADL_VECLO, 1,  1, `PCHPCL,  0, `DB_DI, `SB_ALU, `ALU_SUM, `none,     `none,      `ALU_C_0, `LOAD_S, `none,       0) \
`MICROCODE( _insbyte,  6, `T0 , `ADH_FF,   `ADL_VECHI, 1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `ALU_A_0,  `ALU_B_DB,  `ALU_C_0, `none,   `FLAGS_SETI, 0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_DI,   `ADL_ALU,   1,  1, `ADHADL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `none,     `none,      `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0)

`define ADDR_zp_(_insbyte, tn, _db, _sb, _w) \
`MICROCODE( _insbyte,  2,  tn , `ADH_0,    `ADL_DI,    1,  1, `PCHPCL,  1,  _db,    _sb,    `none,    `none,     `none,      `none,    `none,   `none,       _w)

`define ADDR_zp_x_ind_(_insbyte, _db, _sb, _w) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_0,    `ADL_DI,    1,  1, `PCHPCL,  1, `DB_DI, `SB_X,   `none,    `ALU_A_SB, `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `Tn , `ADH_0,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `ALU_A_0,  `ALU_B_ADL, `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  4, `Tn , `ADH_0,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `ALU_A_0,  `ALU_B_DB,  `ALU_C_1, `none,   `none,       0) \
`MICROCODE( _insbyte,  5, `T0 , `ADH_DI,   `ADL_ALU,   1,  1, `PCHPCL,  0,  _db,    _sb,    `ALU_SUM, `none,     `none,      `ALU_C_0, `none,   `none,       _w)

`define ADDR_abs_(_insbyte, tn, _db, _sb, _w) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `ALU_A_0,  `ALU_B_DB,  `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  3,  tn , `ADH_DI,   `ADL_ALU,   1,  1, `PCHPCL,  1,  _db,    _sb,    `ALU_SUM, `none,     `none,      `ALU_C_0, `none,   `none,       _w)

`define ADDR_abs_x_(_insbyte, t1, t2, _db, _sb, _w) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_X,   `none,    `ALU_A_SB, `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3,  t1 , `ADH_DI,   `ADL_ALU,   1,  1, `PCHPCL,  1,  _db,    _sb,    `ALU_SUM, `ALU_A_0,  `ALU_B_DB,  `ALU_C_0, `none,   `none,       _w) \
`MICROCODE( _insbyte,  4,  t2 , `ADH_ALU,  `ADL_PCLS,  1,  0, `PCHPCL,  0,  _db,    _sb,    `ALU_SUM, `none,     `none,      `ALU_C_A, `none,   `none,       _w)

`define ADDR_abs_y_(_insbyte, _db, _sb, _w) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_Y,   `none,    `ALU_A_SB, `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `TNC, `ADH_DI,   `ADL_ALU,   1,  1, `PCHPCL,  1,  _db,    _sb,    `ALU_SUM, `ALU_A_0,  `ALU_B_DB,  `ALU_C_0, `none,   `none,       _w) \
`MICROCODE( _insbyte,  4, `T0 , `ADH_ALU,  `ADL_PCLS,  1,  0, `PCHPCL,  0,  _db,    _sb,    `ALU_SUM, `none,     `none,      `ALU_C_A, `none,   `none,       _w)

`define ADDR_zp_ind_y_(_insbyte, _db, _sb, _w) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_0,    `ADL_DI,    1,  1, `PCHPCL,  1, `DB_DI, `SB_DB,  `none,    `ALU_A_0,  `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `Tn , `ADH_0,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_DI, `SB_Y,   `ALU_SUM, `ALU_A_SB, `ALU_B_DB,  `ALU_C_1, `none,   `none,       0) \
`MICROCODE( _insbyte,  4, `TNC, `ADH_DI,   `ADL_ALU,   1,  1, `PCHPCL,  0,  _db,    _sb,    `ALU_SUM, `ALU_A_0,  `ALU_B_DB,  `ALU_C_0, `none,   `none,       _w) \
`MICROCODE( _insbyte,  5, `T0 , `ADH_ALU,  `ADL_PCLS,  1,  0, `PCHPCL,  0,  _db,    _sb,    `ALU_SUM, `none,     `none,      `ALU_C_A, `none,   `none,       _w)

`define ADDR_zp_ind_(_insbyte, _db, _sb, _w) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_0,    `ADL_DI,    1,  1, `PCHPCL,  1, `DB_DI, `SB_DB,  `none,    `ALU_A_0,  `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `Tn , `ADH_0,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_DI, `SB_Y,   `ALU_SUM, `ALU_A_0,  `ALU_B_DB,  `ALU_C_1, `none,   `none,       0) \
`MICROCODE( _insbyte,  4, `T0 , `ADH_DI,   `ADL_ALU,   1,  1, `PCHPCL,  0,  _db,    _sb,    `ALU_SUM, `ALU_A_0,  `ALU_B_DB,  `ALU_C_0, `none,   `none,       _w)

`define ADDR_zp_x_(_insbyte, tn, _db, _sb, _w) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_X,   `none,    `ALU_A_SB, `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3,  tn , `ADH_0,    `ADL_ALU,   1,  1, `PCHPCL,  0,  _db,    _sb,    `ALU_SUM, `none,     `none,      `ALU_C_0, `none,   `none,       _w)

`define ADDR_zp_y_(_insbyte, _db, _sb, _w) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_Y,   `none,    `ALU_A_SB, `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `T0 , `ADH_0,    `ADL_ALU,   1,  1, `PCHPCL,  0,  _db,    _sb,    `ALU_SUM, `none,     `none,      `ALU_C_0, `none,   `none,       _w)

`define ADDR_jmp_abs(_insbyte) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `ALU_A_0,  `ALU_B_DB,  `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `Tn , `ADH_DI,   `ADL_ALU,   1,  1, `ADHADL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `none,     `none,      `ALU_C_0, `none,   `none,       0)

`define ADDR_jmp_abs_x(_insbyte) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_X,   `none,    `ALU_A_SB, `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `Tn , `ADH_DI,   `ADL_ALU,   1,  1, `PCHADL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `ALU_A_0,  `ALU_B_DB,  `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  4, `Tn , `ADH_ALU,  `ADL_PCLS,  1,  1, `ADHPCL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `none,     `none,      `ALU_C_A, `none,   `none,       0)

`define ADDR_zp(_insbyte, tn)                     `ADDR_zp_(_insbyte, tn, `DB_DI, `SB_FF, 0)
`define ADDR_zp_w(_insbyte, tn, _db, _sb)         `ADDR_zp_(_insbyte, tn, _db, _sb, 1)
`define ADDR_zp_x_ind(_insbyte)                   `ADDR_zp_x_ind_(_insbyte, `DB_DI, `SB_FF, 0)
`define ADDR_zp_x_ind_w(_insbyte, _db, _sb)       `ADDR_zp_x_ind_(_insbyte, _db, _sb, 1)
`define ADDR_abs(_insbyte, tn)                    `ADDR_abs_(_insbyte, tn, `DB_DI, `SB_FF, 0)
`define ADDR_abs_w(_insbyte, tn, _db, _sb)        `ADDR_abs_(_insbyte, tn, _db, _sb, 1)
`define ADDR_abs_x(_insbyte, t1, t2)              `ADDR_abs_x_(_insbyte, t1, t2, `DB_DI, `SB_FF, 0)
`define ADDR_abs_x_w(_insbyte, t1, t2, _db, _sb)  `ADDR_abs_x_(_insbyte, t1, t2, _db, _sb, 1)
`define ADDR_abs_y(_insbyte)                      `ADDR_abs_y_(_insbyte, `DB_DI, `SB_FF, 0)
`define ADDR_abs_y_w(_insbyte, _db, _sb)          `ADDR_abs_y_(_insbyte, _db, _sb, 1)
`define ADDR_zp_ind_y(_insbyte)                   `ADDR_zp_ind_y_(_insbyte, `DB_DI, `SB_FF, 0)
`define ADDR_zp_ind_y_w(_insbyte, _db, _sb)       `ADDR_zp_ind_y_(_insbyte, _db, _sb, 1)
`define ADDR_zp_ind(_insbyte)                     `ADDR_zp_ind_(_insbyte, `DB_DI, `SB_FF, 0)
`define ADDR_zp_ind_w(_insbyte, _db, _sb)         `ADDR_zp_ind_(_insbyte, _db, _sb, 1)
`define ADDR_zp_x(_insbyte, tn)                   `ADDR_zp_x_(_insbyte, tn, `DB_DI, `SB_FF, 0)
`define ADDR_zp_x_w(_insbyte, tn, _db, _sb)       `ADDR_zp_x_(_insbyte, tn, _db, _sb, 1)
`define ADDR_zp_y(_insbyte)                       `ADDR_zp_y_(_insbyte, `DB_DI, `SB_FF, 0)
`define ADDR_zp_y_w(_insbyte, _db, _sb)           `ADDR_zp_y_(_insbyte, _db, _sb, 1)

`define ALUA(_insbyte, _aluop, _alub, _sb, _carry, _load, _flags, _i) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL, _i, `DB_DI, _sb,     `none,    `ALU_A_SB, _alub,      `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_SB, `SB_ALU, _aluop,   `none,     `none,      _carry,   _load,   _flags,      0) \
`MICROCODE( _insbyte,  7, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_A,  `SB_A,   `none,    `none,     `none,      `none,    `none,   `FLAGS_SBZN, 0)

`define BIT(_insbyte, _flags, _i) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL, _i, `DB_DI, `SB_A,   `none,    `ALU_A_SB, `ALU_B_DB,  `none,    `none,   _flags,      0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_SB, `SB_ALU, `ALU_AND, `none,     `none,      `ALU_C_0, `none,   `FLAGS_Z,    0)

`define STx(_insbyte) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_A,   `none,    `none,     `none,      `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_A,   `none,    `none,     `none,      `none,    `none,   `none,       0)


`define BRA(_insbyte, t2) \
`MICROCODE( _insbyte,  2,   t2, `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_DB,  `none,    `ALU_A_SB, `ALU_B_ADL, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `TBE, `ADH_PCHS, `ADL_ALU,   1,  1, `PCHADL,  0, `DB_BO, `SB_ADH, `ALU_SUM, `ALU_A_SB, `ALU_B_DB,  `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_ALU,  `ADL_PCLS,  1,  1, `ADHPCL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `none,     `none,      `ALU_C_A, `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0)

// BBx
`define BBR(_insbyte) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_0,    `ADL_DI,    1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_DB,  `none,    `ALU_A_IR, `ALU_B_NDB, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  4, `TBT, `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_DB,  `ALU_AND, `ALU_A_SB, `ALU_B_ADL, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  5, `TBE, `ADH_PCHS, `ADL_ALU,   1,  1, `PCHADL,  0, `DB_BO, `SB_ADH, `ALU_SUM, `ALU_A_SB, `ALU_B_DB,  `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_ALU,  `ADL_PCLS,  1,  1, `ADHPCL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `none,     `none,      `ALU_C_A, `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0)

`define BBS(_insbyte) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_0,    `ADL_DI,    1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_DB,  `none,    `ALU_A_IR, `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  4, `TBT, `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_DB,  `ALU_AND, `ALU_A_SB, `ALU_B_ADL, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  5, `TBE, `ADH_PCHS, `ADL_ALU,   1,  1, `PCHADL,  0, `DB_BO, `SB_ADH, `ALU_SUM, `ALU_A_SB, `ALU_B_DB,  `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_ALU,  `ADL_PCLS,  1,  1, `ADHPCL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `none,     `none,      `ALU_C_A, `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0)

`define SHIFT_MEM(_insbyte, c1, c2, _aluop, _carry) \
`MICROCODE( _insbyte, c1, `Tn , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_DI, `SB_DB,  `none,    `ALU_A_SB, `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte, c2, `T0 , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_SB, `SB_ALU, _aluop,   `ALU_A_SB, `ALU_B_ADL, _carry,   `none,   `FLAGS_CNZ,  1) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_ALU, `none,    `none,     `none,      `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0)

`define SHIFT_A(_insbyte, _aluop, _carry) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_A,  `SB_A,    `none,   `ALU_A_SB, `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_SB, `SB_ALU, _aluop,   `none,     `none,      _carry,   `LOAD_A, `FLAGS_CNZ,  0)

`define DEC_REG(_insbyte, _reg, _load) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_0,     _reg, `none,    `ALU_A_SB, `ALU_B_NDB, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_SB, `SB_ALU, `ALU_SUM, `none,     `none,      `ALU_C_0, _load,   `FLAGS_SBZN, 0)

`define INC_REG(_insbyte, _reg, _load) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_0,     _reg, `none,    `ALU_A_SB, `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_SB, `SB_ALU, `ALU_SUM, `none,     `none,      `ALU_C_1, _load,   `FLAGS_SBZN, 0)

`define DEC_MEM(_insbyte, c1, c2) \
`MICROCODE( _insbyte, c1, `Tn , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `ALU_A_SB, `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte, c2, `T0 , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_SB, `SB_ALU, `ALU_SUM, `ALU_A_SB, `ALU_B_ADL, `ALU_C_0, `none,   `FLAGS_SBZN, 1) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,     `none,      `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0)

`define INC_MEM(_insbyte, c1, c2) \
`MICROCODE( _insbyte, c1, `Tn , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_DI, `SB_DB,  `none,    `ALU_A_0,  `ALU_B_DB,  `none,    `none,   `none,       0) \
`MICROCODE( _insbyte, c2, `T0 , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_SB, `SB_ALU, `ALU_SUM, `ALU_A_SB, `ALU_B_ADL, `ALU_C_1, `none,   `FLAGS_SBZN, 1) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,     `none,      `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0)

`define PUSH(_insbyte, _db, _sb) \
`MICROCODE( _insbyte,  2, `T0 , `ADH_1,    `ADL_S,     1,  1, `PCHPCL,  0,  _db,    _sb,    `none,    `none,     `none,      `none,    `none,   `none,       1) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_0,  `SB_S,   `none,    `ALU_A_SB, `ALU_B_NDB, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_ALU, `ALU_SUM, `none,     `none,      `ALU_C_0, `LOAD_S, `none,       0)

`define PULL(_insbyte, _load, _flags) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_1,    `ADL_S,     1,  1, `PCHPCL,  0, `DB_0,  `SB_FF,  `none,    `ALU_A_0,  `ALU_B_ADL, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `T0 , `ADH_1,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_0,  `SB_ALU, `ALU_SUM, `none,     `none,      `ALU_C_1, `LOAD_S, `none,       0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_DB,  `none,    `none,     `none,      `none,    _load,   _flags,      0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0)

`define JSR(_insbyte) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_1,    `ADL_S,     1,  1, `PCHPCL,  1, `DB_PCH,`SB_DB,  `none,    `ALU_A_0,  `ALU_B_ADL, `none,    `LOAD_S, `none,       0) \
`MICROCODE( _insbyte,  3, `Tn , `ADH_1,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_PCH,`SB_FF,  `ALU_SUM, `ALU_A_SB, `none,      `none,    `none,   `none,       1) \
`MICROCODE( _insbyte,  4, `Tn , `ADH_1,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_PCL,`SB_FF,  `ALU_SUM, `ALU_A_SB, `ALU_B_ADL, `ALU_C_0, `none,   `none,       1) \
`MICROCODE( _insbyte,  5, `T0 , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_ALU, `ALU_SUM, `ALU_A_SB, `ALU_B_DB,  `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_DI,   `ADL_S,     1,  1, `ADHADL,  0, `DB_DI, `SB_ALU, `ALU_PSA, `none,     `none,      `ALU_C_0, `LOAD_S, `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0)

`define RTI(_insbyte) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_1,    `ADL_S,     1,  1, `PCHPCL,  1, `DB_DI, `SB_DB,  `none,    `ALU_A_0,  `ALU_B_ADL, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `Tn , `ADH_1,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `ALU_A_0,  `ALU_B_ADL, `ALU_C_1, `none,   `none,       0) \
`MICROCODE( _insbyte,  4, `Tn , `ADH_1,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `ALU_A_0,  `ALU_B_ADL, `ALU_C_1, `none,   `FLAGS_DB,   0) \
`MICROCODE( _insbyte,  5, `T0 , `ADH_1,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_DI, `SB_ALU, `ALU_SUM, `ALU_A_0,  `ALU_B_DB,  `ALU_C_1, `LOAD_S, `none,       0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_DI,   `ADL_ALU,   1,  1, `ADHADL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `none,     `none,      `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0)

`define JMP(_insbyte, t0) \
`MICROCODE( _insbyte, t0, `T0 , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `ALU_A_0,  `ALU_B_DB,  `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_DI,   `ADL_ALU,   1,  1, `ADHADL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `none,     `none,      `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0)

`define RTS(_insbyte) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_1,    `ADL_S,     1,  1, `PCHPCL,  1, `DB_DI, `SB_DB,  `none,    `ALU_A_0,  `ALU_B_ADL, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `Tn , `ADH_1,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `ALU_A_0,  `ALU_B_ADL, `ALU_C_1, `none,   `none,       0) \
`MICROCODE( _insbyte,  4, `Tn , `ADH_1,    `ADL_ALU,   1,  1, `PCHPCL,  0, `DB_DI, `SB_ALU, `ALU_SUM, `ALU_A_0,  `ALU_B_DB,  `ALU_C_1, `LOAD_S, `none,       0) \
`MICROCODE( _insbyte,  5, `T0 , `ADH_DI,   `ADL_ALU,   1,  1, `ADHADL,  0, `DB_DI, `SB_FF,  `ALU_SUM, `none,     `none,      `ALU_C_0, `none,   `none,       0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,     `none,      `none,    `none,   `none,       0)

`define TRB(_insbyte, c1, c2) \
`MICROCODE( _insbyte, c1, `Tn , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_DI, `SB_A,   `none,    `ALU_A_NSB, `ALU_B_DB, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte, c2, `T0 , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_SB, `SB_ALU, `ALU_AND, `none,      `none,     `none,    `none,   `none,       1) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_A,   `none,    `ALU_A_SB,  `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_ALU, `ALU_AND, `none,      `none,     `none,    `none,   `FLAGS_Z,    0)

`define TSB(_insbyte, c1, c2) \
`MICROCODE( _insbyte, c1, `Tn , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_DI, `SB_A,   `none,    `ALU_A_SB,  `ALU_B_DB, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte, c2, `T0 , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_SB, `SB_ALU, `ALU_ORA, `none,      `none,     `none,    `none,   `none,       1) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_A,   `none,    `ALU_A_SB,  `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_ALU, `ALU_AND, `none,      `none,     `none,    `none,   `FLAGS_Z,    0)

`define RMB(_insbyte, c1, c2) \
`MICROCODE( _insbyte, c1, `Tn , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `ALU_A_NIR, `ALU_B_DB, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte, c2, `T0 , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_SB, `SB_ALU, `ALU_AND, `none,      `none,     `none,    `none,   `none,       1) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0)

`define SMB(_insbyte, c1, c2) \
`MICROCODE( _insbyte, c1, `Tn , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `ALU_A_IR,  `ALU_B_DB, `none,    `none,   `none,       0) \
`MICROCODE( _insbyte, c2, `T0 , `ADH_PCHS, `ADL_PCLS,  0,  0, `PCHPCL,  0, `DB_SB, `SB_ALU, `ALU_ORA, `none,      `none,     `none,    `none,   `none,       1) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0)

`define NOP1_1(_insbyte) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0)

`define NOP1_2(_insbyte) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0)

`define NOP2_2(_insbyte) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0)

`define NOP2_3(_insbyte) \
`MICROCODE( _insbyte,  2, `T0 , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0)

`define NOP2_4(_insbyte) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `T0 , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0)

`define NOP3_4(_insbyte) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `T0 , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0)

`define NOP3_8(_insbyte) \
`MICROCODE( _insbyte,  2, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  3, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  4, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  5, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  6, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  7, `T0 , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  0, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  0, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0) \
`MICROCODE( _insbyte,  1, `Tn , `ADH_PCHS, `ADL_PCLS,  1,  1, `PCHPCL,  1, `DB_DI, `SB_FF,  `none,    `none,      `none,     `none,    `none,   `none,       0)

`define ORA(_insbyte,_inc) `ALUA(_insbyte, `ALU_ORA, `ALU_B_DB,  `SB_A, `ALU_C_0, `LOAD_A, `FLAGS_SBZN, _inc)
`define AND(_insbyte,_inc) `ALUA(_insbyte, `ALU_AND, `ALU_B_DB,  `SB_A, `ALU_C_0, `LOAD_A, `FLAGS_SBZN, _inc)
`define EOR(_insbyte,_inc) `ALUA(_insbyte, `ALU_EOR, `ALU_B_DB,  `SB_A, `ALU_C_0, `LOAD_A, `FLAGS_SBZN, _inc)
`define ADC(_insbyte,_inc) `ALUA(_insbyte, `ALU_ADC, `ALU_B_DB,  `SB_A, `ALU_C_P, `LOAD_A, `FLAGS_ALU,  _inc)
`define SBC(_insbyte,_inc) `ALUA(_insbyte, `ALU_SBC, `ALU_B_NDB, `SB_A, `ALU_C_P, `LOAD_A, `FLAGS_ALU,  _inc)
`define CMP(_insbyte,_inc) `ALUA(_insbyte, `ALU_SUM, `ALU_B_NDB, `SB_A, `ALU_C_1, `none,   `FLAGS_CNZ,  _inc)
`define CPX(_insbyte,_inc) `ALUA(_insbyte, `ALU_SUM, `ALU_B_NDB, `SB_X, `ALU_C_1, `none,   `FLAGS_CNZ,  _inc)
`define CPY(_insbyte,_inc) `ALUA(_insbyte, `ALU_SUM, `ALU_B_NDB, `SB_Y, `ALU_C_1, `none,   `FLAGS_CNZ,  _inc)

`define ASL_MEM(_insbyte, c1, c2) `SHIFT_MEM(_insbyte, c1, c2, `ALU_SUM, `ALU_C_0)
`define ROL_MEM(_insbyte, c1, c2) `SHIFT_MEM(_insbyte, c1, c2, `ALU_SUM, `ALU_C_P)
`define LSR_MEM(_insbyte, c1, c2) `SHIFT_MEM(_insbyte, c1, c2, `ALU_ROR, `ALU_C_0)
`define ROR_MEM(_insbyte, c1, c2) `SHIFT_MEM(_insbyte, c1, c2, `ALU_ROR, `ALU_C_P)

`define ASL_A(_insbyte) `SHIFT_A(_insbyte, `ALU_SUM, `ALU_C_0)
`define ROL_A(_insbyte) `SHIFT_A(_insbyte, `ALU_SUM, `ALU_C_P)
`define LSR_A(_insbyte) `SHIFT_A(_insbyte, `ALU_ROR, `ALU_C_0)
`define ROR_A(_insbyte) `SHIFT_A(_insbyte, `ALU_ROR, `ALU_C_P)

`endif

`endif //_6502_inc_vh_
