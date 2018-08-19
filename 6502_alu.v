`include "6502_inc.vh"

`timescale 10ns/10ns

module decadj_half_adder(dec_in, dec_out, carry_in, dec_add, dec_sub);
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

module alu_half_adder(add_in1, add_in2, add_cin, dec_add, add_out, carry_out);
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

module alu_adder(add_in1, add_in2, add_cin, dec_add, dec_sub, add_out, carry_out);
  input [7:0] add_in1;
  input [7:0] add_in2;
  input add_cin;
  input dec_add;
  input dec_sub;

  output [7:0] add_out;
  output carry_out;
  
  wire half_carry;
  
  wire [7:0] tmp;
    
  alu_half_adder  low(add_in1[3:0],add_in2[3:0],add_cin,   dec_add,tmp[3:0],half_carry);
  alu_half_adder high(add_in1[7:4],add_in2[7:4],half_carry,dec_add,tmp[7:4],carry_out);
  
  // We could insert a pre-decimal correction Z test here for 6502 compatibility.
  
  decadj_half_adder  decadj_low(tmp[3:0],add_out[3:0], half_carry_in, dec_add, dec_sub);
  decadj_half_adder decadj_high(tmp[7:4],add_out[7:4], carry_out,     dec_add, dec_sub);

endmodule

module ea_adder(input [7:0] a, input [7:0] b, input carry_in, output wire [7:0] add_out, output carry_out);
wire [8:0] ea_add = a + b + carry_in;
assign add_out = ea_add[7:0];
assign carry_out = ea_add[8];
endmodule

// Input muxing is done outside of the core ALU unit.
`SCHEM_KEEP_HIER module alu_unit(a,b,alu_out,c_in,dec_add,dec_sub,op,carry_out,overflow_out);
  input [7:0] a;
  input [7:0] b;
	input [2:0] op;
	input c_in;
	input dec_add;
	input dec_sub;

  output [7:0] alu_out;
  
  output carry_out;
  output overflow_out;
  
	reg c;
  
	wire [7:0] add_out;
  //wire [8:0] ea_add;
	reg [7:0] tmp;
 	reg [7:0] alu_out;

  wire adder_carry_out;
  
  wire overflow_out;  
  reg carry_out;
  
	alu_adder add_u(a, b, c_in, dec_add, dec_sub, add_out, adder_carry_out);
	  
  assign overflow_out = a[7] == b[7] && a[7] != add_out[7];
  
  always @(*) begin
    c = adder_carry_out; // default case
	  casez(op)
  		`kALU_ORA , `kALU_ORA2:
        begin
  			tmp = a | b;
  			end
  		`kALU_AND: 
        begin
  			tmp = a & b;
        //c = adder_carry_out; // default case
  			end
  		`kALU_EOR: 
        begin
  			tmp = a ^ b;
        //c = adder_carry_out; // default case
  			end
  		`kALU_ADC: 
        begin
        tmp = add_out;
        //c = adder_carry_out; // default case
  			end
  		`kALU_SHR: 
        begin
  			{tmp,c} = {c_in,a[7:0]};
        end
  		`kALU_ASR: 
        begin
  			{tmp,c} = {a[7],a[7:0]};
        end
  		`kALU_SHL: 
        begin
  			{c,tmp} = {a[7:0],c_in};
        end
    endcase

  //$display("ALU op: %x a: %02x b: %02x c_in: %d -> %02x daa: %d dsa: %d flags vc: %d%d add: %02x",op,a,b,c_in,tmp,dec_add,dec_sub,overflow_out,c,add_out);

	alu_out = tmp;
  carry_out = c;
  
	end

endmodule

`SCHEM_KEEP_HIER module z_unit(input clk,input [2:0] op, input [7:0] aluy, output wire z_out, output reg dld_z, input word_z);

wire alu_z;

assign alu_z = ~|aluy;

always @(posedge clk)
begin
  if(op != `ALU_ORA)
    dld_z <= alu_z;
end

assign z_out = alu_z & (~word_z | dld_z);

endmodule
