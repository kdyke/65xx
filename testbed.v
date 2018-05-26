`timescale 10ns/10ns

module main;

reg [15:0] address;
reg [7:0] memory_in;
wire [7:0] memory_out;
reg ready;
reg clk, reset;

reg memory_write;
reg [15:0] memory_address;
wire [15:0] cpu_address;
wire [15:0] cpu_address_next;
reg [7:0] cpu_data_in;
wire [7:0] cpu_data_out;
wire cpu_write;

reg cpu_clock_enable;

reg [7:0] io_port_in;
reg [7:0] io_port;
reg io_port_cs;

wire irq, nmi;

reg [63:0] clock_count;
reg clock_reset;

assign irq = io_port[0];
assign nmi = io_port[1];

	memory memory_inst(.clk(clk), .we(memory_write), .addr(cpu_address_next), .di(memory_in), .do(memory_out));

  cpu6502 cpu_inst(.clk(clk), .reset(reset), .nmi(nmi), .irq(irq), .ready(ready), .write_next(cpu_write), 
            .address(cpu_address), .address_next(cpu_address_next), .data_i(cpu_data_in), .data_o_next(cpu_data_out));

	initial begin
    $display("initial clock: %d",clock_count[31:0]);

    io_port = 0;
		clk = 0;
    clock_reset = 1;
		//reset = 1;	// Start out high
    //ready = 1;
    clock_count = 0;
    cpu_clock_enable = 0;
    
    #1 memory_address = 16'h0000;
    address = 0;

    // Take CPU out of reset.
    cpu_clock_enable = 1;
	  //#8 reset = 0;
    //#100000 $finish;
    
  end
  
  always @(*)
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
  
  always @(*)
  begin
    if(cpu_address != 16'hbffc)
      memory_write = cpu_write;
    else
      memory_write = 0;
  end
  
  always @(*)
  begin
    if(cpu_clock_enable)
    begin
      memory_in = cpu_data_out;
      io_port_in = cpu_data_out;
    end
  end  
  
  always @(*)
  begin
    if(cpu_clock_enable)
      memory_address = cpu_address;
  end
  
  // Start driving memory and CPU clocks.
  always begin
//    $monitor($time,,"%m. clk = %b cnt: %d rdy: %d addr: %x mem: %02x do: %02x w: %d ce: %d irq: %d nmi: %d",
//      clk,clock_count[31:0],ready,cpu_address,cpu_data_in,cpu_data_out,cpu_write,cpu_clock_enable,irq,nmi);
//    if(cpu_clock_enable)
     #1 clk = ~clk;
  end
  
  always @(posedge clk)
  begin
    if(clock_reset)
    begin
      clock_reset <= 0;
      clock_count <= 0;
    end
    else
      clock_count <= clock_count + 1;
      
    //$display("clock: %d reset: %d",clock_count[31:0],clock_reset);
      
    // Stress test for ready signal.
    if((clock_count & 1) == 0)
      ready <= 1;
    else
      ready <= 1;
    if(clock_count == 2)
	    reset <= 1;
    if(clock_count == 16)
      reset <= 0;
          
    if((clock_count & 16'hffff) == 0)
      $display("addr: %04x",cpu_address);
  end

  // io_port writes
  always @(posedge clk)
  begin
    //$display("io_port ? %04x %08b w: %d",cpu_address,cpu_data_out,cpu_write);
    if(cpu_address_next == 16'hbffc && cpu_write)
    begin
      io_port = cpu_data_out;
      $display("io_port <= %08b",cpu_data_out);
    end
  end
  
endmodule
