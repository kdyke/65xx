`include "6502_inc.vh"

module microcode(clk, ir, t, tnext, adh_sel, adl_sel, db_sel, sb_sel, pchs_sel, pcls_sel, alu_op, alu_a, alu_b, alu_c,
                  load_a, load_x, load_y, load_sp, load_p, load_abh, load_abl, load_pch, load_pcl, load_flags, write_cycle, pc_inc);

input clk;
input [7:0] ir;
input [2:0] t;
output [3:0] tnext;
output [2:0] adh_sel;
output [2:0] adl_sel;
output [2:0] db_sel;
output [2:0] sb_sel;
output [3:0] alu_op;
output pchs_sel;
output pcls_sel;
output alu_a;
output [1:0] alu_b;
output [1:0] alu_c;
output load_a;
output load_x;
output load_y;

output load_sp;
output load_p;
output load_ir;

output load_abh;
output load_abl;
output load_pch;
output load_pcl;

output [3:0] load_flags;
output write_cycle;
output pc_inc;

reg [60:0] mc_out;

reg [60:0] mc[0:2047];

reg [12:0] i;

initial begin

`define TNEXT_BITS      59:56
`define ADH_BITS        55:53
`define ADL_BITS        52:50
`define DB_BITS         49:47
`define SB_BITS         46:44
`define ALU_BITS        43:40
`define ALU_A_BITS      39:39
`define ALU_B_BITS      38:37
`define ALU_C_BITS      36:35
`define LOAD_A_BITS     34:34
`define LOAD_X_BITS     33:33
`define LOAD_Y_BITS     32:32
`define LOAD_DL_BITS    31:31       // Obsolete
`define LOAD_SP_BITS    30:30
`define LOAD_ABH_BITS   29:29
`define LOAD_ABL_BITS   28:28
`define LOAD_FLAGS_BITS 24:21
`define WRITE_BITS      20:20
`define PC_INC_BITS     19:19
`define PCHS_BITS       18:18
`define PCLS_BITS       17:17

`define FIELD_SHIFT(_x) (0?_x)
`define _X(_x)  (`_x)

// Init all microcode slots we haven't implemented with a state that halts
for( i = 0; i < 2048; i++ ) 
begin
   mc[i][`TNEXT_BITS] = `TKL;
   //$display("init %d",i);
end

`define MICROCODE(_ins, _t, _tnext, _adh_sel, _adl_sel, _db_sel, _sb_sel, _pchs_sel, _pcls_sel, _alu_sel, _alu_a, _alu_b, _alu_c, _load_a, _load_x, _load_y, _load_sp, _load_abh, _load_abl, _load_flags, _write, _pc_inc) \
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
  (_load_a << `FIELD_SHIFT(`LOAD_A_BITS)) | \
  (_load_x << `FIELD_SHIFT(`LOAD_X_BITS)) | \
  (_load_y << `FIELD_SHIFT(`LOAD_Y_BITS)) | \
  (_load_sp << `FIELD_SHIFT(`LOAD_SP_BITS)) | \
  (_load_abh << `FIELD_SHIFT(`LOAD_ABH_BITS)) | \
  (_load_abl << `FIELD_SHIFT(`LOAD_ABL_BITS)) | \
  (_load_flags << `FIELD_SHIFT(`LOAD_FLAGS_BITS)) | \
  (_write << `FIELD_SHIFT(`WRITE_BITS)) | \
  (_pc_inc << `FIELD_SHIFT(`PC_INC_BITS)) \
  );

// TODO - See how many ADH/ADL combinations are really needed in practice, which might save a few bits.
// 
// Some quick examples:
// ADH_PCHS / ADL_PCLS      the most common
// ADH_1 / ADL_S
// ADH_1 / ADL_ALU          these could be combined by using ABH to hold the 1
// ADH_FF / ADL_VECLO
// ADH_FF / ADL_VECHI       this could probably be eliminated since it's just or'ing in a bit from the prior one
// ADH_PCHS / ADL_ALU       used for branching (and rmw)
// ADH_0 / ADL_DI
// ADH_0 / ADL_ALU
// ADH_DI / ADL_ALU
// ADH_SB / ADL_PCLS
//
// Assuming ADH_1/ADL_ALU and ADH_FF/ADL_VECHI could be eliminated, that'd leave 8 combinations.

// Set up some generic macros for the major instruction groupings so each instruction doesn't have to be
// fully spelled out, which makes making any kind of sweeping changes take that much longer.

