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

`timescale 10ns/10ns

module `decadj_half_adder(dec_in, dec_out, carry_in, dec_add, dec_sub);
  input [3:0] dec_in;
  input carry_in;
  input dec_add;
  input dec_sub;
  output reg [3:0] dec_out;
  
	reg [3:0] correction_factor;
  reg [3:0] tmp;
  reg add_adj, sub_adj;
  
  always @(*) begin  
    add_adj = dec_add & carry_in;
    sub_adj = dec_sub & ~carry_in;
    correction_factor = {sub_adj,add_adj,add_adj|sub_adj,1'b0};
    tmp = dec_in + correction_factor;
    dec_out = tmp;
  end
endmodule

module `alu_half_adder(add_in1, add_in2, add_cin, dec_add, add_out, carry_out);
  input [3:0] add_in1;
  input [3:0] add_in2;
  input add_cin;
  input dec_add;
  output carry_out;
  output [3:0] add_out;
  reg [3:0] add_out;
  
  reg carry_out;
  reg carry_tmp;
	reg greater_than_nine;
  
  reg [4:0] add_tmp;
  
  always @(*)
  begin
    add_tmp = add_in1 + add_in2 + add_cin;
    greater_than_nine = (add_tmp[3] & (add_tmp[2] | add_tmp[1]));
    carry_out = add_tmp[4] | (dec_add & greater_than_nine);
    add_out = add_tmp[3:0];
  end

endmodule

module `alu_adder(add_in1, add_in2, add_cin, dec_add, dec_sub, add_out, carry_out);
  input [7:0] add_in1;
  input [7:0] add_in2;
  input add_cin;
  input dec_add;
  input dec_sub;

  (* dont_touch = "yes" *) output [7:0] add_out;
  (* dont_touch = "yes" *) output carry_out;
  
  wire half_carry;
  
  wire [7:0] tmp;
    
  `alu_half_adder  low(add_in1[3:0],add_in2[3:0],add_cin,   dec_add,tmp[3:0],half_carry);
  `alu_half_adder high(add_in1[7:4],add_in2[7:4],half_carry,dec_add,tmp[7:4],carry_out);
  
  // We could insert a pre-decimal correction Z test here for 6502 compatibility.
  
  `decadj_half_adder  decadj_low(tmp[3:0],add_out[3:0], half_carry,    dec_add, dec_sub);
  `decadj_half_adder decadj_high(tmp[7:4],add_out[7:4], carry_out,     dec_add, dec_sub);

endmodule

module `ea_adder(input [7:0] a, input [7:0] b, input carry_in, output wire [7:0] add_out, output carry_out);
wire [8:0] ea_add = a + b + carry_in;
assign add_out = ea_add[7:0];
assign carry_out = ea_add[8];
endmodule

(* keep_hierarchy = "yes" *) module alu_out_mux(input [2:0] op, input [8:0] alu_ora, input [8:0] alu_xxx, input [8:0] alu_and, input [8:0] alu_eor, input [8:0] alu_adc,
                                                input [8:0] alu_shr, input [8:0] alu_asr, input [8:0] alu_shl, output reg [8:0] alu_out);

  always @(*) begin // synthesis parallel_case full_case
	  case(op)
  		`kALU_ORA:
        begin
  			alu_out = alu_ora;
  			end
  		`kALU_ORA2:
        begin
  			alu_out = alu_xxx;
  			end
  		`kALU_AND: 
        begin
  			alu_out = alu_and;
  			end
  		`kALU_EOR: 
        begin
  			alu_out = alu_eor;
  			end
  		`kALU_ADC: 
        begin
  			alu_out = alu_adc;
  			end
  		`kALU_SHR: 
        begin
  			alu_out = alu_shr;
        end
  		`kALU_ASR: 
        begin
  			alu_out = alu_asr;
        end
  		`kALU_SHL: 
        begin
  			alu_out = alu_shl;
        end
    endcase
  end
endmodule            
                  
// Input muxing is done outside of the core ALU unit.
(* keep_hierarchy = "yes" *) module `alu_unit(a,b,c_in,dec_add,dec_sub,alu_sel,overflow_out, alu_out, alu_carry_out);
  input [7:0] a;
  input [7:0] b;
	input c_in;
	input dec_add;
	input dec_sub;

  input [2:0] alu_sel;
  output wire [7:0] alu_out;
  output wire alu_carry_out;
  
  wire [8:0] alu_ora;
  wire [8:0] alu_and;
  wire [8:0] alu_eor;
  wire [8:0] alu_adc;
  wire [8:0] alu_shr;
  wire [8:0] alu_asr;
  wire [8:0] alu_shl;

  //output wire carry_out;
  output wire overflow_out;
  
	wire [7:0] add_out;

  wire adder_carry_out;
  
	`alu_adder add_u(a, b, c_in, dec_add, dec_sub, add_out, adder_carry_out);
	  
  assign overflow_out = a[7] == b[7] && a[7] != add_out[7];
    
  assign alu_ora = {1'b0, a|b};
  assign alu_and = {1'b0, a&b};
  assign alu_eor = {1'b0, a^b};
  assign alu_adc = {adder_carry_out, add_out};
  assign alu_shr = {a[0],c_in,a[7:1]};
  assign alu_asr = {a[0],a[7],a[7:1]};
  assign alu_shl = {a[7:0],c_in};

  wire [8:0] alu_mux_out;

  assign alu_out = alu_mux_out[7:0];
  assign alu_carry_out = alu_mux_out[8];
  
  alu_out_mux alu_out_mux(alu_sel, alu_ora, 9'b00, alu_and, alu_eor, alu_adc, alu_shr, alu_asr, alu_shl, alu_mux_out);

  //$display("ALU op: %x a: %02x b: %02x c_in: %d -> %02x daa: %d dsa: %d flags vc: %d%d add: %02x",op,a,b,c_in,tmp,dec_add,dec_sub,overflow_out,c,add_out);

endmodule

(* keep_hierarchy = "yes" *) module `z_unit(input clk, input ready, input [2:0] op, input [7:0] aluy, output wire z_out, output reg dld_z, input word_z);

wire alu_z;

assign alu_z = ~|aluy;

always @(posedge clk)
begin
  if(op != `kALU_ORA && ready)
    dld_z <= alu_z;
end

assign z_out = alu_z & (~word_z | dld_z);

endmodule
