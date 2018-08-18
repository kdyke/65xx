`include "6502_inc.vh"

// This may be also defined to "fix" the original 6502 BRK/NMI bug without enabling the full CMOS stuff
`ifdef CMOS
`define NMI_BUG_FIX 1
`endif
`define NMI_BUG_FIX 1

`SCHEM_KEEP_HIER module timing_ctrl(clk, reset, ready, t, t_next, mc_sync, sync, onecycle);
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

`SCHEM_KEEP_HIER module predecode(ir_next, active, onecycle);
input [7:0] ir_next;
input active;
output onecycle;

// This detects single-cycle instructions - doing this the cheesy way for now.
reg onecycle;
always @(*)
begin
  casez(ir_next)
  8'b0001_1000: onecycle = active; // 0x18 - CLC
  8'b0011_1000: onecycle = active; // 0x38 - SEC
  8'b0101_1000: onecycle = active; // 0x58 - CLI
  8'b1zzz_1000: onecycle = active; // 0x[8,9,A,B,C,D,E,F]8
  
  8'bz0zz_1010: onecycle = active; // 0x[0,1,2,3,8,9,A,B][A]
  8'bz1z0_1010: onecycle = active; // 0x[4,6,C,E]A
  8'b0zzz_1011: onecycle = active; // 0x[0-7]B

  default:      onecycle = 0;
  endcase
  //$display("onecycle: %02x %d %d",ir_next,onecycle,active);
end

endmodule

`SCHEM_KEEP_HIER module interrupt_control(clk, reset, irq, nmi, t, reg_p, load_i, intg, nmig, resp, vector_lo);
input clk;
input reset;
input irq;
input nmi;
input [2:0] t;
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
  
  if(reset || (t == 2))
  begin
    if((intp & ~reg_p[`kPF_I]) | nmig | reset)
      intg <= 1;
  end
  // internal pending interrupt is always cleared at the same time we set interrupt mask.
  else if(load_i)
  begin
      intg <= 0;
      if(intg)
        nmig <= 0;
  end
end

reg [7:0] vector_lo;

always @(*)
begin
  if(resp == 1)
    vector_lo = 8'hFC;
  else if(nmig & intg)
    vector_lo = 8'hFA;
  else
    vector_lo = 8'hFE;
end

endmodule

`SCHEM_KEEP_HIER module cond_control(reg_p, dld_z, test_flags, test_bit, cond_met);
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
