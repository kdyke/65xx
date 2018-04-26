`include "6502_inc.vh"

`timescale 10ns/10ns

module decadj_half_adder(dec_in, dec_out, carry_in, dec_add, dec_sub, half);
  input [3:0] dec_in;
  output [3:0] dec_out;
  input carry_in;
  input dec_add;
  input dec_sub;
  input half;
  
	reg [3:0] correction_factor;
  reg [3:0] dec_out;
  
  always @(*)
  begin
    if(dec_add & carry_in)
      correction_factor = 4'h6;
    else if(dec_sub & ~carry_in)
      correction_factor = 4'ha;
    else
      correction_factor = 4'h0;
  
    dec_out = dec_in + correction_factor;

    //$strobe(" dec%d: %x + %x = %x    cin: %d add: %d sub: %d",
    //  half,dec_in,correction_factor,dec_out,carry_in,dec_add,dec_sub);
    
  end
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
module alu_unit(a,b,alu_out,c_in,flags_in,dec_add,flags_out,op,half_carry_out);
   input [7:0] a;
   input [7:0] b;
	input [3:0] op;
	input c_in;
	input dec_add;
  input dec_sub;
   output [7:0] alu_out;
	input [3:0] flags_in;
	output [3:0] flags_out;
  output half_carry_out;
  
	reg c, v, n;
	
	reg [3:0] flags_out;
  reg [7:0] b_in;
	wire [7:0] add_out;

	reg [7:0] tmp;
 	reg [7:0] alu_out;
	reg add_cin;
  reg half_carry_out;
  wire carry_out;
  
  // FIXME/TODO - The negative input should come from microcode not ALU op
  always @(*) begin
  	case(op) // synthesis full_case parallel_case
  		`ALU_CMP: begin : CMP0
  			add_cin = 1;
        b_in = ~b;
  			end
//  		`ALU_SBC: begin: SBC0
//  			add_cin = c_in;
//        b_in = ~b;
//  			end
  		default: begin
  			add_cin = c_in;
        b_in = b;
  			end
  	endcase
  end

  wire hco;
	alu_adder add_u(a, b_in, add_cin, dec_add, add_out, carry_out, hco);
	
always @(*) begin
	case(op) // synthesis full_case parallel_case
		`ALU_ORA: begin : ORA
			tmp = a | b;
			c = c_in;
			v = 0;
			n = tmp[7];
			end
		`ALU_AND: begin : AND
			tmp = a & b;
			c = flags_in[0];
			v = flags_in[2];
			n = tmp[7];
			end
		`ALU_EOR: begin : EOR
			tmp = a ^ b;
			c = c_in;
			v = 0;
			n = 0;
      //$display("ALU EOR: %02x ^ %02x = %02x  c: %d v: %d n: %d",a,b,tmp,c,v,n);
			end
		`ALU_ADC, `ALU_SBC: 
      begin : ADC
			{c,tmp} = {carry_out,add_out};
      //$display("ALD_ADC: carry_out: %d add_out: %02x",carry_out,add_out);
			if(a[7] == b_in[7] && tmp[7] != a[7])
				v = 1;
			else
				v = 0;
			n = tmp[7];
			end
		`ALU_BIT: begin : BIT
			{c,tmp} = {c_in,a & b};
			n = b[7];
			v = b[6];
			end
		`ALU_ROR, `ALU_LSR: begin : ROR
			{tmp,c} = {c_in,a};
			n = tmp[7];
      end
    `ALU_PSA: begin : PSA
			c = 0;
			v = 0;
			n = 0;
      tmp = a;
			end

	endcase
	flags_out = {n,v,~|tmp,c};
	alu_out = tmp;
  half_carry_out = hco;
  //$strobe("ALU a: %02x b: %02x add_cin: %d cin: %d fcin: %d -> %02x daa: %d dsa: %d flags nvzc: %d%d%d%d hc: %d",a,b,add_cin,c_in,flags_in[0],tmp,dec_add,dec_sub,n,v,flags_out[1],c,half_carry_out);
  //$strobe("ALU a: %02x b: %02x c: %d -> %02x d: %d flags nvzc: %d%d%d%d hc: %d",a,b,add_cin /*flags_in[0] */,alu_out,decimal,flags_out[3],flags_out[2],flags_out[1],flags_out[0],half_carry_out);
	end

endmodule

