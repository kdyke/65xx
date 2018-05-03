`include "6502_inc.vh"

module timing_ctrl(clk, reset, ready, t, t_next, tnext_mc, alu_carry_out, taken_branch, branch_page_cross, dec_extra_cycle, onecycle, twocycle, dec_cycle);
input clk;
input reset;
input ready;
input [2:0] tnext_mc;
input alu_carry_out;
input taken_branch;
input branch_page_cross;
input dec_cycle;
input dec_extra_cycle;
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
  t_next = 'bx;
  
  case(t)
    T0 :  t_next = T1;
    T1 :  begin
            if(onecycle)
              t_next = T1;
            else if(dec_cycle)
              t_next = T7;
            else if(twocycle)
              t_next = T0;
            else
              t_next = T2;
          end
    T2 :  begin
            if(tnext_mc == `T0)
              t_next = T0;
            else if(tnext_mc == `TBR && taken_branch == 0)
              t_next = T1;
            else
              t_next = T3;
          end
    T3  :  begin
            if(tnext_mc == `TNC && alu_carry_out == 0)
              t_next = T0;
            else if(tnext_mc == `TBE)
            begin
              if(branch_page_cross == 1)
                t_next = T0;
              else
                t_next = T1;
            end
            else if(tnext_mc == `TBT && alu_carry_out == 0)
              t_next = T1;
            else if(tnext_mc == `T0)
              t_next = T0;
            else
              t_next = T4;
          end
    T4 :  begin
            if(tnext_mc == `TNC && alu_carry_out == 0)
              t_next = T0;
            else if(tnext_mc == `TBT && alu_carry_out == 0)
              t_next = T1;
            else if(tnext_mc == `T0)
              t_next = T0;
            else
              t_next = T5;
          end
    T5 :  begin
            if(tnext_mc == `TBE)
            begin
              if(branch_page_cross == 1)
                t_next = T0;
              else
                t_next = T1;
            end
            else if(tnext_mc == `T0)
              t_next = T0;
            else
              t_next = T6;
          end
    T6 :  begin
            if(tnext_mc == `T0)
              t_next = T0;
            else
              t_next = T7;
          end
    T7 :  begin
            if(dec_extra_cycle)
              t_next = T2;
            else
              t_next = T0;
          end
  endcase
end

endmodule
