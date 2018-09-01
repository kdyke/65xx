`include "6502_inc.vh"

`SCHEM_KEEP_HIER module mapper4510(input clk, input reset, input [7:0] data_i, input [7:0] data_o, input ready, input sync,
                  input ext_irq, input ext_nmi, output cpu_irq, output cpu_nmi,
                  output reg [19:0] address, output reg [19:0] address_next, input [15:0] core_address_next, output reg map);

parameter MAP_IDLE = 0, 
          MAP_READ_A = 1, 
          MAP_READ_X = 2, 
          MAP_READ_Y = 3, 
          MAP_READ_Z = 4;

reg [2:0] map_state, map_state_next; 

reg [19:8] map_offset[0:1];
reg [7:0] map_enable;
reg load_a, load_x, load_y, load_z, set_i, clear_i;
reg int_enable;

// It's not clear whether NMI should be done this way or not. The C65 docs aren't clear on if the MAP instruction masks off NMIs.
assign cpu_irq = ext_irq & int_enable;
assign cpu_nmi = ext_nmi & int_enable;

always @(posedge clk)
  if(reset) map_state <= MAP_IDLE;
  else map_state <= map_state_next;
  
// Look for either MAP or EOM (NOP) being fetched.
always @* begin
  map_state_next = 'bx;
  load_a = 0;
  load_x = 0;
  load_y = 0;
  load_z = 0;
  clear_i = 0;
  
  // This doesn't need to be dependent on the state machine.
  if(data_i == 8'hEA && ready && sync)
    clear_i = 1;
  
  case(map_state) // synthesis full_case parallel_case
    MAP_IDLE:
          if(data_i == 8'h5C && ready && sync)
              map_state_next = MAP_READ_A;
          else
              map_state_next = MAP_IDLE;
    MAP_READ_A: begin
          load_a = 1;
          if(ready)
              map_state_next = MAP_READ_X;
          else
              map_state_next = MAP_READ_A;
      end
    MAP_READ_X: begin
          load_x = 1;
          if(ready)
              map_state_next = MAP_READ_Y;
          else
              map_state_next = MAP_READ_X;
      end
    MAP_READ_Y: begin
          load_y = 1;
          if(ready)
              map_state_next = MAP_READ_Z;
          else
              map_state_next = MAP_READ_Y;
      end
    MAP_READ_Z: begin
          load_z = 1;
          if(ready)
              map_state_next = MAP_IDLE;
          else
              map_state_next = MAP_READ_Z;
      end
  endcase
end

always @(posedge clk or posedge reset) begin
  if(reset) map_offset[0] <= 12'h000;
  else if(load_a) map_offset[0][15:8] <= data_o;
  else if(load_x) map_offset[0][19:16] <= data_o[3:0];

  if(reset) map_enable <= 8'h00;
  else if(load_x) map_enable[3:0] <= data_o[7:4];
  else if(load_z) map_enable[7:4] <= data_o[7:4];
  
  if(reset) map_offset[1] <= 12'h000;
  else if(load_y) map_offset[1][15:8] <= data_o;
  else if(load_z) map_offset[1][19:16] <= data_o[3:0];
  
  if(reset) int_enable <= 1;
  else if(load_a) int_enable <= 0;
  else if(clear_i) int_enable <= 1;
end

reg [2:0] map_enable_index;
reg map_offset_index;
reg [19:8] current_offset;
reg [19:0] mapper_address;

// Mapper combinatorial path
always @(*) begin
  map_enable_index = core_address_next[15:13];
  map_offset_index = core_address_next[15];
  if(map_enable[map_enable_index]) begin
    current_offset = map_offset[map_offset_index];
    map = 1;
  end else begin
    current_offset = 0;
    map = 0;
  end
  
  mapper_address[19:8] = current_offset[19:8] + core_address_next[15:8];
  mapper_address[7:0] = core_address_next[7:0];
  
  if(ready)
    address_next = mapper_address;
  else
    address_next = address;
end

// Registered output address
always @(posedge clk) begin
  if(ready) begin
    address <= address_next;
  end
end

endmodule