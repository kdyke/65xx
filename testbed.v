`timescale 10ns/10ns

module main;

reg [15:0] address;
reg [7:0] memory_in;
wire [7:0] memory_out;
reg ready;
reg clk, reset;

reg memory_write;
reg [15:0] memory_address;
wire [19:0] cpu_address;
wire [19:0] cpu_address_next;
reg [7:0] cpu_data_in;
wire [7:0] cpu_data_out;
wire cpu_write;
wire cpu_write_next;
reg cpu_clock_enable;

reg [7:0] io_port_in;
reg [7:0] io_port;
reg io_port_cs;

wire [7:0] a_out;
wire [7:0] x_out;
wire [7:0] y_out;
wire [7:0] z_out;
wire [15:0] sp_out;
wire [7:0] cpu_data_out_reg;
wire [7:0] cpu_state;

wire sync;

wire irq, nmi;

reg [63:0] clock_count;
reg clock_reset;

wire [2:0] t;

reg [1:0] bus_device;

parameter BUS_MEM = 0,
          BUS_IO  = 1,
          BUS_HYP = 2;
      
assign irq = io_port[0];
assign nmi = io_port[1];

reg hyper_cs;
wire hyper_mode;
wire [7:0] hyper_data_o;
wire [7:0] map_reg_data;
wire hypervisor_load_user_reg;
wire hyp; // Hypervisor interrupt line
wire map_next;
wire [15:0] monitor_state;
wire mapper_busy;
reg bus_ready;

	memory memory_inst(.clk(clk), .we(memory_write), .addr(cpu_address_next[15:0]), .di(memory_in), .do(memory_out));

  cpu4510 cpu_inst(.clk(clk), .reset(reset), .nmi(nmi), .irq(irq), .hyp(hyp), .ready(ready), .write_next(cpu_write_next), .write_out(cpu_write),
            .map_next(map_next), .mapper_busy(mapper_busy), .slow(1'b1),
            .address(cpu_address), .address_next(cpu_address_next), .sync(sync), .data_i(cpu_data_in), .data_o_next(cpu_data_out), .data_o(cpu_data_out_reg),
            .map_reg_data(map_reg_data), .hypervisor_load_user_reg(hypervisor_load_user_reg), .hyper_mode(hyper_mode),
            .monitor_state(monitor_state), .monitor_a(a_out), .monitor_x(x_out), .monitor_y(y_out), .monitor_z(z_out),
            .monitor_sp(sp_out));

  hyper_ctrl hyper_ctrl0(.clk(clk), .reset(reset), .hyper_cs(hyper_cs), .hyper_addr(cpu_address_next[7:0]), .hyper_io_data_i(cpu_data_out), 
                    .hyper_data_o(hyper_data_o), .cpu_write(cpu_write_next), .ready(ready), .hyper_mode(hyper_mode),
                    .hyp(hyp), .load_user_reg(hypervisor_load_user_reg), .user_mapper_reg(map_reg_data));

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
    case(bus_device)
      BUS_IO: cpu_data_in = io_port;
      BUS_HYP: cpu_data_in = hyper_data_o;
      default: cpu_data_in = memory_out;
    endcase
  end
  
  always @(*)
  begin
    hyper_cs = 0;
    io_port_cs = 0;

    if(cpu_address_next[19:6] == {12'h0D6,2'b01})
      hyper_cs = 1;

    if(cpu_address_next == 16'hbffc)
      io_port_cs = 1;
  end
  
  always@(posedge clk)
  begin
      if(io_port_cs)
        bus_device <= BUS_IO;
      else if(hyper_cs)
        bus_device <= BUS_HYP;
      else
        bus_device <= BUS_MEM;
  end
  
  always @(*)
  begin
    memory_write = cpu_write_next & ready & (!(io_port_cs|hyper_cs));
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
      memory_address = cpu_address[15:0];
  end
  
  // Start driving memory and CPU clocks.
  always begin
`ifdef NOTDEF
    $monitor($time,,"%m. clk = %b rst: %d cnt: %d rdy: %d sync: %d t: %x addr: %x addrn: %x hm: %d mapn: %d mem: %02x do: %02x wn: %d w: %d ce: %d irq: %d nmi: %d rst: %d A: %02x X: %02x Y: %02x Z: %02x P: %02x SP: %04x",
      clk,reset,clock_count[31:0],ready,sync,monitor_state,cpu_address,cpu_address_next,hyper_mode,map_next,cpu_data_in,cpu_data_out_reg,cpu_write_next,cpu_write,cpu_clock_enable,irq,nmi,reset,
        a_out,x_out,y_out,z_out,cpu_state,sp_out);
`endif
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
      bus_ready <= 1;
    else
      bus_ready <= 0;
    if(clock_count == 2)
	    reset <= 1;
    if(clock_count == 16)
      reset <= 0;
          
    if((clock_count & 16'hffff) == 0)
      $display("addr: %04x A: %02x X: %02x Y: %02x Z: %02x SP: %04x",cpu_address,a_out,x_out,y_out,z_out,sp_out);
  end

  always @(*)
  begin
    ready = bus_ready & ~mapper_busy;
  end
  
  // io_port writes
  always @(posedge clk)
  begin
    //$display("io_port ? %04x %08b w: %d",cpu_address,cpu_data_out,cpu_write);
    if(cpu_address_next == 16'hbffc && (cpu_write_next & ready))
    begin
      io_port = cpu_data_out;
      $display("io_port <= %08b",cpu_data_out);
    end
  end
  
endmodule
