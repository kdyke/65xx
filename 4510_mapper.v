`include "6502_inc.vh"

`SCHEM_KEEP_HIER module mapper4510(input clk, input reset, output reg int_enable, input [7:0] data_i, input [7:0] data_o, input ready, input sync,
                  output reg [19:0] address, output reg [19:0] address_next, input [15:0] core_address_next, output reg map);

parameter MAP_IDLE = 0, MAP_READ_A = 1, MAP_READ_X = 2, MAP_READ_Y = 3, MAP_READ_Z = 4;

reg [2:0] map_state; 

reg [19:8] map_offset[0:1];
reg [7:0] map_enable;

// Look for either MAP or EOM (NOP) being fetched.
always @(posedge clk) begin
  if(reset) begin
    map_offset[0] <= 12'h000;
    map_offset[1] <= 12'h000;
    map_enable[7:0] <= 8'h00;
    map_state = MAP_IDLE;
  end else begin
      case(map_state) // synthesis full_case parallel_case
        MAP_IDLE:
          if(data_i == 8'h5C && ready && sync) begin
            int_enable <= 1;
            map_state <= MAP_READ_A;
          end else if(data_i == 8'hEA && ready && sync) begin
            map_state <= MAP_IDLE;
            int_enable <= 1;
          end
        MAP_READ_A:
          if(ready) begin
            map_offset[0][15:8] <= data_o;
            map_state <= MAP_READ_X;
          end
        MAP_READ_X:
          if(ready) begin
            map_offset[0][19:16] <= data_o[3:0];
            map_enable[3:0] <= data_o[7:4];
            map_state <= MAP_READ_Y;
          end
        MAP_READ_Y:
          if(ready) begin
            map_offset[1][15:8] <= data_o;
            map_state <= MAP_READ_Z;
          end
        MAP_READ_Z:
          if(ready) begin
            map_offset[1][19:16] <= data_o[3:0];
            map_enable[7:4] <= data_o[7:4];
            map_state <= MAP_IDLE;
          end
      endcase    
  end
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