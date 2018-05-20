`include "6502_inc.vh"

`SCHEM_KEEP_HIER module clocked_reg8(clk, ready, register_in, register_out);
input clk;
input ready;
input [7:0] register_in;
output [7:0] register_out;
reg [7:0] register_out;

always @(posedge clk)
begin
  if(ready)
  begin
    register_out <= register_in;
  end
end

endmodule

`SCHEM_KEEP_HIER module clocked_reset_reg8(clk, reset, ready, register_in, register_out);
input clk;
input reset;
input ready;
input [7:0] register_in;
output [7:0] register_out;
reg [7:0] register_out;

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

`SCHEM_KEEP_HIER module a_reg(clk, load_a, dec_in, carry_in, half_carry_in, dec_add, dec_sub, reg_a);
  input clk;
  input load_a;
  input [7:0] dec_in;
  input carry_in;
  input half_carry_in;
  input dec_add;
  input dec_sub;
  
  wire [7:0] dec_out;
  output reg [7:0] reg_a;
  
  decadj_half_adder  low(dec_in[3:0],dec_out[3:0], half_carry_in, dec_add, dec_sub, 1'b0);
  decadj_half_adder high(dec_in[7:4],dec_out[7:4], carry_in, dec_add, dec_sub, 1'b1);
  
  always @(posedge clk)
  begin
    if(load_a)
      reg_a <= dec_out;
  end
  
endmodule

`SCHEM_KEEP_HIER module p_reg(clk, reset, ready, intg, load_flag_decode, load_b, db_in, sb_z, sb_n, carry, overflow, ir5, reg_p);

input clk;
input reset;
input ready;
input intg;
input [14:0] load_flag_decode;
input load_b;
input [7:0] db_in;
input sb_z;
input sb_n;
input carry;
input overflow;
input ir5;

output [7:0] reg_p;
reg [7:0] reg_p;

always @(*)
begin
  reg_p[`PF_B] = ~intg;
  reg_p[`PF_U] <= 1;
end

always @(posedge clk)
begin    
  if(ready)
  begin
    if(load_flag_decode[`LF_C_ACR])       reg_p[`PF_C] = carry;
    else if(load_flag_decode[`LF_C_IR5])  reg_p[`PF_C] = ir5;
    else if(load_flag_decode[`LF_C_DB0])  reg_p[`PF_C] = db_in[0];

    if(load_flag_decode[`LF_Z_SBZ])       reg_p[`PF_Z] = sb_z;
    else if(load_flag_decode[`LF_Z_DB1])  reg_p[`PF_Z] = db_in[1];
    
    if(load_flag_decode[`LF_I_DB2])       reg_p[`PF_I] = db_in[2];
    else if(load_flag_decode[`LF_I_IR5])  reg_p[`PF_I] = ir5;
    else if(load_flag_decode[`LF_I_1])    reg_p[`PF_I] = 1;

    if(load_flag_decode[`LF_D_DB3])       reg_p[`PF_D] = db_in[3];
    else if(load_flag_decode[`LF_D_IR5])  reg_p[`PF_D] = ir5;
    
    if(load_flag_decode[`LF_V_AVR])       reg_p[`PF_V] = overflow;
    else if(load_flag_decode[`LF_V_DB6])  reg_p[`PF_V] = db_in[6];
    else if(load_flag_decode[`LF_V_0])    reg_p[`PF_V] = 0;
      
    if(load_flag_decode[`LF_N_SBN])       reg_p[`PF_N] = sb_n;
    else if(load_flag_decode[`LF_N_DB7])  reg_p[`PF_N] = db_in[7];
  end
end

endmodule
