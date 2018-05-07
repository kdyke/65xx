`include "6502_inc.vh"

// This may be also defined to "fix" the original 6502 BRK/NMI bug without enabling the full CMOS stuff
`ifdef CMOS
`define NMI_BUG_FIX 1
`endif

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
reg [7:0] db_in; 
reg [7:0] db_out;

reg [7:0] adl_abl;      // ADL that feeds into ABL and ALUB input
reg [7:0] adl_pcls;     // ADL that feeds only into PCLS

reg [7:0] adh_pchs;     // ADH that feeds into PCHS
reg [7:0] adh_sb;       // ADH that feeds into SB and ABH

reg [7:0] sb;

// Clocked internal registers
reg [7:0] abh;
reg [7:0] abl;
reg [7:0] pch;
reg [7:0] pcl;
reg [7:0] ir;

// Clocked architectural registers
reg [7:0] reg_a;
reg [7:0] reg_x;
reg [7:0] reg_y;
reg [7:0] reg_s;
reg [7:0] reg_p;

// ALU inputs and outputs
reg [7:0] alua_in;
reg [7:0] alub_in;
reg [7:0] alua_reg;
reg [7:0] alub_reg;
reg aluc_in;
wire [7:0] alu_out;

wire branch_page_cross;
reg taken_branch;
reg alu_carry_out_last;
reg [7:0] ir_next;

// reset flip flip
reg resp;
reg nmil; // Delayed NMI for edge detection
reg nmig;
reg intp;
reg intg;

wire [7:0] decadj_out;
wire dec_add, dec_sub;
wire alu_carry_out,alu_half_carry_out;

wire ready_i;

// Branch-to-self detection
// synthesis translate_off
reg [15:0] last_fetch_addr;
// synthesis translate_on

wire decimal_extra_cycle;

// PCL select in/out
reg [7:0] pcls_in;
// Extra bit for carry output
reg [8:0] pcls;

// PCH select in/out
reg [7:0] pchs_in;
reg [7:0] pchs;

decadj_adder dadj(sb, decadj_out, alu_carry_out, alu_half_carry_out, dec_add, dec_sub);

// Instantiate ALU
alu_unit alu_inst(alua_reg, alub_reg, alu_out, aluc_in, dec_add, alu_op, alu_carry_out, alu_half_carry_out, alu_overflow_out);

// Note: microcode outputs are *synchronous* and show up on following clock and thus are always driven directly by t_next and not t.
microcode mc_inst(.clk(clk), .ir(ir_next), .t(t_next), .tnext(tnext_mc), .adh_sel(adh_sel), .adl_sel(adl_sel),
                  .pchs_sel(pchs_sel), .pcls_sel(pcls_sel), .alu_op(alu_op), .alu_a(alu_a), .alu_b(alu_b), .alu_c(alu_c),
                  .db_sel(db_sel), .sb_sel(sb_sel),
                  .load_a(load_a), .load_x(load_x), .load_y(load_y), .load_s(load_s),
                  .load_abh(load_abh), .load_abl(load_abl), 
                  .load_flags(load_flag_decode), 
                  .write_cycle(write_cycle), .pc_inc(pc_inc));

assign ready_i = ready | write_cycle;

always @(*)
begin
  taken_branch = 0;
	case({ir[7],ir[6]}) // synthesis full_case parallel_case
		2'b00: taken_branch = (reg_p[7] == ir[5]);
		2'b01: taken_branch = (reg_p[6] == ir[5]);
		2'b10: taken_branch = (reg_p[0] == ir[5]);
		2'b11: taken_branch = (reg_p[1] == ir[5]);
	endcase
end

// IR input
always @(*)
begin
  if(fetch_cycle)
  begin
    if(intg)
      ir_next = 8'h00;
    else
      ir_next = data_i;
  end
  else
    ir_next = ir;
end

// During t1, microcode input addr is selected directly from data_i
assign address = { abh, abl };
assign write = write_cycle & ~resp;
assign data_o = db_out;

always @(posedge clk)
begin
  if(reset)
    resp = 1;
  else if(t == 0)
    resp = 0;
end

// INT is always the last read value of the interrupt status
always @(posedge clk)
begin
  intp <= irq;
end

