`include "6502_inc.vh"

`SCHEM_KEEP_HIER module adl_pcl_reg(clk, ready, pcls_sel, pc_inc, adl_sel, reg_s, alu, pcl, pcls, pcl_carry);
input clk;
input ready;
input pcls_sel;
input pc_inc;
input [2:0] adl_sel;
input [7:0] reg_s;
input [7:0] alu;

output [7:0] pcl;
output [7:0] pcls;
output pcl_carry;

reg [7:0] adl_pcls;

reg [8:0] pcls_in;
reg [7:0] pcls;
reg [7:0] pcl;

reg pcl_carry;

always @(*)
begin
  if(pcls_sel == `PCLS_PCL)
    pcls_in = pcl + pc_inc;
  else
    pcls_in = adl_pcls;
  {pcl_carry, pcls} = pcls_in;
end

always @(*)
begin
  case(adl_sel) // synthesis full_case parallel_case
    `ADL_S     : adl_pcls = reg_s;
    `ADL_ALU   : adl_pcls = alu;
  endcase
end

always @(posedge clk)
begin
  if(ready)
  begin
    pcl <= pcls;
  end
end

endmodule


`SCHEM_KEEP_HIER module adh_pch_reg(clk, ready, pchs_sel, pcl_carry, adh_sel, data_i, alu, pchs, pch, pch_carry);
input clk;
input ready;
input pchs_sel;
input pcl_carry;
input [2:0] adh_sel;
input [7:0] data_i;
input [7:0] alu;
output [7:0] pchs;
output [7:0] pch;
output reg pch_carry;
reg [7:0] pchs;

reg [8:0] pchs_in;
reg [7:0] pch;

reg [7:0] adh_pchs;

always @(*)
begin
  if(pchs_sel == `PCHS_PCH)
    pchs_in = pch + pcl_carry;
  else
    pchs_in = adh_pchs;
  {pch_carry,pchs} = pchs_in; // This is really weird.  If I don't try to keep the carry like for PCL, it actually uses *more* resources?
  //$display("phs_sel: %d pch: %02x adh: %02x pchs_in: %02x pchs: %02x",pchs_sel,pch,adh,pchs_in,pchs);
end

always @(*)
begin
  case(adh_sel)  // synthesis full_case parallel_case
    `ADH_DI  : adh_pchs = data_i;
    `ADH_ALU : adh_pchs = alu;
  endcase
end

always @(posedge clk)
begin
  if(ready)
  begin
    pch <= pchs;
  end
end

endmodule

`SCHEM_KEEP_HIER module adh_abh_reg(clk, load_abh, adh_sel, data_i, pchs, alu, abh);
input clk;
input load_abh;
input [2:0] adh_sel;
input [7:0] data_i;
input [7:0] pchs;
input [7:0] alu;
output reg [7:0] abh;

reg [7:0] adh_abh;

always @(*)
begin
  case(adh_sel)  // synthesis full_case parallel_case
    `ADH_DI  : adh_abh = data_i;
    `ADH_PCHS: adh_abh = pchs;
    `ADH_ALU : adh_abh = alu;
    `ADH_0   : adh_abh = 8'h00;
    `ADH_1   : adh_abh = 8'h01;
    `ADH_FF  : adh_abh = 8'hFF;
  endcase
end

always @(posedge clk)
begin
  if(load_abh)
  begin
    abh <= adh_abh;
  end
end

endmodule

`SCHEM_KEEP_HIER module adl_abl_reg(clk, load_abl, adl_sel, data_i, pcls, reg_s, alu, vector_lo, adl_abl, abl);
input clk;
input load_abl;
input [2:0] adl_sel;
input [7:0] data_i;
input [7:0] pcls;
input [7:0] reg_s;
input [7:0] alu;
input [7:0] vector_lo;

output [7:0] adl_abl;
output [7:0] abl;
reg [7:0] adl_abl;
reg [7:0] abl;

// ADL -> ABL
always @(*)
begin
  case(adl_sel) // synthesis full_case parallel_case
    `ADL_DI    : adl_abl = data_i;
    `ADL_PCLS  : adl_abl = pcls;
    `ADL_S     : adl_abl = reg_s;
    `ADL_ALU   : adl_abl = alu;
    `ADL_VECLO : adl_abl = vector_lo;
    `ADL_VECHI : adl_abl = { vector_lo[7:1],1'b1 };
  endcase
end

always @(posedge clk)
begin
  if(load_abl)
  begin
    abl <= adl_abl;
  end
end

endmodule

// This is the "secondary bus"
`SCHEM_KEEP_HIER module sb_mux(sb_sel, reg_a, reg_x, reg_y, reg_s, alu, pch, db, sb);
input [2:0] sb_sel;
input [7:0] reg_a;
input [7:0] reg_x;
input [7:0] reg_y;
input [7:0] reg_s;
input [7:0] alu;
input [7:0] pch;
input [7:0] db;
output [7:0] sb;
reg [7:0] sb;

always @(*)
begin
  case(sb_sel)  // synthesis full_case parallel_case
    `SB_A   : sb = reg_a;
    `SB_X   : sb = reg_x;
    `SB_Y   : sb = reg_y;
    `SB_S   : sb = reg_s;
    `SB_ALU : sb = alu;
    `SB_ADH : sb = pch;  // Any time SB is sourcing from ADH, it is always to get PCH
    `SB_DB  : sb = db;
    `SB_FF  : sb = 8'hFF;
  endcase
end

endmodule

`SCHEM_KEEP_HIER module alua_mux(input clk,
                                 input ready,
                                 input [1:0] alu_a, 
                                 input [7:0] sb, 
                                 input [7:0] ir_dec, 
                                 output [7:0] alua);
                                 
reg [7:0] aluas;
                             
reg [7:0] alua;
                                 
// ALU A input select
always @(*)
begin
  case(alu_a)  // synthesis full_case parallel_case
    `ALU_A_0  : aluas = 8'h00;
    `ALU_A_SB : aluas = sb;
`ifdef CMOS
    `ALU_A_IR : aluas = ir_dec;
`endif
  endcase
end

always @(posedge clk)
begin
  if(ready)
  begin
    alua <= aluas;
  end
end

endmodule

`SCHEM_KEEP_HIER module alub_mux(input clk,
                                 input ready,
                                 input [1:0] alu_b, 
                                 input [7:0] db, 
                                 input [7:0] adl, 
                                 output [7:0] alub);

reg [7:0] alubs;

reg [7:0] alub;

// ALU B input select
always @(*)
begin
  case(alu_b)  // synthesis full_case parallel_case
    `ALU_B_DB  : alubs = db;
    `ALU_B_NDB : alubs = ~db;
    `ALU_B_ADL : alubs = adl;
  endcase
end

always @(posedge clk)
begin
  if(ready)
  begin
    alub <= alubs;
  end
end

endmodule


`SCHEM_KEEP_HIER module aluc_mux(input [1:0] alu_c, 
                                 input carry,
                                 input last_carry,
                                 output reg carrys);

// ALU C (carry) input select
always @(*)
begin
  case(alu_c)  // synthesis full_case parallel_case
    `ALU_C_0 : carrys = 0;
    `ALU_C_1 : carrys = 1;
    `ALU_C_P : carrys = carry;
    `ALU_C_A : carrys = last_carry;
  endcase
end

endmodule

`SCHEM_KEEP_HIER module db_in_mux(input [2:0] db_sel, 
                                 input [7:0] data_i,
                                 input [7:0] reg_a,
                                 input alua_highbit,
                                 output reg [7:0] db_in);

// DB input mux
always @(*)
begin
  case(db_sel)  // synthesis full_case parallel_case
    `DB_0   : db_in = 8'h00;
    `DB_DI  : db_in = data_i;
    `DB_A   : db_in = reg_a;
    `DB_BO  : db_in = {8{alua_highbit}};   // The high bit of the last ALU A input is the sign bit for branch offsets
  endcase
end

endmodule

`SCHEM_KEEP_HIER module db_out_mux(input [2:0] db_sel, 
                                   input [7:0] reg_a,
                                   input [7:0] sb,
                                   input [7:0] pcl,
                                   input [7:0] pch,
                                   input [7:0] reg_p,
                                   output reg [7:0] db_out);

// DB output mux
always @(*)
begin
  case(db_sel)  // synthesis full_case parallel_case
    `DB_A   : db_out = reg_a;
    `DB_SB  : db_out = sb;
    `DB_PCL : db_out = pcl;
    `DB_PCH : db_out = pch;
    `DB_P   : db_out = reg_p;
    `DB_0   : db_out = 8'h00;
  endcase
end

endmodule


`SCHEM_KEEP_HIER module ir_next_mux(input sync, 
                                    input intg,
                                    input [7:0] data_i,
                                    input [7:0] ir,
                                    output reg [7:0] ir_next);

// IR input
always @(*)
begin
  if(sync)
  begin
    if(intg)
      ir_next = 8'h00;
    else
      ir_next = data_i;
  end
  else
    ir_next = ir;
end

endmodule

// Note: LM_C_DB0, LM_Z_DB1, LM_I_DB2 and LM_D_DB3 are currently always set together and are thus redundant,
// so if we ever went back to predecoded flags we could save 3 bits there.
`SCHEM_KEEP_HIER module flags_decode(input [3:0] load_flags, output reg [14:0] load_flags_decode);
always @(*)
case (load_flags)   // synthesis full_case parallel_case
  `none       : load_flags_decode = 0;
  `FLAGS_DB   : load_flags_decode = (`LM_C_DB0 | `LM_Z_DB1 | `LM_I_DB2 | `LM_D_DB3 | `LM_V_DB6 | `LM_N_DB7);
  `FLAGS_SBZN : load_flags_decode = (`LM_Z_SBZ | `LM_N_SBN);
  `FLAGS_D    : load_flags_decode = (`LM_D_IR5);
  `FLAGS_I    : load_flags_decode = (`LM_I_IR5);
  `FLAGS_C    : load_flags_decode = (`LM_C_IR5);
  `FLAGS_V    : load_flags_decode = (`LM_V_0);
  `FLAGS_Z    : load_flags_decode = (`LM_Z_SBZ);
  `FLAGS_CNZ  : load_flags_decode = (`LM_C_ACR | `LM_Z_SBZ | `LM_N_SBN);
  `FLAGS_ALU  : load_flags_decode = (`LM_C_ACR | `LM_V_AVR | `LM_Z_SBZ | `LM_N_SBN);
  `FLAGS_BIT  : load_flags_decode = (`LM_V_DB6 | `LM_N_DB7);
  `ifdef CMOS
  `FLAGS_SETI : load_flags_decode = (`LM_I_1|`LM_D_IR5);     // Clear D flag too
  `else
  `FLAGS_SETI : load_flags_decode = (`LM_I_1);
  `endif
endcase

endmodule
