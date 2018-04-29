`timescale 10ns/10ns

module main;

reg [15:0] address;
reg [7:0] memory_in;
wire [7:0] memory_out;
reg ready;
reg memclk, clk, reset;

reg memory_write;
reg [15:0] memory_address;
wire [15:0] cpu_address;
reg [7:0] cpu_data_in;
wire [7:0] cpu_data_out;
wire cpu_write;

reg cpu_clock_enable;

reg [7:0] io_port_in;
reg [7:0] io_port;
reg io_port_cs;

wire irq, nmi;

assign irq = io_port[0];
assign nmi = io_port[1];

	memory memory_inst(.clk(memclk), .we(memory_write), .addr(memory_address), .di(memory_in), .do(memory_out));

  cpu6502 cpu_inst(.clk(clk), .reset(reset), .nmi(nmi), .irq(irq), .ready(ready), .write(cpu_write), 
            .address(cpu_address), .data_i(cpu_data_in), .data_o(cpu_data_out));

	initial begin

    io_port = 0;
		clk = 0;
    memclk = 0;
		reset = 1;	// Start out high
    ready = 1;
    clock_count = 0;
    cpu_clock_enable = 0;
    
    //$monitor($time,,"%m. memclk = %b clk = %b  addr: %x mem: %02x cpu: %02x w: %d",memclk,clk,cpu_address,memory_out,cpu_data_out,cpu_write);
    
    // Override reset start vector by clocking data into memory
    memory_write = 0;
    memory_address = 16'hfffc;
    memory_in = 8'h00;
    #1 memclk = 1;
    #1 memclk = 0;
    memory_write = 0;
    #1 memclk = 1;
    #1 memclk = 0;
    memory_write = 0;
    #1 memclk = 1;
    #1 memclk = 0;

    #1 memory_address = 16'hfffd;
    #1 memory_in = 8'h04;
    #1 memclk = 1;
    #1 memclk = 0;
    memory_write = 0;
    #1 memclk = 1;
    #1 memclk = 0;
    memory_write = 0;
    #1 memclk = 1;
    #1 memclk = 0;
    #1 memclk = 1;
    #1 memclk = 0;
    
    #1 memory_address = 16'h0000;
    address = 0;

    // Take CPU out of reset.
    cpu_clock_enable = 1;
	  #8 reset = 0;
    //#100000 $finish;
    
  end
  
  always @(memory_out)
  begin
    if(cpu_address == 16'hbffc)
    begin
      io_port_cs = 1;
      cpu_data_in = io_port;
    end
    else
    begin
      io_port_cs = 0;
      cpu_data_in = memory_out;
    end
  end
  
  always @(cpu_write)
  begin
    if(cpu_address != 16'hbffc)
      memory_write = cpu_write;
    else
      memory_write = 0;
  end
  
  always @(cpu_data_out)
  begin
    if(cpu_clock_enable)
    begin
      memory_in = cpu_data_out;
      io_port_in = cpu_data_out;
    end
  end  
  
  always @(cpu_address)
  begin
    if(cpu_clock_enable)
      memory_address = cpu_address;
  end
  
  // Start driving memory and CPU clocks.
  always begin
  #1 memclk = ~memclk;
    //$monitor($time,,"%m. memclk = %b clk = %b  addr: %x mem: %02x cpu: %02x w: %d ce: %d irq: %d nmi: %d",memclk,clk,cpu_address,cpu_data_in,cpu_data_out,cpu_write,cpu_clock_enable,irq,nmi);
    if(cpu_clock_enable)
     clk = ~clk;
  #1 memclk = ~memclk;
  end

  reg [63:0] clock_count;

  always @(posedge clk)
  begin
    clock_count = clock_count + 1;
    if((clock_count & 16'hffff) == 0)
      $display("addr: %04x",cpu_address);
  end

  // io_port writes
  always @(posedge clk)
  begin
    if(io_port_cs && cpu_write)
    begin
      io_port = cpu_data_out;
      $display("io_port <= %08b",cpu_data_out);
    end
  end
  
endmodule
