`include "6502_inc.vh"

module timing_ctrl(clk, reset, ready, t, t_next, tnext_mc, alu_carry_out, taken_branch, branch_page_cross, fetch_cycle, decimal_extra_cycle, onecycle, twocycle, decimal_cycle);
input clk;
input reset;
input ready;
input [2:0] tnext_mc;
input alu_carry_out;
input taken_branch;
input branch_page_cross;
input fetch_cycle;
input decimal_cycle;
input decimal_extra_cycle;
input onecycle;
input twocycle;
output [2:0] t;
output [2:0] t_next;

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

module predecode(ir_next, onecycle, twocycle);
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