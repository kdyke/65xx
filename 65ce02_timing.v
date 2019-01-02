/* 
** Copyright (c) 2018 Kenneth C. Dyke
** 
** Permission is hereby granted, free of charge, to any person obtaining a copy
** of this software and associated documentation files (the "Software"), to deal
** in the Software without restriction, including without limitation the rights
** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
** copies of the Software, and to permit persons to whom the Software is
** furnished to do so, subject to the following conditions:
** 
** The above copyright notice and this permission notice shall be included in all
** copies or substantial portions of the Software.
** 
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
** SOFTWARE.
*/

`include "65ce02_inc.vh"

// This may be also defined to "fix" the original 6502 BRK/NMI bug without enabling the full CMOS stuff
`ifdef CMOS
`define NMI_BUG_FIX 1
`endif
`define NMI_BUG_FIX 1

//`define M65
`ifdef M65
`define RESET_HYPER 1'b1
`define RESET_VECHI 8'h81
`else
`define RESET_HYPER 1'b0
`define RESET_VECHI 8'hff
`endif

(* keep_hierarchy = "yes" *) module `timing_ctrl(clk, reset, ready, t, t_next, mc_sync, sync, onecycle);
input clk;
input reset;
input ready;
input mc_sync;
output sync;
input onecycle;
output [2:0] t;
output [2:0] t_next;

wire sync;
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

assign sync = (t == 1);

always @(posedge clk)
begin
  if(reset)       t <= T2;
  else if(ready) begin
    t <= t_next;
    //$display("T: %d t_next: %d sync: %d",t,t_next,sync);
  end
end

always @(*)
begin
  t_next = t+1;
  if(onecycle)
    t_next = T1;
  if(mc_sync)
    t_next = T1;

  //$display("Tn: %d t_next: %d mc_sync: %d onecycle: %d",t,t_next,mc_sync,onecycle);
  
  // synthesis translate_off
  //if(t == 7 && !mc_sync)
  //begin
  //  $display("Ran off end of microcode");
  //  $finish;
  //end
  if(t == 0)
  begin
    $display("Jumped to T0!");
    $finish;
  end
  // synthesis translate_on
end

endmodule

(* keep_hierarchy = "yes" *) module `predecode(data_i, sync, onecycle);
input [7:0] data_i;
input sync;
output onecycle;

// This detects single-cycle instructions - doing this the cheesy way for now.
reg onecycle;
always @(*)
begin
  casez(data_i)
  8'b0001_1000: onecycle = sync; // 0x18 - CLC
  8'b0011_1000: onecycle = sync; // 0x38 - SEC
  8'b0101_1000: onecycle = sync; // 0x58 - CLI
  8'b1zzz_1000: onecycle = sync; // 0x[8,9,A,B,C,D,E,F]8
  
  8'bz0zz_1010: onecycle = sync; // 0x[0,1,2,3,8,9,A,B][A]
  8'bz1z0_1010: onecycle = sync; // 0x[4,6,C,E]A
  8'b0zzz_1011: onecycle = sync; // 0x[0-7]B

  default:      onecycle = 0;
  endcase
  //$display("onecycle: %02x %d %d",ir_next,onecycle,active);
end

endmodule

(* keep_hierarchy = "yes" *) module `interrupt_control(clk, ready, reset, irq, nmi, mc_sync, reg_p, load_i, intg, nmig, resp, hyp, hyperg, hyper_mode, hyper_rti, pc_hold, vector_hi, vector_lo);
input clk;
input ready;
input reset;
input irq;
input nmi;
input hyp;
input mc_sync;
input hyper_rti;
input [7:0] reg_p;
output reg hyper_mode;

input load_i;
output intg;
output nmig;
output resp;
output wire pc_hold;
output reg hyperg;
output reg [7:0] vector_hi;
output reg [7:0] vector_lo;

// reset flip flop
reg resp;
reg nmil; // Delayed NMI for edge detection
reg nmig;
reg intp;
reg intg;

