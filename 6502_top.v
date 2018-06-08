`include "6502_inc.vh"

`SCHEM_KEEP_HIER module cpu6502(clk, reset, nmi, irq, ready, write, write_next, sync, address, address_next, data_i, data_o, data_o_next, cpu_state, t, cpu_int);

initial begin
end

input clk, reset, irq, nmi, ready;
input [7:0] data_i;
output [7:0] data_o;
output wire [7:0] data_o_next;
output [15:0] address;
output [15:0] address_next;
output write_next;
output write;
output sync;
output [7:0] cpu_state;
output [2:0] t;
output cpu_int;

// FPGA debug
wire [7:0] cpu_state;

// current timing state
wire [2:0] t;
wire [2:0] t_next;

// microcode output signals
wire [2:0] tnext_mc;
wire [1:0] ab_sel;
wire [1:0] abh_sel;
wire [1:0] ab_incdec;
wire [1:0] sp_incdec;
wire pc_inc;
wire pcl_adl;
wire [2:0] alu_op;
wire [1:0] alu_a;
wire [3:0] abus_sel;
wire [2:0] alu_b;
wire [1:0] alu_c;
wire [3:0] load_reg;
wire [3:0] load_flags;
wire [15:0] load_flag_decode;
wire [13:0] load_reg_decode;

// Derived signals
wire getvec;

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
wire [15:0] sp;
wire [15:0] sp_next;
wire [15:0] pc;
wire [15:0] pc_next;

// ALU inputs and outputs
wire [7:0] abus;
wire [7:0] alua_bus;
wire [7:0] alub_bus;
wire aluc_bus;
wire [7:0] aluy;

wire [7:0] ir_next;

wire dec_add, dec_sub;
wire alu_carry_out;

wire ready_i;

wire sync;

wire onecycle;

wire intg;
wire nmig;
wire resp;

assign cpu_int = intg;

assign getvec = (alu_a == `ALUA_VEC);

wire [7:0] vector_lo;

  // Instantiate ALU
  alu_unit alu_inst(alua_bus, alub_bus, aluy, aluc_bus, dec_add, dec_sub, alu_op, alu_carry_out, alu_overflow_out);
  
  // Note: microcode outputs are *synchronous* and show up on following clock and thus are always driven directly by t_next and not t.
  microcode mc_inst(.clk(clk), .ready(ready_i), .ir(ir_next), .t(t_next), .tnext(tnext_mc), .ab_sel(ab_sel), .abh_sel(abh_sel),
                  .ab_incdec(ab_incdec), .pc_inc(pc_inc), .pcl_adl(pcl_adl), 
                  .alu_sel(alu_op), .alu_a(alu_a), .abus(abus_sel), .alu_b(alu_b), .alu_c(alu_c),
                  .load_reg(load_reg), .load_flags(load_flags), 
                  .write(write_cycle));

  reg_decode     reg_decode(load_reg, load_reg_decode);
  flags_decode flags_decode(load_flags, load_flag_decode);

  assign ready_i = ready | write_next;

  branch_control branch_control(reg_p, ir[7:5], taken_branch);
  
  ir_next_mux ir_next_mux(sync, intg, data_i, ir, ir_next);

  assign write_next = write_cycle & ~resp;
  assign write = w_reg; 
  assign data_o = dor;
  assign data_o_next = aluy;

  always @(posedge clk)
  begin
    if(ready_i)
      w_reg <= write_next;
  end
  
  assign cpu_state = ir; //{ dec_add, dec_sub, decimal_extra_cycle, decimal_cycle};
  
  predecode predecode(data_i, sync & ~intg, onecycle);

  interrupt_control interrupt_control(clk, reset, irq, nmi, t, tnext_mc, reg_p, load_flag_decode[`LF_I_1], intg, nmig, resp, vector_lo);

  // Timing control state machine
  timing_ctrl timing(clk, reset, ready_i, t, t_next, tnext_mc, sync, onecycle);

  // Disable PC increment when processing a BRK with recognized IRQ/NMI, or when about to perform the extra decimal correction cycle
  wire pc_hold;
  assign pc_hold = intg;

  clocked_reset_reg8 ir_reg(clk, reset, sync & ready_i, ir_next, ir);

  addrbus_mux addrbus_mux(clk, ready, ab_sel, ad_next, ab_next, sp_next, pc_next, address_next, address);
  
  ab_reg reg_ab(clk, ready, abh_sel, getvec, load_reg_decode[`LR_ABL], ab_incdec[0], ab_incdec[1], reg_b, aluy, ab_next, ab);
  ad_reg reg_ad(clk, ready, load_reg_decode[`LR_ADL], load_reg_decode[`LR_ADH], aluy, ad_next, ad);
  pc_reg reg_pc(clk, ready, pc_inc & ~pc_hold, pcl_adl, load_reg_decode[`LR_PCL], load_reg_decode[`LR_PCH], ad[7:0], aluy, pc_next, pc);
  sp_reg reg_sp(clk, reset, ready, reg_p[`PF_E], load_reg_decode[`LR_SPH], load_reg_decode[`LR_SPL], sp_incdec[0], sp_incdec[1],
                aluy, sp_next, sp);
  
  wire [7:0] ir_dec;

  aluabus_mux aluabus_mux(abus_sel, reg_a, reg_x, reg_y, reg_z, reg_p, reg_b, pc_next[15:8], sp_next[15:8], pc_next[7:0], sp_next[7:0], abus);
  
  alua_mux alua_mux(alu_a, abus, vector_lo, alua_bus);
  alub_mux alub_mux(alu_b, data_i, ir[2:0], alub_bus);
  aluc_mux aluc_mux(alu_c, reg_p[`PF_C], alu_carry_out_last, aluc_bus);
    
  clocked_reg8 a_reg(clk, load_reg_decode[`LR_A] && ready_i, aluy, reg_a);
  clocked_reg8 x_reg(clk, load_reg_decode[`LR_X] && ready_i, aluy, reg_x);
  clocked_reg8 y_reg(clk, load_reg_decode[`LR_Y] && ready_i, aluy, reg_y);
  clocked_reg8 z_reg(clk, load_reg_decode[`LR_Z] && ready_i, aluy, reg_z);
  clocked_reg8 b_reg(clk, load_reg_decode[`LR_B] && ready_i, aluy, reg_b);
  
  // FIXME - This is kinda hacky right now.  Really should have a pair of dedicated microcode bits for this but
  // I'm currently out of spare microcode bits.   This probably only requires a couple of LUTs though.
  assign dec_add = reg_p[`PF_D] & load_flag_decode[`LF_V_AVR] & (alu_op == `ALU_ADC);
  assign dec_sub = reg_p[`PF_D] & load_flag_decode[`LF_V_AVR] & (alu_op == `ALU_SBC);

  assign sb_z = ~|aluy;
  assign sb_n = aluy[7];

  p_reg p_reg(clk, reset, ready_i, intg, load_flag_decode, sync & ready_i, data_i, sb_z, sb_n, alu_carry_out, alu_overflow_out, ir[5], ir[0], reg_p);

  always @(posedge clk)
  begin
    if(ready_i)
      alu_carry_out_last <= alu_carry_out;
  end

  // Branch-to-self detection
  // synthesis translate off
  reg [15:0] last_fetch_addr;
  always @(posedge clk)
  begin
    if(sync & ready_i)
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
