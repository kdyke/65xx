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

//`define CPU4510_TOP_DEBUG
`ifdef CPU4510_TOP_DEBUG
`define MARK_DEBUG (* mark_debug = "true", dont_touch = "true" *)
`else
`define MARK_DEBUG
`endif

(* keep_hierarchy = "yes" *)  module cpu4510(input clk, `MARK_DEBUG input reset, `MARK_DEBUG input nmi, `MARK_DEBUG input irq, `MARK_DEBUG input hyp, `MARK_DEBUG input ready, 
                                `MARK_DEBUG output wire write_out, `MARK_DEBUG output wire write_next, 
                                `MARK_DEBUG output wire sync, `MARK_DEBUG output wire [19:0] address, `MARK_DEBUG output wire [19:0] address_next, 
                                `MARK_DEBUG output wire map_next, `MARK_DEBUG output wire map_out,
                                `MARK_DEBUG input [7:0] data_i, `MARK_DEBUG output wire [7:0] data_o, `MARK_DEBUG output wire [7:0] data_o_next,
                                // Is the CPU in hypervisor mode or not                                
                                `MARK_DEBUG output wire hyper_mode, output wire mapper_busy,
                                // These two signals let the hypervisor read from the user mapping registers, and request
                                // that the currently active register be loaded from the current CPU data bus output.
                                `MARK_DEBUG output wire [7:0] map_reg_data, `MARK_DEBUG input hypervisor_load_user_reg,
                                // Monitor outputs
                                output wire [7:0] monitor_a, 
                                output wire [7:0] monitor_x, 
                                output wire [7:0] monitor_y, 
                                output wire [7:0] monitor_z, 
                                output wire [7:0] monitor_b, 
                                output wire [7:0] monitor_p, 
                                output wire [15:0] monitor_sp,
                                output wire [15:0] monitor_pc,
                                output wire [7:0] monitor_opcode,
                                output wire [15:0] monitor_state,
                                output wire monitor_hypervisor_mode,
                                output wire monitor_proceed,
                                output wire [11:0] monitor_map_offset_low,
                                output wire [11:0] monitor_map_offset_high,
                                output wire [3:0] monitor_map_enables_low,
                                output wire [3:0] monitor_map_enables_high
                                );
                                
wire [15:0] core_address;
`MARK_DEBUG wire [15:0] core_address_next;

wire [2:0] t;
wire cpu_irq;
wire cpu_nmi;
wire load_a, load_x, load_y, load_z, map_enable_i, map_disable_i;
wire map;

wire [7:0] cpu_data_i;
wire load_map_sel; // Which set of mapper registers is being loaded (user or supervisor)
wire map_insn;

// The mapper handles the mapping address calculations but not the state machine part of it.
mapper4510 mapper(.clk(clk), .reset(reset), .data_i(data_i), .data_o(data_o_next), .ready(ready), .sync(sync),
                  .ext_irq(irq), .ext_nmi(nmi), .cpu_irq(cpu_irq), .cpu_nmi(cpu_nmi), 
                  .hyper_mode(hyper_mode),
                  .map_reg_data(map_reg_data), .mapper_busy(mapper_busy),
                  .hypervisor_load_user_reg(hypervisor_load_user_reg), .map_reg_write_sel(core_address_next[1:0]),
                  .address(address), .address_next(address_next), .core_address_next(core_address_next), 
                  .map_next(map_next), .map(map_out), .map_insn(map_insn), .t(t[1:0]),
                  .monitor_map_offset_low(monitor_map_offset_low),
                  .monitor_map_offset_high(monitor_map_offset_high),
                  .monitor_map_enables_low(monitor_map_enables_low),
                  .monitor_map_enables_high(monitor_map_enables_high));
                  
cpu65CE02 cpu_core(.clk(clk), .reset(reset), .nmi(cpu_nmi), .irq(cpu_irq), .hyp(hyp), .ready(ready), .sync(sync),
                  .write(write_out), .write_next(write_next), .address(core_address), .address_next(core_address_next),
                  .data_i(data_i), .data_o(data_o), .data_o_next(data_o_next), .hyper_mode(hyper_mode), 
                  .t(t), .map(map_insn),
                  .monitor_a(monitor_a), .monitor_x(monitor_x), .monitor_y(monitor_y), .monitor_z(monitor_z),
                  .monitor_b(monitor_b), .monitor_p(monitor_p), .monitor_sp(monitor_sp), .monitor_pc(monitor_pc),
                  .monitor_opcode(monitor_opcode), .monitor_state(monitor_state), 
                  .monitor_hypervisor_mode(monitor_hypervisor_mode), .monitor_proceed(monitor_proceed));
                  
endmodule
