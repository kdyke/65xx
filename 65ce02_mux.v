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

`undef MARK_DEBUG

//`define CPU65CE02_MUX_DEBUG
`ifdef CPU65CE02_MUX_DEBUG
`define MARK_DEBUG (* mark_debug = "true", dont_touch = "true" *)
`else
`define MARK_DEBUG
`endif

(* keep_hierarchy = "yes" *) module `dbi_mux(input clk, input ready, input [7:0] data_i, output reg [7:0] data_i_mux);

reg [7:0] data_i_reg;

always @(*)
begin
  if(ready)
    data_i_mux = data_i;
  else
    data_i_mux = data_i_reg;
end

always @(posedge clk)
begin
  data_i_reg = data_i_mux;
end
endmodule

// This is poorly named as a mux since there's also an output register in here now.
(* keep_hierarchy = "yes" *) module `dbo_mux(input clk, input ready, input [1:0] dbo_sel, input [7:0] data_i, input [7:0] dreg_bus, input [7:0] alu_out, input [7:0] pc_next,
                                output reg [7:0] data_o_next);

reg [7:0] data_o_reg;

always @(*)
begin
  data_o_next = data_o_reg;
  if(ready)
  begin
    case(dbo_sel)
      `kDBO_ALU   : data_o_next = alu_out;
      `kDBO_DREG  : data_o_next = dreg_bus;
      `kDBO_DI    : data_o_next = data_i;
      `kDBO_PCHn  : data_o_next = pc_next;
    endcase
  end
end

always @(posedge clk)
begin
  data_o_reg <= data_o_next;
end
    
endmodule

// This is poorly named as a mux since there's also an output register in here now.
(* keep_hierarchy = "yes" *) module `addrbus_mux(input clk, input ready, input [1:0] ab_sel, 
                                    input [15:0] ad, input [15:0] ab, input [15:0] sp, input [15:0] pc, 
                                    output reg [15:0] abus_next, output reg [15:0] abus);

reg [15:0] tmp;

always @(*)
begin
  case(ab_sel)
    `kAB_PCn  : tmp = pc;
    `kAB_ABn  : tmp = ab;
    `kAB_ADn  : tmp = ad;
    `kAB_SPn  : tmp = sp;
  endcase
end

always @(*)
begin
  if(ready)
    abus_next = tmp;
  else
    abus_next = abus;
end

always @(posedge clk)
begin
  begin
    abus <= abus_next;
  end
end

endmodule

(* keep_hierarchy = "yes" *) module `dreg_mux(input [1:0] dreg, input [7:0] reg_a, input [7:0] reg_x, input [7:0] reg_y, input [7:0] reg_z, output reg [7:0] dreg_bus);

always @(*)
begin
  case(dreg)
    `kDREG_A   : dreg_bus = reg_a;
    `kDREG_X   : dreg_bus = reg_x;
    `kDREG_Y   : dreg_bus = reg_y;
    `kDREG_Z   : dreg_bus = reg_z;
  endcase
  //$display("aluabus: %02x",aluabus);
end

endmodule

(* keep_hierarchy = "yes" *) module `areg_mux(input [1:0] areg, input [7:0] pch, input [7:0] sph, input [7:0] pcl, input [7:0] spl, output reg [7:0] areg_bus);

always @(*)
begin
  case(areg)
    `kAREG_PCH   : areg_bus = pch;
    `kAREG_SPH   : areg_bus = sph;
    `kAREG_PCL   : areg_bus = pcl;
    `kAREG_SPL   : areg_bus = spl;
  endcase
  //$display("aluabus: %02x",aluabus);
end

endmodule

(* keep_hierarchy = "yes" *) module `alua_mux(input [2:0] alua_sel, 
                                 input [7:0] areg_bus,
                                 input [7:0] dreg_bus,
                                 input [7:0] db,
                                 input [7:0] vector_lo,
                                 output reg [7:0] alua);
   
// ALU A input select
always @(*)
begin
  case(alua_sel)
    `kASEL_0      : alua = 8'h00;
    `kASEL_AREG   : alua = areg_bus;
    `kASEL_DREG   : alua = dreg_bus;
    `kASEL_VEC    : alua = vector_lo;
    `kASEL_FF     : alua = 8'hff;
    `kASEL_DB     : alua = db;
    `kASEL_NDREG  : alua = ~dreg_bus;
    `kASEL_NDB    : alua = ~db;
  endcase
  //$display("alua_sel: %d result: %02x reg: %02x nreg: %02x vec: %02x",alua_sel,alua,alua_reg,~alua_reg,vector_lo);
end

endmodule

(* keep_hierarchy = "yes" *) module `decoder3to8(index, inv, outbits);
input [2:0] index;
input inv;
output reg [7:0] outbits;

always @(*)
begin
  case({inv,index})
    0  : outbits = 8'b00000001;
    1  : outbits = 8'b00000010;
    2  : outbits = 8'b00000100;
    3  : outbits = 8'b00001000;
    4  : outbits = 8'b00010000;
    5  : outbits = 8'b00100000;
    6  : outbits = 8'b01000000;
    7  : outbits = 8'b10000000;
    8  : outbits = 8'b11111110;
    9  : outbits = 8'b11111101;
    10 : outbits = 8'b11111011;
    11 : outbits = 8'b11110111;
    12 : outbits = 8'b11101111;
    13 : outbits = 8'b11011111;
    14 : outbits = 8'b10111111;
    15 : outbits = 8'b01111111;
  endcase
