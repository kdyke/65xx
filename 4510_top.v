`include "6502_inc.vh"

`SCHEM_KEEP_HIER module cpu4510(input clk, input reset, input nmi, input irq, input ready, output wire write, output wire write_next, 
                                output wire sync, output wire [19:0] address, output wire [19:0] address_next, output wire map,
                                input [7:0] data_i, output wire [7:0] data_o, output wire [7:0] data_o_next, 
                                output wire [7:0] cpu_state, output wire [2:0] t, output wire cpu_int,
                                output wire [7:0] a_out, output wire [7:0] x_out, output wire [7:0] y_out, output wire [7:0] z_out, output wire [15:0] sp_out);
                                
wire [15:0] core_address;
wire [15:0] core_address_next;

wire int_enable;
wire irq_masked;
wire nmi_masked;

// It's not clear whether NMI should be done this way or not. The C65 docs aren't clear on if the MAP instruction masks off NMIs.
assign irq_masked = irq & int_enable;
assign nmi_masked = nmi & int_enable;

mapper4510 mapper(.clk(clk), .reset(reset), .int_enable(int_enable), .data_i(data_i), .data_o(data_o_next), .ready(ready), .sync(sync),
                  .address(address), .address_next(address_next), .core_address_next(core_address_next), .map(map));
                  
cpu65CE02 cpu_core(.clk(clk), .reset(reset), .nmi(nmi_masked), .irq(irq_masked), .ready(ready), .sync(sync),
                  .write(write), .write_next(write_next), .address(core_address), .address_next(core_address_next),
                  .data_i(data_i), .data_o(data_o), .data_o_next(data_o_next), .cpu_state(cpu_state), .t(t),
                  .cpu_int(cpu_int), .a_out(a_out), .x_out(x_out), .y_out(y_out), .z_out(z_out), .sp_out(sp_out));
                  
endmodule
