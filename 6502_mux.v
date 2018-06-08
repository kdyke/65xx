`include "6502_inc.vh"

`SCHEM_KEEP_HIER module addrbus_mux(input clk, input ready, input [1:0] ab_sel, 
                                    input [15:0] ad, input [15:0] ab, input [15:0] sp, input [15:0] pc, 
                                    output reg [15:0] abus_next, output reg [15:0] abus);

reg [15:0] tmp;

always @(*)
begin
  case(ab_sel)  // synthesis full_case parallel_case
    `AB_PC  : tmp = pc;
    `AB_AB  : tmp = ab;
    `AB_AD  : tmp = ad;
    `AB_S   : tmp = sp;
  endcase
end

always @(*)
begin
  if(ready)
    abus_next = tmp;
  else
    abus_next = abus;
  //$display("abus_next: %04x",abus_next);
end

always @(posedge clk)
begin
  if(ready)
  begin
    abus <= abus_next;
  end
end

endmodule

`SCHEM_KEEP_HIER module aluabus_mux(aluabus_sel, reg_a, reg_x, reg_y, reg_z, reg_p, reg_b, reg_pch, reg_sph, reg_pcl, reg_spl, aluabus);
input [3:0] aluabus_sel;
input [7:0] reg_a;
input [7:0] reg_x;
input [7:0] reg_y;
input [7:0] reg_z;
input [7:0] reg_p;
input [7:0] reg_b;
input [7:0] reg_sph;
input [7:0] reg_pch;
input [7:0] reg_spl;
input [7:0] reg_pcl;

output reg [7:0] aluabus;

always @(*)
begin
  case(aluabus_sel)  // synthesis full_case parallel_case
    `ABUS_0   : aluabus = 8'h00;
    `ABUS_A   : aluabus = reg_a;
    `ABUS_X   : aluabus = reg_x;
    `ABUS_Y   : aluabus = reg_y;
    `ABUS_Z   : aluabus = reg_z;
    `ABUS_P   : aluabus = reg_p;
    `ABUS_B   : aluabus = reg_b;
    `ABUS_PCH : aluabus = reg_pch;
    `ABUS_SPH : aluabus = reg_sph;
    `ABUS_PCL : aluabus = reg_pcl;
    `ABUS_SPL : aluabus = reg_spl;
  endcase
  //$display("aluabus: %02x",aluabus);
end

endmodule

`SCHEM_KEEP_HIER module alua_mux(input [1:0] alua_sel, 
                                 input [7:0] alua_reg,
                                 input [7:0] vector_lo,
                                 output reg [7:0] alua);
   
// ALU A input select
always @(*)
begin
  case(alua_sel)  // synthesis full_case parallel_case
    `ALUA_REG  : alua = alua_reg;
    `ALUA_NREG : alua = ~alua_reg;
    `ALUA_VEC  : alua = vector_lo;
  endcase
  //$display("alua_sel: %d result: %02x reg: %02x nreg: %02x vec: %02x",alua_sel,alua,alua_reg,~alua_reg,vector_lo);
end

endmodule

`SCHEM_KEEP_HIER module decoder3to8(index, outbits);
input [2:0] index;
output reg [7:0] outbits;

always @(*)
begin
  case(index)
    0 : outbits = 8'b00000001;
    1 : outbits = 8'b00000010;
    2 : outbits = 8'b00000100;
    3 : outbits = 8'b00001000;
    4 : outbits = 8'b00010000;
    5 : outbits = 8'b00100000;
    6 : outbits = 8'b01000000;
    7 : outbits = 8'b10000000;
  endcase
end
endmodule

`SCHEM_KEEP_HIER module alub_mux(input [2:0] alub_sel, 
                                 input [7:0] db, 
                                 input [2:0] bit_index, 
                                 output [7:0] alub);

  reg [7:0] alub;
  wire [7:0] bit;

  decoder3to8 dec3to8(bit_index, bit);
  
// ALU B input select
always @(*)
begin
  case(alub_sel)  // synthesis full_case parallel_case
    `ALUB_0    : alub = 8'h00;
    `ALUB_DB   : alub = db;
    `ALUB_BIT  : alub = bit;
    `ALUB_FF   : alub = 8'hFF;
    `ALUB_NDB  : alub = ~db;
    `ALUB_NBIT : alub = ~bit;
  endcase
  $display("alub: %02x",alub);
end

endmodule

`SCHEM_KEEP_HIER module aluc_mux(input [1:0] aluc_sel, 
                                 input carry,
                                 input last_carry,
                                 output reg aluc);

// ALU C (carry) input select
always @(*)
begin
  case(aluc_sel)  // synthesis full_case parallel_case
    `ALUC_0 : aluc = 0;
    `ALUC_1 : aluc = 1;
    `ALUC_P : aluc = carry;
    `ALUC_A : aluc = last_carry;
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
  $display("ir_next: %02x sync: %d",ir_next,sync);
end

endmodule

// Note: LM_C_DB0, LM_Z_DB1, LM_I_DB2 and LM_D_DB3 are currently always set together and are thus redundant,
// so if we ever went back to predecoded flags we could save 3 bits there.
`SCHEM_KEEP_HIER module flags_decode(input [3:0] load_flags, output reg [15:0] load_flags_decode);
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
  `FLAGS_SETI : load_flags_decode = (`LM_I_1|`LM_D_IR5);     // Clear D flag too
  `FLAGS_E    : load_flags_decode = (`LM_E_IR0);
endcase

endmodule

`SCHEM_KEEP_HIER module reg_decode(input [3:0] load_reg, output reg [13:0] load_reg_decode);

always @(*)
case (load_reg) // synthesis full_case parallel_case
  `none       : load_reg_decode = 0;
  `ALUY_A     : load_reg_decode = `LOAD_A;
  `ALUY_X     : load_reg_decode = `LOAD_X;
  `ALUY_Y     : load_reg_decode = `LOAD_Y;
  `ALUY_Z     : load_reg_decode = `LOAD_Z;
  `ALUY_P     : load_reg_decode = `LOAD_P;
  `ALUY_B     : load_reg_decode = `LOAD_B;
  `ALUY_ABH   : load_reg_decode = `LOAD_ABH;
  `ALUY_ADH   : load_reg_decode = `LOAD_ADH;
  `ALUY_PCH   : load_reg_decode = `LOAD_PCH;
  `ALUY_SPH   : load_reg_decode = `LOAD_SPH;
  `ALUY_ABL   : load_reg_decode = `LOAD_ABL;
  `ALUY_ADL   : load_reg_decode = `LOAD_ADL;
  `ALUY_PCL   : load_reg_decode = `LOAD_PCL;
  `ALUY_SPL   : load_reg_decode = `LOAD_SPL;  
endcase

endmodule
  