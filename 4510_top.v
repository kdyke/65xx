`include "6502_inc.vh"

`SCHEM_KEEP_HIER module cpu4510(input clk, input reset, input nmi, input irq, input hyp, input ready, output wire write, output wire write_next, 
                                output wire sync, output wire [19:0] address, output wire [19:0] address_next, 
                                output wire map_next, output wire map,
                                input [7:0] data_i, output wire [7:0] data_o, output wire [7:0] data_o_next,
                                // Is the CPU in hypervisor mode or not                                
                                output wire hyper_mode, 
                                // These two signals let the hypervisor read from the user mapping registers, and request
                                // that the currently active register be loaded from the current CPU data bus output.
                                output wire [7:0] map_reg_data, input hypervisor_load_user_reg,
                                // These signals are all just for monitoring internal CPU state.
                                output wire [7:0] cpu_state, output wire [2:0] t, output wire cpu_int,
                                output wire [7:0] a_out, output wire [7:0] x_out, output wire [7:0] y_out, output wire [7:0] z_out, output wire [15:0] sp_out);
                                
wire [15:0] core_address;
wire [15:0] core_address_next;

wire cpu_irq;
wire cpu_nmi;
wire load_a, load_x, load_y, load_z, map_enable_i, map_disable_i;

wire [7:0] cpu_data_i;
wire load_map_sel; // Which set of mapper registers is being loaded (user or supervisor)

// This is the state machine that actually watches for MAP/EOM instructions and tells the mapper what to do.
mapper_fsm mapper_fsm(.clk(clk), .reset(reset), .data_i(data_i), .ready(ready), .sync(sync), 
                      .load_a(load_a), .load_x(load_x), .load_y(load_y), .load_z(load_z),
                      .map_sel(hyper_mode), .map_reg_write_sel(core_address_next[1:0]), 
                      .load_map_sel(load_map_sel), .hypervisor_load_user_reg(hypervisor_load_user_reg), 
                      .enable_i(map_enable_i), .disable_i(map_disable_i));

// The mapper handles the mapping address calculations but not the state machine part of it.
mapper4510 mapper(.clk(clk), .reset(reset), .data_i(data_i), .data_o(data_o_next), .ready(ready), .sync(sync),
                  .ext_irq(irq), .ext_nmi(nmi), .cpu_irq(cpu_irq), .cpu_nmi(cpu_nmi), 
                  .enable_i(map_enable_i), .disable_i(map_disable_i),
                  .load_a(load_a), .load_x(load_x), .load_y(load_y), .load_z(load_z), .load_map_sel(load_map_sel), .active_map(hyper_mode),
                  .map_reg_data(map_reg_data),
                  .address(address), .address_next(address_next), .core_address_next(core_address_next), 
                  .map_next(map_next), .map(map));
                  
cpu65CE02 cpu_core(.clk(clk), .reset(reset), .nmi(cpu_nmi), .irq(cpu_irq), .hyp(hyp), .ready(ready), .sync(sync),
                  .write(write), .write_next(write_next), .address(core_address), .address_next(core_address_next),
                  .data_i(data_i), .data_o(data_o), .data_o_next(data_o_next), .hyper_mode(hyper_mode), 
                  .cpu_state(cpu_state), .t(t),
                  .cpu_int(cpu_int), .a_out(a_out), .x_out(x_out), .y_out(y_out), .z_out(z_out), .sp_out(sp_out));
                  
endmodule
