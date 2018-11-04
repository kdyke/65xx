`include "65ce02_inc.vh"

`SCHEM_KEEP_HIER module cpu65CE02(clk, reset, nmi, irq, hyp, ready, write, write_next, sync, address, address_next, data_i, data_o, data_o_next, 
                                hyper_mode, cpu_state, t, cpu_int,
                                a_out, x_out, y_out, z_out, sp_out);

initial begin
end

input clk, reset, irq, nmi, ready;
input hyp;
input [7:0] data_i;
output wire [7:0] data_o;
output wire [7:0] data_o_next;
output [15:0] address;
output [15:0] address_next;
output write_next;
output reg write;
output sync;
output [7:0] cpu_state;
output [2:0] t;
output cpu_int;
output wire hyper_mode;

// debugging
output wire [7:0] a_out;
output wire [7:0] x_out;
output wire [7:0] y_out;
output wire [7:0] z_out;
output wire [15:0] sp_out;

// FPGA debug
wire [7:0] cpu_state;

// current timing state
wire [2:0] t;
wire [2:0] t_next;

// microcode output signals
wire mc_sync; 
wire [2:0] alua_sel;
wire [2:0] alub_sel;
wire [1:0] aluc_sel;
wire [1:0] dreg;
wire [1:0] dreg_do;
wire [1:0] areg;
wire [2:0] alu_sel;
wire [1:0] dbo_sel;
wire [1:0] ab_sel;
wire pc_inc;
wire [1:0] pch_sel;
wire [1:0] pcl_sel;
wire [1:0] sp_incdec;
wire sph_sel;
wire spl_sel;
wire ab_inc;
wire [1:0] abh_sel;
wire abl_sel;
wire adh_sel;
wire adl_sel;
wire [2:0] load_reg;
wire [3:0] load_flags;
wire [4:0] test_flags;
wire test_flag0;
wire word_z;

// Clocked internal registers
wire [15:0] ab;
wire [15:0] ab_next;
wire [15:0] ad;
wire [15:0] ad_next;
wire [7:0] ir;
wire [7:0] dor;
reg w_reg;
reg alu_carry_out_last;

// Clocked architectural registers
wire [7:0] reg_a;
wire [7:0] reg_x;
wire [7:0] reg_y;
wire [7:0] reg_z;
wire [7:0] reg_b;
wire [7:0] reg_p;
wire [15:0] usp;
wire [15:0] usp_next;
wire [15:0] hsp;
wire [15:0] hsp_next;
wire [15:0] sp;
wire [15:0] sp_next;
wire [15:0] pc;
wire [15:0] pc_next;

// ALU inputs and outputs
wire [7:0] abus;
wire [7:0] alua_bus;
wire [7:0] areg_bus;
wire [7:0] dreg_bus;
wire [7:0] dreg_do_bus;
wire [7:0] alub_bus;
wire aluc_bus;
wire [7:0] alu_out;
wire [7:0] alu_ea;      // Shorter ALU out path that doesn't include decimal correction
wire alu_ea_c;
wire [7:0] ir_next;
wire [7:0] dbd;
wire bit_inv;
wire dec_add, dec_sub;
wire alu_carry_out;

wire sync;

wire onecycle;

wire hyperg, hyper_rti;
wire intg;
wire nmig;
wire resp;
wire alu_z, dld_z;
wire [4:0] load_reg_decode;
wire [16:0] load_flags_decode;
assign cpu_int = intg;

wire stack_sel;

