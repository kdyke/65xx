`include "6502_inc.vh"

`SCHEM_KEEP_HIER module hyper_ctrl(input clk, input reset, input hyper_cs, input [7:0] hyper_addr, input [7:0] hyper_io_data_i, output reg [7:0] hyper_data_o,
                  input cpu_write, input cpu_sync, input ready, output reg hyper_force_cs, input [15:0] cpu_addr, input cpu_map,
                  output reg hyper_mode, output reg map_enable_ext, 
                  output reg [1:0] mapper_reg_sel, input [7:0] mapper_reg, output reg [7:0] mapper_reg_out, output reg swap_mapper_regs);

parameter HYPER_IDLE                = 0,
          HYPER_ENTER_PHP_FETCH     = 1,
          HYPER_ENTER_PHP_DEC       = 2,
          HYPER_ENTER_PHP_EX        = 3,
          HYPER_ENTER_JMP_FETCH     = 4,
          HYPER_ENTER_JMP_PCL       = 5,
          HYPER_ENTER_JMP_PCH       = 6,
          HYPER_EXIT_CLE_SEE_FETCH  = 7,
          HYPER_EXIT_CLE_SEE_EX     = 8,
          HYPER_EXIT_PLP_FETCH      = 9,
          HYPER_EXIT_PLP_DEC        = 10,
          HYPER_EXIT_PLP_EX         = 11,
          HYPER_EXIT_JMP_FETCH      = 12,
          HYPER_EXIT_JMP_PCL        = 13,
          HYPER_EXIT_JMP_PCH        = 14;

parameter HYPER_MUX_PHP_PLP         = 0,
          HYPER_MUX_P               = 1,
          HYPER_MUX_CLE_SEE         = 2,
          HYPER_MUX_JMP             = 3,
          HYPER_MUX_ENTER_PCL       = 4,
          HYPER_MUX_ENTER_PCH       = 5,
          HYPER_MUX_EXIT_PCL        = 6,
          HYPER_MUX_EXIT_PCH        = 7;

parameter MAP_A = 0,
          MAP_X = 1,
          MAP_Y = 2,
          MAP_Z = 3;

parameter HYPER_REG_A = 6'h00,
          HYPER_REG_X = 6'h01,
          HYPER_REG_Y = 6'h02,
          HYPER_REG_Z = 6'h03,
          HYPER_REG_B = 6'h04,
          HYPER_REG_SPL = 6'h05,
          HYPER_REG_SPH = 6'h06,
          HYPER_REG_P   = 6'h07,
          HYPER_REG_PCL = 6'h08,
          HYPER_REG_PCH = 6'h09,
          HYPER_REG_MAP_X = 6'h0A,
          HYPER_REG_MAP_A = 6'h0B,
          HYPER_REG_MAP_Z = 6'h0C,
          HYPER_REG_MAP_Y = 6'h0D,
          HYPER_REG_TRAP_PCL = 6'h0E,
          HYPER_REG_TRAP_PCH = 6'h0F,
          HYPER_REG_PORT_00 = 6'h10,
          HYPER_REG_PORT_01 = 6'h10,
          HYPER_REG_IOMODE  = 6'h12,
          HYPER_REG_VECTOR_PCL = 6'h20,
          HYPER_REG_VECTOR_PCH = 6'h21,
          
          HYPER_REG_EXIT = 6'h3F;
          
// Hypervisor register space D6xx
//
// Add $40 to get memory address.
// 00 - hyper_a
// 01 - hyper_x
// 02 - hyper_y
// 03 - hyper_z
// 04 - hyper_b
// 05 - hyper_spl
// 06 - hyper_sph
// 07 - hyper_p
// 08 - hyper_pcl
// 09 - hyper_pch
// 0A - hyper_map_x
// 0B - hyper_map_a
// 0C - hyper_map_z
// 0D - hyper_map_y
// 0E - Unused?
// 0F - Unused?
// 10 - hyper_port_00
// 11 - hyper_port_01
// 12 - hyper_iomode
// 13 - Unused
// 14 - Unused
// 15 - Unused
// 16 - Unused
// 17 - Unused
// 18 - virtualize_sd
// 19 - Unused
// 20 - Vector PCL
// 21 - Vector PCH
// 32 - Protected Hardware 
// 3F - Hyper Exit trigger

