`include "6502_inc.vh"

`SCHEM_KEEP_HIER module mapper4510(input clk, input reset, input [7:0] data_i, input [7:0] data_o, input ready, input sync,
                  input ext_irq, input ext_nmi, output cpu_irq, output cpu_nmi, input enable_i, input disable_i,
                  input load_a, input load_x, input load_y, input load_z, input map_enable_ext,
                  input [1:0] map_reg_sel, output reg [7:0] map_reg,
                  output reg [19:0] address, output reg [19:0] address_next, input [15:0] core_address_next, 
                  output reg map_next, output reg map);

reg [19:8] map_offset[0:1];
reg [7:0] map_enable;
reg int_enable;

// It's not clear whether NMI should be done this way or not. The C65 docs aren't clear on if the MAP instruction masks off NMIs.
assign cpu_irq = ext_irq & int_enable;
assign cpu_nmi = ext_nmi & int_enable;

always @(posedge clk) begin
  if(reset) map_offset[0][15:8] <= 8'h00;
  else if(load_a) map_offset[0][15:8] <= data_o;
  
  if(reset) map_offset[0][19:16] <= 4'h0;
  else if(load_x) map_offset[0][19:16] <= data_o[3:0];
  
  if(reset) map_enable[3:0] <= 4'h0;
  else if(load_x) map_enable[3:0] <= data_o[7:4];
  
  if(reset) map_enable[7:4] <= 4'h0;
  else if(load_z) map_enable[7:4] <= data_o[7:4];
  
  if(reset) map_offset[1][15:8] <= 8'h00;
  else if(load_y) map_offset[1][15:8] <= data_o;
  
  if(reset)  map_offset[1][19:16] <= 4'h0;
  else if(load_z) map_offset[1][19:16] <= data_o[3:0];
  
  if(reset) int_enable <= 1;
  else if(disable_i) int_enable <= 0;
  else if(enable_i) int_enable <= 1;
end

// Mapper combinatorial path
reg [2:0] map_enable_index;
reg map_offset_index;
reg [19:8] current_offset;
reg [19:0] mapper_address;
reg map_en;

always @(*) begin
  map_enable_index = core_address_next[15:13];
  map_offset_index = core_address_next[15];
  
  // Mapper can be disabled by external (hypervisor) logic when needed.
  if(map_enable[map_enable_index] & map_enable_ext) begin
    current_offset = map_offset[map_offset_index];
    map_en = 1;
  end else begin
    current_offset = 0;
    map_en = 0;
  end
  
  mapper_address[19:8] = current_offset[19:8] + core_address_next[15:8];
  mapper_address[7:0] = core_address_next[7:0];
  
  if(ready) begin
    address_next = mapper_address;
    map_next = map_en;
  end else begin
    address_next = address;
    map_next = map;
  end
end

// Registered output address
always @(posedge clk) begin
  if(ready) begin
    address <= address_next;
    map <= map_next;
  end
end

// Expose internal map state to hypervisor controller.
always @(*) begin
  case(map_reg_sel)
    0: map_reg = map_offset[0][15:8];
    1: map_reg = {map_enable[3:0], map_offset[0][19:16]};
    2: map_reg = map_offset[1][15:8];
    3: map_reg = {map_enable[7:4], map_offset[1][19:16]};
  endcase
end

endmodule

module mapper_fsm(input clk, input reset, input [7:0] data_i, input ready, input sync,
                  output reg load_a, output reg load_x, output reg load_y, output reg load_z, output reg enable_i, output reg disable_i);

parameter MAP_IDLE = 0, 
          MAP_READ_A = 1, 
          MAP_READ_X = 2, 
          MAP_READ_Y = 3, 
          MAP_READ_Z = 4;

reg [2:0] map_state, map_state_next; 

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
  enable_i = 0;
  disable_i = 0;
  
  // This doesn't need to be dependent on the state machine.
  if(data_i == 8'hEA && ready && sync)
    enable_i = 1;
    
  case(map_state) // synthesis full_case parallel_case
    MAP_IDLE:
          if(data_i == 8'h5C && ready && sync)
              map_state_next = MAP_READ_A;
          else
              map_state_next = MAP_IDLE;
    MAP_READ_A: begin
          load_a = 1;
          disable_i = 1;
          
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

endmodule
                  