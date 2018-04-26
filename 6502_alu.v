`include "6502_inc.vh"

`timescale 10ns/10ns

module decadj_half_adder(dec_in, dec_out, carry_in, dec_add, dec_sub, half);
  input [3:0] dec_in;
  input carry_in;
  input dec_add;
  input dec_sub;
  input half;
  output [3:0] dec_out;
  
	wire [3:0] correction_factor;
  wire [3:0] dec_out;

  wire add_adj, sub_adj;
  
  assign add_adj = dec_add & carry_in;
  assign sub_adj = dec_sub & ~carry_in;
  
  assign correction_factor = {sub_adj,add_adj,add_adj|sub_adj,1'b0};
  assign dec_out = dec_in + correction_factor;
  
  //$strobe(" dec%d: %x + %x = %x    cin: %d add: %d sub: %d",
  //  half,dec_in,correction_factor,dec_out,carry_in,dec_add,dec_sub);
    
endmodule

module decadj_adder(dec_in, dec_out, carry_in, half_carry_in, dec_add, dec_sub);
  input [7:0] dec_in;
  input carry_in;
  input half_carry_in;
  input dec_add;
  input dec_sub;
  output [7:0] dec_out;
  
  decadj_half_adder  low(dec_in[3:0],dec_out[3:0], half_carry_in, dec_add, dec_sub, 1'b0);
  decadj_half_adder high(dec_in[7:4],dec_out[7:4], carry_in, dec_add, dec_sub, 1'b1);  
endmodule

module alu_half_adder(add_in1, add_in2, add_cin, dec_add, add_out, carry_out, dec_carry_out, half);
  input [3:0] add_in1;
  input [3:0] add_in2;
  input add_cin;
  input dec_add;
  input half;
  output carry_out;
  output dec_carry_out;
  output [3:0] add_out;
  reg [3:0] add_out;
  
  reg carry_out;
  reg carry_tmp;
  reg dec_carry_out;
	reg greater_than_nine;
  
  reg [4:0] add_tmp;
  
  always @(*)
  begin
    add_tmp = add_in1 + add_in2 + add_cin;
    greater_than_nine = (add_tmp[3] & (add_tmp[2] | add_tmp[1]));
    carry_tmp = add_tmp[4] | (dec_add & greater_than_nine);

    //$strobe("half%d: %x + %x + %d = %02x dadd: %d co: %d",half,add_in1,add_in2,add_cin,add_tmp[4:0],dec_add,carry_tmp);
    carry_out = carry_tmp;
    dec_carry_out = greater_than_nine;
    add_out = add_tmp[3:0];
  end

endmodule

module alu_adder(add_in1, add_in2, add_cin, dec_add, add_out, carry_out, half_carry_out);
  input [7:0] add_in1;
  input [7:0] add_in2;
  input add_cin;
  input dec_add;

  output [7:0] add_out;
  output carry_out;
  output half_carry_out;
    
  wire dec_carry_out; // unused
  
  //always @(*)
  //begin
  //  $strobe("adder: %02x + %02x + %d = %02x daa: %d hc: %d c: %d",add_in1,add_in2,add_cin,add_out,dec_add,half_carry_out,carry_out);
  //end
  
  alu_half_adder  low(add_in1[3:0],add_in2[3:0],add_cin,dec_add,add_out[3:0],half_carry_out,dec_half_carry_out,1'b0);
  alu_half_adder high(add_in1[7:4],add_in2[7:4],half_carry_out,dec_add,add_out[7:4],carry_out,dec_carry_out,1'b1);
    
endmodule

// Input muxing is done outside of the core ALU unit.
module alu_unit(a,b,alu_out,c_in,dec_add,op,carry_out,half_carry_out,overflow_out);
  input [7:0] a;
  input [7:0] b;
	input [3:0] op;
	input c_in;
	input dec_add;

  output [7:0] alu_out;
  output carry_out;
  output half_carry_out;
  output overflow_out;
  
	reg c;
	
	wire [7:0] add_out;
	reg [7:0] tmp;
 	reg [7:0] alu_out;

  wire adder_carry_out;
  wire half_carry_out;
  wire overflow_out;
  
  reg carry_out;
  
	alu_adder add_u(a, b, c_in, dec_add, add_out, adder_carry_out, half_carry_out);
	
  assign overflow_out = a[7] == b[7] && a[7] != add_out[7];
  
always @(*) begin
	case(op) // synthesis full_case parallel_case
		`ALU_ORA: begin : ORA
      c = 0;
			tmp = a | b;
			end
		`ALU_AND: begin : AND
      c = 0;
			tmp = a & b;
			end
		`ALU_EOR: begin : EOR
      c = 0;
			tmp = a ^ b;
			end
		`ALU_ADC, `ALU_SBC: 
      begin : ADC
      c = adder_carry_out;
      tmp = add_out;
			end
		`ALU_ROR: begin : ROR
			{tmp,c} = {c_in,a};
      end
    `ALU_PSA: begin : PSA
			c = 0;
      tmp = a;
			end

	endcase

	alu_out = tmp;
  carry_out = c;
  
  //$strobe("ALU a: %02x b: %02x c_in: %d -> %02x daa: %d flags vc: %d%d hc: %d",a,b,c_in,tmp,dec_add,overflow_out,carry_out,half_carry_out);
	end

endmodule

