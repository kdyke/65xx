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

`undef MARK_DEBUG

`define CPU4510_HYPER_DEBUG
`ifdef CPU4510_MAPPER_DEBUG
`define MARK_DEBUG (* mark_debug = "true", dont_touch = "true" *)
`else
`define MARK_DEBUG
`endif

(* keep_hierarchy = "yes" *) module mapper4510(input clk, input reset, input [7:0] data_i, `MARK_DEBUG input [7:0] data_o, input ready, input sync,
                  input [1:0] map_reg_write_sel, input hypervisor_load_user_reg,
                  input ext_irq, input ext_nmi, output cpu_irq, output cpu_nmi,
                  `MARK_DEBUG input hyper_mode, input map_insn, input [1:0] t,
                  output reg [7:0] map_reg_data, output reg mapper_busy,
                  output reg [19:0] address, input [15:0] core_address_next, 
                  `MARK_DEBUG output reg map_next, output reg map,
                  output wire [11:0] monitor_map_offset_low,
                  output wire [11:0] monitor_map_offset_high,
                  output wire [3:0] monitor_map_enables_low,
                  output wire [3:0] monitor_map_enables_high
                  );

`MARK_DEBUG reg [19:8] map_offset[0:3];
`MARK_DEBUG reg [3:0] map_enable[0:3];
reg int_enable;
reg enable_i, disable_i;

`MARK_DEBUG reg load_a, load_x, load_y, load_z;
`MARK_DEBUG reg load_map_sel;

reg [19:0] address_next;

// It's not clear whether NMI should be done this way or not. The C65 docs aren't clear on if the MAP instruction masks off NMIs.
assign cpu_irq = ext_irq & int_enable;
assign cpu_nmi = ext_nmi & int_enable;

//`define FAST_MAPPER
`ifdef FAST_MAPPER
reg [19:8] map_offset_fast[0:15]; // Two sets of 8
reg map_enable_fast[0:15]; // Two sets of 8
reg map_enable_tmp;
//reg mapper_busy;
reg refresh_sel;
reg [3:0] refresh_cnt;
`endif

