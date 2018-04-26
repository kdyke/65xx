`include "6502_inc.vh"

module cpu6502(clk, reset, nmi, irq, ready, write, address, data_i, data_o);

initial begin
end

input clk, reset, irq, nmi, ready;
input [7:0] data_i;
output [7:0] data_o;
output [15:0] address;
output write;

// current timing state
reg [2:0] t;

// microcode output signals
wire [3:0] tnext_mc;     // top bit serves special purpose.
wire [2:0] adh_sel;
wire [2:0] adl_sel;
wire [2:0] db_sel;
wire [2:0] sb_sel;
wire pchs_sel;
wire pcls_sel;
wire [3:0] alu_op;
wire alu_a;
wire [1:0] alu_b;
wire [1:0] alu_c;
wire load_a;
wire load_x;
wire load_y;
wire load_sp;
wire load_abh;
wire load_abl;
wire write_cycle;
wire pc_inc;
wire [3:0] load_flags;

// Internal busses
reg [7:0] adh;
reg [7:0] db_in; 
reg [7:0] db_out;

reg [7:0] abl_adl;      // ADL that feeds into ABL and ALUB input
reg [7:0] pcls_adl;     // ADL that feeds only into PCLS

reg [7:0] pchs_adh;     // ADH that feeds only into PCHS

reg [7:0] sb;

// Internal registers
reg [7:0] abh;
reg [7:0] abl;
reg [7:0] pch;
reg [7:0] pcl;

// Architectural registers
reg [7:0] reg_a;
reg [7:0] reg_x;
reg [7:0] reg_y;
reg [7:0] reg_s;
reg [7:0] reg_p;

reg [2:0] t_next;
reg [7:0] ir;

// ALU inputs and outputs
reg [7:0] alua_in;
reg [7:0] alub_in;
reg aluc_in;
wire [7:0] alu_out;
wire alu_d;

reg taken_branch;
reg alu_carry_out_last;
wire branch_page_cross;
wire [7:0] ir_sel;

// reset flip flip
reg reset_f;

reg [7:0] alua_reg;
reg [7:0] alub_reg;

wire [7:0] decadj_out;
wire dec_add, dec_sub;
wire alu_carry_out,alu_half_carry_out, alu_decimal_enable;

// Branch-to-self detection
// synthesis translate_off
reg [15:0] last_fetch_addr;
// synthesis translate_on

// predecode signals
reg twocycle;

// PCL select in/out
reg [7:0] pcls_in;
// Extra bit for carry output
reg [8:0] pcls;

// PCH select in/out
reg [7:0] pchs_in;
reg [7:0] pchs;

always @(posedge clk or posedge reset)
begin
  if(reset)
    reset_f = 1;
  else if(t == 0)
    reset_f = 0;
end

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
  
// During t1, microcode input addr is selected directly from data_i
assign ir_sel = t == 1 ? data_i : ir;
assign address = { abh, abl };
assign write = write_cycle;
assign data_o = db_out;

// A page is crossed if the carry result is different than the sign of the branch offset input
assign branch_page_cross = alu_carry_out ^ alua_reg[7];

// This detects the instruction patterns where we need to go immediately to T0 instead of T2.
always @(*)
begin
  twocycle = 0;
  if(t == 1) begin
    if((ir_sel & 8'b00011101) == 8'b00001001 || (ir_sel & 8'b10011101) == 8'b10000000 ||
      ((ir_sel & 8'b00001101) == 8'b00001000 && (ir_sel & 8'b10010010) != 8'b00000000))
      twocycle = 1;
  end
  //$display("TWOCYCLE: %d",twocycle);
end

// Next cycle (T) selection.   Eventually will need to add more predecode stuff here....
always @(*)
begin
  // Defaults to next microcode t-state bottom 3 bits
  t_next = t+1;
  if(reset)
    t_next = 5;
  else if(t == 1 && twocycle == 1)
    t_next = 0;
  else if(tnext_mc == `T0)
    t_next = 0;
  else if(tnext_mc == `TNC)
  begin
    if(alu_carry_out == 0)
      t_next = 0;
      //$display("TNC t: %d carry: %d t_next: %d",t,alu_carry_out,t_next);
  end
  else if(tnext_mc == `TBR)
  begin
    //$display("tn = TBR, taken_branch = %d",taken_branch);
     if(taken_branch == 0)
        t_next = 1;
  end
  else if(tnext_mc == `TBE)
  begin
    if(branch_page_cross == 1)
      t_next = 0;
    else
      t_next = 1;
    //$display("t: %d tn = TBE, taken_branch, alu_a: %02x alu_b: %02x alu_c: %d alu_out: %02x alu_c_out: %d branch page cross = %d t_next = %d",t,
    //  alua_reg, alub_reg, aluc_in, alu_out, alu_carry_out,
    //  branch_page_cross,t_next
    //  );
  end
  else if(t != 1 && tnext_mc == `TKL)
  begin
    $display("FETCH ADDR: %04x byte: %02x  TWOCYCLE: %d (Microcode KIL)",address,data_i,twocycle);
    //$display("mc[%d | %d]",ir,t);
    $finish;
  end
