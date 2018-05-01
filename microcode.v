`include "6502_inc.vh"

(* keep_hierarchy = "yes" *) module microcode(clk, ir, t, tnext, adh_sel, adl_sel, db_sel, sb_sel, pchs_sel, pcls_sel, alu_op, alu_a, alu_b, alu_c,
                  load_a, load_x, load_y, load_s, load_abh, load_abl, 
                  load_flags,
                  write_cycle, pc_inc);

input clk;
input [7:0] ir;
input [2:0] t;
output [3:0] tnext;
output [2:0] adh_sel;
output [2:0] adl_sel;
output [2:0] db_sel;
output [2:0] sb_sel;
output [3:0] alu_op;
output pchs_sel;
output pcls_sel;
output [1:0] alu_a;
output [1:0] alu_b;
output [1:0] alu_c;
output load_a;
output load_x;
output load_y;
output load_s;
output load_abh;
output load_abl;
output [14:0] load_flags;
output write_cycle;
output pc_inc;

reg [`MICROCODE_BITS] mc_out;
(* rom_style = "block" *) reg [`MICROCODE_BITS] mc[0:2047];

// synthesis translate off
reg [12:0] i;
// synthesis translate on

initial begin

// synthesis translate off
// Init all microcode slots we haven't implemented with a state that halts
for( i = 0; i < 2048; i = i + 1 ) 
begin
   mc[i][`TNEXT_BITS] = `TKL;
   //$display("init %d",i);
end
// synthesis translate on

                            `BRK(8'h00)       // BRK
                            
`ADDR_zp_x_ind(8'h01)       `ORA(8'h01,0)     // ORA (zp,x)
`ADDR_zp(8'h05,`T0)         `ORA(8'h05,0)     // ORA zp
                            `ORA(8'h09,1)     // ORA #
`ADDR_abs(8'h0D,`T0)        `ORA(8'h0D,0)     // ORA abs
`ADDR_zp_ind_y(8'h11)       `ORA(8'h11,0)     // ORA (zp),y
`ADDR_zp_x(8'h15,`T0)       `ORA(8'h15,0)     // ORA zp,x
`ADDR_abs_y(8'h19)          `ORA(8'h19,0)     // ORA abs,y
`ADDR_abs_x(8'h1D,`TNC,`T0) `ORA(8'h1D,0)     // ORA abs,x

`ADDR_zp_x_ind(8'h21)       `AND(8'h21,0)     // AND (zp,x)
`ADDR_zp(8'h25,`T0)         `AND(8'h25,0)     // AND zp
                            `AND(8'h29,1)     // AND #
`ADDR_abs(8'h2D,`T0)        `AND(8'h2D,0)     // AND abs
`ADDR_zp_ind_y(8'h31)       `AND(8'h31,0)     // AND (zp),y
`ADDR_zp_x(8'h35,`T0)       `AND(8'h35,0)     // AND zp,x
`ADDR_abs_y(8'h39)          `AND(8'h39,0)     // AND abs,y
`ADDR_abs_x(8'h3D,`TNC,`T0) `AND(8'h3D,0)     // AND abs,x

`ADDR_zp(8'h24,`T0)         `BIT(8'h24)       // BIT zp
`ADDR_abs(8'h2C,`T0)        `BIT(8'h2C)       // BIT abs

