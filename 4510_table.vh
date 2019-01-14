  // Primary and secondary (if required) microcode addresses for all 256 4510 opcodes
  `A0_A1_ADDR_4510(8'h00, kMCA_e_brk0               , 8'hFF                 ) // 00 BRK
  `A0_A1_ADDR_4510(8'h01, kMCA_e_addr_r_zpxind0     , kMCA_e_ora            ) // 01 ORA (zp,x)
  `A0_A1_ADDR_4510(8'h02, kMCA_e_clesee0            , 8'hFF                 ) // 02 CLE 
  `A0_A1_ADDR_4510(8'h03, kMCA_e_clesee0            , 8'hFF                 ) // 03 SEE 
  `A0_A1_ADDR_4510(8'h04, kMCA_e_addr_r_zp0         , kMCA_e_tsb0           ) // 04 TSB zp
  `A0_A1_ADDR_4510(8'h05, kMCA_e_addr_r_zp0         , kMCA_e_ora            ) // 05 ORA zp
  `A0_A1_ADDR_4510(8'h06, kMCA_e_addr_r_zp0         , kMCA_e_asl_mem0       ) // 06 ASL zp
  `A0_A1_ADDR_4510(8'h07, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 07 RMB0 zp
  `A0_A1_ADDR_4510(8'h08, kMCA_e_push_p             , 8'hFF                 ) // 08 PHP
  `A0_A1_ADDR_4510(8'h09, kMCA_e_orai               , 8'hFF                 ) // 09 ORA #
  `A0_A1_ADDR_4510(8'h0A, kMCA_e_asl_a              , 8'hFF                 ) // 0A ASL
  `A0_A1_ADDR_4510(8'h0B, kMCA_e_tsy0               , 8'hFF                 ) // 0B TSY
  `A0_A1_ADDR_4510(8'h0C, kMCA_e_addr_r_abs0        , kMCA_e_tsb0           ) // 0C TSB abs
  `A0_A1_ADDR_4510(8'h0D, kMCA_e_addr_r_abs0        , kMCA_e_ora            ) // 0D ORA abs
  `A0_A1_ADDR_4510(8'h0E, kMCA_e_addr_r_abs0        , kMCA_e_asl_mem0       ) // 0E ASL abs
  `A0_A1_ADDR_4510(8'h0F, kMCA_e_bbr0               , 8'hFF                 ) // 0F BBR0 zp
                                                                      
  `A0_A1_ADDR_4510(8'h10, kMCA_e_bc0                , 8'hFF                 ) // 10 BPL rel
  `A0_A1_ADDR_4510(8'h11, kMCA_e_addr_r_zpindy0     , kMCA_e_ora            ) // 11 ORA (zp),y
  `A0_A1_ADDR_4510(8'h12, kMCA_e_addr_r_zpindz0     , kMCA_e_ora            ) // 12 ORA (zp),z
  `A0_A1_ADDR_4510(8'h13, kMCA_e_braw0              , kMCA_e_bcw1           ) // 13 BPL wrel
  `A0_A1_ADDR_4510(8'h14, kMCA_e_addr_r_zp0         , kMCA_e_trb0           ) // 14 TRB zp
  `A0_A1_ADDR_4510(8'h15, kMCA_e_addr_r_zpx0        , kMCA_e_ora            ) // 15 ORA zp,x
  `A0_A1_ADDR_4510(8'h16, kMCA_e_addr_r_zpx0        , kMCA_e_asl_mem0       ) // 16 ASL zp,x
  `A0_A1_ADDR_4510(8'h17, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 17 RMB1 zp
  `A0_A1_ADDR_4510(8'h18, kMCA_e_clcsec0            , 8'hFF                 ) // 18 CLC
  `A0_A1_ADDR_4510(8'h19, kMCA_e_addr_r_absy0       , kMCA_e_ora            ) // 19 ORA abs,y
  `A0_A1_ADDR_4510(8'h1A, kMCA_e_inca               , 8'hFF                 ) // 1A INC
  `A0_A1_ADDR_4510(8'h1B, kMCA_e_incz               , 8'hFF                 ) // 1B INZ
  `A0_A1_ADDR_4510(8'h1C, kMCA_e_addr_r_abs0        , kMCA_e_trb0           ) // 1C TRB abs
  `A0_A1_ADDR_4510(8'h1D, kMCA_e_addr_r_absx0       , kMCA_e_ora            ) // 1D ORA abs,x
  `A0_A1_ADDR_4510(8'h1E, kMCA_e_addr_r_absx0       , kMCA_e_asl_mem0       ) // 1E ASL abs,x
  `A0_A1_ADDR_4510(8'h1F, kMCA_e_bbr0               , 8'hFF                 ) // 1F BBR1 zp
                                                                      
  `A0_A1_ADDR_4510(8'h20, kMCA_e_jsr0               , 8'hFF                 ) // 20 JSR abs
  `A0_A1_ADDR_4510(8'h21, kMCA_e_addr_r_zpxind0     , kMCA_e_and            ) // 21 AND (zp,x)
  `A0_A1_ADDR_4510(8'h22, kMCA_e_jsrind0            , 8'hFF                 ) // 22 JSR (ind)
  `A0_A1_ADDR_4510(8'h23, kMCA_e_jsrindx0           , 8'hFF                 ) // 23 JSR (ind,x)
  `A0_A1_ADDR_4510(8'h24, kMCA_e_addr_r_zp0         , kMCA_e_bitm0          ) // 24 BIT zp
  `A0_A1_ADDR_4510(8'h25, kMCA_e_addr_r_zp0         , kMCA_e_and            ) // 25 AND zp
  `A0_A1_ADDR_4510(8'h26, kMCA_e_addr_r_zp0         , kMCA_e_rol_mem0       ) // 26 ROL zp
  `A0_A1_ADDR_4510(8'h27, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 27 RMB2 zp
  `A0_A1_ADDR_4510(8'h28, kMCA_e_pull0              , kMCA_e_pull_p         ) // 28 PLP
  `A0_A1_ADDR_4510(8'h29, kMCA_e_andi               , 8'hFF                 ) // 29 AND #
  `A0_A1_ADDR_4510(8'h2A, kMCA_e_rol_a              , 8'hFF                 ) // 2A ROL
  `A0_A1_ADDR_4510(8'h2B, kMCA_e_tys0               , 8'hFF                 ) // 2B TYS
  `A0_A1_ADDR_4510(8'h2C, kMCA_e_addr_r_abs0        , kMCA_e_bitm0          ) // 2C BIT abs
  `A0_A1_ADDR_4510(8'h2D, kMCA_e_addr_r_abs0        , kMCA_e_and            ) // 2D AND abs
  `A0_A1_ADDR_4510(8'h2E, kMCA_e_addr_r_abs0        , kMCA_e_rol_mem0       ) // 2E ROL abs
  `A0_A1_ADDR_4510(8'h2F, kMCA_e_bbr0               , 8'hFF                 ) // 2F BBR2 zp
                                                                      
  `A0_A1_ADDR_4510(8'h30, kMCA_e_bc0                , 8'hFF                 ) // 30 BMI rel
  `A0_A1_ADDR_4510(8'h31, kMCA_e_addr_r_zpindy0     , kMCA_e_and            ) // 31 AND (zp),y
  `A0_A1_ADDR_4510(8'h32, kMCA_e_addr_r_zpindz0     , kMCA_e_and            ) // 32 AND (zp),z
  `A0_A1_ADDR_4510(8'h33, kMCA_e_braw0              , kMCA_e_bcw1           ) // 33 BMI wrel
  `A0_A1_ADDR_4510(8'h34, kMCA_e_addr_r_zpx0        , kMCA_e_bitm0          ) // 34 BIT zp,x
  `A0_A1_ADDR_4510(8'h35, kMCA_e_addr_r_zpx0        , kMCA_e_and            ) // 35 AND zp,x
  `A0_A1_ADDR_4510(8'h36, kMCA_e_addr_r_zpx0        , kMCA_e_rol_mem0       ) // 36 ROL zp,x
  `A0_A1_ADDR_4510(8'h37, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 37 RMB3 zp
  `A0_A1_ADDR_4510(8'h38, kMCA_e_clcsec0            , 8'hFF                 ) // 38 SEC
  `A0_A1_ADDR_4510(8'h39, kMCA_e_addr_r_absy0       , kMCA_e_and            ) // 39 AND abs,y
  `A0_A1_ADDR_4510(8'h3A, kMCA_e_deca               , 8'hFF                 ) // 3A DEC
  `A0_A1_ADDR_4510(8'h3B, kMCA_e_decz               , 8'hFF                 ) // 3B DEZ
  `A0_A1_ADDR_4510(8'h3C, kMCA_e_addr_r_absx0       , kMCA_e_bitm0          ) // 3C BIT abs,x
  `A0_A1_ADDR_4510(8'h3D, kMCA_e_addr_r_absx0       , kMCA_e_and            ) // 3D AND abs,x
  `A0_A1_ADDR_4510(8'h3E, kMCA_e_addr_r_absx0       , kMCA_e_rol_mem0       ) // 3E ROL abs,x
  `A0_A1_ADDR_4510(8'h3F, kMCA_e_bbr0               , 8'hFF                 ) // 3F BBR3 zp
                                                                      
  `A0_A1_ADDR_4510(8'h40, kMCA_e_rti0               , 8'hFF                 ) // 40 RTI
  `A0_A1_ADDR_4510(8'h41, kMCA_e_addr_r_zpxind0     , kMCA_e_eor            ) // 41 EOR (zp,x)
  `A0_A1_ADDR_4510(8'h42, kMCA_e_neg                , 8'hFF                 ) // 42 NEG
  `A0_A1_ADDR_4510(8'h43, kMCA_e_asr_a              , 8'hFF                 ) // 43 ASR
  `A0_A1_ADDR_4510(8'h44, kMCA_e_addr_r_zp0         , kMCA_e_asr_mem0       ) // 44 ASR zp
  `A0_A1_ADDR_4510(8'h45, kMCA_e_addr_r_zp0         , kMCA_e_eor            ) // 45 EOR zp
  `A0_A1_ADDR_4510(8'h46, kMCA_e_addr_r_zp0         , kMCA_e_lsr_mem0       ) // 46 LSR zp
  `A0_A1_ADDR_4510(8'h47, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 47 RMB4 zp
  `A0_A1_ADDR_4510(8'h48, kMCA_e_push_a             , 8'hFF                 ) // 48 PHA
  `A0_A1_ADDR_4510(8'h49, kMCA_e_eori               , 8'hFF                 ) // 49 EOR #
  `A0_A1_ADDR_4510(8'h4A, kMCA_e_lsr_a              , 8'hFF                 ) // 4A LSR
  `A0_A1_ADDR_4510(8'h4B, kMCA_e_taz0               , 8'hFF                 ) // 4B TAZ
  `A0_A1_ADDR_4510(8'h4C, kMCA_e_jmp0               , 8'hFF                 ) // 4C JMP abs
  `A0_A1_ADDR_4510(8'h4D, kMCA_e_addr_r_abs0        , kMCA_e_eor            ) // 4D EOR abs
  `A0_A1_ADDR_4510(8'h4E, kMCA_e_addr_r_abs0        , kMCA_e_lsr_mem0       ) // 4E LSR abs
  `A0_A1_ADDR_4510(8'h4F, kMCA_e_bbr0               , 8'hFF                 ) // 4F BBR4 zp
                                                                      
  `A0_A1_ADDR_4510(8'h50, kMCA_e_bc0                , 8'hFF                 ) // 50 BVC rel
  `A0_A1_ADDR_4510(8'h51, kMCA_e_addr_r_zpindy0     , kMCA_e_eor            ) // 51 EOR (zp),y
  `A0_A1_ADDR_4510(8'h52, kMCA_e_addr_r_zpindz0     , kMCA_e_eor            ) // 52 EOR (zp),z
  `A0_A1_ADDR_4510(8'h53, kMCA_e_braw0              , kMCA_e_bcw1           ) // 53 BVC wrel
  `A0_A1_ADDR_4510(8'h54, kMCA_e_addr_r_zpx0        , kMCA_e_asr_mem0       ) // 54 ASR zp,x
  `A0_A1_ADDR_4510(8'h55, kMCA_e_addr_r_zpx0        , kMCA_e_eor            ) // 55 EOR zp,x
  `A0_A1_ADDR_4510(8'h56, kMCA_e_addr_r_zpx0        , kMCA_e_lsr_mem0       ) // 56 LSR zp,x
  `A0_A1_ADDR_4510(8'h57, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 57 RMB5 zp
  `A0_A1_ADDR_4510(8'h58, kMCA_e_cli0               , 8'hFF                 ) // 58 CLI
  `A0_A1_ADDR_4510(8'h59, kMCA_e_addr_r_absy0       , kMCA_e_eor            ) // 59 EOR abs,y
  `A0_A1_ADDR_4510(8'h5A, kMCA_e_push_y             , 8'hFF                 ) // 5A PHY
  `A0_A1_ADDR_4510(8'h5B, kMCA_e_tab0               , 8'hFF                 ) // 5B TAB
  `A0_A1_ADDR_4510(8'h5C, kMCA_e_map0               , 8'hFF                 ) // 5C MAP
  `A0_A1_ADDR_4510(8'h5D, kMCA_e_addr_r_absx0       , kMCA_e_eor            ) // 5D EOR abs,x
  `A0_A1_ADDR_4510(8'h5E, kMCA_e_addr_r_absx0       , kMCA_e_lsr_mem0       ) // 5E LSR abs,x
  `A0_A1_ADDR_4510(8'h5F, kMCA_e_bbr0               , 8'hFF                 ) // 5F BBR5 zp
                                                                      
  `A0_A1_ADDR_4510(8'h60, kMCA_e_rts0               , 8'hFF                 ) // 60 RTS
  `A0_A1_ADDR_4510(8'h61, kMCA_e_addr_r_zpxind0     , kMCA_e_adc            ) // 61 ADC (zp,x)
  `A0_A1_ADDR_4510(8'h62, kMCA_e_rtn0               , 8'hFF                 ) // 62 RTN imm
  `A0_A1_ADDR_4510(8'h63, kMCA_e_bsr0               , 8'hFF                 ) // 63 BSR
  `A0_A1_ADDR_4510(8'h64, kMCA_e_addr_w_zp0_z       , 8'hFF                 ) // 64 STZ zp
  `A0_A1_ADDR_4510(8'h65, kMCA_e_addr_r_zp0         , kMCA_e_adc            ) // 65 ADC zp
  `A0_A1_ADDR_4510(8'h66, kMCA_e_addr_r_zp0         , kMCA_e_ror_mem0       ) // 66 ROR zp
  `A0_A1_ADDR_4510(8'h67, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 67 RMB6 zp
  `A0_A1_ADDR_4510(8'h68, kMCA_e_pull0              , kMCA_e_lda            ) // 68 PLA
  `A0_A1_ADDR_4510(8'h69, kMCA_e_adci               , 8'hFF                 ) // 69 ADC #
  `A0_A1_ADDR_4510(8'h6A, kMCA_e_ror_a              , 8'hFF                 ) // 6A ROR
  `A0_A1_ADDR_4510(8'h6B, kMCA_e_tza0               , 8'hFF                 ) // 6B TZA
  `A0_A1_ADDR_4510(8'h6C, kMCA_e_jmpind0            , 8'hFF                 ) // 69 JMP (ind)
  `A0_A1_ADDR_4510(8'h6D, kMCA_e_addr_r_abs0        , kMCA_e_adc            ) // 6D ADC abs
  `A0_A1_ADDR_4510(8'h6E, kMCA_e_addr_r_abs0        , kMCA_e_ror_mem0       ) // 6E ROR abs
  `A0_A1_ADDR_4510(8'h6F, kMCA_e_bbr0               , 8'hFF                 ) // 6F BBR6 zp
                                                                      
  `A0_A1_ADDR_4510(8'h70, kMCA_e_bc0                , 8'hFF                 ) // 70 BVS rel
  `A0_A1_ADDR_4510(8'h71, kMCA_e_addr_r_zpindy0     , kMCA_e_adc            ) // 71 ADC (zp),y
  `A0_A1_ADDR_4510(8'h72, kMCA_e_addr_r_zpindz0     , kMCA_e_adc            ) // 72 ADC (zp),z
  `A0_A1_ADDR_4510(8'h73, kMCA_e_braw0              , kMCA_e_bcw1           ) // 73 BVS wrel
  `A0_A1_ADDR_4510(8'h74, kMCA_e_addr_w_zpx0_z      , 8'hFF                 ) // 74 STZ zp,x
  `A0_A1_ADDR_4510(8'h75, kMCA_e_addr_r_zpx0        , kMCA_e_adc            ) // 75 ADC zp,x
  `A0_A1_ADDR_4510(8'h76, kMCA_e_addr_r_zpx0        , kMCA_e_ror_mem0       ) // 76 ROR zp,x
  `A0_A1_ADDR_4510(8'h77, kMCA_e_addr_r_zp0         , kMCA_e_rmb0           ) // 77 RMB7 zp
  `A0_A1_ADDR_4510(8'h78, kMCA_e_sei0               , 8'hFF                 ) // 78 SEI               // Always 2 cycles
  `A0_A1_ADDR_4510(8'h79, kMCA_e_addr_r_absy0       , kMCA_e_adc            ) // 79 ADC abs,y
  `A0_A1_ADDR_4510(8'h7A, kMCA_e_pull0              , kMCA_e_ldy            ) // 7A PLY
  `A0_A1_ADDR_4510(8'h7B, kMCA_e_tba0               , 8'hFF                 ) // 7B TBA
  `A0_A1_ADDR_4510(8'h7C, kMCA_e_jmpindx0           , 8'hFF                 ) // 7C JMP (ind,x)
  `A0_A1_ADDR_4510(8'h7D, kMCA_e_addr_r_absx0       , kMCA_e_adc            ) // 7D ADC abs,x
  `A0_A1_ADDR_4510(8'h7E, kMCA_e_addr_r_absx0       , kMCA_e_ror_mem0       ) // 7E ROR abs,x
  `A0_A1_ADDR_4510(8'h7F, kMCA_e_bbr0               , 8'hFF                 ) // 7F BBR7 zp
                                                                      
  `A0_A1_ADDR_4510(8'h80, kMCA_e_bra                , 8'hFF                 ) // 80 BRA rel
  `A0_A1_ADDR_4510(8'h81, kMCA_e_addr_w_zpxind0     , 8'hFF                 ) // 81 STA (zp,x)
  `A0_A1_ADDR_4510(8'h82, kMCA_e_addr_spind0        , kMCA_e_addr_w_zpindy2 ) // 82 STA (d,SP),Y
  `A0_A1_ADDR_4510(8'h83, kMCA_e_braw0              , kMCA_e_braw1          ) // 83 BRA wrel
  `A0_A1_ADDR_4510(8'h84, kMCA_e_addr_w_zp0_y       , 8'hFF                 ) // 84 STZ zp
  `A0_A1_ADDR_4510(8'h85, kMCA_e_addr_w_zp0_a       , 8'hFF                 ) // 85 STA zp
  `A0_A1_ADDR_4510(8'h86, kMCA_e_addr_w_zp0_x       , 8'hFF                 ) // 86 STX zp
  `A0_A1_ADDR_4510(8'h87, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // 87 SMB0 zp
  `A0_A1_ADDR_4510(8'h88, kMCA_e_decy               , 8'hFF                 ) // 88 DEY
  `A0_A1_ADDR_4510(8'h89, kMCA_e_biti               , 8'hFF                 ) // 89 BIT #
  `A0_A1_ADDR_4510(8'h8A, kMCA_e_txa0               , 8'hFF                 ) // 8A TXA
  `A0_A1_ADDR_4510(8'h8B, kMCA_e_addr_w_absx0       , kMCA_e_addr_w_absx1_y ) // 8B STY abs,x
  `A0_A1_ADDR_4510(8'h8C, kMCA_e_addr_w_abs0        , kMCA_e_addr_w_abs1_y  ) // 8C STY abs
  `A0_A1_ADDR_4510(8'h8D, kMCA_e_addr_w_abs0        , kMCA_e_addr_w_abs1_a  ) // 8D STA abs
  `A0_A1_ADDR_4510(8'h8E, kMCA_e_addr_w_abs0        , kMCA_e_addr_w_abs1_x  ) // 8E STX abs
  `A0_A1_ADDR_4510(8'h8F, kMCA_e_bbs0               , 8'hFF                 ) // 8F BBS0 zp
  
  `A0_A1_ADDR_4510(8'h90, kMCA_e_bc0                , 8'hFF                 ) // 90 BCC rel
  `A0_A1_ADDR_4510(8'h91, kMCA_e_addr_w_zpindy0     , 8'hFF                 ) // 91 STA (zp),y
  `A0_A1_ADDR_4510(8'h92, kMCA_e_addr_w_zpindz0     , 8'hFF                 ) // 92 STA (zp),z
  `A0_A1_ADDR_4510(8'h93, kMCA_e_braw0              , kMCA_e_bcw1           ) // 93 BCC wrel
  `A0_A1_ADDR_4510(8'h94, kMCA_e_addr_w_zpx0_y      , 8'hFF                 ) // 94 STY zp,x
  `A0_A1_ADDR_4510(8'h95, kMCA_e_addr_w_zpx0_a      , 8'hFF                 ) // 95 STA zp,x
  `A0_A1_ADDR_4510(8'h96, kMCA_e_addr_w_zpy0_x      , 8'hFF                 ) // 96 STX zp,y
  `A0_A1_ADDR_4510(8'h97, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // 97 SMB1 zp
  `A0_A1_ADDR_4510(8'h98, kMCA_e_tya0               , 8'hFF                 ) // 98 TYA
  `A0_A1_ADDR_4510(8'h99, kMCA_e_addr_w_absy0       , kMCA_e_addr_w_absx1_a ) // 99 STA abs,y
  `A0_A1_ADDR_4510(8'h9A, kMCA_e_txs0               , 8'hFF                 ) // 9A TXS
  `A0_A1_ADDR_4510(8'h9B, kMCA_e_addr_w_absy0       , kMCA_e_addr_w_absy1_x ) // 9B STX abs,y
  `A0_A1_ADDR_4510(8'h9C, kMCA_e_addr_w_abs0        , kMCA_e_addr_w_abs1_z  ) // 9C STZ abs
  `A0_A1_ADDR_4510(8'h9D, kMCA_e_addr_w_absx0       , kMCA_e_addr_w_absx1_a ) // 9D STA abs,x
  `A0_A1_ADDR_4510(8'h9E, kMCA_e_addr_w_absx0       , kMCA_e_addr_w_absx1_z ) // 9E STZ abs,x
  `A0_A1_ADDR_4510(8'h9F, kMCA_e_bbs0               , 8'hFF                 ) // 9F BBS1 zp
  
  `A0_A1_ADDR_4510(8'hA0, kMCA_e_ldyi               , 8'hFF                 ) // A0 LDY #
  `A0_A1_ADDR_4510(8'hA1, kMCA_e_addr_r_zpxind0     , kMCA_e_lda            ) // A1 LDA (zp,x)
  `A0_A1_ADDR_4510(8'hA2, kMCA_e_ldxi               , 8'hFF                 ) // A2 LDX #
  `A0_A1_ADDR_4510(8'hA3, kMCA_e_ldzi               , 8'hFF                 ) // A3 LDZ #
  `A0_A1_ADDR_4510(8'hA4, kMCA_e_addr_r_zp0         , kMCA_e_ldy            ) // A4 LDY zp
  `A0_A1_ADDR_4510(8'hA5, kMCA_e_addr_r_zp0         , kMCA_e_lda            ) // A5 LDA zp
  `A0_A1_ADDR_4510(8'hA6, kMCA_e_addr_r_zp0         , kMCA_e_ldx            ) // A6 LDX zp
  `A0_A1_ADDR_4510(8'hA7, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // A7 SMB2 zp
  `A0_A1_ADDR_4510(8'hA8, kMCA_e_tay0               , 8'hFF                 ) // A8 TAY
  `A0_A1_ADDR_4510(8'hA9, kMCA_e_ldai               , 8'hFF                 ) // A9 LDA #
  `A0_A1_ADDR_4510(8'hAA, kMCA_e_tax0               , 8'hFF                 ) // AA TAX
  `A0_A1_ADDR_4510(8'hAB, kMCA_e_addr_r_abs0        , kMCA_e_ldz            ) // AB LDZ abs
  `A0_A1_ADDR_4510(8'hAC, kMCA_e_addr_r_abs0        , kMCA_e_ldy            ) // AC LDY abs
  `A0_A1_ADDR_4510(8'hAD, kMCA_e_addr_r_abs0        , kMCA_e_lda            ) // AD LDA abs
  `A0_A1_ADDR_4510(8'hAE, kMCA_e_addr_r_abs0        , kMCA_e_ldx            ) // AE LDX abs
  `A0_A1_ADDR_4510(8'hAF, kMCA_e_bbs0               , 8'hFF                 ) // AF BBS2 zp
  
  `A0_A1_ADDR_4510(8'hB0, kMCA_e_bc0                , 8'hFF                 ) // B0 BCS rel
  `A0_A1_ADDR_4510(8'hB1, kMCA_e_addr_r_zpindy0     , kMCA_e_lda            ) // B1 LDA (zp),y
  `A0_A1_ADDR_4510(8'hB2, kMCA_e_addr_r_zpindz0     , kMCA_e_lda            ) // B2 LDA (zp),z
  `A0_A1_ADDR_4510(8'hB3, kMCA_e_braw0              , kMCA_e_bcw1           ) // B3 BCS wrel
  `A0_A1_ADDR_4510(8'hB4, kMCA_e_addr_r_zpx0        , kMCA_e_ldy            ) // B4 LDY zp,x
  `A0_A1_ADDR_4510(8'hB5, kMCA_e_addr_r_zpx0        , kMCA_e_lda            ) // B5 LDA zp,x
  `A0_A1_ADDR_4510(8'hB6, kMCA_e_addr_r_zpy0        , kMCA_e_ldx            ) // B6 LDX zp,y
  `A0_A1_ADDR_4510(8'hB7, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // B7 SMB3 zp
  `A0_A1_ADDR_4510(8'hB8, kMCA_e_clv0               , 8'hFF                 ) // B8 CLV
  `A0_A1_ADDR_4510(8'hB9, kMCA_e_addr_r_absy0       , kMCA_e_lda            ) // B9 LDA abs,y
  `A0_A1_ADDR_4510(8'hBA, kMCA_e_tsx0               , 8'hFF                 ) // BA TSX
  `A0_A1_ADDR_4510(8'hBB, kMCA_e_addr_r_absx0       , kMCA_e_ldz            ) // BB LDZ abs,x
  `A0_A1_ADDR_4510(8'hBC, kMCA_e_addr_r_absx0       , kMCA_e_ldy            ) // BC LDY abs,x
  `A0_A1_ADDR_4510(8'hBD, kMCA_e_addr_r_absx0       , kMCA_e_lda            ) // BD LDA abs,x
  `A0_A1_ADDR_4510(8'hBE, kMCA_e_addr_r_absy0       , kMCA_e_ldx            ) // BE LDX abs,y
  `A0_A1_ADDR_4510(8'hBF, kMCA_e_bbs0               , 8'hFF                 ) // BF BBS3 zp

  `A0_A1_ADDR_4510(8'hC0, kMCA_e_cmpyi              , 8'hFF                 ) // C0 CPY #
  `A0_A1_ADDR_4510(8'hC1, kMCA_e_addr_r_zpxind0     , kMCA_e_cmpa           ) // C1 CPA (zp,x)
  `A0_A1_ADDR_4510(8'hC2, kMCA_e_cmpzi              , 8'hFF                 ) // C2 CPZ #
  `A0_A1_ADDR_4510(8'hC3, kMCA_e_dew0               , 8'hFF                 ) // C3 DEW
  `A0_A1_ADDR_4510(8'hC4, kMCA_e_addr_r_zp0         , kMCA_e_cmpy           ) // C4 CPY zp
  `A0_A1_ADDR_4510(8'hC5, kMCA_e_addr_r_zp0         , kMCA_e_cmpa           ) // C5 CMP zp
  `A0_A1_ADDR_4510(8'hC6, kMCA_e_addr_r_zp0         , kMCA_e_dec_mem0       ) // C6 DEC zp
  `A0_A1_ADDR_4510(8'hC7, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // C7 SMB4 zp
  `A0_A1_ADDR_4510(8'hC8, kMCA_e_incy               , 8'hFF                 ) // C8 INY
  `A0_A1_ADDR_4510(8'hC9, kMCA_e_cmpai              , 8'hFF                 ) // C9 CMP #
  `A0_A1_ADDR_4510(8'hCA, kMCA_e_decx               , 8'hFF                 ) // CA DEX
  `A0_A1_ADDR_4510(8'hCB, kMCA_e_asw0               , 8'hFF                 ) // CB ASW abs
  `A0_A1_ADDR_4510(8'hCC, kMCA_e_addr_r_abs0        , kMCA_e_cmpy           ) // CC CPY abs
  `A0_A1_ADDR_4510(8'hCD, kMCA_e_addr_r_abs0        , kMCA_e_cmpa           ) // CD CMP abs
  `A0_A1_ADDR_4510(8'hCE, kMCA_e_addr_r_abs0        , kMCA_e_dec_mem0       ) // CE DEC abs
  `A0_A1_ADDR_4510(8'hCF, kMCA_e_bbs0               , 8'hFF                 ) // CF BBS4 zp

  `A0_A1_ADDR_4510(8'hD0, kMCA_e_bc0                , 8'hFF                 ) // D0 BNE rel
  `A0_A1_ADDR_4510(8'hD1, kMCA_e_addr_r_zpindy0     , kMCA_e_cmpa           ) // D1 CMP (zp),y
  `A0_A1_ADDR_4510(8'hD2, kMCA_e_addr_r_zpindz0     , kMCA_e_cmpa           ) // D2 CMP (zp),z
  `A0_A1_ADDR_4510(8'hD3, kMCA_e_braw0              , kMCA_e_bcw1           ) // D3 BNE wrel
  `A0_A1_ADDR_4510(8'hD4, kMCA_e_addr_r_zp0         , kMCA_e_cmpz           ) // D4 CPZ zp
  `A0_A1_ADDR_4510(8'hD5, kMCA_e_addr_r_zpx0        , kMCA_e_cmpa           ) // D5 CMP zp,x
  `A0_A1_ADDR_4510(8'hD6, kMCA_e_addr_r_zpx0        , kMCA_e_dec_mem0       ) // D6 DEC zp,x
  `A0_A1_ADDR_4510(8'hD7, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // D7 SMB5 zp
  `A0_A1_ADDR_4510(8'hD8, kMCA_e_cldsed0            , 8'hFF                 ) // D8 CLD
  `A0_A1_ADDR_4510(8'hD9, kMCA_e_addr_r_absy0       , kMCA_e_cmpa           ) // D9 CMP abs,y
  `A0_A1_ADDR_4510(8'hDA, kMCA_e_push_x             , 8'hFF                 ) // DA PHX
  `A0_A1_ADDR_4510(8'hDB, kMCA_e_push_z             , 8'hFF                 ) // DA PHZ
  `A0_A1_ADDR_4510(8'hDC, kMCA_e_addr_r_abs0        , kMCA_e_cmpz           ) // DC CPZ abs
  `A0_A1_ADDR_4510(8'hDD, kMCA_e_addr_r_absx0       , kMCA_e_cmpa           ) // DD CMP abs,x
  `A0_A1_ADDR_4510(8'hDE, kMCA_e_addr_r_absx0       , kMCA_e_dec_mem0       ) // DE DEC abs,x
  `A0_A1_ADDR_4510(8'hDF, kMCA_e_bbs0               , 8'hFF                 ) // DF BBS5 zp

  `A0_A1_ADDR_4510(8'hE0, kMCA_e_cmpxi              , 8'hFF                 ) // E0 CPX #
  `A0_A1_ADDR_4510(8'hE1, kMCA_e_addr_r_zpxind0     , kMCA_e_sbc            ) // E1 SBC (zp,x)
  `A0_A1_ADDR_4510(8'hE2, kMCA_e_addr_spind0        , kMCA_e_addr_r_spind3  ) // E2 LDA (d,SP),Y
  `A0_A1_ADDR_4510(8'hE3, kMCA_e_inw0               , 8'hFF                 ) // E3 INW
  `A0_A1_ADDR_4510(8'hE4, kMCA_e_addr_r_zp0         , kMCA_e_cmpx           ) // E4 CPX zp
  `A0_A1_ADDR_4510(8'hE5, kMCA_e_addr_r_zp0         , kMCA_e_sbc            ) // E5 SBC zp
  `A0_A1_ADDR_4510(8'hE6, kMCA_e_addr_r_zp0         , kMCA_e_inc_mem0       ) // E6 INC zp
  `A0_A1_ADDR_4510(8'hE7, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // E7 SMB6 zp
  `A0_A1_ADDR_4510(8'hE8, kMCA_e_incx               , 8'hFF                 ) // E8 INX
  `A0_A1_ADDR_4510(8'hE9, kMCA_e_sbci               , 8'hFF                 ) // E9 SBC #
  `A0_A1_ADDR_4510(8'hEA, kMCA_e_fetch0             , 8'hFF                 ) // EA NOP
  `A0_A1_ADDR_4510(8'hEB, kMCA_e_row0               , 8'hFF                 ) // EB ROW abs
  `A0_A1_ADDR_4510(8'hEC, kMCA_e_addr_r_abs0        , kMCA_e_cmpx           ) // EC CPX abs
  `A0_A1_ADDR_4510(8'hED, kMCA_e_addr_r_abs0        , kMCA_e_sbc            ) // ED SBC abs
  `A0_A1_ADDR_4510(8'hEE, kMCA_e_addr_r_abs0        , kMCA_e_inc_mem0       ) // EE INC abs
  `A0_A1_ADDR_4510(8'hEF, kMCA_e_bbs0               , 8'hFF                 ) // EF BBS6 zp

  `A0_A1_ADDR_4510(8'hF0, kMCA_e_bc0               , 8'hFF                  ) // F0 BEQ rel
  `A0_A1_ADDR_4510(8'hF1, kMCA_e_addr_r_zpindy0     , kMCA_e_sbc            ) // F1 SBC (zp),y
  `A0_A1_ADDR_4510(8'hF2, kMCA_e_addr_r_zpindz0     , kMCA_e_sbc            ) // F2 SBC (zp),z
  `A0_A1_ADDR_4510(8'hF3, kMCA_e_braw0              , kMCA_e_bcw1           ) // F3 BEQ wrel
  `A0_A1_ADDR_4510(8'hF4, kMCA_e_phwi0              , 8'hFF                 ) // F4 PHD imm
  `A0_A1_ADDR_4510(8'hF5, kMCA_e_addr_r_zpx0        , kMCA_e_sbc            ) // F5 SBC zp,x
  `A0_A1_ADDR_4510(8'hF6, kMCA_e_addr_r_zpx0        , kMCA_e_inc_mem0       ) // F6 INC zp,x
  `A0_A1_ADDR_4510(8'hF7, kMCA_e_addr_r_zp0         , kMCA_e_smb0           ) // F7 SMB7 zp
  `A0_A1_ADDR_4510(8'hF8, kMCA_e_cldsed0            , 8'hFF                 ) // F8 SED
  `A0_A1_ADDR_4510(8'hF9, kMCA_e_addr_r_absy0       , kMCA_e_sbc            ) // F9 SBC abs,y
  `A0_A1_ADDR_4510(8'hFA, kMCA_e_pull0              , kMCA_e_ldx            ) // FA PLX
  `A0_A1_ADDR_4510(8'hFB, kMCA_e_pull0              , kMCA_e_ldz            ) // FB PLZ
  `A0_A1_ADDR_4510(8'hFC, kMCA_e_phw0               , 8'hFF                 ) // FC PHD abs
  `A0_A1_ADDR_4510(8'hFD, kMCA_e_addr_r_absx0       , kMCA_e_sbc            ) // FD SBC abs,x
  `A0_A1_ADDR_4510(8'hFE, kMCA_e_addr_r_absx0       , kMCA_e_inc_mem0       ) // FE INC abs,x
  `A0_A1_ADDR_4510(8'hFF, kMCA_e_bbs0               , 8'hFF                 ) // FF BBS7 zp

