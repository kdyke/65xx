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

`define CPU65CE02_TIMING_DEBUG
`ifdef CPU65CE02_TIMING_DEBUG
`define MARK_DEBUG (* mark_debug = "true", dont_touch = "true" *)
`else
`define MARK_DEBUG
`endif

// Description of phases and transitions
//
// phase0 - right after latching data.   This is where we will load the microcode so the datapath happens during phase 1
// phase1 - driving datapath and then updating address/data outputs at the rising edge of the clk going into phase 2
// phase2 - driving address/data/etc bus signals.  always proceeds to phase 3?
// phase3 - waiting for data to arrive.   Latches data and stops driving bus if ready is asserted during this phase.

// TODO - Determine if we should run the datapath during phase0.  This would imply that the microcode is updated directly
// from the data bus, allowing the address to show up one full external cycle before phase2.  Still TBD.

// The output signals are driven high when we're basically "completing" that state and can be thought of as clock enables
// for the external flip flops.  There's a separate internal state vector that's combined as needed with things like the
// ready signal to generate the outputs and next state transitions.
(* keep_hierarchy = "yes" *) module state_ctl(input clk, input reset, `MARK_DEBUG input ready,
  `MARK_DEBUG output reg phase0, `MARK_DEBUG output reg phase1, `MARK_DEBUG output reg phase2, `MARK_DEBUG output reg phase3);

parameter PHASE0 = 2'b00, PHASE1 = 2'b01, PHASE2 = 2'b10, PHASE3 = 2'b11;

reg [1:0] state, next;

always @(posedge clk) begin
  if(reset)
    state <= PHASE0;
  else begin
    state <= next;
    //$display("state: %d",next);
  end
end

always @(*) begin
  next = 1'bx;
  phase0 = 1'b0;
  phase1 = 1'b0;
  phase2 = 1'b0;
  phase3 = 1'b0;
  case(state)
    PHASE0: begin
              phase0 = 1;
              next = PHASE1;
            end
    PHASE1: begin
              phase1 = 1;
              next = PHASE2;
            end
    PHASE2: begin
              phase2 = 1;
              next = PHASE3;
            end
    PHASE3: begin
              phase3 = ready;
              if(ready)
                next = PHASE0;
              else
                next = PHASE3;
            end
  endcase
end    
  
endmodule

//`define M65
`ifdef M65
`define RESET_HYPER 1'b1
`define RESET_VECHI 8'h81
`else
`define RESET_HYPER 1'b0
`define RESET_VECHI 8'hff
`endif

(* keep_hierarchy = "yes" *) module `timing_ctrl(input clk, input reset, `MARK_DEBUG input ready, 
      `MARK_DEBUG output reg [8:0] mca, `MARK_DEBUG output reg [8:0] next_mca, `MARK_DEBUG input [8:0] next_mca_ucode, 
      `MARK_DEBUG input [8:0] next_mca_a0, `MARK_DEBUG input [8:0] next_mca_a1, `MARK_DEBUG input [1:0] next_mca_sel,
      `MARK_DEBUG input mc_sync, `MARK_DEBUG output reg sync, `MARK_DEBUG input onecycle,
      `MARK_DEBUG input mc_cond_met);

`MARK_DEBUG reg sync_next;

always @(posedge clk)
begin
  if(reset) begin
    mca <= 0;      // This is primarily just for debugging/logging/monitor/etc.
    sync <= 0;
  end else if(ready) begin
    mca <= next_mca;      // This is primarily just for debugging/logging/monitor/etc.
    sync <= sync_next;
  //$display("mca: %03x next_mca: %03x: sync: %d mc_cond_met: %d",mca,next_mca,sync,mc_cond_met);
  //$display("r: %d rdy: %d mca: %03x mca_next: %03x mc_sync: %d onecycle: %d mca_sel: %d uc: %03x a0: %03x a1: %03x",reset, ready, mca, next_mca, mc_sync,onecycle,next_mca_sel,
  //  next_mca_ucode,next_mca_a0,next_mca_a1);
  end
end

always @(*)
begin
  next_mca = 1'b0;//mca;
  sync_next = 1'b0;//sync;
  if(1) begin
    sync_next = 0;
    if(onecycle) begin
      //next_mca = next_mca_a0;
      sync_next = 1;
    end
    if(mc_sync) begin
      //next_mca = next_mca_a0;
      sync_next = 1;
    end
    next_mca = next_mca_ucode;
    if(sync)
      next_mca = next_mca_a0;
    else if(mc_cond_met)
      next_mca = mca+1;
    else if(next_mca_sel == `kNEXT_A1)
      next_mca = next_mca_a1;
  end
  if(reset) begin
    next_mca = 9'h00;
  end
  //$display("timing: next_mca: %02x   mca: %02x sync: %d onecycle: %d mc_sync: %d ucode: %02x sn: %d sel: %d cond: %d",next_mca,mca,sync,onecycle,mc_sync,next_mca_ucode,sync_next,next_mca_sel,mc_cond_met);
  // synthesis translate_off
  //if(t == 7 && !mc_sync)
  //begin
  //  $display("Ran off end of microcode");
  //  $finish;
  //end
  //if(t == 0)
  //begin
  //  $display("Jumped to T0!");
  //  $finish;
  //end
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
  //$display("onecycle: %02x %d %d",data_i,onecycle,sync);
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
  //hyper_mode = hyper_mode_int & ~(hyper_rti&mc_sync);
  hyper_mode <= hyper_mode_int; // & ~(hyper_rti&mc_sync);
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

(* keep_hierarchy = "yes" *) module mc_cond_control(input slow, input branch_cond_met, input branch_page_cross, input alu_carry_out, input alu_last_carry,
    input [2:0] mc_cond, output reg mc_cond_met);

always @(*)
begin
  mc_cond_met = 0;
  if(slow)
  begin
    //$display("mc_cond: %d bc: %d bp: %d co: %d lc: %d",mc_cond,branch_cond_met,branch_page_cross,alu_carry_out,alu_last_carry);
    case(mc_cond)
      `kNEXT_COND_BRANCH: mc_cond_met = branch_cond_met;
      `kNEXT_COND_BPC:    mc_cond_met = branch_page_cross;
      `kNEXT_COND_LC:     mc_cond_met = alu_last_carry;
      default:            ;
    endcase
  end
end

endmodule

(* keep_hierarchy = "yes" *) module `cond_control(reg_p, dld_z, ir, test_flags, test_bit, cond_met);
input [7:0] reg_p;
input [7:5] ir;
input [1:0] test_flags;
input test_bit;
input dld_z;
output reg cond_met;

wire no_flag;

reg [4:0] test_mask;

reg test_polarity;

always @(*)
begin
  test_mask = 0;
  test_polarity = 0;
  if(test_flags[0])
  begin
    test_polarity = ~ir[5];
    case(ir[7:6])
  		2'b00: test_mask[`kF_N] = 1;
  		2'b01: test_mask[`kF_V] = 1;
  		2'b10: test_mask[`kF_C] = 1;
  		2'b11: test_mask[`kF_Z] = 1;
    endcase
   end
   
   else if(test_flags[1]) begin
     test_polarity = test_bit;
     test_mask[`kF_B] = 1;
    end
end
 
assign no_flag = ~|test_mask;

always @(*)
begin
  cond_met = ~(~test_polarity ^ (no_flag | 
                          (test_mask[`kF_Z] & reg_p[`kPF_Z]) |
                          (test_mask[`kF_V] & reg_p[`kPF_V]) |
                          (test_mask[`kF_C] & reg_p[`kPF_C]) |
                          (test_mask[`kF_N] & reg_p[`kPF_N]) |
                          (test_mask[`kF_B] & dld_z)));
`ifdef NOTDEF
  $display("cond_met: %d  ir: %x bit: %d no_flag: %d z: %d:%d v: %d:%d c: %d:%d n: %d:%d b: %d:%d x: %d",
    cond_met,ir,test_polarity,no_flag,
    test_mask[`kF_Z],reg_p[`kPF_Z],
    test_mask[`kF_V],reg_p[`kPF_V],
    test_mask[`kF_C],reg_p[`kPF_C],
    test_mask[`kF_N],reg_p[`kPF_N],
    test_mask[`kF_B],dld_z,
    (no_flag | 
                              (test_mask[`kF_Z] & reg_p[`kPF_Z]) |
                              (test_mask[`kF_V] & reg_p[`kPF_V]) |
                              (test_mask[`kF_C] & reg_p[`kPF_C]) |
                              (test_mask[`kF_N] & reg_p[`kPF_N]) |
                              (test_mask[`kF_B] & dld_z)));
`endif
end

endmodule