`ADDR_zp_x_ind(8'h41)       `EOR(8'h41,0)     // EOR (zp,x)
`ADDR_zp(8'h45,`T0)         `EOR(8'h45,0)     // EOR zp
                            `EOR(8'h49,1)     // EOR #
`ADDR_abs(8'h4D,`T0)        `EOR(8'h4D,0)     // EOR abs
`ADDR_zp_ind_y(8'h51)       `EOR(8'h51,0)     // EOR (zp),y
`ADDR_zp_x(8'h55,`T0)       `EOR(8'h55,0)     // EOR zp,x
`ADDR_abs_y(8'h59)          `EOR(8'h59,0)     // EOR abs,y
`ADDR_abs_x(8'h5D,`TNC,`T0) `EOR(8'h5D,0)     // EOR abs,x

`ADDR_zp_x_ind(8'h61)       `ADC(8'h61,0)     // ADC (zp,x)
`ADDR_zp(8'h65,`T0)         `ADC(8'h65,0)     // ADC zp
                            `ADC(8'h69,1)     // ADC #
`ADDR_abs(8'h6D,`T0)        `ADC(8'h6D,0)     // ADC abs
`ADDR_zp_ind_y(8'h71)       `ADC(8'h71,0)     // ADC (zp),y
`ADDR_zp_x(8'h75,`T0)       `ADC(8'h75,0)     // ADC zp,x
`ADDR_abs_y(8'h79)          `ADC(8'h79,0)     // ADC abs,y
`ADDR_abs_x(8'h7D,`TNC,`T0) `ADC(8'h7D,0)     // ADC abs,x

`ADDR_zp_x_ind(8'h81)       `STA(8'h81)       // STA (zp,x)
`ADDR_zp(8'h84,`T0)         `STY(8'h84)       // STY zp
`ADDR_zp(8'h85,`T0)         `STA(8'h85)       // STA zp
`ADDR_zp(8'h86,`T0)         `STX(8'h86)       // STX zp
`ADDR_abs(8'h8C,`T0)        `STY(8'h8C)       // STY abs
`ADDR_abs(8'h8D,`T0)        `STA(8'h8D)       // STA abs
`ADDR_abs(8'h8E,`T0)        `STX(8'h8E)       // STX abs
`ADDR_zp_ind_y(8'h91)       `STA(8'h91)       // STA (zp),y
`ADDR_zp_x(8'h94,`T0)       `STY(8'h94)       // STY zp,x
`ADDR_zp_x(8'h95,`T0)       `STA(8'h95)       // STA zp,x
`ADDR_zp_y(8'h96)           `STX(8'h96)       // STX zp,y
`ADDR_abs_y(8'h99)          `STA(8'h99)       // STA abs,y
`ADDR_abs_x(8'h9D,`TNC,`T0) `STA(8'h9D)       // STA abs,x

                            `LDY(8'hA0,1)     // LDY #
`ADDR_zp_x_ind(8'hA1)       `LDA(8'hA1,0)     // LDA (zp,x)
                            `LDX(8'hA2,1)     // LDX #
                            `LDA(8'hA9,1)     // LDA #
`ADDR_zp(8'hA4,`T0)         `LDY(8'hA4,0)     // LDY zp
`ADDR_zp(8'hA5,`T0)         `LDA(8'hA5,0)     // LDA zp
`ADDR_zp(8'hA6,`T0)         `LDX(8'hA6,0)     // LDX zp
`ADDR_abs(8'hAC,`T0)        `LDY(8'hAC,0)     // LDY abs
`ADDR_abs(8'hAD,`T0)        `LDA(8'hAD,0)     // LDA abs
`ADDR_abs(8'hAE,`T0)        `LDX(8'hAE,0)     // LDX abs
`ADDR_zp_ind_y(8'hB1)       `LDA(8'hB1,0)     // LDA (zp),y
`ADDR_zp_x(8'hB4,`T0)       `LDY(8'hB4,0)     // LDY zp,x
`ADDR_zp_x(8'hB5,`T0)       `LDA(8'hB5,0)     // LDA zp,x
`ADDR_zp_y(8'hB6)           `LDX(8'hB6,0)     // LDX zp,y
`ADDR_abs_y(8'hB9)          `LDA(8'hB9,0)     // LDA abs,y
`ADDR_abs_x(8'hBC,`TNC,`T0) `LDY(8'hBC,0)     // LDY abs,x
`ADDR_abs_x(8'hBD,`TNC,`T0) `LDA(8'hBD,0)     // LDA abs,x
`ADDR_abs_y(8'hBE)          `LDX(8'hBE,0)     // LDX abs,y

                            `CPY(8'hC0,1)     // CPY #
`ADDR_zp_x_ind(8'hC1)       `CMP(8'hC1,0)     // CMP (zp,x)
`ADDR_zp(8'hC4,`T0)         `CPY(8'hC4,0)     // CPY zp
`ADDR_zp(8'hC5,`T0)         `CMP(8'hC5,0)     // CMP zp
                            `CMP(8'hC9,1)     // CMP #
`ADDR_abs(8'hCC,`T0)        `CPY(8'hCC,0)     // CPY abs
`ADDR_abs(8'hCD,`T0)        `CMP(8'hCD,0)     // CMP abs
`ADDR_zp_ind_y(8'hD1)       `CMP(8'hD1,0)     // CMP (zp),y
`ADDR_zp_x(8'hD5,`T0)       `CMP(8'hD5,0)     // CMP zp,x
`ADDR_abs_y(8'hD9)          `CMP(8'hD9,0)     // CMP abs,y
`ADDR_abs_x(8'hDD,`TNC,`T0) `CMP(8'hDD,0)     // CMP abs,x
                            `CPX(8'hE0,1)     // CPX #
`ADDR_zp(8'hE4,`T0)         `CPX(8'hE4,0)     // CPY zp
`ADDR_abs(8'hEC,`T0)        `CPX(8'hEC,0)     // CPX abs

`ADDR_zp_x_ind(8'hE1)       `SBC(8'hE1,0)     // SBC (zp,x)
`ADDR_zp(8'hE5,`T0)         `SBC(8'hE5,0)     // SBC zp
                            `SBC(8'hE9,1)     // SBC #
`ADDR_abs(8'hED,`T0)        `SBC(8'hED,0)     // SBC abs
`ADDR_zp_ind_y(8'hF1)       `SBC(8'hF1,0)     // SBC (zp),y
`ADDR_zp_x(8'hF5,`T0)       `SBC(8'hF5,0)     // SBC zp,x
`ADDR_abs_y(8'hF9)          `SBC(8'hF9,0)     // SBC abs,y
`ADDR_abs_x(8'hFD,`TNC,`T0) `SBC(8'hFD,0)     // SBC abs,x

                            `BRA(8'h10,`TBR) // BPL
                            `BRA(8'h30,`TBR) // BMI
                            `BRA(8'h50,`TBR) // BVC
                            `BRA(8'h70,`TBR) // BVS
                            `ifdef CMOS
                            `BRA(8'h80,`Tn)  // BRA
                            `endif
                            `BRA(8'h90,`TBR) // BCC
                            `BRA(8'hB0,`TBR) // BCS
                            `BRA(8'hD0,`TBR) // BNE
                            `BRA(8'hF0,`TBR) // BEQ

