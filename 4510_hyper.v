`include "6502_inc.vh"

module hyper_ctrl(input clk, input reset, input hyper_cs, input [7:0] hyper_addr, input [7:0] hyper_io_data_i, output reg [7:0] hyper_io_data_o,
                  input [15:0] cpu_addr, input [7:0] cpu_ext_data_i, input [7:0] cpu_data_o, input cpu_sync, input cpu_write, input ready,
                  output reg [7:0] cpu_data_i, output reg hyper_mode, /* output mapper_int_en, */ output reg map_enable,
                  output reg [1:0] mapper_reg_sel, input [7:0] mapper_reg);

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

reg [15:0] hyper_pc, load_hyper_pcl, load_hyper_pch, load_hyper_pc;
reg [15:0] hyper_sp, load_hyper_spl, load_hyper_sph, load_hyper_sp;
reg [7:0] hyper_p, load_hyper_p;

reg [7:0] hyper_map_enable;
reg [11:0] hyper_map_offset[0:1];

reg cpu_data_src;

reg cpu_data_mux_sel;
reg [2:0] hyper_mux_sel;

reg hyper_enter, hyper_exit;
reg hyper_enter_req, hyper_exit_req;

reg [3:0] hyper_state, hyper_state_next;

reg [15:0] hyper_enter_pc;

reg [6:0] hypervisor_trap_port;

reg [7:0] hyper_cpu_data_i;

reg hyper_map_gate;
reg hyper_exit_gate;
reg save_hyper_regs;

// Top level CPU data in mux
always @(*)
begin
  if(cpu_data_mux_sel) begin
    cpu_data_i <= hyper_cpu_data_i;
    $display("cpu_data hyp %02x",hyper_cpu_data_i);  
  end else begin
    cpu_data_i <= cpu_ext_data_i;
    $display("cpu_data mem %02x",cpu_ext_data_i);
  end
end

// Secondary mux
always @(*)
begin
  case (hyper_mux_sel)
    HYPER_MUX_PHP_PLP : hyper_cpu_data_i = hyper_exit ? 8'h28 : 8'h08; // PHP
    HYPER_MUX_P : hyper_cpu_data_i = hyper_p;
    HYPER_MUX_CLE_SEE : hyper_cpu_data_i = {7'b0000001,hyper_p[5]}; // CLE or SEE based on saved E bit
    HYPER_MUX_JMP : hyper_cpu_data_i = 8'h4C; // JMP
    HYPER_MUX_ENTER_PCL : hyper_cpu_data_i = hyper_enter_pc[7:0];
    HYPER_MUX_ENTER_PCH : hyper_cpu_data_i = hyper_enter_pc[15:8];
    HYPER_MUX_EXIT_PCL : hyper_cpu_data_i = hyper_pc[7:0];
    HYPER_MUX_EXIT_PCH : hyper_cpu_data_i = hyper_pc[15:8];
  endcase
end

always @(posedge clk)
begin
  if(reset)
    hyper_state <= HYPER_IDLE;
  else
    hyper_state <= hyper_state_next;
    $display("hyper state -> %d",hyper_state_next);
end

always @(posedge clk)
begin

  // Clear hypervisor map enable gate when we enter so it defaults to disabled once we are in 
  // hypervisor mode.  The hypervisor can re-enable it later.   We also force enable it upon
  // exit.
  if(reset) begin
    hyper_mode <= 0;
    hyper_map_gate <= 1;
  end else if(hyper_enter_req) begin
    hyper_mode <= 1;
    hyper_map_gate <= 0;
    hyper_enter_pc <= {7'b1000000,hypervisor_trap_port,2'b00};
    $display("hyper_enter_pc: %016x",{7'b1000000,hypervisor_trap_port,2'b00});
    hyper_exit <= 0;
  end else if(hyper_exit_req) begin
    hyper_exit <= 1;    
  end else if(hyper_exit_gate) begin
    hyper_map_gate <= 1;
    hyper_mode <= 0;
  end
  
  if(load_hyper_pc)
      hyper_pc <= cpu_addr;
      
  if(load_hyper_p)
    hyper_p <= cpu_data_o;
    
  if(save_hyper_regs) begin
    case (mapper_reg_sel)
      MAP_A: begin
        hyper_map_offset[0][7:0] <= mapper_reg;
      end
      
      MAP_X: begin
        hyper_map_offset[0][11:8] <= mapper_reg[3:0];
        hyper_map_enable[3:0] <= mapper_reg[7:4];
      end
      
      MAP_Y: begin
        hyper_map_offset[1][7:0] <= mapper_reg;
      end
      
      MAP_Z: begin
        hyper_map_offset[1][11:8] <= mapper_reg[3:0];
        hyper_map_enable[7:4] <= mapper_reg[7:4];
      end
    endcase    
  end
end
  
// This will eventually be all of the register decoder stuff and other hypervisor entry/exit control.
always @(*)
begin
  hyper_enter_req = 0;
  hyper_exit_req = 0;
  hypervisor_trap_port = 0;
  
  if(hyper_cs & ready) begin
    $display("HyperCS!");
    if(hyper_addr[7:6] == 2'b01) begin
      if(cpu_write) begin
        if(hyper_mode) begin
          hyper_exit_req = 1;
        end else begin
          hyper_enter_req = 1;
          hypervisor_trap_port <= {1'b0,cpu_addr[5:0]};
          $display("hyper_enter_req.  Trap port %d",hypervisor_trap_port);
        end
      end
    end
  end
end

// FSM next-state generation logic
always @(*)
begin
  // Default output states
  cpu_data_mux_sel = 1; // Default to our mux source if not idle.
  map_enable = 0;    // Mapping is pretty much disabled any time we're not in the idle state.
  hyper_mux_sel = HYPER_MUX_JMP;
  save_hyper_regs = 0;
  load_hyper_pc = 0;
  load_hyper_p = 0;
  hyper_exit_gate = 0;
  
  $display("hyper_state_next def: %d",hyper_state);
  hyper_state_next = hyper_state;
  
  case(hyper_state)
    // Wait here until we get a request to enter or exit hypervisor mode.
    HYPER_IDLE: begin
      $display("hyper_state = HYPER_IDLE hyper_enter_req %d",hyper_enter_req);
      if(hyper_enter_req) begin
        $display("hyper_state_next = HYPER_ENTER_PHP_FETCH");
        hyper_state_next = HYPER_ENTER_PHP_FETCH;
      end else if(hyper_exit_req)
        hyper_state_next = HYPER_EXIT_CLE_SEE_FETCH;
      else begin
        map_enable = hyper_map_gate;
        cpu_data_mux_sel = 0;
      end
    end
    
    // Wait here until CPU begins fetch of next instruction.   Once it's sourcing
    // from the data bus we'll begin the process of interposing the instruction stream
    // and capturing the processor state.  We also begin the process of capturing the
    // current mapper state.   That runs in parallel with the process of performing
    // the trap.
    HYPER_ENTER_PHP_FETCH: begin
      $display("hyper_state = HYPER_ENTER_PHP_FETCH ready: %d sync: %d",ready,cpu_sync);
      if(ready & cpu_sync) begin  // CPU is now fetching next instruction
        hyper_mux_sel = HYPER_MUX_PHP_PLP;
        load_hyper_pc = 1;
        hyper_state_next = HYPER_ENTER_PHP_DEC;
        save_hyper_regs = 1;
        mapper_reg_sel = MAP_A;
        $display("hyper_state_next = HYPER_ENTER_PHP_DEC");
      end
    end
      
    HYPER_ENTER_PHP_DEC: begin
      $display("hyper_state = HYPER_ENTER_PHP_DEC ready: %d",ready);
      hyper_mux_sel = HYPER_MUX_PHP_PLP;
      if(ready) begin  // CPU is now pushing SP and P onto its "next" output, but we'll grab it on the next cycle.
        hyper_mux_sel = HYPER_MUX_JMP;
        hyper_state_next = HYPER_ENTER_PHP_EX;
        save_hyper_regs = 1;
        mapper_reg_sel = MAP_X;
        $display("hyper_state_next = HYPER_ENTER_PHP_EX");
      end
    end
    
    HYPER_ENTER_PHP_EX: begin
      hyper_mux_sel = HYPER_MUX_PHP_PLP;
      if(ready) begin  // CPU now has P on the clocked data output so snag it and move on to next state.
        load_hyper_p = 1;
        hyper_state_next = HYPER_ENTER_JMP_FETCH;
        save_hyper_regs = 1;
        mapper_reg_sel = MAP_Y;
      end
    end
    
    HYPER_ENTER_JMP_FETCH: begin
      hyper_mux_sel = HYPER_MUX_JMP;
      if(ready & cpu_sync) begin  // Strictly speaking, the check for cpu_sync isn't needed, but it'd be a good assertion
        hyper_state_next = HYPER_ENTER_JMP_PCL;
        save_hyper_regs = 1;
        mapper_reg_sel = MAP_Z;
      end
    end

    HYPER_ENTER_JMP_PCL: begin
      hyper_mux_sel = HYPER_MUX_ENTER_PCL;
      if(ready) begin
        hyper_state_next = HYPER_ENTER_JMP_PCH;
      end
    end

    HYPER_ENTER_JMP_PCH: begin
      hyper_mux_sel = HYPER_MUX_ENTER_PCH;
      if(ready) begin
        hyper_state_next = HYPER_IDLE;
      end
    end
  
  default:
    hyper_state_next <= 4'hx;
  endcase
  
end

endmodule