end

always @(posedge clk)
begin
  t <= t_next;
end

always @(*)
begin
  if(pcls_sel == `PCLS_PCL)
    pcls_in = pcl;
  else
    pcls_in = pcls_adl;
  pcls = pcls_in + pc_inc;
  //$display("pls_sel: %d pcl: %02x adl: %02x pcls_in: %02x pcls: %02x",pcls_sel,pcl,adl,pcls_in,pcls);
end

always @(*)
begin
  if(pchs_sel == `PCHS_PCH)
    pchs_in = pch;
  else
    pchs_in = pchs_adh;
  pchs = pchs_in + pcls[8];
  //$display("phs_sel: %d pch: %02x adh: %02x pchs_in: %02x pchs: %02x",pchs_sel,pch,adh,pchs_in,pchs);
end

// IR is always loaded from data_i during t1  (data_i was fetched during t0)
always @(posedge clk)
begin
  if(reset)
    ir <= 8'h00;
  else if(t == 1)
  begin
    ir <= data_i;
     // synthesis translate off
     if(last_fetch_addr == address)
     begin
      $display("Halting, branch to self detected: %04x   A: %02x X: %02x Y: %02x S: %02x P: %02x ",last_fetch_addr,
        reg_a, reg_x, reg_y, reg_s, reg_p);
      $finish;
    end
    last_fetch_addr <= address;
     // synthesis translate on
    
    //$display("FETCH ADDR: %04x byte: %02x  TWOCYCLE: %d",address,data_i,twocycle);
  end
end

// Temporary hack for CPU bootstrapping until I get interrupts hooked up
reg [7:0] vector_lo;

always @(*)
begin
  // Default BRK vector
  vector_lo = 8'hFE;
  if(reset_f == 1)
    vector_lo = 8'hFC;
end

// ADH -> PCHS
always @(*)
begin
  pchs_adh = data_i;
  case(adh_sel)  // synthesis full_case parallel_case
    `ADH_DI  : pchs_adh = data_i;
    `ADH_ALU : pchs_adh = alu_out;
  endcase
  //$display("ADH: t: %d adh_sel: %d adh: %02x ",t,adh_sel,adh);
end


// ADH mux
always @(*)
begin
  case(adh_sel)  // synthesis full_case parallel_case
    `ADH_DI  : adh = data_i;
    `ADH_PCHS: adh = pchs;
    `ADH_ALU : adh = alu_out;
    `ADH_0   : adh = 8'h00;
    `ADH_1   : adh = 8'h01;
    `ADH_FF  : adh = 8'hFF;
  endcase
  //$display("ADH: t: %d adh_sel: %d adh: %02x ",t,adh_sel,adh);
end

// ADL -> PCLS
always @(*)
begin
  pcls_adl = data_i;
  case(adl_sel) // synthesis full_case parallel_case
    `ADL_DI    : pcls_adl = data_i;
    `ADL_S     : pcls_adl = reg_s;
    `ADL_ALU   : pcls_adl = alu_out;
  endcase
end

// ADL -> ABL
always @(*)
begin
  case(adl_sel) // synthesis full_case parallel_case
    `ADL_DI    : abl_adl = data_i;
    `ADL_PCLS  : abl_adl = pcls;
    `ADL_S     : abl_adl = reg_s;
    `ADL_ALU   : abl_adl = alu_out;
    `ADL_VECLO : abl_adl = vector_lo;
    `ADL_VECHI : abl_adl = vector_lo | 1;
  endcase
  //$display("ADL: t: %d adl_sel: %d adl: %02x",t,adl_sel,adl);
end

// DB input mux
always @(*)
begin
  case(db_sel)  // synthesis full_case parallel_case
    `DB_FF  : db_in = 8'hFF;
    `DB_DI  : db_in = data_i;
    `DB_A   : db_in = reg_a;
