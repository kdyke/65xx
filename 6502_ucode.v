`include "6502_inc.vh"

(* keep_hierarchy = "yes" *) module microcode(
                input clk, 
                input ready, 
                input [7:0] ir, 
                input [2:0] t, 
                output mc_sync, 
                output [2:0] alua_sel,
                output [2:0] alub_sel,
                output [1:0] aluc_sel,
                output [1:0] dreg,
                output [1:0] dreg_do,
                output [1:0] areg,
                output [2:0] alu_sel,
                output [1:0] dbo_sel,
                output [1:0] ab_sel,
                output pc_inc, 
                output [1:0] pch_sel,
                output [1:0] pcl_sel,
                output [1:0] sp_incdec,
                output sph_sel,
                output spl_sel,
                output ab_inc,
                output [1:0] abh_sel,
                output abl_sel,
                output adh_sel,
                output adl_sel,
                output [2:0] load_reg, 
                output [3:0] load_flags,
                output [4:0] test_flags,
                output test_flag0,
                output word_z,
                output write);

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
   mc[i][`LOAD_REG_BITS] = `kLOAD_KILL;
   //$display("init %d",i);
end
// synthesis translate on

                                    `BRK(8'h00)       // BRK

                                    `FLAG_OP(8'h18, `FLAGS_C) // CLC
                                    `FLAG_OP(8'h38, `FLAGS_C) // SEC
                                    `FLAG_OP(8'h58, `FLAGS_I) // CLI
                                    `FLAG_OP2(8'h78, `FLAGS_I) // SEI
                                    `FLAG_OP(8'hB8, `FLAGS_V) // CLV
                                    `FLAG_OP(8'hD8, `FLAGS_D) // CLD
                                    `FLAG_OP(8'hF8, `FLAGS_D) // SED

                                    `Txx(8'h8A, `ASEL_DREG `DREG_X `LOAD_A `FLAGS_SBZN)   // TXA
                                    `Txx(8'h98, `ASEL_DREG `DREG_Y `LOAD_A `FLAGS_SBZN)   // TYA
                                    `Txx(8'h9A, `ASEL_DREG `DREG_X `SPL_ALU)              // TXS
                                    `Txx(8'hA8, `ASEL_DREG `DREG_A `LOAD_Y `FLAGS_SBZN)   // TAY
                                    `Txx(8'hAA, `ASEL_DREG `DREG_A `LOAD_X `FLAGS_SBZN)   // TAX
                                    `Txx(8'hBA, `ASEL_AREG `AREG_SPL `LOAD_X `FLAGS_SBZN) // TSX

`ADDR_zp_x_ind(8'h01)               `ORA(8'h01,5,|0)        // ORA (zp,x)
`ADDR_zp(8'h05)                     `ORA(8'h05,3,|0)        // ORA zp
                                    `ORA(8'h09,2,`PC_INC)   // ORA #
`ADDR_abs(8'h0D)                    `ORA(8'h0D,4,|0)        // ORA abs
`ADDR_zp_ind_y(8'h11)               `ORA(8'h11,5,|0)        // ORA (zp),y
`ADDR_zp_x(8'h15)                   `ORA(8'h15,3,|0)        // ORA zp,x
`ADDR_abs_y(8'h19)                  `ORA(8'h19,4,|0)        // ORA abs,y
`ADDR_abs_x(8'h1D)                  `ORA(8'h1D,4,|0)        // ORA abs,x

`ADDR_zp_x_ind(8'h21)               `AND(8'h21,5,|0)        // AND (zp,x)
`ADDR_zp(8'h25)                     `AND(8'h25,3,|0)        // AND zp
                                    `AND(8'h29,2,`PC_INC)   // AND #
`ADDR_abs(8'h2D)                    `AND(8'h2D,4,|0)        // AND abs
`ADDR_zp_ind_y(8'h31)               `AND(8'h31,5,|0)        // AND (zp),y
`ADDR_zp_x(8'h35)                   `AND(8'h35,3,|0)        // AND zp,x
`ADDR_abs_y(8'h39)                  `AND(8'h39,4,|0)        // AND abs,y
`ADDR_abs_x(8'h3D)                  `AND(8'h3D,4,|0)        // AND abs,x

`ADDR_zp_x_ind(8'h41)               `EOR(8'h41,5,|0)        // EOR (zp,x)
`ADDR_zp(8'h45)                     `EOR(8'h45,3,|0)        // EOR zp
                                    `EOR(8'h49,2,`PC_INC)   // EOR #
`ADDR_abs(8'h4D)                    `EOR(8'h4D,4,|0)        // EOR abs
`ADDR_zp_ind_y(8'h51)               `EOR(8'h51,5,|0)        // EOR (zp),y
`ADDR_zp_x(8'h55)                   `EOR(8'h55,3,|0)        // EOR zp,x
`ADDR_abs_y(8'h59)                  `EOR(8'h59,4,|0)        // EOR abs,y
`ADDR_abs_x(8'h5D)                  `EOR(8'h5D,4,|0)        // EOR abs,x

`ADDR_zp_x_ind(8'h61)               `ADC(8'h61,5,|0)        // ADC (zp,x)
`ADDR_zp(8'h65)                     `ADC(8'h65,3,|0)        // ADC zp
                                    `ADC(8'h69,2,`PC_INC)   // ADC #
`ADDR_abs(8'h6D)                    `ADC(8'h6D,4,|0)        // ADC abs
`ADDR_zp_ind_y(8'h71)               `ADC(8'h71,5,|0)        // ADC (zp),y
`ADDR_zp_x(8'h75)                   `ADC(8'h75,3,|0)        // ADC zp,x
`ADDR_abs_y(8'h79)                  `ADC(8'h79,4,|0)        // ADC abs,y
`ADDR_abs_x(8'h7D)                  `ADC(8'h7D,4,|0)        // ADC abs,x

`ADDR_zp_x_ind_w(8'h81,`DREG_DO_A)  `STx(8'h81,5)           // STA (zp,x)
`ADDR_zp_w(8'h84, `DREG_DO_Y)       `STx(8'h84,3)           // STY zp
`ADDR_zp_w(8'h85, `DREG_DO_A)       `STx(8'h85,3)           // STA zp
`ADDR_zp_w(8'h86, `DREG_DO_X)       `STx(8'h86,3)           // STX zp
`ADDR_abs_w(8'h8C, `DREG_DO_Y)      `STx(8'h8C,4)           // STY abs
`ADDR_abs_w(8'h8D, `DREG_DO_A)      `STx(8'h8D,4)           // STA abs
`ADDR_abs_w(8'h8E, `DREG_DO_X)      `STx(8'h8E,4)           // STX abs
`ADDR_zp_ind_y_w(8'h91, `DREG_DO_A) `STx(8'h91,5)           // STA (zp),y
`ADDR_zp_x_w(8'h94, `DREG_DO_Y)     `STx(8'h94,3)           // STY zp,x
`ADDR_zp_x_w(8'h95, `DREG_DO_A)     `STx(8'h95,3)           // STA zp,x
`ADDR_zp_y_w(8'h96, `DREG_DO_X)     `STx(8'h96,3)           // STX zp,y
`ADDR_abs_y_w(8'h99, `DREG_DO_A)    `STx(8'h99,4)           // STA abs,y
`ADDR_abs_x_w(8'h9D, `DREG_DO_A)    `STx(8'h9D,4)           // STA abs,x

                                    `LDY(8'hA0,2,`PC_INC)     // LDY #
`ADDR_zp_x_ind(8'hA1)               `LDA(8'hA1,5,|0)          // LDA (zp,x)
                                    `LDX(8'hA2,2,`PC_INC)     // LDX #
`ADDR_zp(8'hA4)                     `LDY(8'hA4,3,|0)          // LDY zp
`ADDR_zp(8'hA5)                     `LDA(8'hA5,3,|0)          // LDA zp
`ADDR_zp(8'hA6)                     `LDX(8'hA6,3,|0)          // LDX zp
                                    `LDA(8'hA9,2,`PC_INC)     // LDA #
`ADDR_abs(8'hAC)                    `LDY(8'hAC,4,|0)          // LDY abs
`ADDR_abs(8'hAD)                    `LDA(8'hAD,4,|0)          // LDA abs
`ADDR_abs(8'hAE)                    `LDX(8'hAE,4,|0)          // LDX abs
`ADDR_zp_ind_y(8'hB1)               `LDA(8'hB1,05,|0)         // LDA (zp),y
`ADDR_zp_x(8'hB4)                   `LDY(8'hB4,3,|0)          // LDY zp,x
`ADDR_zp_x(8'hB5)                   `LDA(8'hB5,3,|0)          // LDA zp,x
`ADDR_zp_y(8'hB6)                   `LDX(8'hB6,3,|0)          // LDX zp,y
`ADDR_abs_x(8'hBC)                  `LDY(8'hBC,4,|0)          // LDY abs,x
`ADDR_abs_y(8'hB9)                  `LDA(8'hB9,4,|0)          // LDA abs,y
`ADDR_abs_x(8'hBD)                  `LDA(8'hBD,4,|0)          // LDA abs,x
`ADDR_abs_y(8'hBE)                  `LDX(8'hBE,4,|0)          // LDA abs,x

                                    `CPY(8'hC0,2,`PC_INC)     // CPY #
`ADDR_zp_x_ind(8'hC1)               `CMP(8'hC1,5,|0)          // CMP (zp,x)
`ADDR_zp(8'hC4)                     `CPY(8'hC4,3,|0)          // CPY zp
`ADDR_zp(8'hC5)                     `CMP(8'hC5,3,|0)          // CMP zp
                                    `CMP(8'hC9,2,`PC_INC)     // CMP #
`ADDR_abs(8'hCC)                    `CPY(8'hCC,4,|0)          // CPY abs
`ADDR_abs(8'hCD)                    `CMP(8'hCD,4,|0)          // CMP abs
`ADDR_zp_ind_y(8'hD1)               `CMP(8'hD1,5,|0)          // CMP (zp),y
`ADDR_zp_x(8'hD5)                   `CMP(8'hD5,3,|0)          // CMP zp,x
`ADDR_abs_y(8'hD9)                  `CMP(8'hD9,4,|0)          // CMP abs,y
`ADDR_abs_x(8'hDD)                  `CMP(8'hDD,4,|0)          // CMP abs,x
                                    `CPX(8'hE0,2,`PC_INC)     // CPX #
`ADDR_zp(8'hE4)                     `CPX(8'hE4,3,|0)          // CPY zp
`ADDR_abs(8'hEC)                    `CPX(8'hEC,4,|0)          // CPX abs

`ADDR_zp_x_ind(8'hE1)               `SBC(8'hE1,5,|0)          // SBC (zp,x)
`ADDR_zp(8'hE5)                     `SBC(8'hE5,3,|0)          // SBC zp
                                    `SBC(8'hE9,2,`PC_INC)     // SBC #
`ADDR_abs(8'hED)                    `SBC(8'hED,4,|0)          // SBC abs
`ADDR_zp_ind_y(8'hF1)               `SBC(8'hF1,5,|0)          // SBC (zp),y
`ADDR_zp_x(8'hF5)                   `SBC(8'hF5,3,|0)          // SBC zp,x
`ADDR_abs_y(8'hF9)                  `SBC(8'hF9,4,|0)          // SBC abs,y
`ADDR_abs_x(8'hFD)                  `SBC(8'hFD,4,|0)          // SBC abs,x

`ADDR_zp(8'h24)                     `BIT(8'h24,3,`FLAGS_BIT)  // BIT zp
`ADDR_abs(8'h2C)                    `BIT(8'h2C,4,`FLAGS_BIT)  // BIT abs
                                  
                                    `BPL(8'h10) // BPL
                                    `BMI(8'h30) // BMI
                                    `BVC(8'h50) // BVC
                                    `BVS(8'h70) // BVS
                                    `BRA(8'h80) // BRA
                                    `BCC(8'h90) // BCC
                                    `BCS(8'hB0) // BCS
                                    `BNE(8'hD0) // BNE
                                    `BEQ(8'hF0) // BEQ
                                  
                                    `DEC_REG(8'h88, `ASEL_DREG `DREG_Y `LOAD_Y) // DEY
                                    `DEC_REG(8'hCA, `ASEL_DREG `DREG_X `LOAD_X) // DEX
                                  
                                    `INC_REG(8'hC8, `ASEL_DREG `DREG_Y `LOAD_Y) // INY
                                    `INC_REG(8'hE8, `ASEL_DREG `DREG_X `LOAD_X) // INX                                  
                                  
                                    `NOP(8'hEA)         // NOP/ENDM
                                    
                                    `PUSH(8'h08, `BSEL_P)           // PHP
                                    `PUSH(8'h48, `ASEL_DREG `DREG_A)           // PHA
                                    `PUSH(8'hDA, `ASEL_DREG `DREG_X)           // PHX
                                    `PUSH(8'h5A, `ASEL_DREG `DREG_Y)           // PHY
                                    
                                    `PULL(8'h28, `FLAGS_DB)                     // PLP
                                    `PULL(8'h68, `BSEL_DB `LOAD_A `FLAGS_SBZN)  // PLA
                                    `PULL(8'hFA, `BSEL_DB `LOAD_X `FLAGS_SBZN)  // PLX
                                    `PULL(8'h7A, `BSEL_DB `LOAD_Y `FLAGS_SBZN)  // PLY
                                    
                                    `JMP(8'h4C)         // JMP abs
                                    `JMPIND(8'h6C)      // JMP (abs)
                                    
                                    `JSR(8'h20)       // JSR
                                    `RTS(8'h60)       // RTS
                                    `RTI(8'h40)       // RTI
                                    
`ADDR_zp(8'h06)                     `ASL_MEM(8'h06, 3, `AB_ABn)     // ASL zp
                                    `ASL_A(8'h0A)                   // ASL a
`ADDR_abs(8'h0E)                    `ASL_MEM(8'h0E, 4, `AB_ABn)     // ASL abs
`ADDR_zp_x(8'h16)                   `ASL_MEM(8'h16, 3, `AB_ABn)     // ASL zp,x
`ADDR_abs_x(8'h1E)                  `ASL_MEM(8'h1E, 4, `AB_ABn)     // ASL abs,x
                                    
`ADDR_zp(8'h26)                     `ROL_MEM(8'h26, 3, `AB_ABn)     // ROL zp
                                    `ROL_A(8'h2A)                   // ROL a
`ADDR_abs(8'h2E)                    `ROL_MEM(8'h2E, 4, `AB_ABn)     // ROL abs
`ADDR_zp_x(8'h36)                   `ROL_MEM(8'h36, 3, `AB_ABn)     // ROL zp,x
`ADDR_abs_x(8'h3E)                  `ROL_MEM(8'h3E, 4, `AB_ABn)     // ROL abs,x
                                    
`ADDR_zp(8'h46)                     `LSR_MEM(8'h46, 3, `AB_ABn)     // LSR zp
                                    `LSR_A(8'h4A)                   // LSR a
`ADDR_abs(8'h4E)                    `LSR_MEM(8'h4E, 4, `AB_ABn)     // LSR abs
`ADDR_zp_x(8'h56)                   `LSR_MEM(8'h56, 3, `AB_ABn)     // LSR zp,x
`ADDR_abs_x(8'h5E)                  `LSR_MEM(8'h5E, 4, `AB_ABn)     // LSR abs,x
                                    
`ADDR_zp(8'h66)                     `ROR_MEM(8'h66, 3, `AB_ABn)     // ROR zp
                                    `ROR_A(8'h6A)                   // ROR a
`ADDR_abs(8'h6E)                    `ROR_MEM(8'h6E, 4, `AB_ABn)     // ROR abs
`ADDR_zp_x(8'h76)                   `ROR_MEM(8'h76, 3, `AB_ABn)     // ROR zp,x
`ADDR_abs_x(8'h7E)                  `ROR_MEM(8'h7E, 4, `AB_ABn)     // ROR abs,x
                                    
`ADDR_zp(8'hC6)                     `DEC_MEM(8'hC6, 3, `AB_ABn)     // DEC zp
`ADDR_abs(8'hCE)                    `DEC_MEM(8'hCE, 4, `AB_ABn)     // DEC abs
`ADDR_zp_x(8'hD6)                   `DEC_MEM(8'hD6, 3, `AB_ABn)     // DEC zp,x
`ADDR_abs_x(8'hDE)                  `DEC_MEM(8'hDE, 4, `AB_ABn)     // DEC abs,x
                                    
`ADDR_zp(8'hE6)                     `INC_MEM(8'hE6, 3, `AB_ABn)     // INC zp
`ADDR_abs(8'hEE)                    `INC_MEM(8'hEE, 4, `AB_ABn)     // INC abs
`ADDR_zp_x(8'hF6)                   `INC_MEM(8'hF6, 3, `AB_ABn)     // INC zp,x
`ADDR_abs_x(8'hFE)                  `INC_MEM(8'hFE, 4, `AB_ABn)     // INC abs,x

`ifdef NOTDEFINED

                            // "Standard" CMOS Extensions
`ifdef CMOS
                            
`ADDR_jmp_abs_x(8'h7C)      `JMP(8'h7C, 5)    // JMP (abs,x)
                            
                            `DEC_REG(8'h3A, `SB_A, `LOAD_A) // DEC
                            `INC_REG(8'h1A, `SB_A, `LOAD_A) // INC
                            
                            // (zp)
`ADDR_zp_ind(8'h12)         `ORA(8'h12,0)
`ADDR_zp_ind(8'h32)         `AND(8'h32,0)
`ADDR_zp_ind(8'h52)         `EOR(8'h52,0)
`ADDR_zp_ind(8'h72)         `ADC(8'h72,0)
`ADDR_zp_ind_w(8'h92, `DB_SB, `SB_A)         `STx(8'h92)
`ADDR_zp_ind(8'hB2)         `LDA(8'hB2,0)
`ADDR_zp_ind(8'hD2)         `CMP(8'hD2,0)
`ADDR_zp_ind(8'hF2)         `SBC(8'hF2,0)

                            // STZ
`ADDR_zp_w(8'h64,`T0, `DB_0, `SB_FF)         `STx(8'h64)       // STZ zp
`ADDR_zp_x_w(8'h74,`T0, `DB_0, `SB_FF)       `STx(8'h74)       // STZ zp,x
`ADDR_abs_w(8'h9C,`T0, `DB_0, `SB_FF)        `STx(8'h9C)       // STZ abs
`ADDR_abs_x_w(8'h9E,`TNC,`T0, `DB_0, `SB_FF) `STx(8'h9E)       // STZ abs,x

                            `BIT(8'h89, `none, 1)           // BIT #
`ADDR_zp_x(8'h34,`T0)       `BIT(8'h34,`FLAGS_BIT, 0)       // BIT zp,x
`ADDR_abs_x(8'h3C,`TNC,`T0) `BIT(8'h3C,`FLAGS_BIT, 0)       // BIT abs,x

`ADDR_zp(8'h14,`Tn)         `TRB(8'h14, 3, 4)     // TRB zp
`ADDR_abs(8'h1C,`Tn)        `TRB(8'h1C, 4, 5)     // TRB abs

`ADDR_zp(8'h04,`Tn)         `TSB(8'h04, 3, 4)     // TSB zp
`ADDR_abs(8'h0C,`Tn)        `TSB(8'h0C, 4, 5)     // TSB abs

                            // WDC65C02 and Rockwell extensions
`ADDR_zp(8'h07,`Tn)         `RMB(8'h07, 3, 4)     // RMB0 zp
`ADDR_zp(8'h17,`Tn)         `RMB(8'h17, 3, 4)     // RMB1 zp
`ADDR_zp(8'h27,`Tn)         `RMB(8'h27, 3, 4)     // RMB2 zp
`ADDR_zp(8'h37,`Tn)         `RMB(8'h37, 3, 4)     // RMB3 zp
`ADDR_zp(8'h47,`Tn)         `RMB(8'h47, 3, 4)     // RMB4 zp
`ADDR_zp(8'h57,`Tn)         `RMB(8'h57, 3, 4)     // RMB5 zp
`ADDR_zp(8'h67,`Tn)         `RMB(8'h67, 3, 4)     // RMB6 zp
`ADDR_zp(8'h77,`Tn)         `RMB(8'h77, 3, 4)     // RMB7 zp

`ADDR_zp(8'h87,`Tn)         `SMB(8'h87, 3, 4)     // SMB0 zp
`ADDR_zp(8'h97,`Tn)         `SMB(8'h97, 3, 4)     // SMB1 zp
`ADDR_zp(8'hA7,`Tn)         `SMB(8'hA7, 3, 4)     // SMB2 zp
`ADDR_zp(8'hB7,`Tn)         `SMB(8'hB7, 3, 4)     // SMB3 zp
`ADDR_zp(8'hC7,`Tn)         `SMB(8'hC7, 3, 4)     // SMB4 zp
`ADDR_zp(8'hD7,`Tn)         `SMB(8'hD7, 3, 4)     // SMB5 zp
`ADDR_zp(8'hE7,`Tn)         `SMB(8'hE7, 3, 4)     // SMB6 zp
`ADDR_zp(8'hF7,`Tn)         `SMB(8'hF7, 3, 4)     // SMB7 zp

                            `BBR(8'h0F)   // BBR 0
                            `BBR(8'h1F)   // BBR 0
                            `BBR(8'h2F)   // BBR 0
                            `BBR(8'h3F)   // BBR 0
                            `BBR(8'h4F)   // BBR 0
                            `BBR(8'h5F)   // BBR 0
                            `BBR(8'h6F)   // BBR 0
                            `BBR(8'h7F)   // BBR 0
                            `BBS(8'h8F)   // BBR 0
                            `BBS(8'h9F)   // BBR 0
                            `BBS(8'hAF)   // BBR 0
                            `BBS(8'hBF)   // BBR 0
                            `BBS(8'hCF)   // BBR 0
                            `BBS(8'hDF)   // BBR 0
                            `BBS(8'hEF)   // BBR 0
                            `BBS(8'hFF)   // BBR 0

                            // Various flavors of CMOS NOPs
                            `NOP2_2(8'h02)
                            `NOP2_2(8'h22)
                            `NOP2_2(8'h42)
                            `NOP2_2(8'h62)
                            `NOP2_2(8'h82)
                            `NOP2_2(8'hC2)
                            `NOP2_2(8'hE2)

                            `NOP2_3(8'h44)
                            `NOP2_4(8'h54)
                            `NOP2_4(8'hD4)
                            `NOP2_4(8'hF4)
                            
                            `NOP1_1(8'h03)
                            `NOP1_1(8'h13)
                            `NOP1_1(8'h23)
                            `NOP1_1(8'h33)
                            `NOP1_1(8'h43)
                            `NOP1_1(8'h53)
                            `NOP1_1(8'h63)
                            `NOP1_1(8'h73)
                            `NOP1_1(8'h83)
                            `NOP1_1(8'h93)
                            `NOP1_1(8'hA3)
                            `NOP1_1(8'hB3)
                            `NOP1_1(8'hC3)
                            `NOP1_1(8'hD3)
                            `NOP1_1(8'hE3)
                            `NOP1_1(8'hF3)

                            `NOP1_1(8'h0B)
                            `NOP1_1(8'h1B)
                            `NOP1_1(8'h2B)
                            `NOP1_1(8'h3B)
                            `NOP1_1(8'h4B)
                            `NOP1_1(8'h5B)
                            `NOP1_1(8'h6B)
                            `NOP1_1(8'h7B)
                            `NOP1_1(8'h8B)
                            `NOP1_1(8'h9B)
                            `NOP1_1(8'hAB)
                            `NOP1_1(8'hBB)
                            `NOP1_1(8'hCB)
                            `NOP1_1(8'hDB)
                            `NOP1_1(8'hEB)
                            `NOP1_1(8'hFB)
                            
                            `NOP3_8(8'h5C)
                            `NOP3_4(8'hDC)
                            `NOP3_4(8'hFC)
                            
`endif
`endif

end

// microcode outputs wired to specific bits
assign mc_sync   = mc_out[`SYNC_BITS];
assign alua_sel  = mc_out[`ASEL_BITS];
assign alub_sel  = mc_out[`BSEL_BITS];
assign aluc_sel  = mc_out[`CSEL_BITS];
assign dreg      = mc_out[`DREG_BITS];
assign dreg_do   = mc_out[`DREG_DO_BITS];
assign areg      = mc_out[`AREG_BITS];
assign alu_sel   = mc_out[`ALU_BITS];
assign dbo_sel   = mc_out[`DBO_BITS];
assign ab_sel    = mc_out[`AB_BITS];
assign pc_inc    = mc_out[`PC_INC_BITS];
assign pch_sel   = mc_out[`PCH_BITS];
assign pcl_sel   = mc_out[`PCL_BITS];
assign sp_incdec = mc_out[`SP_CNT_BITS];
assign sph_sel   = mc_out[`SPH_SEL_BITS];
assign spl_sel   = mc_out[`SPL_SEL_BITS];
assign ab_inc    = mc_out[`AB_INC_BITS];
assign abh_sel   = mc_out[`ABH_SEL_BITS];
assign abl_sel   = mc_out[`ABL_SEL_BITS];
assign adh_sel   = mc_out[`ADH_SEL_BITS];
assign adl_sel   = mc_out[`ADL_SEL_BITS];
assign load_reg  = mc_out[`LOAD_REG_BITS];
assign load_flags = mc_out[`LOAD_FLAGS_BITS];
assign word_z     = mc_out[`WORD_Z_BITS];
assign write      = mc_out[`WRITE_BITS];
assign test_flags = mc_out[`TEST_FLAGS_BITS];
assign test_flag0 = mc_out[`TEST_FLAG0_BITS];

always @(posedge clk)
begin
  //$display("mc[%02x|%d] sync: %01d alu: %03b bits: %051b",ir,t,mc[{ir, t}][`SYNC_BITS],mc[{ir, t}][`ALU_BITS],mc[{ir, t}]);
  if(ready)
  begin
    mc_out <= mc[{ir, t}];
    if(mc[{ir, t}][`LOAD_REG_BITS] == `kLOAD_KILL)
    begin
      $display("unimplemented microcode insn: %02x cycle: %d",ir,t);
      $finish;
    end
  end
//  if(write == 1)
//  begin
//      $display("mc write!");
//        $finish;
//  end
end

endmodule