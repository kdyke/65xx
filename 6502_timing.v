`include "6502_inc.vh"

`SCHEM_KEEP_HIER module timing_ctrl(clk, reset, ready, t, t_next, tnext_mc, alu_carry_out, taken_branch, branch_page_cross, fetch_cycle, load_sbz, onecycle, twocycle, decimal_cycle);
input clk;
input reset;
input ready;
input [2:0] tnext_mc;
input alu_carry_out;
input taken_branch;
input branch_page_cross;
output fetch_cycle;
input decimal_cycle;
input load_sbz;
input onecycle;
input twocycle;
output [2:0] t;
output [2:0] t_next;

wire fetch_cycle;
reg [2:0] t;
reg [2:0] t_next;

// TODO - Separate the state machine from the output encoding?
parameter T0 = 3'b000,
          T1 = 3'b001,
          T2 = 3'b010,
          T3 = 3'b011,
          T4 = 3'b100,
          T5 = 3'b101,
          T6 = 3'b110,
          T7 = 3'b111;

`ifdef CMOS
wire decimal_extra_cycle;
assign decimal_extra_cycle = (t == 7 && load_sbz);
assign fetch_cycle = (t == 1 && ~(decimal_cycle)) | decimal_extra_cycle;
`else
assign decimal_extra_cycle = 0;
assign fetch_cycle = (t == 1);
`endif

always @(posedge clk or posedge reset)
begin
  if(reset)       t <= T2;
  else if(ready) begin
    t <= t_next;
    //$display("T: %d t_next: %d",t,t_next);
  end
end

always @(*)
begin
  t_next = t+1;

  if(onecycle & fetch_cycle)
    t_next = T1;
  else if(decimal_extra_cycle)
    t_next = T2;
  else if(decimal_cycle)
    t_next = T7;
  else if(twocycle & fetch_cycle)
    t_next = T0;
  if(tnext_mc == `T0)
    t_next = T0;
  else if(tnext_mc == `TNC && alu_carry_out == 0)
    t_next = T0;
  else if(tnext_mc == `TBR && taken_branch == 0)
    t_next = T1;
  else if(tnext_mc == `TBE)
  begin
    if(branch_page_cross == 1)
      t_next = T0;
    else
      t_next = T1;
  end
  else if(tnext_mc == `TBT && alu_carry_out == 0)
    t_next = T1;
  // synthesis translate_off
  else if(t != 1 && tnext_mc == `TKL)
  begin
    $display("Microcode KIL encountered");
    $finish;
  end
  // synthesis translate_on
end

endmodule

`SCHEM_KEEP_HIER module predecode(ir_next, onecycle, twocycle);
input [7:0] ir_next;
output onecycle;
output twocycle;

reg twocycle;

`ifdef CMOS
// This detects single-cycle instructions
reg onecycle;
always @(*)
begin
  if((ir_next & 8'b00000111) == 8'b00000011)
    onecycle = 1;
  else
    onecycle = 0;
end
`else
wire onecycle;
assign onecycle = 0;
`endif

// This detects the instruction patterns where we need to go immediately to T0 instead of T2 during a fetch cycle.
always @(*)
begin
  casez(ir_next)
    `ifdef CMOS
    8'b?1?1_1010: twocycle = 0;
    8'b???0_0010: twocycle = 1;
    `endif
    8'b???0_10?1: twocycle = 1;
    8'b1??0_00?0: // This would hit the CMOS BRA, but is disabled below
      begin
        twocycle = 1;
        `ifdef CMOS
        casez(ir_next)
          8'b?00???0?: twocycle = 0;
        endcase
        `endif
      end
    8'b????_10?0:
      begin
        twocycle = 1;
        casez(ir_next)
          8'b0??0??0?: twocycle = 0;
        endcase
      end
    default: twocycle = 0;
  endcase;

end

endmodule

`SCHEM_KEEP_HIER module interrupt_control(clk, reset, irq, nmi, t, tnext_mc, reg_p, load_i, intg, nmig, resp, vector_lo);
input clk;
input reset;
input irq;
input nmi;
input [2:0] t;
input [2:0] tnext_mc;
input [7:0] reg_p;

input load_i;
output intg;
output nmig;
output resp;
output [7:0] vector_lo;

// reset flip flop
reg resp;
reg nmil; // Delayed NMI for edge detection
reg nmig;
reg intp;
reg intg;

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
  else if(load_i)
  begin
      intg <= 0;
`ifdef NMI_BUG_FIX      
      if(~reg_p[`PF_B])
`endif
        nmig <= 0;
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

endmodule

`SCHEM_KEEP_HIER module branch_control(reg_p, ir, taken_branch);
input [7:0] reg_p;
input [7:5] ir;
output reg taken_branch;

always @(*)
begin
  taken_branch = 0;
	case({ir[7],ir[6]}) // synthesis full_case parallel_case
		2'b00: taken_branch = (reg_p[`PF_N] == ir[5]);
		2'b01: taken_branch = (reg_p[`PF_V] == ir[5]);
		2'b10: taken_branch = (reg_p[`PF_C] == ir[5]);
		2'b11: taken_branch = (reg_p[`PF_Z] == ir[5]);
	endcase
end

endmodule
