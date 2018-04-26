`timescale 10ns/10ns

module main;

reg [15:0] address;
wire [7:0] memory_in;
wire [7:0] memory_out;
reg nmi, irq, ready;
reg we;
reg memclk, clk, reset;

wire [15:0] memory_address;
wire [15:0] cpu_address_out;
wire [7:0] cpu_data_in;
wire [7:0] cpu_data_out;
wire cpu_write;

assign cpu_data_in = memory_out;
assign memory_in = cpu_data_out;
assign memory_address = cpu_address_out;

	memory memory_inst(.clk(memclk), .we(cpu_write), .addr(memory_address), .di(memory_in), .do(memory_out));

  cpu6502 cpu_inst(.clk(clk), .reset(reset), .nmi(nmi), .irq(irq), .ready(ready), .write(cpu_write), 
            .address(cpu_address_out), .data_i(cpu_data_in), .data_o(cpu_data_out));

	initial begin

    we = 0;
		clk = 0;
    memclk = 0;
		reset = 1;	// Start out high
    ready = 1;
    irq = 0;
    nmi = 0;
    clock_count = 0;
    
    //$monitor($time,,"%m. memclk = %b clk = %b  addr: %x mem: %02x cpu: %02x w: %d",memclk,clk,cpu_address_out,memory_out,cpu_data_out,cpu_write);
    
// Override start vector
//ram[16'hfffc] = 8'h00;
//ram[16'hfffd] = 8'h04;
    
    address = 0;
    
	  #8 reset = 0;
    //#100000 $finish;
    
  end
      
always begin
  #1 memclk = ~memclk;
//    $strobe($time,,"%m. memclk = %b clk = %b  addr: %x mem: %02x cpu: %02x w: %d",memclk,clk,cpu_address_out,memory_out,cpu_data_out,cpu_write);
     clk = ~clk;
  #1 memclk = ~memclk;
end

reg [63:0] clock_count;

always @(posedge clk)
begin
  clock_count = clock_count + 1;
  if((clock_count & 16'hffff) == 0)
    $display("addr: %04x",cpu_address_out);
end

endmodule