wire [7:0] vector_hi;
wire [7:0] vector_lo;

  // Note: microcode outputs are *synchronous* and show up on following clock and thus are always driven directly by t_next and not t.
  `microcode mc_inst(.clk(clk), .ready(ready), .ir(ir_next), .t(t_next), .mc_sync(mc_sync), .alua_sel(alua_sel), .alub_sel(alub_sel),
                  .aluc_sel(aluc_sel), .bit_inv(bit_inv),
                  .dreg(dreg), .dreg_do(dreg_do), .areg(areg), .alu_sel(alu_sel), .dbo_sel(dbo_sel), .ab_sel(ab_sel),
                  .pc_inc(pc_inc), .pch_sel(pch_sel), .pcl_sel(pcl_sel), 
                  .sp_incdec(sp_incdec), .sph_sel(sph_sel), .spl_sel(spl_sel),
                  .ab_inc(ab_inc), .abh_sel(abh_sel), .abl_sel(abl_sel),
                  .adh_sel(adh_sel), .adl_sel(adl_sel),
                  .load_reg(load_reg), .load_flags(load_flags), .test_flags(test_flags), .test_flag0(test_flag0),
                  .word_z(word_z),.write(write_cycle));

  //always @(mc_sync)
  //begin
  //  $display("MC_SYNC: %d",mc_sync);
  //end
  
  `reg_decode     reg_decode(load_reg, load_reg_decode);
  `flags_decode flags_decode(load_flags, load_flags_decode);

  `cond_control cond_control(reg_p, dld_z, test_flags, test_flag0, cond_met);
  
  `ir_next_mux ir_next_mux(sync, intg|hyperg, data_i, ir, ir_next);

  assign write_next = write_cycle & ~resp;
  always @(posedge clk)
  begin
    if(ready)
      write <= write_next;
  end
  
  `dreg_mux  dreg_do_mux(dreg_do, reg_a, reg_x, reg_y, reg_z, dreg_do_bus);
  `dbo_mux   dbo_mux(dbo_sel, data_i, dreg_do_bus, alu_out, pc_next[15:8], data_o_next);
    
  `predecode predecode(data_i, sync & ~intg, onecycle);

  `interrupt_control interrupt_control(clk, reset, irq, nmi, mc_sync, reg_p, load_flags_decode[`kLF_I_1], intg, nmig, resp,
                                      hyp, hyperg, hyper_mode, hyper_rti, pc_hold, vector_hi, vector_lo);

  // Timing control state machine
  `timing_ctrl timing(clk, reset, ready, t, t_next, mc_sync, sync, onecycle);

  `clocked_reset_reg8 ir_reg(clk, reset, sync & ready, ir_next, ir);

  `addrbus_mux addrbus_mux(clk, ready, ab_sel, ad_next, ab_next, sp_next, pc_next, address_next, address);
  
  wire [7:0] pcl_alu_out;
  wire pcl_alu_carry;
  
  // Instantiate ALU
  `alu_unit alu_inst(alua_bus, alub_bus, alu_out, aluc_bus, dec_add, dec_sub, alu_sel, alu_carry_out, alu_overflow_out);

  // A couple of dedicated adders for effective address calculations.
  `ea_adder pcl_adder(areg[1] == 1 /* areg ==`kAREG_PCL */ ? pc[7:0] : 8'h00, data_i, aluc_sel[0], pcl_alu_out, pcl_alu_carry);  
  `ea_adder ea_adder(alua_bus,alub_bus,aluc_bus,alu_ea,alu_ea_c);
  
  `ab_reg reg_ab(clk, ready, ab_inc, abh_sel, abl_sel, reg_b, alu_ea, vector_hi, ab_next, ab);
  `ad_reg reg_ad(clk, ready, adh_sel, adl_sel, alu_ea, ad_next, ad);
  `pc_reg reg_pc(clk, ready, pc_inc & ~pc_hold, cond_met, pch_sel, pcl_sel, ad[7:0], alu_ea, alu_ea_c, data_i[7], pcl_alu_out, pcl_alu_carry, pc_next, pc);
  `sp_reg reg_usp(clk, reset, ready & ~stack_sel, reg_p[`kPF_E], sp_incdec, sph_sel, spl_sel, alu_ea, usp_next, usp, 1'b0);

  // For now the hypervisor stack is forced to work in 8-bit mode since I'm using the E bit in hypervisor mode to control
  // which stack gets used.   Leaving the true hypervisor stack in 8-bit mode is probably not a big deal, but it's easy
  // enough to change it to always run in 16-bit mode if it becomes a big limitation.  In any case it doesn't seem like it
  // needs to be switchable on the fly.   It was only done that way on the 65CE02 for backwards compatibility reasons.
  `sp_reg reg_hsp(clk, reset, ready & stack_sel, 1'b1, sp_incdec, sph_sel, spl_sel, alu_ea, hsp_next, hsp, 1'b1);
  
  // In hypervisor mode, the E bit controls whether we are accessing the hypervisor (1) or user (0) stack registers.
  assign stack_sel = hyper_mode & reg_p[`kPF_E];
  
  `sp_sel_mux sp_next_mux(stack_sel, usp_next, hsp_next, sp_next);
  `sp_sel_mux sp_mux(stack_sel, usp, hsp, sp);
  
  wire [7:0] ir_dec;

  `dreg_mux dreg_mux(dreg, reg_a, reg_x, reg_y, reg_z, dreg_bus);
  `areg_mux areg_mux(areg, pc[15:8], sp[15:8], pc[7:0], sp[7:0], areg_bus);
  
  `alua_mux alua_mux(alua_sel, areg_bus, dreg_bus, data_i, vector_lo, alua_bus);
  `alub_mux alub_mux(alub_sel, data_i, dbd, reg_p, reg_b, ir[6:4], bit_inv, alub_bus);
  `aluc_mux aluc_mux(aluc_sel, reg_p[`kPF_C], alu_carry_out_last, aluc_bus);
    
  `clocked_reg8 dbd_reg(clk, ready, data_i, dbd);
  `clocked_reg8 a_reg(clk, load_reg_decode[`kLR_A] && ready, alu_out, reg_a);
  `clocked_reg8 x_reg(clk, load_reg_decode[`kLR_X] && ready, alu_out, reg_x);
  `clocked_reg8 y_reg(clk, load_reg_decode[`kLR_Y] && ready, alu_out, reg_y);
  `clocked_reset_reg8 z_reg(clk, reset, load_reg_decode[`kLR_Z] && ready, alu_out, reg_z);
  `clocked_reset_reg8 b_reg(clk, reset, load_reg_decode[`kLR_B] && ready, alu_out, reg_b);
  `clocked_reg8 do_reg(clk, ready, data_o_next, data_o);
  
  assign cpu_state = reg_p; //{ dec_add, dec_sub, decimal_extra_cycle, decimal_cycle};
  assign a_out = reg_a;
  assign x_out = reg_x;
  assign y_out = reg_y;
  assign z_out = reg_z;
  assign sp_out = sp;
  
  // FIXME - This is kinda hacky right now.  Really should have a pair of dedicated microcode bits for this but
  // I'm currently out of spare microcode bits.   This probably only requires a couple of LUTs though.
  wire dec_op;
  assign dec_op = reg_p[`kPF_D] & load_flags_decode[`kLF_V_AVR] /* & (alu_sel == `kALU_ADC) */;
  assign dec_add = dec_op & (ir[7] == 0);
  assign dec_sub = dec_op & (ir[7] == 1);

  `z_unit z_unit(clk, ready, alu_sel, alu_out, sb_z, dld_z, word_z);

  assign sb_n = alu_out[7];

  `p_reg p_reg(clk, reset, ready, intg, hyperg, hyper_mode, hyper_rti, sync & ready, load_flags_decode, data_i, sb_z, sb_n, alu_carry_out, alu_overflow_out, ir[5], ir[0], reg_p);

  always @(posedge clk)
  begin
    if(ready && alu_sel[2] != 0)    // Only update delayed carry for add/shift ops
      alu_carry_out_last <= alu_carry_out;
  end

  // Branch-to-self detection
  // synthesis translate off
  reg [15:0] last_fetch_addr;
  always @(posedge clk)
  begin
    if(sync & ready)
    begin
      if(last_fetch_addr == address)
      begin
        $display("Halting, branch to self detected: %04x   A: %02x X: %02x Y: %02x Z: %02x B: %02x S: %04x P: %02x ",last_fetch_addr,
          reg_a, reg_x, reg_y, reg_z, reg_b, sp, reg_p);
        $finish;
      end
      if(pc_hold == 0)
        last_fetch_addr <= address;
    
    //$display("FETCH ADDR: %04x byte: %02x  1C: %d 2C: %d  pc_hold: %d intg: %g",address,ir_next,onecycle,twocycle,pc_hold, intg);
    end
  end
  // synthesis translate on

endmodule
