`include "6502_inc.vh"

`SCHEM_KEEP_HIER module hyper_ctrl(input clk, input reset, input hyper_cs, input [7:0] hyper_addr, input [7:0] hyper_io_data_i, output reg [7:0] hyper_io_data_o,
                  input cpu_write, input ready,
                  output reg [7:0] cpu_data_i, output reg hyper_mode, output reg hyper_enter, output reg hyper_exit, output reg map_enable_ext,
                  output reg [1:0] mapper_reg_sel, input [7:0] mapper_reg);

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
          HYPER_REG_PORT_00 = 6'h10,
          HYPER_REG_PORT_01 = 6'h10,
          HYPER_REG_IOMODE  = 6'h12,
          
          HYPER_REG_ENTER_PCH = 6'h27,
          HYPER_REG_ENTER_PCL = 6'h28,
          HYPER_REG_ENTER_P = 6'h29,
          HYPER_REG_TRAP_PCL = 6'h2A,
          HYPER_REG_TRAP_PCH = 6'h2B,
          
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
// 0A - hyper_map_low | hyper_map_offset_low[11:8]
// 0B - hyper_map_offset_low[7:0]
// 0C - hyper_map_high | hyper_map_offset_high[11:8]
// 0D - hyper_map_offset_high[7:0]
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
// 27 - hyper_p alias
// 28 - hyper_pcl alias
// 29 - hyper_pch alias
// 2A - hyper_enter_pcl
// 2B - hyper_enter_pch
// 32 - Protected Hardware 
// 3F - Hyper Exit trigger

reg [15:0] hyper_pc, load_hyper_pcl, load_hyper_pch;
reg [15:0] hyper_sp, load_hyper_spl, load_hyper_sph;
reg [7:0] hyper_p, load_hyper_p;

reg [7:0] hyper_map_enable;
reg [11:0] hyper_map_offset[0:1];

reg load_hyper_a, load_hyper_x, load_hyper_y, load_hyper_z, load_hyper_b;
reg [7:0] hyper_a, hyper_x, hyper_y, hyper_z, hyper_b;

reg cpu_data_src;

reg cpu_data_mux_sel;
reg [2:0] hyper_mux_sel;

// Combinatorial signals used to begin enter/exit sequence.
reg hyper_enter_req, hyper_exit_req;
reg hyper_enter_reg, hyper_exit_reg;

reg [15:0] hyper_enter_pc;

reg [6:0] hypervisor_trap_port;

reg [7:0] hyper_cpu_data_i;

reg hyper_enter_ack;
reg hyper_exit_ack;

reg hyper_map_gate;
reg save_hyper_regs;

always @(*)
begin
  map_enable_ext = hyper_map_gate;
end