`ADDR_zp(8'h06,`Tn)         `ASL_MEM(8'h06, 3, 4)     // ASL zp
                            `ASL_A(8'h0A)             // ASL a
`ADDR_abs(8'h0E,`Tn)        `ASL_MEM(8'h0E, 4, 5)     // ASL abs
`ADDR_zp_x(8'h16,`Tn)       `ASL_MEM(8'h16, 4, 5)     // ASL zp,x
`ADDR_abs_x(8'h1E,`Tn,`Tn)  `ASL_MEM(8'h1E, 5, 6)     // ASL abs,x

`ADDR_zp(8'h26,`Tn)         `ROL_MEM(8'h26, 3, 4)     // ROL zp
                            `ROL_A(8'h2A)             // ROL a
`ADDR_abs(8'h2E,`Tn)        `ROL_MEM(8'h2E, 4, 5)     // ROL abs
`ADDR_zp_x(8'h36,`Tn)       `ROL_MEM(8'h36, 4, 5)     // ROL zp,x
`ADDR_abs_x(8'h3E,`Tn,`Tn)  `ROL_MEM(8'h3E, 5, 6)     // ROL abs,x

`ADDR_zp(8'h46,`Tn)         `LSR_MEM(8'h46, 3, 4)     // LSR zp
                            `LSR_A(8'h4A)             // LSR a
`ADDR_abs(8'h4E,`Tn)        `LSR_MEM(8'h4E, 4, 5)     // LSR abs
`ADDR_zp_x(8'h56,`Tn)       `LSR_MEM(8'h56, 4, 5)     // LSR zp,x
`ADDR_abs_x(8'h5E,`Tn,`Tn)  `LSR_MEM(8'h5E, 5, 6)     // LSR abs,x

`ADDR_zp(8'h66,`Tn)         `ROR_MEM(8'h66, 3, 4)     // ROR zp
                            `ROR_A(8'h6A)             // ROR a
`ADDR_abs(8'h6E,`Tn)        `ROR_MEM(8'h6E, 4, 5)     // ROR abs
`ADDR_zp_x(8'h76,`Tn)       `ROR_MEM(8'h76, 4, 5)     // ROR zp,x
`ADDR_abs_x(8'h7E,`Tn,`Tn)  `ROR_MEM(8'h7E, 5, 6)     // ROR abs,x

                            `FLAG_OP(8'h18, `FLAGS_C) // CLC
                            `FLAG_OP(8'h38, `FLAGS_C) // SEC
                            `FLAG_OP(8'h58, `FLAGS_I) // CLI
                            `FLAG_OP(8'h78, `FLAGS_I) // SEI
                            `FLAG_OP(8'hB8, `FLAGS_V) // CLV
                            `FLAG_OP(8'hD8, `FLAGS_D) // CLD
                            `FLAG_OP(8'hF8, `FLAGS_D) // SED

                            `Txx(8'h8A, `SB_X,  `LOAD_A, `FLAGS_DBZN)  // TXA
                            `Txx(8'h98, `SB_Y,  `LOAD_A, `FLAGS_DBZN)  // TYA
                            `Txx(8'h9A, `SB_X,  `LOAD_S, `none)        // TXS
                            `Txx(8'hA8, `SB_A,  `LOAD_Y, `FLAGS_DBZN)  // TAY
                            `Txx(8'hAA, `SB_A,  `LOAD_X, `FLAGS_DBZN)  // TAX
                            `Txx(8'hBA, `SB_S, `LOAD_X, `FLAGS_DBZN)  // TSX

                            `DEC_REG(8'h88, `SB_Y, `LOAD_Y) // DEY
                            `DEC_REG(8'hCA, `SB_X, `LOAD_X) // DEX
                            `INC_REG(8'hC8, `SB_Y, `LOAD_Y) // INY
                            `INC_REG(8'hE8, `SB_X, `LOAD_X) // INX

`ADDR_zp(8'hC6,`Tn)         `DEC_MEM(8'hC6, 3, 4)     // DEC zp
`ADDR_abs(8'hCE,`Tn)        `DEC_MEM(8'hCE, 4, 5)     // DEC abs
`ADDR_zp_x(8'hD6,`Tn)       `DEC_MEM(8'hD6, 4, 5)     // DEC zp,x
`ADDR_abs_x(8'hDE,`Tn,`Tn)  `DEC_MEM(8'hDE, 5, 6)     // DEC abs,x