end
endmodule

(* keep_hierarchy = "yes" *) module `alub_mux(input [2:0] alub_sel, 
                                 input [7:0] db, 
                                 input [7:0] dbd,
                                 input [7:0] reg_p,
                                 input [7:0] reg_b,
                                 input [2:0] bit_index, 
                                 input bit_inv,
                                 output reg [7:0] alub);

  wire [7:0] bit;

  `decoder3to8 dec3to8(bit_index, bit_inv, bit);
  
// ALU B input select
always @(*)
begin
  case(alub_sel)
    `kBSEL_0    : alub = 8'h00;
    `kBSEL_DB   : alub = db;
    `kBSEL_BIT  : alub = bit;
    `kBSEL_B    : alub = reg_b;
    `kBSEL_FF   : alub = 8'hFF;
    `kBSEL_NDB  : alub = ~db;
    `kBSEL_DBD  : alub = dbd;
    `kBSEL_P    : alub = reg_p;
  endcase
  //$display("alub: %02x sel = %d  bit: %d %02x",alub,alub_sel,bit_index,bit);
end

endmodule

(* keep_hierarchy = "yes" *) module `aluc_mux(input [1:0] aluc_sel, 
                                 input carry,
                                 input last_carry,
                                 output reg aluc);

// ALU C (carry) input select
always @(*)
begin
  case(aluc_sel)
    `kCSEL_0 : aluc = 0;
    `kCSEL_1 : aluc = 1;
    `kCSEL_P : aluc = carry;
    `kCSEL_D : aluc = last_carry;
  endcase
end

endmodule

(* keep_hierarchy = "yes" *) module `ir_next_mux(input sync, 
                                    input intg,
                                    input [7:0] data_i,
                                    `MARK_DEBUG input [7:0] ir,
                                    `MARK_DEBUG output reg [7:0] ir_next);

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
  //$display("ir_next: %02x sync: %d",ir_next,sync);
end

endmodule

// Note: LM_C_DB0, LM_Z_DB1, LM_I_DB2 and LM_D_DB3 are currently always set together and are thus redundant,
// so if we ever went back to predecoded flags we could save 3 bits there.
(* keep_hierarchy = "yes" *) module `flags_decode(input [3:0] load_flags, output reg [16:0] load_flags_decode);
always @(*)
begin
  case (load_flags)
    `kFLAGS_DB   : load_flags_decode = (`kLM_C_DB0 | `kLM_Z_DB1 | `kLM_I_DB2 | `kLM_D_DB3 | `kLM_V_DB6 | `kLM_N_DB7);
    `kFLAGS_SBZN : load_flags_decode = (`kLM_Z_SBZ | `kLM_N_SBN);
    `kFLAGS_D    : load_flags_decode = (`kLM_D_IR5);
    `kFLAGS_I    : load_flags_decode = (`kLM_I_IR5);
    `kFLAGS_C    : load_flags_decode = (`kLM_C_IR5);
    `kFLAGS_V    : load_flags_decode = (`kLM_V_0);
    `kFLAGS_Z    : load_flags_decode = (`kLM_Z_SBZ);
    `kFLAGS_CNZ  : load_flags_decode = (`kLM_C_ACR | `kLM_Z_SBZ | `kLM_N_SBN);
    `kFLAGS_ALU  : load_flags_decode = (`kLM_C_ACR | `kLM_V_AVR | `kLM_Z_SBZ | `kLM_N_SBN);
    `kFLAGS_BIT  : load_flags_decode = (`kLM_V_DB6 | `kLM_N_DB7);
    `kFLAGS_SETI : load_flags_decode = (`kLM_I_1|`kLM_D_IR5);     // Clear D flag too
    `kFLAGS_E    : load_flags_decode = (`kLM_E_IR0);
    `kFLAGS_RTI  : load_flags_decode = (`kLM_C_DB0 | `kLM_Z_DB1 | `kLM_I_DB2 | `kLM_D_DB3 | `kLM_V_DB6 | `kLM_N_DB7 | `kLM_E_RTI);
    default      : load_flags_decode = 0;
  endcase
end

endmodule

(* keep_hierarchy = "yes" *) module `reg_decode(input [2:0] load_reg, output reg [4:0] load_reg_decode);

always @(*)
begin
case (load_reg)
  `kLOAD_A    : load_reg_decode = `kLM_A;
  `kLOAD_X    : load_reg_decode = `kLM_X;
  `kLOAD_Y    : load_reg_decode = `kLM_Y;
  `kLOAD_Z    : load_reg_decode = `kLM_Z;
  `kLOAD_B    : load_reg_decode = `kLM_B;
  default     : load_reg_decode = 0;
endcase
//$display("load_reg: %02x decode: %016b",load_reg,load_reg_decode);
end

endmodule

(* keep_hierarchy = "yes" *) module `sp_sel_mux(input hyper_mode, input [15:0] usp, input [15:0] hsp, output reg [15:0] sp);

always @(*)
begin
  if(hyper_mode)
    sp = hsp;
  else
    sp = usp;
end
endmodule