always @(posedge clk) begin
  if(reset) begin
    map_offset[0][15:8] <= 8'h00;
    map_offset[2][15:8] <= 8'h00;
  end
    else if(load_a) map_offset[{load_map_sel,1'b0}][15:8] <= data_o;
  
  if(reset) begin
    map_offset[0][19:16] <= 4'h0;
    map_offset[2][19:16] <= 4'h0;
  end
    else if(load_x) map_offset[{load_map_sel,1'b0}][19:16] <= data_o[3:0];
  
  if(reset) begin
    map_enable[0][3:0] <= 4'h0;
    map_enable[2][3:0] <= 4'h0;
  end
    else if(load_x) map_enable[{load_map_sel,1'b0}][3:0] <= data_o[7:4];
  
  if(reset) begin
    map_offset[1][15:8] <= 8'h00;
    map_offset[3][15:8] <= 8'h00;
  end
    else if(load_y) map_offset[{load_map_sel,1'b1}][15:8] <= data_o;
  
  if(reset) begin
    map_offset[1][19:16] <= 4'h0;
    map_offset[3][19:16] <= 4'hf;
  end
    else if(load_z) map_offset[{load_map_sel,1'b1}][19:16] <= data_o[3:0];

  if(reset) begin
    map_enable[1][3:0] <= 4'h0;
    map_enable[3][3:0] <= 4'h3;
`ifdef FAST_MAPPER
    mapper_busy <= 1;
    refresh_cnt <= 0;
`endif
  end 
    else if(load_z) begin
      map_enable[{load_map_sel,1'b1}][3:0] <= data_o[7:4];
`ifdef FAST_MAPPER
      mapper_busy <= 1;
      refresh_sel <= load_map_sel;
      refresh_cnt <= 0;
    end else if(mapper_busy) begin
      refresh_cnt <= refresh_cnt + 1;
      if(refresh_cnt == 15)
        mapper_busy <= 0;
`endif
    end
    
  if(reset) int_enable <= 1;
  else if(disable_i) int_enable <= 0;
  else if(enable_i) int_enable <= 1;
  
`ifdef FAST_MAPPER
  if(mapper_busy) begin
    map_enable_tmp = map_enable[refresh_cnt[3:2]][refresh_cnt[1:0]];
    map_enable_fast[refresh_cnt[3:0]] <= map_enable_tmp;
    map_offset_fast[refresh_cnt[3:0]] <= map_enable_tmp ? map_offset[refresh_cnt[3:2]] : 0;
  end
`else
  mapper_busy <= 0;
`endif
    
end

// Monitor map info
assign monitor_map_offset_low = map_offset[{hyper_mode,1'b0}];
assign monitor_map_offset_high = map_offset[{hyper_mode,1'b1}];
assign monitor_map_enables_low = map_enable[{hyper_mode,1'b0}];
assign monitor_map_enables_high = map_enable[{hyper_mode,1'b1}];

// Mapper combinatorial path
`ifdef FAST_MAPPER
`MARK_DEBUG reg [3:0] map_index;
`else
`MARK_DEBUG reg [1:0] map_enable_index;
`MARK_DEBUG reg map_offset_index;
`endif

`MARK_DEBUG reg [19:0] mapper_address;
`MARK_DEBUG reg [19:8] current_offset;
`MARK_DEBUG reg map_en;

always @(*) begin
`ifdef FAST_MAPPER
  map_index = {hyper_mode,core_address_next[15:13]};
  current_offset = map_offset_fast[map_index];
  map_en = map_enable_fast[map_index];
`else
  map_offset_index = core_address_next[15];
  map_enable_index = core_address_next[14:13];
  //$display("off_idx: %d en_idx: %d en: %d offset: %03x",map_offset_index,map_enable_index,map_enable[{hyper_mode,map_offset_index}][map_enable_index],map_offset[{hyper_mode,map_offset_index}]);
  // Mapper can be disabled by external (hypervisor) logic when needed.
  if(map_enable[{hyper_mode,map_offset_index}][map_enable_index]) begin
    current_offset = map_offset[{hyper_mode,map_offset_index}];
    map_en = 1;
  end else begin
    current_offset = 0;
    map_en = 0;
  end
`endif

  mapper_address[19:8] = current_offset[19:8] + core_address_next[15:8];
  mapper_address[7:0] = core_address_next[7:0];
  
  address_next = mapper_address;
  map_next = map_en;
end

// Registered output address
always @(posedge clk) begin
  if(ready) begin
    address <= address_next;
    map <= map_next;
  end
end

// Expose internal user mapper state to hypervisor controller.  The selection is always
// based on the bottom two CPU address bits.   Note: The ordering here is so that the
// addresses line up with how the legacy hypervisor registers are placed, which is like
// this:
/*
          HYPER_REG_MAP_X = 6'h0A,
          HYPER_REG_MAP_A = 6'h0B,
          HYPER_REG_MAP_Z = 6'h0C,
          HYPER_REG_MAP_Y = 6'h0D,
*/
always @(*) begin
  case(core_address_next[1:0])
    3: map_reg_data = map_offset[0][15:8];                        // A
    2: map_reg_data = {map_enable[0][3:0], map_offset[0][19:16]}; // X
    1: map_reg_data = map_offset[1][15:8];                        // Y
    0: map_reg_data = {map_enable[1][3:0], map_offset[1][19:16]}; // Z
  endcase
end

// Look for either MAP or EOM (NOP) being fetched.
always @* begin
  load_a = 0;
  load_x = 0;
  load_y = 0;
  load_z = 0;
  enable_i = 0;
  disable_i = 0;
  load_map_sel = hyper_mode;
  
  // This doesn't need to be dependent on the state machine.
  if(data_i == 8'hEA && ready && sync)
    enable_i = 1;
  
  // So long as mapper state is idle (we're not executing a MAP instruction) we can also
  // allow direct user mapper register updates via the hypervisor controller I/O registers.
  // See comment up above on why these are in a seemingly strange order.
  if(map_insn == 0) begin
    if(hypervisor_load_user_reg) begin
      case(map_reg_write_sel)
        3: begin
          load_map_sel = 0;
          load_a = 1;
        end
        2: begin
          load_map_sel = 0;
          load_x = 1;
        end
        1: begin
          load_map_sel = 0;
          load_y = 1;
        end
        0: begin
          load_map_sel = 0;
          load_z = 1;
        end
      endcase
    end
  end else begin
    disable_i = 1;
    if(ready)
    begin
      case(t)
        2: load_a = 1;
        3: load_x = 1;
        0: load_y = 1;
        1: load_z = 1;
      endcase
    end
  end
  //$display("load: %d%d%d%d data: %02x t: %d  rdy: %d",load_a,load_x,load_y,load_z,data_o,t,ready);
end

endmodule
