`include "65ce02_inc.vh"

`SCHEM_KEEP_HIER module hyper_ctrl(input clk, input reset, input hyper_cs, input [7:0] hyper_addr, input [7:0] hyper_io_data_i, output reg [7:0] hyper_data_o,
                  input cpu_write, input ready, input hyper_mode, output reg hyp, output reg load_user_reg, input [7:0] user_mapper_reg);

parameter HYPER_REG_A = 6'h00,
          HYPER_REG_X = 6'h01,
          HYPER_REG_Y = 6'h02,
          HYPER_REG_Z = 6'h03,
          //HYPER_REG_B = 6'h04,
          //HYPER_REG_SPL = 6'h05,
          //HYPER_REG_SPH = 6'h06,
          //HYPER_REG_P   = 6'h07,
          //HYPER_REG_PCL = 6'h08,
          //HYPER_REG_PCH = 6'h09,
          //HYPER_REG_MAP_X = 6'h0A,
          //HYPER_REG_MAP_A = 6'h0B,
          //HYPER_REG_MAP_Z = 6'h0C,
          //HYPER_REG_MAP_Y = 6'h0D,
          HYPER_REG_TRAP_PCL = 6'h0E,
          HYPER_REG_TRAP_PCH = 6'h0F,
          //HYPER_REG_PORT_00 = 6'h10,
          //HYPER_REG_PORT_01 = 6'h10,
          //HYPER_REG_IOMODE  = 6'h12,
          HYPER_REG_VECTOR_PCL = 6'h20,
          HYPER_REG_VECTOR_PCH = 6'h21;
          
          //HYPER_REG_EXIT = 6'h3F;
          
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

// Combinatorial signals used to begin enter/exit sequence.
reg hyper_enter_req, hyper_enter_ack;

reg load_trap_pcl, load_trap_pch;
reg [15:0] hyper_trap_pc;

reg load_vector_pcl, load_vector_pch;
reg [15:0] hyper_vector_pc;

reg [6:0] hypervisor_trap_port;

reg [7:0] hyper_reg_data_o;

always @(*)
begin
  hyper_enter_ack = 0;
  hyper_reg_data_o = 8'hFF;
  if(hyper_mode & hyper_cs & hyper_addr[7:6] == 2'b01) begin
    case(hyper_addr[5:0])
      HYPER_REG_A:                        hyper_reg_data_o = user_mapper_reg;
      HYPER_REG_X:                        hyper_reg_data_o = user_mapper_reg;
      HYPER_REG_Y:                        hyper_reg_data_o = user_mapper_reg;
      HYPER_REG_Z:                        hyper_reg_data_o = user_mapper_reg;
      //HYPER_REG_B:                        hyper_reg_data_o = hyper_b;
      //HYPER_REG_SPL:                      hyper_reg_data_o = hyper_sp[7:0];
      //HYPER_REG_SPH:                      hyper_reg_data_o = hyper_sp[15:8];
      //HYPER_REG_P:                        hyper_reg_data_o = hyper_p;
      //HYPER_REG_PCL:                      hyper_reg_data_o = hyper_pc[7:0];
      //HYPER_REG_PCH:                      hyper_reg_data_o = hyper_pc[15:8];
      //HYPER_REG_MAP_A:                    hyper_reg_data_o = hyper_map_a;
      //HYPER_REG_MAP_X:                    hyper_reg_data_o = hyper_map_x;
      //HYPER_REG_MAP_Y:                    hyper_reg_data_o = hyper_map_y;
      //HYPER_REG_MAP_Z:                    hyper_reg_data_o = hyper_map_z;
      //HYPER_REG_PORT_00:                  hyper_reg_data_o = hyper_port_00;
      //HYPER_REG_PORT_01:                  hyper_reg_data_o = hyper_port_01;
      //HYPER_REG_IOMODE:                   hyper_reg_data_o = hyper_iomode;
      HYPER_REG_TRAP_PCL:                 hyper_reg_data_o = hyper_trap_pc[7:0];
      HYPER_REG_TRAP_PCH:                 hyper_reg_data_o = hyper_trap_pc[15:8];
      HYPER_REG_VECTOR_PCL: begin
        hyper_enter_ack = 1;
        hyper_reg_data_o = hyper_vector_pc[7:0];
      end
      HYPER_REG_VECTOR_PCH:               hyper_reg_data_o = hyper_vector_pc[15:8];
      default: ;
    endcase
  end
end

always @(posedge clk)
begin
    hyper_data_o = hyper_reg_data_o;
end

always @(posedge clk)
begin

  if(reset) begin
    hyp <= 0;
  end else if(hyper_enter_req) begin
    hyp <= 1;
  end else if(hyper_enter_ack) begin
    hyp <= 0;
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
  
end
  
// This will eventually be all of the register decoder stuff and other hypervisor entry/exit control.
always @(*)
begin
  hyper_enter_req = 0;
  hypervisor_trap_port = 0;
  load_user_reg = 0;
  load_trap_pcl = 0;
  load_trap_pch = 0;
  load_vector_pcl = 0;
  load_vector_pch = 0;
  
  if(hyper_cs & ready) begin
    if(hyper_addr[7:6] == 2'b01) begin
      if(cpu_write) begin
        if(hyper_mode) begin
          case(hyper_addr[5:0])
            HYPER_REG_A, HYPER_REG_X,
            HYPER_REG_Y, HYPER_REG_Z: load_user_reg = 1;

            HYPER_REG_TRAP_PCL: load_trap_pcl = 1;
            HYPER_REG_TRAP_PCH: load_trap_pch = 1;
            HYPER_REG_VECTOR_PCL: load_vector_pcl = 1;
            HYPER_REG_VECTOR_PCH: load_vector_pch = 1;
            default: ;
          endcase
        end else begin
          hyper_enter_req = 1;
          hypervisor_trap_port = {1'b0,hyper_addr[5:0]};          
        end
      end
    end
  end
end

endmodule