reg [15:0] hyper_pc;
reg load_hyper_pc, load_hyper_pcl, load_hyper_pch;

reg [15:0] hyper_sp;
reg load_hyper_spl, load_hyper_sph;

reg [7:0] hyper_p;
reg load_hyper_p, load_hyper_p_io;

reg [7:0] hyper_map_a, hyper_map_x, hyper_map_y, hyper_map_z;

reg load_hyper_a, load_hyper_x, load_hyper_y, load_hyper_z, load_hyper_b;
reg [7:0] hyper_a, hyper_x, hyper_y, hyper_z, hyper_b;

reg cpu_data_src;

reg [2:0] hyper_internal_mux_sel;

// Combinatorial signals used to begin enter/exit sequence.
reg hyper_enter_req, hyper_exit_req;

reg [3:0] hyper_state, hyper_state_next;
reg hyper_enter_reg, hyper_exit_reg;

reg load_trap_pcl, load_trap_pch;
reg [15:0] hyper_trap_pc;

reg load_vector_pcl, load_vector_pch;
reg [15:0] hyper_vector_pc;

reg [7:0] hyper_port_00, hyper_port_01;
reg load_hyper_00, load_hyper_01;

reg [7:0] hyper_iomode;
reg load_hyper_iomode;

reg [6:0] hypervisor_trap_port;

reg [7:0] hyper_internal_data_o;

reg [7:0] hyper_reg_data_o;

reg hyper_enter_ack;
reg hyper_exit_ack;

reg hyper_map_gate;

