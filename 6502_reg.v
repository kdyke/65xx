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

`SCHEM_KEEP_HIER module ab_reg(input clk, input ready, input [1:0] abh_sel, input getvec, input load_abl, input ab_inc, input ab_dec,
                               input [7:0] b, input[7:0] aluy, output reg [15:0] ab_next, output reg [15:0] ab);

reg [15:0] ab_add;

always @(*)
begin
  if(ab_inc)
    ab_add = ab + 1;
  else if(ab_inc)
    ab_add = ab - 1;
  else
    ab_add = ab;
end

always @(*)
begin
  ab_next = ab;
  if(ready)
  begin
    case(abh_sel)
      `ABH_B:     ab_next[15:8] = b;
      `ABH_ALU:   ab_next[15:8] = aluy;
      `ABH_ADJ:   ab_next[15:8] = ab_add[15:8];
    endcase
    if(getvec)
      ab_next[15:8] = 8'hFF;
    if(load_abl)
      ab_next[7:0] = aluy;
    else if(ab_inc|ab_dec)
      ab_next[7:0] = ab_add[7:0];
  end
  //$display("ab_next: %04x aluy: %02x",ab_next,aluy);
end

always @(posedge clk)
begin
  if(ready)
    ab <= ab_next;
end

endmodule

`SCHEM_KEEP_HIER module ad_reg(input clk, input ready, input load_adl, input load_adh, 
                               input [7:0] aluy, output reg [15:0] ad_next, output reg [15:0] ad);

always @(*)
begin
  ad_next = ad;
  if(ready)
  begin
    if(load_adl)
      ad_next[7:0] = aluy;
    if(load_adh)
      ad_next[15:8] = aluy;
  end
end

always @(posedge clk)
begin
  if(ready)
    ad <= ad_next;
end

endmodule

`SCHEM_KEEP_HIER module pc_reg(input clk, input ready, input pc_inc, input load_pcl_adl,
                               input load_pcl, input load_pch,
                               input [7:0] adl, input [7:0] aluy, 
                               output reg [15:0] pc_next, output reg[15:0] pc);

always @(*)
begin
  pc_next = pc;
  if(load_pcl_adl)
    pc_next[7:0] = adl;
  else if(load_pcl)
    pc_next[7:0] = aluy;
  else if(load_pch)
    pc_next[15:8] = aluy;
  else if(pc_inc)
    pc_next = pc + 1;
  $display("pc_next: %04x pc: %04x adl: %d pcl: %d pch: %d inc: %d aluy: %02x",pc_next,pc,load_pcl_adl,load_pcl,load_pch,pc_inc,aluy);
end

always @(posedge clk)
begin
  if(ready)
    pc <= pc_next;
end

endmodule

`SCHEM_KEEP_HIER module sp_reg(input clk, input reset, input ready, input e_bit, 
                               input load_sph, input load_spl, input sp_inc, input sp_dec, input [7:0] aluy, 
                               output reg [15:0] sp_next, output reg [15:0] sp);

reg [15:0] sp_add_in;
wire [15:0] sp_add_out;

always @(*)
begin
  case({sp_inc,sp_dec})
    2'b01:    sp_add_in = 16'hFFFF;
    2'b10:    sp_add_in = 16'h0001;
    default:  sp_add_in = 16'h0000;
  endcase
end

assign sp_add_out = sp + sp_add_in;

always @(*)
begin
  sp_next = sp;
  if(reset)
    sp_next[15:8] = 8'h01;
  else if(ready)
  begin  
    if(load_sph)
      sp_next[15:8] = aluy;
    else if(load_spl)
      sp_next[7:0] = aluy;
    else if(sp_inc|sp_dec)
    begin
      sp_next[7:0] = sp_add_out[7:0];
      if(e_bit == 0)
        sp_next[15:8] = sp_add_out[15:8];
    end
  end
end

always @(posedge clk)
begin
  if(ready)
    sp <= sp_next;
end

endmodule

`SCHEM_KEEP_HIER module p_reg(input clk, input reset, input ready, input intg, 
                              input [15:0] load_flag_decode, input load_b, 
                              input [7:0] db_in, input sb_z, input sb_n, input carry, input overflow, input ir5, input ir0, output reg [7:0] reg_p);

always @(*)
begin
  reg_p[`PF_B] = ~intg;
end

always @(posedge clk)
begin
  if(reset)
    reg_p[`PF_E] <= 1;    
  else if(ready)
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
    
    if(load_flag_decode[`LF_E_IR0])       reg_p[`PF_E] = ir0;
  end
end

endmodule