// intg is the signal that actually causes interrupts to be processed. It 
// can be updated from intp either during T0 or during T2 if the instruction
// is a branch, or immediately in the case of reset.
always @(posedge clk)
begin
  // NMI edge detection
  // This will be delayed by one cycle so if an NMI happens on T0 it won't get recognized
  // until the next T0 or T2 of a branch.
  if(nmi & ~nmil)
    nmig <= 1;
  nmil <= nmi;    // remember current state
  
  if(reset || (t == 0) || (tnext_mc == `TBR))
  begin
    if((intp & ~reg_p[`PF_I]) | nmig | reset)
      intg <= 1;
  end
  // internal pending interrupt is always cleared at the same time we set interrupt mask.
  else if(load_flag_decode[14])
  begin
      intg <= 0;
`ifdef NMI_BUG_FIX      
      if(~reg_p[`PF_B])
`endif
        nmig <= 0;
  end
end

// A page is crossed if the carry result is different than the sign of the branch offset input
assign branch_page_cross = alu_carry_out ^ alua_reg[7];

wire fetch_cycle;
wire onecycle;
wire twocycle;

predecode predecode(ir_next, onecycle, twocycle);

`ifdef CMOS
wire decimal_cycle;
assign decimal_cycle = dec_add | dec_sub;
assign decimal_extra_cycle = (t == 7 && load_flag_decode[`LF_Z_SBZ]);
assign fetch_cycle = (t == 1 && ~(decimal_cycle)) | decimal_extra_cycle;
`else
assign fetch_cycle = (t == 1);
assign decimal_extra_cycle = 0;
`endif

// Timing control state machine
timing_ctrl timing(clk, reset, ready_i, t, t_next, tnext_mc, alu_carry_out, taken_branch, branch_page_cross, 
                   fetch_cycle, decimal_extra_cycle, onecycle, twocycle, decimal_cycle);

// Disable PC increment when processing a BRK with recognized IRQ/NMI, or when about to perform the extra decimal correction cycle
wire pc_hold;
`ifdef CMOS
assign pc_hold = (intg && (ir_next == 8'h00)) || (decimal_cycle);
`else
assign pc_hold = (intg && (ir_next == 8'h00));
`endif

always @(*)
begin
  if(pcls_sel == `PCLS_PCL)
    pcls_in = pcl;
  else
    pcls_in = adl_pcls;
  pcls = pcls_in + (pc_inc & ~pc_hold);
  //$display("pls_sel: %d pcl: %02x adl: %02x pcls_in: %02x pcls: %02x pc_inc: %d pc_hold: %d intg: %g t1: %d ir0: %d",pcls_sel,pcl,adl_pcls,pcls_in,pcls,
  //  pc_inc,pc_hold,intg,t==1,ir == 8'h00);
end

always @(*)
begin
  if(pchs_sel == `PCHS_PCH)
    pchs_in = pch;
  else
    pchs_in = adh_pchs;
  pchs = pchs_in + pcls[8];
  //$display("phs_sel: %d pch: %02x adh: %02x pchs_in: %02x pchs: %02x",pchs_sel,pch,adh,pchs_in,pchs);
end

// IR is always loaded from data_i during t1  (data_i was fetched during t0)
always @(posedge clk)
begin
  if(reset)
  begin
    ir <= 8'h00;
    //reg_s <= 0;         // Not clear if the real hardware reset SP to anything or not.
    reg_p[`PF_B] <= 1;
    reg_p[`PF_U] <= 1;
  end
  else if(fetch_cycle & ready_i)
  begin
    if(intg)
      reg_p[`PF_B] <= 0;
    else
      reg_p[`PF_B] <= 1;
    ir <= ir_next;

    // synthesis translate off
    if(last_fetch_addr == address)
    begin
      $display("Halting, branch to self detected: %04x   A: %02x X: %02x Y: %02x S: %02x P: %02x ",last_fetch_addr,
        reg_a, reg_x, reg_y, reg_s, reg_p);
      $finish;
    end
    if(pc_hold == 0)
      last_fetch_addr <= address;
    // synthesis translate on
    
  //$display("FETCH ADDR: %04x byte: %02x  1C: %d 2C: %d  pc_hold: %d intg: %g",address,ir_next,onecycle,twocycle,pc_hold, intg);
  end
end

reg [7:0] vector_lo;

always @(*)
begin
  if(resp == 1)
    vector_lo = 8'hFC;
  else if(nmig 
`ifdef NMI_BUG_FIX    
    & ~reg_p[`PF_B]
`endif
    )
    vector_lo = 8'hFA;
  else
    vector_lo = 8'hFE;
end

// ADH -> PCHS
always @(*)
begin
  adh_pchs = data_i;
  case(adh_sel)  // synthesis full_case parallel_case
    `ADH_DI  : adh_pchs = data_i;
    `ADH_ALU : adh_pchs = alu_out;
  endcase
end

// ADH -> SB
always @(*)
begin
  case(adh_sel)  // synthesis full_case parallel_case
    `ADH_DI  : adh_sb = data_i;
    `ADH_PCHS: adh_sb = pchs;
    `ADH_ALU : adh_sb = alu_out;
    `ADH_0   : adh_sb = 8'h00;
    `ADH_1   : adh_sb = 8'h01;
    `ADH_FF  : adh_sb = 8'hFF;
  endcase
end

// ADL -> PCLS
always @(*)
begin
  adl_pcls = data_i;
  case(adl_sel) // synthesis full_case parallel_case
    `ADL_DI    : adl_pcls = data_i;
    `ADL_S     : adl_pcls = reg_s;
    `ADL_ALU   : adl_pcls = alu_out;
  endcase
end

// ADL -> ABL
always @(*)
begin
  case(adl_sel) // synthesis full_case parallel_case
    `ADL_DI    : adl_abl = data_i;
    `ADL_PCLS  : adl_abl = pcls;
    `ADL_S     : adl_abl = reg_s;
    `ADL_ALU   : adl_abl = alu_out;
    `ADL_VECLO : adl_abl = vector_lo;
    `ADL_VECHI : adl_abl = vector_lo | 1;
  endcase
end

// DB input mux
always @(*)
begin
  case(db_sel)  // synthesis full_case parallel_case
    `DB_0   : db_in = 8'h00;
    `DB_DI  : db_in = data_i;
    `DB_A   : db_in = reg_a;
    `DB_BO  : db_in = {8{alua_reg[7]}};   // The high bit of the last ALU A input is the sign bit for branch offsets
  endcase
end

// DB output mux
always @(*)
begin
  case(db_sel)  // synthesis full_case parallel_case
    `DB_A   : db_out = reg_a;
    `DB_SB  : db_out = sb;
    `DB_PCL : db_out = pcl;
    `DB_PCH : db_out = pch;
    `DB_P   : db_out = reg_p;
    `DB_0   : db_out = 8'h00;
  endcase
end

// SB mux
always @(*)
begin
  case(sb_sel)  // synthesis full_case parallel_case
    `SB_A   : sb = reg_a;
    `SB_X   : sb = reg_x;
    `SB_Y   : sb = reg_y;
    `SB_S   : sb = reg_s;
    `SB_ALU : sb = alu_out;
    `SB_ADH : sb = adh_sb;
    `SB_DB  : sb = db_in;
    `SB_FF  : sb = 8'hFF;
  endcase
end

`ifdef CMOS
wire [7:0] ir_dec;
decoder3to8 dec3to8(ir[6:4], ir_dec);
`endif

// ALU A input select
always @(*)
begin
  case(alu_a)  // synthesis full_case parallel_case
    `ALU_A_0  : alua_in = 8'h00;
    `ALU_A_SB : alua_in = sb;
`ifdef CMOS
    `ALU_A_IR : alua_in = ir_dec;
`endif
  endcase
end

// ALU B input select
always @(*)
begin
  case(alu_b)  // synthesis full_case parallel_case
    `ALU_B_DB  : alub_in = db_in;
    `ALU_B_NDB : alub_in = ~db_in;
    `ALU_B_ADL : alub_in = adl_abl;
  endcase
end

// ALU C (carry) input select
always @(*)
begin
  case(alu_c)  // synthesis full_case parallel_case
    `ALU_C_0 : aluc_in = 0;
    `ALU_C_1 : aluc_in = 1;
    `ALU_C_P : aluc_in = reg_p[0];
    `ALU_C_A : aluc_in = alu_carry_out_last;    // last clocked out carry
  endcase
end


// clocked ALU inputs (only A and B, everything else is "live")
always @(posedge clk)
begin
  if(alu_a != 0 && ready_i)
    alua_reg <= alua_in;
  if(alu_b != 0 && ready_i)
    alub_reg <= alub_in;
  alu_carry_out_last <= alu_carry_out;
end

// ABL/ADH registers
always @(posedge clk)
begin
  if(load_abh && ready_i)
  begin
    if(adh_sel == `ADH_PCHS)
      abh <= pchs;
    else
      abh <= adh_sb;
  end
  if(load_abl && ready_i)
      abl <= adl_abl;
end

// PCH/PCL always take value of PCHS/PCLS
always @(posedge clk)
begin
  if(ready_i)
  begin
    pch <= pchs;
    pcl <= pcls;
  end
end

// FIXME - This is kinda hacky right now.  Really should have a pair of dedicated microcode bits for this but
// I'm currently out of spare microcode bits.   This probably only requires a couple of LUTs though.
assign dec_add = reg_p[`PF_D] & load_flag_decode[`LF_V_AVR] & (alu_op == `ALU_ADC);
assign dec_sub = reg_p[`PF_D] & load_flag_decode[`LF_V_AVR] & (alu_op == `ALU_SBC);

always @(posedge clk)
begin
  if(ready_i)
  begin
    if(load_a)
      begin
        reg_a <= decadj_out;
        //$display("A = %02x",sb);
      end
    if(load_x)
      begin
        reg_x <= sb;
        //$display("X = %02x",sb);
      end
    if(load_y)
      begin
        reg_y <= sb;
        //$display("Y = %02x",sb);
      end
    if(load_s)
      begin
        reg_s <= sb;
        //$display("S = %02x",sb);
      end
  end
end

// In the real 6502 the internal data bus is bidirectional and so it doesn't matter whether it is a "source" or destination.  But
// in an FPGA you never want to have combinatorial loops since it generally makes the synthesis tools really unhappy.  So because
// I had to split the data bus into two unidirectional busses, I was faced with the problem that sometimes I needed to update the Z
// and N flags based on data coming into the CPU (Load, BIT, etc), and sometimes when it was just the result of an internal operation.

// However, my secondary (SB) bus is essentially unidirectional, and in all cases where I needed to update the Z or N flags it was
// possible to either have the input data bus feed the secondary bus to pick up the flags, or just pick up the flags from the secondary
// bus directly (which is a case where the original would have cross connected the two busses).  So, I always just get Z or N from
// the secondary bus instead.
assign sb_z = ~|sb;
assign sb_n = sb[7];

always @(posedge clk)
begin    
  if(ready_i)
  begin
    if(load_flag_decode[`LF_C_ACR])       reg_p[`PF_C] = alu_carry_out;
    else if(load_flag_decode[`LF_C_IR5])  reg_p[`PF_C] = ir[5];
    else if(load_flag_decode[`LF_C_DB0])  reg_p[`PF_C] = db_in[0];

    if(load_flag_decode[`LF_Z_SBZ])       reg_p[`PF_Z] = sb_z;
    else if(load_flag_decode[`LF_Z_DB1])  reg_p[`PF_Z] = db_in[1];
    
    if(load_flag_decode[`LF_I_DB2])       reg_p[`PF_I] = db_in[2];
    else if(load_flag_decode[`LF_I_IR5])  reg_p[`PF_I] = ir[5];
    else if(load_flag_decode[`LF_I_1])    reg_p[`PF_I] = 1;

    if(load_flag_decode[`LF_D_DB3])       reg_p[`PF_D] = db_in[3];
    else if(load_flag_decode[`LF_D_IR5])  reg_p[`PF_D] = ir[5];
    
    if(load_flag_decode[`LF_V_AVR])       reg_p[`PF_V] = alu_overflow_out;
    else if(load_flag_decode[`LF_V_DB6])  reg_p[`PF_V] = db_in[6];
    else if(load_flag_decode[`LF_V_0])    reg_p[`PF_V] = 0;
      
    if(load_flag_decode[`LF_N_SBN])       reg_p[`PF_N] = sb_n;
    else if(load_flag_decode[`LF_N_DB7])  reg_p[`PF_N] = db_in[7];
  end
end

endmodule