//    `DB_SB  : db_in = sb;
//    `DB_PCL : db_in = pcl;
//    `DB_PCH : db_in = pch;
//    `DB_P   : db_in = reg_p | 8'h30;      // Temp kludge until interrupts are implmented and I have a mechanism for pusing P with B set to 0
    `DB_BO  : db_in = {8{alua_reg[7]}};   // The high bit of the last ALU A input is the sign bit for branch offsets
  endcase
end

// DB output mux
always @(*)
begin
  case(db_sel)  // synthesis full_case parallel_case
//    `DB_FF  : db_out = 8'hFF;
//    `DB_DI  : db_out = data_i;
    `DB_A   : db_out = reg_a;
    `DB_SB  : db_out = sb;
    `DB_PCL : db_out = pcl;
    `DB_PCH : db_out = pch;
    `DB_P   : db_out = reg_p | 8'h30;      // Temp kludge until interrupts are implmented and I have a mechanism for pusing P with B set to 0
//    `DB_BO  : db_out = {8{alua_reg[7]}};   // The high bit of the last ALU A input is the sign bit for branch offsets
  endcase
end

// SB input mux
always @(*)
begin
  case(sb_sel)  // synthesis full_case parallel_case
    `SB_A   : sb = reg_a;
    `SB_X   : sb = reg_x;
    `SB_Y   : sb = reg_y;
    `SB_SP  : sb = reg_s;
    `SB_ALU : sb = alu_out;
    `SB_ADH : sb = adh;
    `SB_DB  : sb = db_in;
    `SB_FF  : sb = 8'hFF;
  endcase
    //$display("sb_sel: %d  sb: %02x",sb_sel,sb);
end

// ALU A input select
always @(*)
begin
  case(alu_a)  // synthesis full_case parallel_case
    `ALU_A_0  : alua_in = 8'h00;
    `ALU_A_SB : alua_in = sb;
  endcase
    //$display("alu_a_in: %02x",alua_in);
end

// ALU B input select
always @(*)
begin
  case(alu_b)  // synthesis full_case parallel_case
    `ALU_B_DB  : alub_in = db_in;
    `ALU_B_NDB : alub_in = ~db_in;
    `ALU_B_ADL : alub_in = abl_adl;
  endcase
    //$display("alu_b: %d  alub_in: %02x",alu_b,alub_in);
end

// ALU C (carry) input select
always @(*)
begin
  case(alu_c)  // synthesis full_case parallel_case
    `ALU_C_0 : aluc_in = 0;
    `ALU_C_1 : aluc_in = 1;
    `ALU_C_P : aluc_in = reg_p[0];
    `ALU_C_AC : aluc_in = alu_carry_out_last;    // last clocked out carry
  endcase
end


// clocked ALU inputs (only A and B, everything else is "live") and outputs
always @(posedge clk)
begin
  alua_reg <= alua_in;
  //$display("ALUA = %02x",alua_in);
  if(alu_b != 0)        // This is kindof a hack
  begin
    alub_reg <= alub_in;
    //$display("ALUB = %02x",alub_in);
  end
  alu_carry_out_last <= alu_carry_out;
end

// ABL/ADH registers
always @(posedge clk)
begin
  if(load_abh)
  begin
    if(adh_sel == `ADH_PCHS)
      abh <= pchs;
    else
      abh <= adh;
  end
  if(load_abl)
      abl <= abl_adl;
end

// PCH/PCL always take value of PCHS/PCLS
always @(posedge clk)
begin
    pch <= pchs;
    pcl <= pcls;
end

// FIXME - This is kinda hacky right now.  Really should have a pair of dedicated microcode bits for this.
assign dec_add = reg_p[`PF_D] & (load_flags == `FLAGS_ALU) & (alu_op == `ALU_ADC);
assign dec_sub = reg_p[`PF_D] & (load_flags == `FLAGS_ALU) & (alu_op == `ALU_SBC);
  decadj_adder dadj(sb, decadj_out, alu_carry_out, alu_half_carry_out, dec_add, dec_sub);