always @(*)
begin
  hyper_enter = hyper_enter_req | hyper_enter_reg;
  hyper_exit  = hyper_exit_req | hyper_exit_reg;
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
    hyper_enter_reg <= 1;
    hyper_map_gate <= 0;
    $display("hyper_enter_pc: %016x",{7'b1000000,hypervisor_trap_port,2'b00});
    hyper_enter_pc <= {7'b1000000,hypervisor_trap_port,2'b00};
    hyper_exit_reg <= 0;
  end else if(hyper_enter_ack) begin
    hyper_enter_reg <= 0;
  end else if(hyper_exit_req) begin
    hyper_exit_reg <= 1;    
  end else if(hyper_exit_ack) begin
    hyper_exit_reg <= 0;    
    hyper_map_gate <= 1;
    hyper_mode <= 0;
  end
  
  if(load_hyper_pcl) begin
    $display("hyper pcl: %02x",hyper_io_data_i);
    hyper_pc[7:0] <= hyper_io_data_i;
  end
  
  if(load_hyper_pch) begin
    $display("hyper pch: %02x",hyper_io_data_i);
    hyper_pc[15:8] <= hyper_io_data_i;
  end
  
  if(load_hyper_p) begin
    $display("hyper p: %02x",hyper_io_data_i);
    hyper_p <= hyper_io_data_i;
  end
  
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
  hyper_enter_ack = 0;
  hyper_exit_req = 0;
  hyper_exit_ack = 0;
  hypervisor_trap_port = 0;
  load_hyper_pcl = 0;
  load_hyper_pch = 0;
  
  if(hyper_cs & ready) begin
    $display("HyperCS!");
    if(hyper_addr[7:6] == 2'b01) begin
      $display("Hyper01!");
      if(cpu_write) begin
        $display("HyperWrite");
        if(hyper_mode) begin
          case(hyper_addr[5:0])
            HYPER_REG_A:                        load_hyper_a = 1;
            HYPER_REG_X:                        load_hyper_x = 1;
            HYPER_REG_Y:                        load_hyper_y = 1;
            HYPER_REG_Z:                        load_hyper_z = 1;
            HYPER_REG_B:                        load_hyper_b = 1;
            HYPER_REG_SPL:                      load_hyper_spl = 1;
            HYPER_REG_SPH:                      load_hyper_sph = 1;
            HYPER_REG_P, HYPER_REG_ENTER_P:     load_hyper_p = 1;
            HYPER_REG_PCL, HYPER_REG_ENTER_PCL: load_hyper_pcl = 1;
            HYPER_REG_PCH, HYPER_REG_ENTER_PCH: load_hyper_pch = 1;
            HYPER_REG_EXIT:                     hyper_exit_req = 1;
            default: ;
          endcase
        end else begin
          hyper_enter_req = 1;
          hypervisor_trap_port <= {1'b0,hyper_addr[5:0]};          
          $display("hyper_enter_req.  Trap port %d",hypervisor_trap_port);
        end
      end
    end
  end
end

// Read decode.
always @(*)
begin
  save_hyper_regs = 0;
  mapper_reg_sel = 0;
  hyper_io_data_o = 8'hFF;
  if(hyper_mode & hyper_cs & hyper_addr[7:6] == 2'b01) begin
    case(hyper_addr[5:0])
      HYPER_REG_A:                        hyper_io_data_o = hyper_a;
      HYPER_REG_X:                        hyper_io_data_o = hyper_x;
      HYPER_REG_Y:                        hyper_io_data_o = hyper_y;
      HYPER_REG_Z:                        hyper_io_data_o = hyper_z;
      HYPER_REG_B:                        hyper_io_data_o = hyper_b;
      HYPER_REG_SPL:                      hyper_io_data_o = hyper_sp[7:0];
      HYPER_REG_SPH:                      hyper_io_data_o = hyper_sp[15:8];
      HYPER_REG_P:                        hyper_io_data_o = hyper_p;
      HYPER_REG_PCL:                      hyper_io_data_o = hyper_pc[7:0];
      HYPER_REG_PCH:                      hyper_io_data_o = hyper_pc[15:8];
      HYPER_REG_ENTER_P: begin
        hyper_io_data_o = hyper_p;
        if(hyper_enter) begin
          save_hyper_regs = 1;
          mapper_reg_sel = MAP_A;
          hyper_enter_ack = 1;
        end
      end
      HYPER_REG_ENTER_PCL: begin
        hyper_io_data_o = hyper_pc[7:0];
        if(hyper_enter) begin
          save_hyper_regs = 1;
          mapper_reg_sel = MAP_X;
        end
      end
      HYPER_REG_ENTER_PCH: begin
        hyper_io_data_o = hyper_pc[15:8];
        if(hyper_enter) begin
          save_hyper_regs = 1;
          mapper_reg_sel = MAP_Y;
        end
      end
      HYPER_REG_TRAP_PCL: begin
        hyper_io_data_o = hyper_enter_pc[7:0];
        $display("HYPER_REG_TRAP_PCL: %02x",hyper_enter_pc[7:0]);
        if(hyper_enter) begin
          save_hyper_regs = 1;
          mapper_reg_sel = MAP_Z;
        end
      end
      HYPER_REG_TRAP_PCH:                  hyper_io_data_o = hyper_enter_pc[15:8];
      default:;
    endcase
    $display("hyper read sel %02x %02x",hyper_addr[5:0],hyper_io_data_o);
  end
end

always @(*)
begin
  hyper_exit_ack = 0;
  if(hyper_mode & hyper_cs & hyper_addr[7:6] == 2'b01)
    if(hyper_addr[5:0] == HYPER_REG_P)
      hyper_exit_ack = 1;
end

endmodule
