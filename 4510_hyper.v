/* 
** Copyright (c) 2018 Kenneth C. Dyke
** 
** Permission is hereby granted, free of charge, to any person obtaining a copy
** of this software and associated documentation files (the "Software"), to deal
** in the Software without restriction, including without limitation the rights
** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
** copies of the Software, and to permit persons to whom the Software is
** furnished to do so, subject to the following conditions:
** 
** The above copyright notice and this permission notice shall be included in all
** copies or substantial portions of the Software.
** 
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
** SOFTWARE.
*/

`include "65ce02_inc.vh"

`define EN_MARK_DEBUG
`ifdef EN_MARK_DEBUG
`define MARK_DEBUG (* mark_debug = "true", dont_touch = "true" *)
`else
`define MARK_DEBUG
`endif

`SCHEM_KEEP_HIER module hyper_ctrl(input clk, input phi1, input phi2, input phi3, input reset, `MARK_DEBUG input hyper_cs, 
                  `MARK_DEBUG input [7:0] hyper_addr, `MARK_DEBUG input [7:0] hyper_io_data_i, `MARK_DEBUG output reg [7:0] hyper_data_o,
                  `MARK_DEBUG input cpu_write, `MARK_DEBUG input ready, `MARK_DEBUG input hyper_mode, `MARK_DEBUG output reg hyp, 
                  `MARK_DEBUG output reg load_user_reg, `MARK_DEBUG input [7:0] user_mapper_reg,
                  output reg [7:0] virtualised_hardware, output reg [7:0] protected_hardware, 
                  output wire rom_writeprotect, output wire speed_gate_enable, output wire force_fast,
                  `MARK_DEBUG output reg [7:0] monitor_char, `MARK_DEBUG output reg monitor_char_toggle, `MARK_DEBUG input monitor_char_busy,
                  `MARK_DEBUG input [1:0] iomode, `MARK_DEBUG output reg [1:0] iomode_set, `MARK_DEBUG output reg iomode_set_toggle);

// Note: Many of these registers won't be needed once I do the cutover and then
// rework the kickstart code to just use kickstart memory locations rather than
// dedicated registers.   Using registers for these is only currently for 
// compatibility reasons with the current kickstart code, which I don't want
// to change too much until I can switch to the new CPU core/hypervisor
// implementation.
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
          HYPER_REG_PORT_01 = 6'h11,
          HYPER_REG_IOMODE  = 6'h12,  // This is just storage at the moment.
          
          HYPER_REG_VIRT_HW = 6'h19,
                              
          // D672 - Protected hardware
          HYPER_REG_PROT_HW = 6'h32,
          
          HYPER_REG_SET_IOMODE = 6'h33,
          
          // New regisers used to control the initial entry vector and to record
          // the actual desired trap.
          HYPER_REG_VECTOR_PCL = 6'h34,
          HYPER_REG_VECTOR_PCH = 6'h35,
          
          HYPER_REG_TRAP_PCL = 6'h36,
          HYPER_REG_TRAP_PCH = 6'h37,
          
          HYPER_REG_UART_OUT = 6'h3C,
          HYPER_REG_OVERRIDES = 6'h3D,
          HYPER_REG_UPGRADED = 6'h3E,
          
          // This last one isn't used any more
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

// Combinatorial signals used to begin enter/exit sequence.
reg hyper_enter_req, hyper_enter_ack;

reg load_trap_pcl, load_trap_pch;
reg [15:0] hyper_trap_pc;

reg load_vector_pcl, load_vector_pch;
reg [15:0] hyper_vector_pc;

reg [6:0] hypervisor_trap_port;

reg [7:0] hyper_reg_data_o;

reg [7:0] hyper_a, hyper_x, hyper_y, hyper_z, hyper_b;
reg load_a, load_x, load_y, load_z, load_b;
reg [7:0] hyper_spl, hyper_sph, hyper_p, hyper_pcl, hyper_pch;
reg load_spl, load_sph, load_p, load_pcl, load_pch;
reg [7:0] hyper_port_00, hyper_port_01;
reg load_port_00, load_port_01;
reg [1:0] hyper_iomode;
reg load_iomode;
`MARK_DEBUG reg hyper_upgraded;

reg [7:0] overrides;

reg load_overrides;
reg load_virtualised_hw;
reg load_protected_hw;
reg load_set_iomode;
reg load_uart_out;
`MARK_DEBUG reg load_hyper_upgraded;