//                                                                                                                                      Register Loads
//            INS   T    Tn    Adh       Adl        Db,       Sb,     PCHs       PCLs        Alu_op      Alu_a      Alu_b     Alu_c    A   X   Y  SP  AH  AL         Flags W INC
// BRK
`MICROCODE(  8'h00,  2, `Tn , `ADH_1,   `ADL_S,    `DB_DI,  `SB_FF,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h00,  3, `Tn , `ADH_1,   `ADL_ALU,  `DB_PCH, `SB_FF,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,`ALU_A_SB,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h00,  4, `Tn , `ADH_1,   `ADL_ALU,  `DB_PCL, `SB_FF,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,`ALU_A_SB,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h00,  5, `Tn , `ADH_FF,  `ADL_VECLO,`DB_P,   `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  1,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h00,  6, `T0 , `ADH_FF,  `ADL_VECHI,`DB_DI,  `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1, `FLAGS_SETI, 0, 0)
`MICROCODE(  8'h00,  0, `Tn , `ADH_DI,  `ADL_ALU,  `DB_DI,  `SB_A,   `PCHS_ADH, `PCLS_ADL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h00,  1, `Tn , `ADH_PCHS,`ADL_PCLS, `DB_DI,  `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// ORA (zp,x)
`MICROCODE(  8'h01,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h01,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h01,  4, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h01,  5, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h01,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h01,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ORA,    `none,     `none, `ALU_C_0,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// ORA zp
`MICROCODE(  8'h05,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h05,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h05,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ORA,    `none,     `none, `ALU_C_0,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// ORA abs
`MICROCODE(  8'h0D,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h0D,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h0D,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h0D,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ORA,    `none,     `none, `ALU_C_0,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// ORA (zp),y
`MICROCODE(  8'h11,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h11,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_SB,`ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h11,  4, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h11,  5, `T0 , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h11,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h11,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ORA,    `none,     `none, `ALU_C_0,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// ORA zp,x
`MICROCODE(  8'h15,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h15,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h15,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h15,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ORA,    `none,     `none, `ALU_C_0,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// ORA abs,y
`MICROCODE(  8'h19,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h19,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h19,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h19,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h19,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ORA,    `none,     `none, `ALU_C_0,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// ORA abs,x
`MICROCODE(  8'h1D,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h1D,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h1D,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h1D,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h1D,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ORA,    `none,     `none, `ALU_C_0,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// ASL zp
`MICROCODE(  8'h06,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h06,  3, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h06,  4, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h06,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h06,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// PHP
`MICROCODE(  8'h08,  2, `T0 , `ADH_1,    `ADL_S,    `DB_FF, `SB_FF,  `PCHS_PCH, `PCLS_PCL,     `none, `ALU_A_SB,`ALU_B_ADL,   `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h08,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_P,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  1,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h08,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,    `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// ORA #
`MICROCODE(  8'h09,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,`ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h09,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ORA,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// ASL a
`MICROCODE(  8'h0A,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_A,  `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,`ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h0A,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  1,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// ASL abs
`MICROCODE(  8'h0E,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI,  `SB_A,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h0E,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI,  `SB_A,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h0E,  4, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI,  `SB_DB, `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h0E,  5, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB,  `SB_ALU,`PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h0E,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB,  `SB_ALU,`PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h0E,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI,  `SB_ALU,`PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// BPL
`MICROCODE(  8'h10,  2, `TBR, `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h10,  3, `TBE, `ADH_PCHS, `ADL_ALU,  `DB_BO, `SB_ADH, `PCHS_PCH, `PCLS_ADL,  `ALU_SUM,`ALU_A_SB, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h10,  0, `Tn , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_ADH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h10,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// ASL zp,x
`MICROCODE(  8'h16,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h16,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h16,  4, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h16,  5, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h16,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h16,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// CLC
`MICROCODE(  8'h18,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,    `FLAGS_C, 0, 0)
`MICROCODE(  8'h18,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// ASL abs,x
`MICROCODE(  8'h1E,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h1E,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h1E,  4, `Tn , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h1E,  5, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h1E,  6, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h1E,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h1E,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// JSR - 0x20
// Cycle 2 -- Reading low byte of branch address into SP, loading ALU B input register from ALU, ADL also loading from SP, increment PC by one
// Cycle 3 -- SP contains low byte of branch address, ALU A input loading FF from SB, ALU B input register holds last value
// Cycle 4 -- Writing low byte of PC, ALU summing 0xFF + SP for next cycle -> ADL, ALU B input loads from ADL (adder result)
// Cycle 5 -- Writing high byte of current PC, ALU A loads from ALU output, ALU B input loads zero
// Cycle 0 -- Reading high byte of next PC, feeds directly to ADH, ADL loads from stack, SB reads from ALU, which reloads SP, PC also loads from ADH/ADL
// Cycle 1 -- Fetching next instruction - whew!
`MICROCODE(  8'h20,  2, `Tn , `ADH_1,    `ADL_S,    `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,     `none, `ALU_A_0,`ALU_B_ADL,    `none,  0,  0,  0,  1,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h20,  3, `Tn , `ADH_1,    `ADL_ALU,  `DB_PCH,`SB_FF,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,`ALU_A_SB,    `none,     `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h20,  4, `Tn , `ADH_1,    `ADL_ALU,  `DB_PCH,`SB_FF,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,`ALU_A_SB,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h20,  5, `T0 , `ADH_PCHS, `ADL_PCLS, `DB_PCL,`SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,`ALU_A_SB,`ALU_B_DB,  `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h20,  0, `Tn , `ADH_DI,   `ADL_S,    `DB_DI, `SB_ALU, `PCHS_ADH, `PCLS_ADL,  `ALU_PSA,    `none,     `none, `ALU_C_0,  0,  0,  0,  1,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h20,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// AND (zp,x)
`MICROCODE(  8'h21,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h21,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h21,  4, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h21,  5, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h21,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h21,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_AND,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// BIT zp
`MICROCODE(  8'h24,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h24,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,  `FLAGS_BIT, 0, 0)
`MICROCODE(  8'h24,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_AND,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,    `FLAGS_Z, 0, 1)

// AND zp
`MICROCODE(  8'h25,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h25,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h25,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_AND,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// ROL zp
`MICROCODE(  8'h26,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h26,  3, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h26,  4, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_P,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h26,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h26,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// PLP
`MICROCODE(  8'h28,  2, `Tn , `ADH_1,    `ADL_S,    `DB_FF, `SB_FF,  `PCHS_PCH, `PCLS_PCL,     `none, `ALU_A_0,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h28,  3, `T0 , `ADH_1,    `ADL_ALU,  `DB_FF, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  1,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h28,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,     `none,    `none,     `none,    `none,  0,  0,  0,  0,  1,  1,   `FLAGS_DB, 0, 0)
`MICROCODE(  8'h28,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,    `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// AND #
`MICROCODE(  8'h29,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,`ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h29,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_AND,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// ROL a
`MICROCODE(  8'h2A,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_A,  `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,`ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h2A,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// BIT abs
`MICROCODE(  8'h2C,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h2C,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h2C,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,  `FLAGS_BIT, 0, 0)
`MICROCODE(  8'h2C,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_AND,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,    `FLAGS_Z, 0, 1)

// AND abs
`MICROCODE(  8'h2D,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h2D,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h2D,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h2D,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_AND,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// ROL abs
`MICROCODE(  8'h2E,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h2E,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h2E,  4, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h2E,  5, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_P,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h2E,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h2E,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// BMI
`MICROCODE(  8'h30,  2, `TBR, `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h30,  3, `TBE, `ADH_PCHS, `ADL_ALU,  `DB_BO, `SB_ADH, `PCHS_PCH, `PCLS_ADL,  `ALU_SUM,`ALU_A_SB, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h30,  0, `Tn , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_ADH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h30,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// AND (zp),y
`MICROCODE(  8'h31,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h31,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_SB,`ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h31,  4, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h31,  5, `T0 , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h31,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h31,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_AND,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// AND zp,x
`MICROCODE(  8'h35,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h35,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h35,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h35,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_AND,    `none,     `none, `ALU_C_0,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// ROL zp,x
`MICROCODE(  8'h36,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h36,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h36,  4, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h36,  5, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_P,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h36,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h36,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// SEC
`MICROCODE(  8'h38,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,    `FLAGS_C, 0, 0)
`MICROCODE(  8'h38,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// AND abs,y
`MICROCODE(  8'h39,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h39,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h39,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h39,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h39,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_AND,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// AND abs,x
`MICROCODE(  8'h3D,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h3D,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h3D,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h3D,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h3D,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_AND,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_DBZN, 0, 1)

// ROL abs,x
`MICROCODE(  8'h3E,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h3E,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h3E,  4, `Tn , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h3E,  5, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h3E,  6, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_P,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h3E,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h3E,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// RTI - 0x40
// Cycle 2 - Set up ADH/ADL for current stack read, set up ALU with SP
// Cycle 3 - Set up ADH/ADL for incremented SP
// Cycle 5 - Set up ADH/ADL for incremented SP, read processor status
// Cycle 5 - Set up ADH/ADL for incremented SP, read low byte of return address (minus 1) into ALUB, reload SP from SB ALU
// Cycle 6 - Read high byte of return address into ADH, read incremented return address from ALU into ADL, load PC from AD bus
// Cycle 0 - Dummy read, but increment PC
// Cycle 1 - Fetch
`MICROCODE(  8'h40,  2, `Tn , `ADH_1,    `ADL_S,    `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h40,  3, `Tn , `ADH_1,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h40,  4, `Tn , `ADH_1,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_1,  0,  0,  0,  0,  1,  1,   `FLAGS_DB, 0, 0)
`MICROCODE(  8'h40,  5, `T0 , `ADH_1,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_DB,  `ALU_C_1,  0,  0,  0,  1,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h40,  0, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_ADH, `PCLS_ADL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h40,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// EOR (zp,x)
`MICROCODE(  8'h41,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h41,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h41,  4, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h41,  5, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h41,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h41,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_EOR,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// EOR zp
`MICROCODE(  8'h45,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h45,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h45,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_EOR,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// LSR zp
`MICROCODE(  8'h46,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h46,  3, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h46,  4, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ROR, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h46,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h46,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// PHA
`MICROCODE(  8'h48,  2, `T0 , `ADH_1,    `ADL_S,    `DB_FF, `SB_FF,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_ADL,   `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h48,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  1,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h48,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// EOR #
`MICROCODE(  8'h49,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,`ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h49,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_EOR,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// LSR a
`MICROCODE(  8'h4A,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,`ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h4A,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ROR,    `none,     `none, `ALU_C_0,  1,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// JMP abs
`MICROCODE(  8'h4C,  2, `T0 , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h4C,  0, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_ADH, `PCLS_ADL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h4C,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// EOR abs
`MICROCODE(  8'h4D,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h4D,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h4D,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h4D,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_EOR,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// LSR abs
`MICROCODE(  8'h4E,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h4E,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h4E,  4, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h4E,  5, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ROR, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h4E,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h4E,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// BVC
`MICROCODE(  8'h50,  2, `TBR, `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h50,  3, `TBE, `ADH_PCHS, `ADL_ALU,  `DB_BO, `SB_ADH, `PCHS_PCH, `PCLS_ADL,  `ALU_SUM,`ALU_A_SB, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h50,  0, `Tn , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_ADH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h50,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// EOR (zp),y
`MICROCODE(  8'h51,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h51,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_SB,`ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h51,  4, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h51,  5, `T0 , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h51,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h51,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_EOR,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// EOR zp,x
`MICROCODE(  8'h55,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h55,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h55,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h55,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_EOR,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// LSR zp,x
`MICROCODE(  8'h56,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h56,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h56,  4, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h56,  5, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ROR, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h56,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h56,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// CLI
`MICROCODE(  8'h58,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,    `FLAGS_I, 0, 0)
`MICROCODE(  8'h58,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// EOR abs,y
`MICROCODE(  8'h59,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h59,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h59,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h59,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h59,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_EOR,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// EOR abs,x
`MICROCODE(  8'h5D,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h5D,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h5D,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h5D,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h5D,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_EOR,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// LSR abs,x
`MICROCODE(  8'h5E,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h5E,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h5E,  4, `Tn , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h5E,  5, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h5E,  6, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ROR, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h5E,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h5E,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// RTS
// Cycle 2 - Set up ADH/ADL for current stack read, set up ALU with SP
// Cycle 3 - Set up ADH/ADL for incremented SP
// Cycle 4 - Set up ADH/ADL for incremented SP, read low byte of return address (minus 1) into ALUB, reload SP from SB ALU
// Cycle 5 - Read high byte of return address into ADH, read incremented return address from ALU into ADL, load PC from AD bus
// Cycle 0 - Dummy read, but increment PC
// Cycle 1 - Fetch
`MICROCODE(  8'h60,  2, `Tn , `ADH_1,    `ADL_S,    `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,     `none, `ALU_A_0,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h60,  3, `Tn , `ADH_1,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h60,  4, `Tn , `ADH_1,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_DB,  `ALU_C_1,  0,  0,  0,  1,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h60,  5, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_ADH, `PCLS_ADL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h60,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h60,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// ADC (zp,x)
`MICROCODE(  8'h61,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h61,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h61,  4, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h61,  5, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h61,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h61,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ADC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// ADC zp
`MICROCODE(  8'h65,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h65,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h65,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ADC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// ROR zp
`MICROCODE(  8'h66,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h66,  3, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h66,  4, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ROR, `ALU_A_0,`ALU_B_ADL, `ALU_C_P,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h66,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h66,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// PLA
`MICROCODE(  8'h68,  2, `Tn , `ADH_1,    `ADL_S,    `DB_FF, `SB_FF,  `PCHS_PCH, `PCLS_PCL,     `none, `ALU_A_0,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h68,  3, `T0 , `ADH_1,    `ADL_ALU,  `DB_FF, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  1,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h68,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,     `none,    `none,     `none,    `none,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'h68,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,    `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// ADC #
`MICROCODE(  8'h69,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,`ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h69,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ADC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// ROR a
`MICROCODE(  8'h6A,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,`ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h6A,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ROR,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// JMP (abs)
`MICROCODE(  8'h6C,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h6C,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_ADH, `PCLS_ADL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h6C,  4, `T0 , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h6C,  0, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_ADH, `PCLS_ADL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h6C,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// ADC abs
`MICROCODE(  8'h6D,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h6D,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h6D,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h6D,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ADC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// ROR abs
`MICROCODE(  8'h6E,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h6E,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h6E,  4, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h6E,  5, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ROR, `ALU_A_0,`ALU_B_ADL, `ALU_C_P,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h6E,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h6E,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// BVS
`MICROCODE(  8'h70,  2, `TBR, `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h70,  3, `TBE, `ADH_PCHS, `ADL_ALU,  `DB_BO, `SB_ADH, `PCHS_PCH, `PCLS_ADL,  `ALU_SUM,`ALU_A_SB, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h70,  0, `Tn , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_ADH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h70,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// ADC (zp),y
`MICROCODE(  8'h71,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h71,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_SB,`ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h71,  4, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h71,  5, `T0 , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h71,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h71,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ADC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// ADC zp,x
`MICROCODE(  8'h75,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h75,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h75,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h75,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ADC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// ROR zp,x
`MICROCODE(  8'h76,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h76,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h76,  4, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h76,  5, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ROR, `ALU_A_0,`ALU_B_ADL, `ALU_C_P,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h76,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h76,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// SEI
`MICROCODE(  8'h78,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,    `FLAGS_I, 0, 0)
`MICROCODE(  8'h78,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// ADC abs,y
`MICROCODE(  8'h79,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h79,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h79,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h79,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h79,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ADC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// ADC abs,x
`MICROCODE(  8'h7D,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h7D,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h7D,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h7D,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h7D,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ADC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// ROR abs,x
`MICROCODE(  8'h7E,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h7E,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h7E,  4, `Tn , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h7E,  5, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'h7E,  6, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_ROR, `ALU_A_0,`ALU_B_ADL, `ALU_C_P,  0,  0,  0,  0,  0,  0,  `FLAGS_CNZ, 0, 0)
`MICROCODE(  8'h7E,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h7E,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// STA (zp,x)
`MICROCODE(  8'h81,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h81,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h81,  4, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h81,  5, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h81,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h81,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// STY zp
`MICROCODE(  8'h84,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h84,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_A,  `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h84,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// STA zp
`MICROCODE(  8'h85,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h85,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_A,  `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h85,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// STX zp
`MICROCODE(  8'h86,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h86,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h86,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// DEY
`MICROCODE(  8'h88,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_FF,  `SB_Y,  `PCHS_PCH, `PCLS_PCL, `none,   `ALU_A_SB,  `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h88,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  1,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// STY abs
`MICROCODE(  8'h8C,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h8C,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h8C,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h8C,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// STA abs
`MICROCODE(  8'h8D,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h8D,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h8D,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h8D,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// STX abs
`MICROCODE(  8'h8E,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h8E,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h8E,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h8E,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// TXA
`MICROCODE(  8'h8A,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'h8A,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// BCC
`MICROCODE(  8'h90,  2, `TBR, `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h90,  3, `TBE, `ADH_PCHS, `ADL_ALU,  `DB_BO, `SB_ADH, `PCHS_PCH, `PCLS_ADL,  `ALU_SUM,`ALU_A_SB, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h90,  0, `Tn , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_ADH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h90,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// STA (zp),y
`MICROCODE(  8'h91,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h91,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_SB,`ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h91,  4, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h91,  5, `T0 , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h91,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h91,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// STY zp,x
`MICROCODE(  8'h94,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h94,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h94,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h94,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// STA zp,x
`MICROCODE(  8'h95,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h95,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h95,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h95,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// STX zp,y
`MICROCODE(  8'h96,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h96,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h96,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h96,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// TYA
`MICROCODE(  8'h98,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'h98,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// STA abs,y
`MICROCODE(  8'h99,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h99,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h99,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h99,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_A,  `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  1,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h99,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// TXS
`MICROCODE(  8'h9A,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  1,  1,  1,       `none, 0, 0)
`MICROCODE(  8'h9A,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// STA abs,x
`MICROCODE(  8'h9D,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h9D,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'h9D,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'h9D,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_A,  `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  1,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'h9D,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDY #
`MICROCODE(  8'hA0,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  1,  0,  1,  1, `FLAGS_DBZN, 0, 1)
`MICROCODE(  8'hA0,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDA (zp,x)
`MICROCODE(  8'hA1,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hA1,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hA1,  4, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hA1,  5, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hA1,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hA1,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDX #
`MICROCODE(  8'hA2,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  1,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)
`MICROCODE(  8'hA2,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDY zp
`MICROCODE(  8'hA4,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hA4,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  1,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hA4,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDA zp
`MICROCODE(  8'hA5,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hA5,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hA5,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDX zp
`MICROCODE(  8'hA6,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hA6,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  1,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hA6,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// TAY
`MICROCODE(  8'hA8,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hA8,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  1,  0,  1,  1,       `none, 0, 1)

// LDA #
`MICROCODE(  8'hA9,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)
`MICROCODE(  8'hA9,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// TAX
`MICROCODE(  8'hAA,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  1,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hAA,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDY abs
`MICROCODE(  8'hAC,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hAC,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hAC,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  1,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hAC,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDA abs
`MICROCODE(  8'hAD,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hAD,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hAD,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hAD,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDX abs
`MICROCODE(  8'hAE,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hAE,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hAE,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  1,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hAE,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDA (zp),y
`MICROCODE(  8'hB1,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hB1,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_SB,`ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hB1,  4, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hB1,  5, `T0 , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hB1,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hB1,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// BCS
`MICROCODE(  8'hB0,  2, `TBR, `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hB0,  3, `TBE, `ADH_PCHS, `ADL_ALU,  `DB_BO, `SB_ADH, `PCHS_PCH, `PCLS_ADL,  `ALU_SUM,`ALU_A_SB, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hB0,  0, `Tn , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_ADH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hB0,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDY zp,x
`MICROCODE(  8'hB4,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hB4,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hB4,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  1,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hB4,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDA zp,x
`MICROCODE(  8'hB5,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hB5,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hB5,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hB5,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDX zp,y
`MICROCODE(  8'hB6,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hB6,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hB6,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  1,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hB6,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// CLV
`MICROCODE(  8'hB8,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,    `FLAGS_V, 0, 0)
`MICROCODE(  8'hB8,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDA abs,y
`MICROCODE(  8'hB9,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hB9,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hB9,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hB9,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hB9,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// TSX
`MICROCODE(  8'hBA,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_SP,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  1,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hBA,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDY abs,x
`MICROCODE(  8'hBC,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hBC,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hBC,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hBC,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  1,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hBC,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDA abs,x
`MICROCODE(  8'hBD,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hBD,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hBD,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hBD,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  1,  0,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hBD,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// LDX abs,y
`MICROCODE(  8'hBE,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hBE,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hBE,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hBE,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  1,  0,  0,  1,  1, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hBE,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// CPY #
`MICROCODE(  8'hC0,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,    `none, `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hC0,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// CMP (zp,x)
`MICROCODE(  8'hC1,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hC1,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hC1,  4, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hC1,  5, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hC1,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hC1,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// CPY zp
`MICROCODE(  8'hC4,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hC4,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hC4,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// CMP zp
`MICROCODE(  8'hC5,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hC5,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hC5,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// DEC zp
`MICROCODE(  8'hC6,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hC6,  3, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_FF,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'hC6,  4, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU ,`PCHS_PCH, `PCLS_PCL,  `ALU_SUM,`ALU_A_0, `ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  0,  0, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hC6,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU ,`PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'hC6,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU ,`PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// INY
`MICROCODE(  8'hC8,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_FF, `SB_Y,   `PCHS_PCH, `PCLS_PCL,     `none,`ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hC8,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU ,`PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  1,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// CMP #
`MICROCODE(  8'hC9,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,    `none, `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hC9,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// DEX
`MICROCODE(  8'hCA,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_FF, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,`ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hCA,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU ,`PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  1,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// CPY abs
`MICROCODE(  8'hCC,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hCC,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hCC,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hCC,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// CMP abs
`MICROCODE(  8'hCD,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hCD,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hCD,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hCD,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// DEC abs
`MICROCODE(  8'hCE,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hCE,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hCE,  4, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_FF,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'hCE,  5, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU ,`PCHS_PCH, `PCLS_PCL,  `ALU_SUM,`ALU_A_0, `ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  0,  0, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hCE,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU ,`PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'hCE,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU ,`PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// Branch handling
// During cycle 2 we make the decision about whether or not we branch while the data bus is loading the branch offset.  The PC is still incremented so that it would point at
// the instruction following the offset and that's byte is always read even in the taken branch case.
// If the branch is not taken then we force the following T state to 1 so that it's performing an instruction fetch.
// If the branch is taken then cycle T3 winds up being a dummy read.  However, during cycle 3 we change the ADL input
// (which configures we address ABL gets during the next cycle) to read from the ALU output, which we set up during cycle 2
// to add the offset from the bus to what was on ADL, which was sourcing from PCL.   During cycle 3 we are also calculating
// a potential updated PCH value in the ALU for use on the next cycle if there is to be a page crossing.  If there's no page
// crossing then we can go to T1.  Otherwise we need to go to T0 because we'll be redoing the fetch but with the corrected
// PCH value.
// BCS
`MICROCODE(  8'hD0,  2, `TBR, `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hD0,  3, `TBE, `ADH_PCHS, `ADL_ALU,  `DB_BO, `SB_ADH, `PCHS_PCH, `PCLS_ADL,  `ALU_SUM,`ALU_A_SB, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hD0,  0, `Tn , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_ADH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hD0,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// CMP (zp),y
`MICROCODE(  8'hD1,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hD1,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_SB,`ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hD1,  4, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hD1,  5, `T0 , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hD1,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hD1,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// CMP zp,x
`MICROCODE(  8'hD5,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hD5,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hD5,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hD5,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// DEC zp,x
`MICROCODE(  8'hD6,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hD6,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hD6,  4, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_FF,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'hD6,  5, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,`ALU_A_0, `ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  0,  0, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hD6,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'hD6,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// CLD
`MICROCODE(  8'hD8,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,    `FLAGS_D, 0, 0)
`MICROCODE(  8'hD8,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// CMP abs,y
`MICROCODE(  8'hD9,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hD9,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hD9,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hD9,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hD9,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// CMP abs,x
`MICROCODE(  8'hDD,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hDD,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hDD,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hDD,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hDD,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// DEC abs,x
`MICROCODE(  8'hDE,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hDE,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hDE,  4, `Tn , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hDE,  5, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_FF,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'hDE,  6, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,`ALU_A_0, `ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  0,  0, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hDE,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'hDE,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// CPX #
`MICROCODE(  8'hE0,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,    `none, `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hE0,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// SBC (zp,x)
`MICROCODE(  8'hE1,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hE1,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hE1,  4, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hE1,  5, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hE1,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hE1,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SBC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// CPX zp
`MICROCODE(  8'hE4,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hE4,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hE4,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// SBC zp
`MICROCODE(  8'hE5,  2, `T0 , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hE5,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hE5,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SBC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// INC zp
`MICROCODE(  8'hE6,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hE6,  3, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'hE6,  4, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_1,  0,  0,  0,  0,  0,  0, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hE6,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'hE6,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// INX
`MICROCODE(  8'hE8,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_FF, `SB_X,   `PCHS_PCH, `PCLS_PCL,     `none,`ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hE8,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  1,  0,  0,  1,  1, `FLAGS_DBZN, 0, 1)

// SBC #
`MICROCODE(  8'hE9,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,     `none,`ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hE9,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SBC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// NOP
`MICROCODE(  8'hEA,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hEA,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// CPX abs
`MICROCODE(  8'hEC,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hEC,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hEC,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hEC,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_1,  0,  0,  0,  0,  1,  1,  `FLAGS_CNZ, 0, 1)

// SBC abs
`MICROCODE(  8'hED,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hED,  3, `T0 , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hED,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_NDB,   `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hED,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SBC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// INC abs
`MICROCODE(  8'hEE,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hEE,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hEE,  4, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'hEE,  5, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_1,  0,  0,  0,  0,  0,  0, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hEE,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'hEE,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// BEQ
`MICROCODE(  8'hF0,  2, `TBR, `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_ADL,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hF0,  3, `TBE, `ADH_PCHS, `ADL_ALU,  `DB_BO, `SB_ADH, `PCHS_PCH, `PCLS_ADL,  `ALU_SUM,`ALU_A_SB, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hF0,  0, `Tn , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_ADH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hF0,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// SBC (zp),y
`MICROCODE(  8'hF1,  2, `Tn , `ADH_0,    `ADL_DI,   `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hF1,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_SB,`ALU_B_DB, `ALU_C_1,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hF1,  4, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0, `ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hF1,  5, `T0 , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hF1,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hF1,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SBC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// SBC zp,x
`MICROCODE(  8'hF5,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hF5,  3, `T0 , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hF5,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hF5,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SBC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// INC zp,x
`MICROCODE(  8'hF6,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB, `ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hF6,  3, `Tn , `ADH_0,    `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hF6,  4, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'hF6,  5, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_1,  0,  0,  0,  0,  0,  0, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hF6,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'hF6,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// SED
`MICROCODE(  8'hF8,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,    `FLAGS_D, 0, 0)
`MICROCODE(  8'hF8,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

// SBC abs,y
`MICROCODE(  8'hF9,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_Y,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hF9,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hF9,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hF9,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hF9,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SBC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// SBC abs,x
`MICROCODE(  8'hFD,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hFD,  3, `TNC, `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hFD,  4, `T0 , `ADH_SB,   `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hFD,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_A,   `PCHS_PCH, `PCLS_PCL,  `none,   `ALU_A_SB,`ALU_B_NDB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 0)
`MICROCODE(  8'hFD,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SBC,    `none,     `none, `ALU_C_P,  1,  0,  0,  0,  1,  1,  `FLAGS_ALU, 0, 1)

// INC abs,x
`MICROCODE(  8'hFE,  2, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_X,   `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_SB,`ALU_B_DB,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hFE,  3, `Tn , `ADH_DI,   `ADL_ALU,  `DB_DI, `SB_ADH, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,  `ALU_A_0,`ALU_B_DB, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 0, 1)
`MICROCODE(  8'hFE,  4, `Tn , `ADH_SB,   `ADL_PCLS, `DB_A,  `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none,`ALU_C_AC,  0,  0,  0,  0,  1,  0,       `none, 0, 0)
`MICROCODE(  8'hFE,  5, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_DB,  `PCHS_PCH, `PCLS_PCL,  `none,    `ALU_A_0, `ALU_B_DB,    `none,  0,  0,  0,  0,  0,  0,       `none, 0, 0)
`MICROCODE(  8'hFE,  6, `T0 , `ADH_PCHS, `ADL_ALU,  `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM, `ALU_A_0,`ALU_B_ADL, `ALU_C_1,  0,  0,  0,  0,  0,  0, `FLAGS_DBZN, 0, 0)
`MICROCODE(  8'hFE,  0, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_SB, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `ALU_SUM,    `none,     `none, `ALU_C_0,  0,  0,  0,  0,  1,  1,       `none, 1, 0)
`MICROCODE(  8'hFE,  1, `Tn , `ADH_PCHS, `ADL_PCLS, `DB_DI, `SB_ALU, `PCHS_PCH, `PCLS_PCL,  `none,       `none,     `none,    `none,  0,  0,  0,  0,  1,  1,       `none, 0, 1)

end

// microcode outputs wired to specific bits
assign tnext = mc_out[`TNEXT_BITS];
assign adh_sel= mc_out[`ADH_BITS];
assign adl_sel= mc_out[`ADL_BITS];
assign db_sel = mc_out[`DB_BITS];
assign sb_sel = mc_out[`SB_BITS];
assign alu_a = mc_out[`ALU_A_BITS];
assign alu_b = mc_out[`ALU_B_BITS];
assign alu_op = mc_out[`ALU_BITS];
assign alu_c = mc_out[`ALU_C_BITS];
assign load_a = mc_out[`LOAD_A_BITS];
assign load_x = mc_out[`LOAD_X_BITS];
assign load_y = mc_out[`LOAD_Y_BITS];
assign load_sp = mc_out[`LOAD_SP_BITS];
assign load_abh = mc_out[`LOAD_ABH_BITS];
assign load_abl = mc_out[`LOAD_ABL_BITS];
assign load_flags = mc_out[`LOAD_FLAGS_BITS];
assign write_cycle = mc_out[`WRITE_BITS];
assign pc_inc = mc_out[`PC_INC_BITS];
assign pchs_sel = mc_out[`PCHS_BITS];
assign pcls_sel = mc_out[`PCLS_BITS];

always @(posedge clk)
begin
  mc_out <= mc[{ir, t}];
  //$display("mc[%02x|%d] tn: %04x",ir,t,mc[{ir, t}][`TNEXT_BITS]);
end

endmodule