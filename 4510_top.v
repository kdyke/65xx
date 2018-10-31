`include "6502_inc.vh"

`SCHEM_KEEP_HIER module cpu4510(input clk, input reset, input nmi, input irq, input ready, output wire write, output wire write_next, 
                                output wire sync, output wire [19:0] address, output wire [19:0] address_next, 
                                output wire map_next, output wire map,
                                input [7:0] data_i, output wire [7:0] data_o, output wire [7:0] data_o_next,                                
                                input [1:0] map_reg_sel, output wire [7:0] map_reg, input map_enable_ext,
                                input [7:0] map_reg_hyper, input load_map_hyper,
                                output wire [7:0] cpu_state, output wire [2:0] t, output wire cpu_int,
                                output wire [7:0] a_out, output wire [7:0] x_out, output wire [7:0] y_out, output wire [7:0] z_out, output wire [15:0] sp_out);
                                
wire [15:0] core_address;
wire [15:0] core_address_next;

wire cpu_irq;
wire cpu_nmi;
wire load_a, load_x, load_y, load_z, map_enable_i, map_disable_i;

wire [7:0] cpu_data_i;
wire map_enable_ext;

// This is the state machine that actually watches for MAP/EOM instructions and tells the mapper what to do.
mapper_fsm mapper_fsm(clk, reset, data_i, ready, sync, load_a, load_x, load_y, load_z, map_enable_i, map_disable_i);

// The mapper handles the mapping address calculations but not the state machine part of it.
mapper4510 mapper(.clk(clk), .reset(reset), .data_i(data_i), .data_o(data_o_next), .ready(ready), .sync(sync),
                  .ext_irq(irq), .ext_nmi(nmi), .cpu_irq(cpu_irq), .cpu_nmi(cpu_nmi), 
                  .enable_i(map_enable_i), .disable_i(map_disable_i), .map_enable_ext(map_enable_ext),
                  .load_a(load_a), .load_x(load_x), .load_y(load_y), .load_z(load_z),
                  .map_reg_sel(map_reg_sel), .map_reg(map_reg), .map_reg_hyper(map_reg_hyper), .load_map_hyper(load_map_hyper),
                  .address(address), .address_next(address_next), .core_address_next(core_address_next), 
                  .map_next(map_next), .map(map));
                  
cpu65CE02 cpu_core(.clk(clk), .reset(reset), .nmi(cpu_nmi), .irq(cpu_irq), .ready(ready), .sync(sync),
                  .write(write), .write_next(write_next), .address(core_address), .address_next(core_address_next),
                  .data_i(data_i), .data_o(data_o), .data_o_next(data_o_next), .cpu_state(cpu_state), .t(t),
                  .cpu_int(cpu_int), .a_out(a_out), .x_out(x_out), .y_out(y_out), .z_out(z_out), .sp_out(sp_out));
                  
endmodule