always @(posedge clk)
begin
  if(load_a)
    begin
      reg_a <= decadj_out;
      //$display("A = %02x",sb);
    end
  if(load_x)
    begin
      reg_x <= sb;
    //$display("LOAD X alu_a: %02x alu_b: %02x alu_c: %d alu_out: %02x alu_c_out: %d ",
    //  alua_reg, alub_reg, aluc_in, alu_out, alu_carry_out);
      //$display("X = %02x",sb);
    end
  if(load_y)
    begin
      reg_y <= sb;
      //$display("Y = %02x",sb);
    end
  if(load_sp)
    begin
      reg_s <= sb;
      //$display("S = %02x",sb);
    end
end

wire db_z;

assign sb_z = ~|sb;
assign sb_n = sb[7];

// TODO - Consider turning this into a bigger bitfield with individual control bits for which
// flags to update (and from where) rather than needing all of the decode control logic.  Microcode
// bits are cheap. ;)
always @(posedge clk)
begin
  if(load_flags == `FLAGS_DB)
  begin
    reg_p <= db_in;
    //$display("LOAD P from DB: %02x",db);
  end
  else if(load_flags == `FLAGS_DBZN)
    begin
      reg_p[`PF_Z] <= sb_z;
      reg_p[`PF_N] <= sb_n;
    end
  else if(load_flags == `FLAGS_D)
    reg_p[`PF_D] <= ir[5];
  else if(load_flags == `FLAGS_I)
    reg_p[`PF_I] <= ir[5];
  else if(load_flags == `FLAGS_C)
    reg_p[`PF_C] <= ir[5];
  else if(load_flags == `FLAGS_V)
    reg_p[`PF_V] <= 0;
  else if(load_flags == `FLAGS_Z)
    reg_p[`PF_Z] <= sb_z;
  else if(load_flags == `FLAGS_SETI)
    reg_p[`PF_I] <= 1;
  else if(load_flags == `FLAGS_CNZ)
    begin
      reg_p[`PF_C] <= alu_carry_out;
      //$display("status register C = %d",alu_carry_out);
      reg_p[`PF_Z] <= sb_z;
      //$display("status register Z = %d",db_z);
      reg_p[`PF_N] <= sb_n; 
      //$display("status register N = %d",db_n);
    end
  else if(load_flags == `FLAGS_ALU)
    begin
      reg_p[`PF_C] <= alu_carry_out;
      //$display("status register C = %d",alu_carry_out);
      reg_p[`PF_Z] <= sb_z;
      //$display("status register Z = %d",db_z);
      reg_p[`PF_V] <= alu_overflow_out;
      //$display("status register V = %d",alu_overflow_out);
      reg_p[`PF_N] <= sb_n;
      //$display("status register N = %d",db_n);
    end
  else if(load_flags == `FLAGS_BIT)
    begin
      reg_p[`PF_V] <= db_in[6];
      //$display("status register Z = %d",db_in[6]);
      reg_p[`PF_N] <= db_in[7]; 
      //$display("status register N = %d",db_in[7]);
    end
end

// Instantiate ALU
alu_unit alu_inst(alua_reg, alub_reg, alu_out, aluc_in, dec_add, alu_op, alu_carry_out, alu_half_carry_out, alu_overflow_out);

// Note: microcode outputs are *synchronous* and show up on following clock and thus are always driven directly by t_next and not t.
microcode mc_inst(.clk(clk), .ir(ir_sel), .t(t_next), .tnext(tnext_mc), .adh_sel(adh_sel), .adl_sel(adl_sel),
                  .pchs_sel(pchs_sel), .pcls_sel(pcls_sel), .alu_op(alu_op), .alu_a(alu_a), .alu_b(alu_b), .alu_c(alu_c),
                  .db_sel(db_sel), .sb_sel(sb_sel),
                  .load_a(load_a), .load_x(load_x), .load_y(load_y), .load_sp(load_sp),
                  .load_abh(load_abh), .load_abl(load_abl), .load_flags(load_flags), .write_cycle(write_cycle), .pc_inc(pc_inc));

endmodule
