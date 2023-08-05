/* 
** Copyright (c) 2018-2023 Kenneth C. Dyke
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

`include "6502_inc.vh"

`SCHEM_KEEP_HIER module clocked_reg8(input clk, input ready, input [7:0] register_in, output reg [7:0] register_out);

always @(posedge clk)
begin
  if(ready)
  begin
    register_out <= register_in;
  end
end

endmodule

`SCHEM_KEEP_HIER module clocked_reset_reg8(input clk, input reset, input ready, 
                                           input [7:0] register_in, output reg [7:0] register_out);

always @(posedge clk)
begin
  if(reset)
    register_out <= 0;
  else if(ready)
  begin
    register_out <= register_in;
  end
end

endmodule

`SCHEM_KEEP_HIER module ab_reg(input clk, input ready, input ab_inc, input [1:0] abh_sel, input abl_sel,
                               input [7:0] b, input[7:0] alu_ea, output reg [15:0] ab_next, output reg [15:0] ab);

reg [15:0] ab_add;

always @(*)
begin
    ab_add = ab + ab_inc;
end

always @(*)
begin
  begin
    case(abh_sel)
      `kABH_ABH:   ab_next[15:8] = ab_add[15:8];
      `kABH_B:     ab_next[15:8] = b;
      `kABH_ALU:   ab_next[15:8] = alu_ea;
      `kABH_VEC:   ab_next[15:8] = 8'hff;
    endcase
    if(abl_sel)
      ab_next[7:0] = alu_ea;
    else      
      ab_next[7:0] = ab_add[7:0];
  end
  //$display("ab_next: %04x alu_ea: %02x abh_sel: %01x abl_sel: %d",ab_next,alu_ea,abh_sel,abl_sel);
end

always @(posedge clk)
begin
  if(ready)
    ab <= ab_next;
end

endmodule

`SCHEM_KEEP_HIER module ad_reg(input clk, input ready, input adh_sel, input adl_sel,
                               input [7:0] alu_ea, output reg [15:0] ad_next, output reg [15:0] ad);

always @(*)
begin
  ad_next = ad;
  begin
    if(adl_sel)
      ad_next[7:0] = alu_ea;
    if(adh_sel)
      ad_next[15:8] = alu_ea;
  end
  //$display("ad_next: %04x alu_ea: %02x adh_sel: %01x adl_sel: %d",ad_next,alu_ea,adh_sel,adl_sel);
end

always @(posedge clk)
begin
  if(ready)
    ad <= ad_next;
end

endmodule

`SCHEM_KEEP_HIER module pc_reg(input clk, input ready, input pc_inc, input cond_met, input [1:0] pch_sel, input [1:0] pcl_sel,
                               input [7:0] adl, input [7:0] alu_ea, input aluc, input alub7, input [7:0] pcl_alu, input pcl_alu_carry,
                               output reg [15:0] pc_next, output reg[15:0] pc);

wire [8:0] pcl_incremented;
assign pcl_incremented = pc[7:0] + pc_inc;

always @(*)
begin

  if(cond_met && pcl_sel == `kPCL_ALU)
    pc_next[7:0] = pcl_alu;
  else if(cond_met && pcl_sel == `kPCL_ADL)
    pc_next[7:0] = adl;
  else
    pc_next[7:0] = pcl_incremented;

  if(cond_met && pch_sel == `kPCH_ALU)
    pc_next[15:8] = alu_ea;
  else if(cond_met && pch_sel == `kPCH_ADJ)
    pc_next[15:8] = pc[15:8] + {8{alub7}} + pcl_alu_carry;
  else
    pc_next[15:8] = pc[15:8] + pcl_incremented[8];

end

always @(posedge clk)
begin
  if(ready)
    pc <= pc_next;
end

endmodule

`SCHEM_KEEP_HIER module sp_reg(input clk, input reset, input ready, input e_bit, 
                               input [1:0] sp_inc, input sph_sel, input spl_sel, input [7:0] alu_ea, 
                               output reg [15:0] sp_next, output reg [15:0] sp);

reg [15:0] sp_add_in;
wire [15:0] sp_add_out;

always @(*)
begin
  case(sp_inc)
    `kSP_DEC:    sp_add_in = 16'hFFFF;
    `kSP_INC:    sp_add_in = 16'h0001;
    default:     sp_add_in = 16'h0000;
  endcase
end

assign sp_add_out = sp + sp_add_in;

always @(*)
begin
  sp_next = sp;
  if(reset)
    sp_next[15:8] = 8'h01;
  else
  begin  
    if(sph_sel)
      sp_next[15:8] = alu_ea;
    else if(spl_sel)
      sp_next[7:0] = alu_ea;
    else if(sp_inc != 0)
    begin
      sp_next[7:0] = sp_add_out[7:0];
      if(e_bit == 0)
        sp_next[15:8] = sp_add_out[15:8];
    end
  end
end

always @(posedge clk)
begin
  if(ready|reset)
    sp <= sp_next;
end

endmodule

`SCHEM_KEEP_HIER module p_reg(input clk, input reset, input ready, input intg, 
                              input [15:0] load_flag_decode, input load_b, 
                              input [7:0] db_in, input sb_z, input sb_n, input carry, input overflow, input ir5, input ir0, output reg [7:0] reg_p);

always @(*)
begin
  reg_p[`kPF_B] = ~intg;
end

always @(posedge clk)
begin
  if(reset)
    reg_p[`kPF_E] <= 1;    
  else if(ready)
  begin
    if(load_flag_decode[`kLF_C_ACR])       reg_p[`kPF_C] = carry;
    else if(load_flag_decode[`kLF_C_IR5])  reg_p[`kPF_C] = ir5;
    else if(load_flag_decode[`kLF_C_DB0])  reg_p[`kPF_C] = db_in[0];

    if(load_flag_decode[`kLF_Z_SBZ])       reg_p[`kPF_Z] = sb_z;
    else if(load_flag_decode[`kLF_Z_DB1])  reg_p[`kPF_Z] = db_in[1];
    
    if(load_flag_decode[`kLF_I_DB2])       reg_p[`kPF_I] = db_in[2];
    else if(load_flag_decode[`kLF_I_IR5])  reg_p[`kPF_I] = ir5;
    else if(load_flag_decode[`kLF_I_1])    reg_p[`kPF_I] = 1;

    if(load_flag_decode[`kLF_D_DB3])       reg_p[`kPF_D] = db_in[3];
    else if(load_flag_decode[`kLF_D_IR5])  reg_p[`kPF_D] = ir5;
    
    if(load_flag_decode[`kLF_V_AVR])       reg_p[`kPF_V] = overflow;
    else if(load_flag_decode[`kLF_V_DB6])  reg_p[`kPF_V] = db_in[6];
    else if(load_flag_decode[`kLF_V_0])    reg_p[`kPF_V] = 0;
      
    if(load_flag_decode[`kLF_N_SBN])       reg_p[`kPF_N] = sb_n;
    else if(load_flag_decode[`kLF_N_DB7])  reg_p[`kPF_N] = db_in[7];
    
    if(load_flag_decode[`kLF_E_IR0])       reg_p[`kPF_E] = ir0;
  end
end

endmodule