always @(*)
begin
  hyper_enter_ack = 0;
  hyper_reg_data_o = 8'hFF;
  if(hyper_mode & hyper_cs & hyper_addr[7:6] == 2'b01) begin
    case(hyper_addr[5:0])
      HYPER_REG_A:                        hyper_reg_data_o = hyper_a;
      HYPER_REG_X:                        hyper_reg_data_o = hyper_x;
      HYPER_REG_Y:                        hyper_reg_data_o = hyper_y;
      HYPER_REG_Z:                        hyper_reg_data_o = hyper_z;
      HYPER_REG_B:                        hyper_reg_data_o = hyper_b;
      HYPER_REG_SPL:                      hyper_reg_data_o = hyper_spl;
      HYPER_REG_SPH:                      hyper_reg_data_o = hyper_sph;
      HYPER_REG_P:                        hyper_reg_data_o = hyper_p;
      HYPER_REG_PCL:                      hyper_reg_data_o = hyper_pcl;
      HYPER_REG_PCH:                      hyper_reg_data_o = hyper_pch;
      HYPER_REG_MAP_A:                    hyper_reg_data_o = user_mapper_reg;
      HYPER_REG_MAP_X:                    hyper_reg_data_o = user_mapper_reg;
      HYPER_REG_MAP_Y:                    hyper_reg_data_o = user_mapper_reg;
      HYPER_REG_MAP_Z:                    hyper_reg_data_o = user_mapper_reg;
      HYPER_REG_PORT_00:                  hyper_reg_data_o = hyper_port_00;
      HYPER_REG_PORT_01:                  hyper_reg_data_o = hyper_port_01;
      HYPER_REG_IOMODE:                   hyper_reg_data_o = hyper_iomode;
      HYPER_REG_TRAP_PCL:                 hyper_reg_data_o = hyper_trap_pc[7:0];
      HYPER_REG_TRAP_PCH:                 hyper_reg_data_o = hyper_trap_pc[15:8];
      HYPER_REG_VECTOR_PCL: begin
        hyper_enter_ack = 1;
        hyper_reg_data_o = hyper_vector_pc[7:0];
      end
      HYPER_REG_VECTOR_PCH:               hyper_reg_data_o = hyper_vector_pc[15:8];

      HYPER_REG_SET_IOMODE:               hyper_reg_data_o = iomode;
      HYPER_REG_OVERRIDES:                hyper_reg_data_o = overrides;
      HYPER_REG_VIRT_HW:                  hyper_reg_data_o = virtualised_hardware;
      HYPER_REG_PROT_HW:                  hyper_reg_data_o = protected_hardware;
      HYPER_REG_UART_OUT:                 hyper_reg_data_o = {6'b0,monitor_char_busy,monitor_char_busy};
      HYPER_REG_UPGRADED:                 hyper_reg_data_o = {hyper_upgraded,2'b11,5'b0}; // FIXME, exrom and game not hooked up yet
      HYPER_REG_EXIT:                     hyper_reg_data_o = 8'h48;
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
  
  // Default hypervisor vector landing address is 0x8200 but can be changed by
  // the hypervisor if desired.
  if(reset)
    hyper_vector_pc[15:8] <= 16'h82;
  else if(load_vector_pch)
    hyper_vector_pc[15:8] <= hyper_io_data_i;  

  if(reset)
    hyper_vector_pc[7:0] <= 16'h00;
  else if(load_vector_pcl)
    hyper_vector_pc[7:0] <= hyper_io_data_i;    

  // These are all just storage and so don't really need special reset
  // treatment.
  if(load_a) hyper_a <= hyper_io_data_i;
  if(load_x) hyper_x <= hyper_io_data_i;
  if(load_y) hyper_y <= hyper_io_data_i;
  if(load_z) hyper_z <= hyper_io_data_i;
  if(load_b) hyper_b <= hyper_io_data_i;
  if(load_p) hyper_p <= hyper_io_data_i;
  if(load_spl) hyper_spl <= hyper_io_data_i;
  if(load_sph) hyper_sph <= hyper_io_data_i;
  if(load_pcl) hyper_pcl <= hyper_io_data_i;
  if(load_pch) hyper_pch <= hyper_io_data_i;
  if(load_port_00) hyper_port_00 <= hyper_io_data_i;
  if(load_port_01) hyper_port_01 <= hyper_io_data_i;
  if(load_iomode) hyper_iomode <= hyper_io_data_i[1:0];
  
  if(reset)
    virtualised_hardware <= 0;
  else if(load_virtualised_hw) 
    virtualised_hardware <= hyper_io_data_i;
  
  if(reset)
    protected_hardware <= 0;
  else if(load_protected_hw)
    protected_hardware <= hyper_io_data_i;
    
  if(load_uart_out) begin
    monitor_char <= hyper_io_data_i;
    monitor_char_toggle <= ~monitor_char_toggle;
  end
  
  if(load_set_iomode) begin
    iomode_set <= hyper_io_data_i;
    iomode_set_toggle <= ~iomode_set_toggle;
  end
  
  if(reset)
    overrides <= 8'h40;
  else if(load_overrides)
    overrides <= hyper_io_data_i;
    
  if(reset)
    hyper_upgraded <= 0;
  else if(load_hyper_upgraded)
    hyper_upgraded <= 1;
  
end
  
assign rom_writeprotect = overrides[2];
assign speed_gate_enable = overrides[3];
assign force_fast = overrides[4];

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
  load_a = 0;
  load_x = 0;
  load_y = 0;
  load_z = 0;
  load_b = 0;
  load_spl = 0;
  load_sph = 0;
  load_p = 0;
  load_pcl = 0;
  load_pch = 0;
  load_port_00 = 0;
  load_port_01 = 0;
  load_iomode = 0;
  
  load_overrides = 0;
  load_virtualised_hw = 0;
  load_protected_hw = 0;
  load_iomode = 0;
  load_set_iomode = 0;
  load_uart_out = 0;
  load_hyper_upgraded = 0;
  
  if(hyper_cs & phi3) begin
    if(hyper_addr[7:6] == 2'b01) begin
      if(cpu_write) begin
        if(hyper_mode) begin
          case(hyper_addr[5:0])
            HYPER_REG_A: load_a = 1;
            HYPER_REG_X: load_x = 1;
            HYPER_REG_Y: load_y = 1;
            HYPER_REG_Z: load_z = 1;
            HYPER_REG_B: load_b = 1;
            HYPER_REG_SPL: load_spl = 1;
            HYPER_REG_SPH: load_sph = 1;
            HYPER_REG_P: load_p = 1;
            HYPER_REG_PCL: load_pcl = 1;
            HYPER_REG_PCH: load_pch = 1;
            
            HYPER_REG_PORT_00: load_port_00 = 1;
            HYPER_REG_PORT_01: load_port_01 = 1;
            HYPER_REG_IOMODE: load_iomode = 1;
            
            HYPER_REG_MAP_A, HYPER_REG_MAP_X,
            HYPER_REG_MAP_Y, HYPER_REG_MAP_Z: load_user_reg = 1;

            HYPER_REG_TRAP_PCL: load_trap_pcl = 1;
            HYPER_REG_TRAP_PCH: load_trap_pch = 1;
            HYPER_REG_VECTOR_PCL: load_vector_pcl = 1;
            HYPER_REG_VECTOR_PCH: load_vector_pch = 1;
            
            HYPER_REG_SET_IOMODE: load_set_iomode = 1;
            HYPER_REG_VIRT_HW: load_virtualised_hw = 1;
            HYPER_REG_PROT_HW: load_protected_hw = 1;
            HYPER_REG_OVERRIDES: load_overrides = 1;
            HYPER_REG_UART_OUT: load_uart_out = 1;
            HYPER_REG_UPGRADED: load_hyper_upgraded = 1;
            
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