`ADDR_zp(8'hE6,`Tn)         `INC_MEM(8'hE6, 3, 4)     // INC zp
`ADDR_abs(8'hEE,`Tn)        `INC_MEM(8'hEE, 4, 5)     // INC abs
`ADDR_zp_x(8'hF6,`Tn)       `INC_MEM(8'hF6, 4, 5)     // INC zp,x
`ADDR_abs_x(8'hFE,`Tn,`Tn)  `INC_MEM(8'hFE, 5, 6)     // INC abs,x

                            `PUSH(8'h08, `DB_P, `SB_FF)           // PHP
                            `PUSH(8'h48, `DB_A, `SB_FF)           // PHA
                            `PULL(8'h28, `none,   `FLAGS_DB)    // PLP
                            `PULL(8'h68, `LOAD_A, `FLAGS_DBZN)  // PLA

                            `JSR(8'h20)       // JSR
                            `RTS(8'h60)       // RTS
                            `RTI(8'h40)       // RTI
                            `JMP(8'h4C, 2)    // JMP abs
`ADDR_jmp_abs(8'h6C)        `JMP(8'h6C, 4)    // JMP (abs)

                            `NOP1(8'hEA)      // NOP

`ifdef CMOS
                            `PUSH(8'hDA, `DB_SB, `SB_X)           // PHX
                            `PUSH(8'h5A, `DB_SB, `SB_Y)           // PHY
                            `PULL(8'hFA, `LOAD_X, `FLAGS_DBZN)    // PLX
                            `PULL(8'h7A, `LOAD_Y, `FLAGS_DBZN)    // PLY
`endif
end

// microcode outputs wired to specific bits
assign tnext = mc_out[`TNEXT_BITS];
assign adh_sel= mc_out[`ADH_BITS];
assign adl_sel= mc_out[`ADL_BITS];
assign db_sel = mc_out[`DB_BITS];
assign sb_sel = mc_out[`SB_BITS];
assign alu_a = mc_out[`ALU_A_BITS];
assign alu_b = mc_out[`ALU_B_BITS];
assign alu_op = mc_out[`ALU_BITS];
assign alu_c = mc_out[`ALU_C_BITS];
assign load_a = mc_out[`LOAD_A_BITS];
assign load_x = mc_out[`LOAD_X_BITS];
assign load_y = mc_out[`LOAD_Y_BITS];
assign load_s = mc_out[`LOAD_S_BITS];
assign load_abh = mc_out[`LOAD_ABH_BITS];
assign load_abl = mc_out[`LOAD_ABL_BITS];
assign load_flags = mc_out[`LOAD_FLAGS_BITS];
assign write_cycle = mc_out[`WRITE_BITS];
assign pc_inc = mc_out[`PC_INC_BITS];
assign pchs_sel = mc_out[`PCHS_BITS];
assign pcls_sel = mc_out[`PCLS_BITS];

always @(posedge clk)
begin
  mc_out <= mc[{ir, t}];
  //$display("mc[%02x|%d] tn: %04x",ir,t,mc[{ir, t}][`TNEXT_BITS]);
end

endmodule