always @(*)
begin
  case (hyper_internal_mux_sel)
    HYPER_MUX_PHP_PLP : hyper_internal_data_o = hyper_exit_reg ? 8'h28 : 8'h08; // PHP
    HYPER_MUX_P : hyper_internal_data_o = hyper_p;
    HYPER_MUX_CLE_SEE : hyper_internal_data_o = {7'b0000001,hyper_p[5]}; // CLE or SEE based on saved E bit
    HYPER_MUX_JMP : hyper_internal_data_o = 8'h4C; // JMP
    HYPER_MUX_ENTER_PCL : hyper_internal_data_o = hyper_vector_pc[7:0];
    HYPER_MUX_ENTER_PCH : hyper_internal_data_o = hyper_vector_pc[15:8];
    HYPER_MUX_EXIT_PCL : hyper_internal_data_o = hyper_pc[7:0];
    HYPER_MUX_EXIT_PCH : hyper_internal_data_o = hyper_pc[15:8];
  endcase
end

always @(*)
begin
  hyper_reg_data_o = 8'hFF;
  if(hyper_mode & hyper_cs & hyper_addr[7:6] == 2'b01) begin
    case(hyper_addr[5:0])
      //HYPER_REG_A:                        hyper_reg_data_o = hyper_a;
      //HYPER_REG_X:                        hyper_reg_data_o = hyper_x;
      //HYPER_REG_Y:                        hyper_reg_data_o = hyper_y;
      //HYPER_REG_Z:                        hyper_reg_data_o = hyper_z;
      //HYPER_REG_B:                        hyper_reg_data_o = hyper_b;
      //HYPER_REG_SPL:                      hyper_reg_data_o = hyper_sp[7:0];
      //HYPER_REG_SPH:                      hyper_reg_data_o = hyper_sp[15:8];
      HYPER_REG_P:                        hyper_reg_data_o = hyper_p;
      HYPER_REG_PCL:                      hyper_reg_data_o = hyper_pc[7:0];
      HYPER_REG_PCH:                      hyper_reg_data_o = hyper_pc[15:8];
      HYPER_REG_MAP_A:                    hyper_reg_data_o = hyper_map_a;
      HYPER_REG_MAP_X:                    hyper_reg_data_o = hyper_map_x;
      HYPER_REG_MAP_Y:                    hyper_reg_data_o = hyper_map_y;
      HYPER_REG_MAP_Z:                    hyper_reg_data_o = hyper_map_z;
      //HYPER_REG_PORT_00:                  hyper_reg_data_o = hyper_port_00;
      //HYPER_REG_PORT_01:                  hyper_reg_data_o = hyper_port_01;
      HYPER_REG_IOMODE:                   hyper_reg_data_o = hyper_iomode;
      HYPER_REG_TRAP_PCL:                 hyper_reg_data_o = hyper_trap_pc[7:0];
      HYPER_REG_TRAP_PCH:                 hyper_reg_data_o = hyper_trap_pc[15:8];
      HYPER_REG_VECTOR_PCL:               hyper_reg_data_o = hyper_vector_pc[7:0];
      HYPER_REG_VECTOR_PCH:               hyper_reg_data_o = hyper_vector_pc[15:8];
      default: ;
    endcase
  end
end

always @(*)
begin
  case(mapper_reg_sel)
    MAP_A: mapper_reg_out = hyper_map_a;
    MAP_X: mapper_reg_out = hyper_map_x;
    MAP_Y: mapper_reg_out = hyper_map_y;
    MAP_Z: mapper_reg_out = hyper_map_z;
  endcase
end

always @(*)
begin
  if(hyper_force_cs)
    hyper_data_o = hyper_internal_data_o;
  else
    hyper_data_o = hyper_reg_data_o;
end

always @(posedge clk)
begin
  if(reset)  begin
    hyper_state <= HYPER_IDLE;
  end else begin
    hyper_state <= hyper_state_next;
    //$display("hyper state -> %d",hyper_state_next);
  end
end

always @(posedge clk)
begin

  // Clear hypervisor map enable gate when we enter so it defaults to disabled once we are in 
  // hypervisor mode.  The hypervisor can re-enable it later.   We also force enable it upon
  // exit.
  if(reset) begin
    hyper_mode <= 0;
    hyper_enter_reg <= 0;
    hyper_exit_reg <= 0;
    hyper_map_gate <= 1;
  end else if(hyper_enter_req) begin
    hyper_mode <= 1;
    hyper_map_gate <= 0;
  end else if(hyper_exit_req) begin
    hyper_exit_reg <= 1;    
  end else if(hyper_exit_ack) begin
    hyper_exit_reg <= 0;    
    hyper_map_gate <= 1;
    hyper_mode <= 0;
  end
  
  if(load_hyper_pc) begin
      if(cpu_map) begin
        $display("mapper enabled when capturing PC!");
        $finish;
      end      
      hyper_pc <= cpu_addr;
  end else if(load_hyper_pcl) begin
      hyper_pc[7:0] <= hyper_io_data_i;
  end else if(load_hyper_pch) begin
      hyper_pc[15:8] <= hyper_io_data_i;
  end
  
  if(hyper_enter_req) begin
    $display("hyper_trap_pc: %016x",{7'b1000000,hypervisor_trap_port,2'b00});
    hyper_trap_pc <= {7'b1000000,hypervisor_trap_port,2'b00};
  end else if(load_trap_pcl) begin
    hyper_trap_pc[7:0] <= hyper_io_data_i;
  end else if(load_trap_pch) begin
    hyper_trap_pc[15:8] <= hyper_io_data_i;  
  end

  if(reset)
    hyper_vector_pc <= 16'h00;
  else if(load_vector_pcl)
    hyper_vector_pc[7:0] <= hyper_io_data_i;
    
  if(reset)
    hyper_vector_pc[15:8] <= 16'h82;
  else if(load_vector_pch)
    hyper_vector_pc[15:8] <= hyper_io_data_i;  
  
  if(load_hyper_p | load_hyper_p_io) begin
    hyper_p <= hyper_io_data_i;
  end
  
  if(load_hyper_spl)
    hyper_sp[7:0] <= hyper_io_data_i;
    
  if(load_hyper_sph)
    hyper_sp[15:8] <= hyper_io_data_i;

  if(load_hyper_a)
    hyper_a <= hyper_io_data_i;

  if(load_hyper_x)
    hyper_x <= hyper_io_data_i;

  if(load_hyper_y)
    hyper_y <= hyper_io_data_i;

  if(load_hyper_z)
    hyper_z <= hyper_io_data_i;

  if(load_hyper_b)
    hyper_b <= hyper_io_data_i;
    
  if(swap_mapper_regs) begin
    case (mapper_reg_sel)
      MAP_A: hyper_map_a <= mapper_reg;
      MAP_X: hyper_map_x <= mapper_reg;
      MAP_Y: hyper_map_y <= mapper_reg;
      MAP_Z: hyper_map_z <= mapper_reg;
    endcase    
  end
end
  
// This will eventually be all of the register decoder stuff and other hypervisor entry/exit control.
always @(*)
begin
  hyper_enter_req = 0;
  hypervisor_trap_port = 0;
  load_hyper_a = 0;
  load_hyper_x = 0;
  load_hyper_y = 0;
  load_hyper_z = 0;
  load_hyper_b = 0;
  load_hyper_spl = 0;
  load_hyper_sph = 0;
  load_hyper_p_io = 0;
  load_hyper_pcl = 0;
  load_hyper_pch = 0;
  load_hyper_00 = 0;
  load_hyper_01 = 0;
  load_hyper_iomode = 0;
  load_trap_pcl = 0;
  load_trap_pch = 0;
  load_vector_pcl = 0;
  load_vector_pch = 0;
  hyper_exit_req = 0;
  
  if(hyper_cs & ready) begin
    if(hyper_addr[7:6] == 2'b01) begin
      if(cpu_write) begin
        if(hyper_mode) begin
          case(hyper_addr[5:0])
            //HYPER_REG_A:    load_hyper_a = 1;
            //HYPER_REG_X:    load_hyper_x = 1;
            //HYPER_REG_Y:    load_hyper_y = 1;
            //HYPER_REG_Z:    load_hyper_z = 1;
            //HYPER_REG_B:    load_hyper_b = 1;
            //HYPER_REG_SPL:  load_hyper_spl = 1;
            //HYPER_REG_SPH:  load_hyper_sph = 1;
            HYPER_REG_P:    load_hyper_p_io = 1;
            HYPER_REG_PCL:  load_hyper_pcl = 1;
            HYPER_REG_PCH:  load_hyper_pch = 1;
            //HYPER_REG_PORT_00: load_hyper_00 = 1;
            //HYPER_REG_PORT_01: load_hyper_01 = 1;
            HYPER_REG_IOMODE:  load_hyper_iomode = 1;
            HYPER_REG_TRAP_PCL: load_trap_pcl = 1;
            HYPER_REG_TRAP_PCH: load_trap_pch = 1;
            HYPER_REG_VECTOR_PCL: load_vector_pcl = 1;
            HYPER_REG_VECTOR_PCH: load_vector_pch = 1;
            HYPER_REG_EXIT: hyper_exit_req = 1;
            default: ;
          endcase
        end else begin
          hyper_enter_req = 1;
          hypervisor_trap_port = {1'b0,hyper_addr[5:0]};          
        end
      end
    end
  end

  // Default output states
  hyper_force_cs = 1; // Default to our mux source if not idle.
  map_enable_ext = 0;    // Mapping is pretty much disabled any time we're not in the idle state.
  hyper_internal_mux_sel = HYPER_MUX_JMP;
  swap_mapper_regs = 0;
  load_hyper_pc = 0;
  load_hyper_p = 0;
  hyper_enter_ack = 0;
  hyper_exit_ack = 0;
  mapper_reg_sel = MAP_A;
  
  hyper_state_next = hyper_state;
  
  case(hyper_state)
    // Wait here until we get a request to enter or exit hypervisor mode.
    HYPER_IDLE: begin
      //$display("hyper_state = HYPER_IDLE hyper_enter_req %d",hyper_enter_req);
      if(hyper_enter_req) begin
        //$display("hyper_enter_req=1, hyper_state_next = HYPER_ENTER_PHP_FETCH");
        hyper_state_next = HYPER_ENTER_PHP_FETCH;
      end else if(hyper_exit_req) begin
        //$display("hyper_exit_req=1, hyper_state_next = HYPER_EXIT_CLE_SEE_FETCH");
        hyper_state_next = HYPER_EXIT_CLE_SEE_FETCH;
      end else begin
        //$display("idle, hyper_state_next = HYPER_IDLE, map_enable_ext = %d",hyper_map_gate);
        map_enable_ext = hyper_map_gate;
        hyper_force_cs = 0;
      end
    end
    
    // Wait here until CPU begins fetch of next instruction.   Once it's sourcing
    // from the data bus we'll begin the process of interposing the instruction stream
    // and capturing the processor state.  We also begin the process of capturing the
    // current mapper state.   That runs in parallel with the process of performing
    // the trap.
    HYPER_ENTER_PHP_FETCH: begin
      //$display("hyper_state = HYPER_ENTER_PHP_FETCH ready: %d sync: %d",ready,cpu_sync);
      if(ready & cpu_sync) begin  // CPU is now fetching next instruction
        hyper_internal_mux_sel = HYPER_MUX_PHP_PLP;
        load_hyper_pc = 1;
        hyper_state_next = HYPER_ENTER_PHP_DEC;
        swap_mapper_regs = 1;
        mapper_reg_sel = MAP_A;
        //$display("hyper_state_next = HYPER_ENTER_PHP_DEC");
      end
    end
      
    HYPER_ENTER_PHP_DEC: begin
      //$display("hyper_state = HYPER_ENTER_PHP_DEC ready: %d",ready);
      hyper_internal_mux_sel = HYPER_MUX_JMP;
      if(ready) begin  // CPU is now pushing SP and P onto its "next" output, but we'll grab it on the next cycle.
        hyper_state_next = HYPER_ENTER_PHP_EX;
        swap_mapper_regs = 1;
        mapper_reg_sel = MAP_X;
        //$display("hyper_state_next = HYPER_ENTER_PHP_EX");
      end
    end
    
    HYPER_ENTER_PHP_EX: begin
      //$display("hyper_state = HYPER_ENTER_PHP_EX ready: %d",ready);
      hyper_internal_mux_sel = HYPER_MUX_JMP;
      if(ready) begin  // CPU now has P on the clocked data output so snag it and move on to next state.
        load_hyper_p = 1;
        hyper_state_next = HYPER_ENTER_JMP_FETCH;
        swap_mapper_regs = 1;
        mapper_reg_sel = MAP_Y;
        //$display("hyper_state_next = HYPER_ENTER_JMP_FETCH");
      end
    end
    
    HYPER_ENTER_JMP_FETCH: begin
      //$display("hyper_state = HYPER_ENTER_JMP_FETCH ready: %d",ready);
      hyper_internal_mux_sel = HYPER_MUX_JMP;
      if(ready & cpu_sync) begin  // Strictly speaking, the check for cpu_sync isn't needed, but it'd be a good assertion
        hyper_state_next = HYPER_ENTER_JMP_PCL;
        swap_mapper_regs = 1;
        mapper_reg_sel = MAP_Z;
        //$display("hyper_state_next = HYPER_ENTER_JMP_PCL");
      end
    end

    HYPER_ENTER_JMP_PCL: begin
      //$display("hyper_state = HYPER_ENTER_JMP_PCL ready: %d",ready);
      hyper_internal_mux_sel = HYPER_MUX_ENTER_PCL;
      if(ready) begin
        hyper_state_next = HYPER_ENTER_JMP_PCH;
        //$display("hyper_state_next = HYPER_ENTER_JMP_PCH");
      end
    end

    HYPER_ENTER_JMP_PCH: begin
      //$display("hyper_state = HYPER_ENTER_JMP_PCL ready: %d",ready);
      hyper_internal_mux_sel = HYPER_MUX_ENTER_PCH;
      if(ready) begin
        hyper_state_next = HYPER_IDLE;
        //$display("hyper_state_next = HYPER_IDLE");
      end
    end
  
    HYPER_EXIT_CLE_SEE_FETCH : begin
      //$display("hyper_state = HYPER_EXIT_CLE_SEE_FETCH");
      if(ready & cpu_sync) begin  // CPU is now fetching next instruction
        hyper_internal_mux_sel = HYPER_MUX_CLE_SEE;
        hyper_state_next = HYPER_EXIT_CLE_SEE_EX;
        swap_mapper_regs = 1;
        mapper_reg_sel = MAP_A;
        //$display("hyper_state_next = HYPER_EXIT_CLE_SEE_EX");
      end
    end
    
    HYPER_EXIT_CLE_SEE_EX : begin
      //$display("hyper_state = HYPER_EXIT_CLE_SEE_EX");
      hyper_internal_mux_sel = HYPER_MUX_PHP_PLP;
      if(ready) begin
        hyper_state_next = HYPER_EXIT_PLP_FETCH;
        swap_mapper_regs = 1;
        mapper_reg_sel = MAP_X;
        //$display("hyper_state_next = HYPER_EXIT_PLP_FETCH");
      end
    end

    HYPER_EXIT_PLP_FETCH : begin
      //$display("hyper_state = HYPER_EXIT_PLP_FETCH");
      hyper_internal_mux_sel = HYPER_MUX_PHP_PLP;
      if(ready & cpu_sync) begin  // CPU is now fetching next instruction
        hyper_state_next = HYPER_EXIT_PLP_DEC;
        swap_mapper_regs = 1;
        mapper_reg_sel = MAP_Y;
        //$display("hyper_state_next = HYPER_EXIT_PLP_DEC");
      end
    end

    HYPER_EXIT_PLP_DEC : begin
      //$display("hyper_state = HYPER_EXIT_PLP_DEC");
      hyper_internal_mux_sel = HYPER_MUX_P;
      if(ready) begin
        hyper_state_next = HYPER_EXIT_PLP_EX;
        swap_mapper_regs = 1;
        mapper_reg_sel = MAP_Z;
        //$display("hyper_state_next = HYPER_EXIT_PLP_EX");
      end
    end

    HYPER_EXIT_PLP_EX : begin
      //$display("hyper_state = HYPER_EXIT_PLP_DEC");
      hyper_internal_mux_sel = HYPER_MUX_P;
      if(ready) begin
        hyper_state_next = HYPER_EXIT_JMP_FETCH;
        //$display("hyper_state_next = HYPER_EXIT_PLP_EX");
      end
    end

    HYPER_EXIT_JMP_FETCH: begin
      //$display("hyper_state = HYPER_EXIT_JMP_FETCH");
      hyper_internal_mux_sel = HYPER_MUX_JMP;
      if(ready & cpu_sync) begin
        hyper_state_next = HYPER_EXIT_JMP_PCL;
        //$display("hyper_state_next = HYPER_EXIT_JMP_PCL");
      end
    end

    HYPER_EXIT_JMP_PCL: begin
      //$display("hyper_state = HYPER_EXIT_JMP_PCL");
      hyper_internal_mux_sel = HYPER_MUX_EXIT_PCL;
      if(ready) begin
        hyper_state_next = HYPER_EXIT_JMP_PCH;
        //$display("hyper_state_next = HYPER_EXIT_JMP_PCH");
      end
    end

    HYPER_EXIT_JMP_PCH: begin
      //$display("hyper_state = HYPER_EXIT_JMP_PCH");
      hyper_internal_mux_sel = HYPER_MUX_EXIT_PCH;
      if(ready) begin
        map_enable_ext = 1;
        hyper_exit_ack = 1;
        hyper_state_next = HYPER_IDLE;
        //$display("hyper_state_next = HYPER_IDLE");
      end
    end
    
  default:
    hyper_state_next <= 4'hx;
  endcase
  
end

endmodule
