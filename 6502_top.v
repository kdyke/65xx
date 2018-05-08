`include "6502_inc.vh"

// This may be also defined to "fix" the original 6502 BRK/NMI bug without enabling the full CMOS stuff
`ifdef CMOS
`define NMI_BUG_FIX 1
`endif
`define NMI_BUG_FIX 1

module cpu6502(clk, reset, nmi, irq, ready, write, address, data_i, data_o);

initial begin
end

input clk, reset, irq, nmi, ready;
input [7:0] data_i;
output [7:0] data_o;
output [15:0] address;
output write;

// current timing state
wire [2:0] t;
wire [2:0] t_next;

// microcode output signals
wire [2:0] tnext_mc;
wire [2:0] adh_sel;
wire [2:0] adl_sel;
wire [2:0] db_sel;
wire [2:0] sb_sel;
wire pchs_sel;
wire pcls_sel;
wire [3:0] alu_op;
wire [1:0] alu_a;
wire [1:0] alu_b;
wire [1:0] alu_c;
wire load_a;
wire load_x;
wire load_y;
wire load_s;
wire load_abh;
wire load_abl;
wire write_cycle;
wire pc_inc;
wire [14:0] load_flag_decode;

// Internal busses (muxes)
wire [7:0] db_in; 
wire [7:0] db_out;

wire [7:0] adl_abl;      // ADL that feeds into ABL and ALUB input
wire [7:0] adl_pcls;     // ADL that feeds only into PCLS
wire [7:0] adh_pchs;     // ADH that feeds into PCHS
wire [7:0] adh_sb;       // ADH that feeds into SB and ABH
wire [7:0] adh_abh;      // ADH that feeds into ABH
wire [7:0] sb;
wire [7:0] sb_reg;      // SB that only feeds architectural registers and does not source from addressing logic

// Clocked internal registers
wire [7:0] abh;
wire [7:0] abl;
wire [7:0] pch;
wire [7:0] pcl;
wire [7:0] ir;

// Clocked architectural registers
wire [7:0] reg_a;
wire [7:0] reg_x;
wire [7:0] reg_y;
wire [7:0] reg_s;
wire [7:0] reg_p;

// ALU inputs and outputs
wire [7:0] aluas;
wire [7:0] alubs;
wire [7:0] alua;
wire [7:0] alub;
wire alucs;
wire [7:0] alu_out;

wire branch_page_cross;
wire taken_branch;
wire [7:0] ir_next;

wire [7:0] decadj_out;
wire dec_add, dec_sub;
wire alu_carry_out,alu_half_carry_out;

wire ready_i;

wire fetch_cycle;       // this is really sync, shoud probably rename it

wire [7:0] pcls;
wire pcl_carry;

wire [7:0] pchs;

wire onecycle;
wire twocycle;
wire decimal_cycle;

wire intg;
wire nmig;
wire resp;

wire [7:0] vector_lo;

  decadj_adder dadj(sb_reg, decadj_out, alu_carry_out, alu_half_carry_out, dec_add, dec_sub);

  // Instantiate ALU
  alu_unit alu_inst(clk, alua, alub, alu_out, alucs, dec_add, alu_op, alu_carry_out, alu_half_carry_out, alu_overflow_out, alu_carry_out_last);

  // Note: microcode outputs are *synchronous* and show up on following clock and thus are always driven directly by t_next and not t.
  microcode mc_inst(.clk(clk), .ir(ir_next), .t(t_next), .tnext(tnext_mc), .adh_sel(adh_sel), .adl_sel(adl_sel),
                  .pchs_sel(pchs_sel), .pcls_sel(pcls_sel), .alu_op(alu_op), .alu_a(alu_a), .alu_b(alu_b), .alu_c(alu_c),
                  .db_sel(db_sel), .sb_sel(sb_sel),
                  .load_a(load_a), .load_x(load_x), .load_y(load_y), .load_s(load_s),
                  .load_abh(load_abh), .load_abl(load_abl), 
                  .load_flags(load_flag_decode), 
                  .write_cycle(write_cycle), .pc_inc(pc_inc));

  assign ready_i = ready | write_cycle;

  branch_control branch_control(reg_p, ir[7:5], taken_branch);
  
  ir_next_mux ir_next_mux(fetch_cycle, intg, data_i, ir, ir_next);

  assign address = { abh, abl };
  assign write = write_cycle & ~resp;
  assign data_o = db_out;

  // A page is crossed if the carry result is different than the sign of the branch offset input
  assign branch_page_cross = alu_carry_out ^ alua[7];

  predecode predecode(ir_next, onecycle, twocycle);

  interrupt_control interrupt_control(clk, reset, irq, nmi, t, tnext_mc, reg_p, load_flag_decode[`LF_I_1], intg, nmig, resp, vector_lo);

  // Timing control state machine
  timing_ctrl timing(clk, reset, ready_i, t, t_next, tnext_mc, alu_carry_out, taken_branch, branch_page_cross, 
                   fetch_cycle, load_flag_decode[`LF_Z_SBZ], onecycle, twocycle, decimal_cycle);

// Disable PC increment when processing a BRK with recognized IRQ/NMI, or when about to perform the extra decimal correction cycle
wire pc_hold;
`ifdef CMOS
assign pc_hold = (intg && (ir_next == 8'h00)) || (decimal_cycle);
`else
assign pc_hold = (intg && (ir_next == 8'h00));
`endif

  pcls_mux pcls_mux(.pcls_sel(pcls_sel), .pc_inc(pc_inc & ~pc_hold), .pcl(pcl), .adl(adl_pcls), .pcls(pcls), .pcl_carry(pcl_carry));
  pchs_mux pchs_mux(.pchs_sel(pchs_sel), .pcl_carry(pcl_carry), .pch(pch), .adh(adh_pchs), .pchs(pchs));

  clocked_reset_reg8 ir_reg(clk, reset, fetch_cycle & ready_i, ir_next, ir);
  
  adh_pchs_mux adh_pchs_mux(.adh_sel(adh_sel), .data_i(data_i), .alu(alu_out), .adh_pchs(adh_pchs));
  adh_sb_mux adh_sb_mux(.adh_sel(adh_sel), .data_i(data_i), .pchs(pchs), .alu(alu_out), .adh_sb(adh_sb));
  adl_pcls_mux adl_pcls_mux(.adl_sel(adl_sel), .data_i(data_i), .reg_s(reg_s), .alu(alu_out), .adl_pcls(adl_pcls));
  adl_abl_mux adl_abl_mux(.adl_sel(adl_sel), .data_i(data_i), .pcls(pcls), .reg_s(reg_s), .alu(alu_out), .vector_lo(vector_lo), .adl_abl(adl_abl));
  adh_abh_mux adh_abh_mux(.adh_sel(adh_sel), .pchs(pchs), .sb(adh_sb), .adh_abh(adh_abh));
  db_in_mux db_in_mux(db_sel, data_i, reg_a, alua[7], db_in);
  db_out_mux db_out_mux(db_sel, reg_a, sb, pcl, pch, reg_p, db_out);
  
  sb_mux sb_mux(sb_sel, reg_a, reg_x, reg_y, reg_s, alu_out, pchs /*adh_sb */, db_in, sb);

  sb_reg_mux sb_reg_mux(sb_sel, reg_a, reg_x, reg_y, reg_s, alu_out, db_in, sb_reg);

wire [7:0] ir_dec;
`ifdef CMOS
decoder3to8 dec3to8(ir[6:4], ir_dec);
`endif

  alua_mux alua_mux(alu_a, sb, ir_dec, aluas);
  alub_mux alub_mux(alu_b, db_in, adl_abl, alubs);
  aluc_mux aluc_mux(alu_c, reg_p[`PF_C], alu_carry_out_last, alucs);
  
  clocked_reg8 a_reg(clk, load_a, decadj_out, reg_a);
  clocked_reg8 x_reg(clk, load_x, sb_reg, reg_x);
  clocked_reg8 y_reg(clk, load_y, sb_reg, reg_y);
  clocked_reg8 s_reg(clk, load_s, sb_reg, reg_s);

  clocked_reg8 alua_reg(clk, alu_a != 0 && ready_i, aluas, alua);
  clocked_reg8 alub_reg(clk, alu_b != 0 && ready_i, alubs, alub);

  clocked_reg8 pcl_reg(clk, ready, pcls, pcl);
  clocked_reg8 pch_reg(clk, ready, pchs, pch);
  
  clocked_reg8 abl_reg(clk, load_abl, adl_abl, abl);
  clocked_reg8 abh_reg(clk, load_abh, adh_abh, abh);
    
  // FIXME - This is kinda hacky right now.  Really should have a pair of dedicated microcode bits for this but
  // I'm currently out of spare microcode bits.   This probably only requires a couple of LUTs though.
  assign dec_add = reg_p[`PF_D] & load_flag_decode[`LF_V_AVR] & (alu_op == `ALU_ADC);
  assign dec_sub = reg_p[`PF_D] & load_flag_decode[`LF_V_AVR] & (alu_op == `ALU_SBC);
  assign decimal_cycle = dec_add | dec_sub;

  // In the real 6502 the internal data bus is bidirectional and so it doesn't matter whether it is a "source" or destination.  But
  // in an FPGA you never want to have combinatorial loops since it generally makes the synthesis tools really unhappy.  So because
  // I had to split the data bus into two unidirectional busses, I was faced with the problem that sometimes I needed to update the Z
  // and N flags based on data coming into the CPU (Load, BIT, etc), and sometimes when it was just the result of an internal operation.

  // However, my secondary (SB) bus is essentially unidirectional, and in all cases where I needed to update the Z or N flags it was
  // possible to either have the input data bus feed the secondary bus to pick up the flags, or just pick up the flags from the secondary
  // bus directly (which is a case where the original would have cross connected the two busses).  So, I always just get Z or N from
  // the secondary bus instead.
  assign sb_z = ~|sb_reg;
  assign sb_n = sb_reg[7];

  p_reg p_reg(clk, reset, ready_i, intg, load_flag_decode, fetch_cycle & ready_i, db_in, sb_z, sb_n, alu_carry_out, alu_overflow_out, ir[5], reg_p);


  // Branch-to-self detection
  // synthesis translate off
  reg [15:0] last_fetch_addr;
  always @(posedge clk)
  begin
    if(fetch_cycle & ready_i)
    begin
      if(last_fetch_addr == address)
      begin
        $display("Halting, branch to self detected: %04x   A: %02x X: %02x Y: %02x S: %02x P: %02x ",last_fetch_addr,
          reg_a, reg_x, reg_y, reg_s, reg_p);
        $finish;
      end
      if(pc_hold == 0)
        last_fetch_addr <= address;
    
    //$display("FETCH ADDR: %04x byte: %02x  1C: %d 2C: %d  pc_hold: %d intg: %g",address,ir_next,onecycle,twocycle,pc_hold, intg);
    end
  end
  // synthesis translate on

endmodule