// This is the internal hypervisor mode bit.
reg hyper_mode_int;

// We need to start driving hyper_mode to 0 as soon as we are in
// the cycle that has the microcode signal that says to exit
// hypervisor mode.  This is because at this point we will already
// be driving the address bus with the first PC address to fetch
// upon exit.  The internal flip flop will lag by one cycle.
always @(*)
begin
  hyper_mode = hyper_mode_int & ~(hyper_rti&mc_sync);
end

always @(posedge clk)
begin
  if(reset)
    resp <= 1;
  else if(load_i)
    resp <= 0;
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
  
  if(ready | reset) begin
    if(reset | mc_sync)
    begin
      // Hypervisor interrupts take precedence over NMI and IRQ.
      if(hyp) begin
        hyperg <= 1;
        hyper_mode_int <= 1;
      end else if((((intp & ~reg_p[`kPF_I]) | nmig ) & ~hyper_mode_int) | reset) begin
        intg <= 1;
        hyperg <= 0;
        if(reset)
          hyper_mode_int <= `RESET_HYPER;
      end else if(hyper_rti) begin
        hyper_mode_int <= 0;
      end
    end
    // internal pending interrupt is always cleared at the same time we set interrupt mask.
    else if(load_i)
    begin
        if(hyperg) begin
          hyperg <= 0;      // Only clear hyperg.  Leave intg and nmig alone.
        end else begin        
          intg <= 0;
          if(intg)
            nmig <= 0;
        end
    end
  end
end

// Disable PC increment when processing a BRK with recognized IRQ/NMI or upon hypervisor entry
assign pc_hold = intg|hyperg;

always @(*)
begin
  if(resp == 1)
    vector_hi = `RESET_VECHI;
  else if(hyperg)
    vector_hi = 8'hD6;  // Hypervisor vectors through hypervisor register at 0xD660
  else
    vector_hi = 8'hFF;
end

always @(*)
begin
  if(resp == 1)
    vector_lo = 8'hFC;
  else if(hyperg)
    vector_lo = 8'h74;
  else if(nmig & intg)
    vector_lo = 8'hFA;
  else
    vector_lo = 8'hFE;
end

endmodule

(* keep_hierarchy = "yes" *) module `cond_control(reg_p, dld_z, test_flags, test_bit, cond_met);
input [7:0] reg_p;
input [4:0] test_flags;
input test_bit;
input dld_z;
output reg cond_met;

wire no_flag;

assign no_flag = ~|test_flags;

always @(*)
begin
  cond_met = ~(~test_bit ^ (no_flag | 
                          (test_flags[`kF_Z] & reg_p[`kPF_Z]) |
                          (test_flags[`kF_V] & reg_p[`kPF_V]) |
                          (test_flags[`kF_C] & reg_p[`kPF_C]) |
                          (test_flags[`kF_N] & reg_p[`kPF_N]) |
                          (test_flags[`kF_B] & dld_z)));
`ifdef NOTDEF
  $display("cond_met: %d  bit: %d no_flag: %d z: %d:%d v: %d:%d c: %d:%d n: %d:%d b: %d:%d x: %d",
    cond_met,test_bit,no_flag,
    test_flags[`kF_Z],reg_p[`kPF_Z],
    test_flags[`kF_V],reg_p[`kPF_V],
    test_flags[`kF_C],reg_p[`kPF_C],
    test_flags[`kF_N],reg_p[`kPF_N],
    test_flags[`kF_B],dld_z,
    (no_flag | 
                              (test_flags[`kF_Z] & reg_p[`kPF_Z]) |
                              (test_flags[`kF_V] & reg_p[`kPF_V]) |
                              (test_flags[`kF_C] & reg_p[`kPF_C]) |
                              (test_flags[`kF_N] & reg_p[`kPF_N]) |
                              (test_flags[`kF_B] & dld_z)));
`endif
end

endmodule
