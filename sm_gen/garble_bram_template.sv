// Amazon FPGA Hardware Development Kit
//
// Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License"). You may not use
// this file except in compliance with the License. A copy of the License is
// located at
//
//    http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
// implied. See the License for the specific language governing permissions and
// limitations under the License.

// -----------------------------------------------------------------------------
// This module is an example of how to master transactions on a master port
// of the PCIS AXI Interconnect. The module issues a write command (Write
// virtual DIP switches and output to be reflected on the virtual LED.
//"I don't want to write any kind of HOST c/c++ application"/ Address, Write Data, and Write Response) followed by a read command (Read
// Address, and Read Data) to the same address.
// -----------------------------------------------------------------------------

module xor_gate (   
                    input               [79:0]  Ga,
		            input               [79:0]  Gb,
		            input                       aclk,
         	        input                       input_valid,
		            input                       aresetn,
		            output logic        [79:0]  Gc_xor_out
                );

    always_ff @(posedge aclk)
      	if (!aresetn) begin
		    Gc_xor_out <= 80'b0;
	    end
	    else if(input_valid) begin
		    Gc_xor_out <= Ga ^ Gb;
	    end
	    else begin
		    Gc_xor_out <= Gc_xor_out;
	    end
endmodule

module cl_dram_dma_axi_mstr (

    input            aclk,
    input            aresetn,
    axi_bus_t.slave  cl_axi_mstr_bus,  // AXI Master Bus
    cfg_bus_t.master axi_mstr_cfg_bus  // Config Bus for Register Access
);

 `include "cl_dram_dma_defines.vh"
// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------

   // State Machine States
   typedef enum logic [2:0] {
      AXI_MSTR_SM_IDLE     = 3'd0,
      AXI_MSTR_SM_WR       = 3'd1,
      AXI_MSTR_SM_WR_DATA  = 3'd2,
      AXI_MSTR_SM_WR_RESP  = 3'd3,
      AXI_MSTR_SM_RD       = 3'd4,
      AXI_MSTR_SM_RD_DATA  = 3'd5
                             } axi_mstr_sm_states;

///////////////////////////////////////////////////////////////////////////////	
// ->state_enum
// -----------------------------------------------------------------------------
// Internal signals
// -----------------------------------------------------------------------------

   // Command Registers
   logic        cmd_done_ns;
   logic [31:0] cmd_rd_data_ns;

   logic        cmd_go_q;
   logic        cmd_done_q;
   logic        cmd_rd_wrb_q;
   logic [31:0] cmd_addr_hi_q;
   logic [31:0] cmd_addr_lo_q;
   logic [31:0] cmd_rd_data_q;
   logic [31:0] cmd_wr_data_q;

   // AXI Master State Machine
   axi_mstr_sm_states axi_mstr_sm_ns;
   axi_mstr_sm_states axi_mstr_sm_q;

   logic axi_mstr_sm_idle;
   logic axi_mstr_sm_wr;
   logic axi_mstr_sm_wr_data;
   logic axi_mstr_sm_wr_resp;
   logic axi_mstr_sm_rd;
   logic axi_mstr_sm_rd_data;

   logic cfg_wr_stretch;
   logic cfg_rd_stretch;

   logic [15:0] cfg_addr_q  = 0; // Only care about lower 8-bits of address. Upper bits are decoded somewhere else.
   logic [31:0] cfg_wdata_q = 0;

///////////////////////////////////////////////////////////////////////////////	
   logic [31:0] gbr_sm_cmd;
   logic [31:0] gbr_sm_and_en_q;
   logic [31:0] gbr_sm_en_q;
   logic [31:0] gbr_sm_xor_en_q;
   logic [31:0] gbr_output;
   logic [31:0] gbr_output1;
   logic [31:0] gbr_output2;
	
   garbler_sm_states garbler_sm_q;
   garbler_sm_states garbler_sm_ns;
	
//->signals
   logic 		garbler_sm_core_done_q, garbler_sm_core_done_ns;	

   logic [31:0]		R1_q;
   logic [31:0]		R2_q;
   logic [31:0]		R3_q;

   logic 		garble_and_aresetn;
   logic [79:0] 	R;	
   logic [511:0] 	data_write_back_q;

// Generate BRAM
 
//---------------------------------------
// Inst RAMs
//---------------------------------------

logic [31:0] bram_addra_wr ;
logic [31:0] bram_addrb_rd ;
logic [511:0] bram_da_wr,bram_qa_wr,bram_qb_rd;

bram_2rw #(.WIDTH(512), .ADDR_WIDTH(31), .DEPTH(10000) ) BRAM_INST (
   .clk(aclk),
   .wea(1'b1),
   .ena(1'b1),
   .addra(bram_addra_wr),
   .da(bram_da_wr),
   .qa(bram_qa_wr),

   .web(1'b0),
   .enb(1'b1),
   .addrb(bram_addrb_rd),
   .db(512'h0),
   .qb(bram_qb_rd)
   );
// write read bram
// ->bram_write_read
// -----------------------------------------------------------------------------
// Register Access
// -----------------------------------------------------------------------------

   always @(posedge aclk)
      if (!aresetn)
      begin
         cfg_wr_stretch <= 0;
         cfg_rd_stretch <= 0;
      end
      else
      begin
         cfg_wr_stretch <= axi_mstr_cfg_bus.wr || (cfg_wr_stretch && !axi_mstr_cfg_bus.ack);
         cfg_rd_stretch <= axi_mstr_cfg_bus.rd || (cfg_rd_stretch && !axi_mstr_cfg_bus.ack);
         if (axi_mstr_cfg_bus.wr||axi_mstr_cfg_bus.rd)
         begin
            cfg_addr_q  <= axi_mstr_cfg_bus.addr[16:0];
            cfg_wdata_q <= axi_mstr_cfg_bus.wdata[31:0];
         end
      end
   
   //Readback mux
   always @(posedge aclk)
   begin
         case (cfg_addr_q)
            16'h00:      axi_mstr_cfg_bus.rdata[31:0] <= {29'b0, cmd_rd_wrb_q, cmd_done_q, cmd_go_q};
            16'h04:      axi_mstr_cfg_bus.rdata[31:0] <= cmd_addr_hi_q[31:0];
            16'h08:      axi_mstr_cfg_bus.rdata[31:0] <= cmd_addr_lo_q[31:0];
            16'h0C:      axi_mstr_cfg_bus.rdata[31:0] <= cmd_wr_data_q[31:0];
            16'h10:      axi_mstr_cfg_bus.rdata[31:0] <= cmd_rd_data_q[31:0];
            16'h14:	    axi_mstr_cfg_bus.rdata[31:0] <= gbr_sm_en_q[31:0];
            16'h18:	    axi_mstr_cfg_bus.rdata[31:0] <= gbr_sm_xor_en_q[31:0];
            16'h1C:	    axi_mstr_cfg_bus.rdata[31:0] <= gbr_output[31:0];
            16'hE0: 	    axi_mstr_cfg_bus.rdata[31:0] <= gbr_output1[31:0];
            16'hE4:	    axi_mstr_cfg_bus.rdata[31:0] <= gbr_output2[31:0];
            16'hE8: 	    axi_mstr_cfg_bus.rdata[31:0] <= {31'b0, garbler_sm_core_done_q};
            default:    axi_mstr_cfg_bus.rdata[31:0] <= 32'hffffffff;
         endcase
   end
   
   //Ack for cycle
   always_ff @(posedge aclk)
      if (!aresetn)
         axi_mstr_cfg_bus.ack <= 0;
      else
         axi_mstr_cfg_bus.ack <= ((cfg_wr_stretch||cfg_rd_stretch) && !axi_mstr_cfg_bus.ack);

// -----------------------------------------------------------------------------
// AXI Master Command Registers
// -----------------------------------------------------------------------------
// Offset     Register
// -------    --------------------
// 0x00       Command Control Register (CCR)
//             31:3 - Reserved
//                2 - Read/Write_B
//                1 - Done
//                0 - Go
// 0x04       Command Address High Register (CAHR)
//             31:0 - Address
// 0x08       Command Address Low Register (CALR)
//             31:0 - Address
// 0x0C       Command Write Data Register (CWDR)
//             31:0 - Write Data
// 0x10       Command Read Data Register (CRDR)
//             31:3 - Read Data

/////////////////////////////////////////////////////////////////////////////////////
// MY REGISTER MAPPINGS
// -------------------------------------------------------------------------------
// 0x14		and enable regs    	gbr_sm_en_q
// 0x18		xor enable regs    	gbr_sm_xor_en_q
// 0x1C	 	my output			gbr_output
// -------------------------------------------------------------------------------
// 0x20		gbr_input_addr_arr[0]
// 0x24		gbr_input_addr_arr[1]
// 0x28		gbr_input_addr_arr[2]
// 0x2C		gbr_input_addr_arr[3]
// 0x30		gbr_input_addr_arr[4]
// 0x34		gbr_input_addr_arr[5]
// 0x38		gbr_input_addr_arr[6]
// 0x3C		gbr_input_addr_arr[7]
//
// 0xA0		gbr_output_addr_arr[0]
// 0xA4		gbr_output_addr_arr[1]
// 0xA8		gbr_output_addr_arr[2]
// 0xAC		gbr_output_addr_arr[3]
//
// 0xD0		R[]
// 0xD4		R[]
// 0xD8		R[]
// 0xCC		gate id 0[31:0]
// 0xC8		gate id 1[31:0]
// 0xC4		gate id 2[31:0]
// 0xC0		gate id 3[31:0]				
// 0xE4		
// 0xE8 	sm_done_q

   // ----------------------
   // Command Go
   // ----------------------

//->cmd_go


   // ----------------------
   // Command Done
   // ----------------------

//->cmd_done

   // ----------------------
   // Command Rd/Wr_B
   // ----------------------

//->cmd_rw

   // ----------------------
   // Command Address - High
   // ----------------------

   always_ff @(posedge aclk)
      if (!aresetn) begin
         cmd_addr_hi_q[31:0] <= 32'h0000_0000;
      end
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CAHR_ADDR)) begin
         cmd_addr_hi_q[31:0] <= cfg_wdata_q[31:0];
      end
      else begin
         cmd_addr_hi_q[31:0] <= cmd_addr_hi_q[31:0];
      end

   // ----------------------
   // Command Address - Low
   // ----------------------

//->cmd_addr_low
   // ----------------------
   // Command Write Data
   // ----------------------

   always_ff @(posedge aclk)
      if (!aresetn) begin
         cmd_wr_data_q[31:0] <= 32'h0000_0000;
      end
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CWDR_ADDR)) begin
         cmd_wr_data_q <= cfg_wdata_q[31:0];
      end
      else begin
         cmd_wr_data_q[31:0] <= cmd_wr_data_q[31:0];
      end

   // ----------------------
   // Command Read Data
   // ----------------------

   assign cmd_rd_data_ns[31:0] =
        // (axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? cl_axi_mstr_bus.rdata[31:0] :
        (axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  
	                                                cmd_rd_data_q[31:0]         ;		//my changes here

   always_ff @(posedge aclk)
      if (!aresetn) begin
         cmd_rd_data_q[31:0] <= 32'h0000_0000;
      end
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CRDR_ADDR)) begin
         cmd_rd_data_q <= cfg_wdata_q[31:0];
      end
      else begin
         cmd_rd_data_q[31:0] <= cmd_rd_data_ns[31:0];
      end

//////////////////////////////////////////////////////////////////////////////////////////////////
	
	// ----------------------
   	// and enable reg write 
   	// ----------------------

	always_ff @(posedge aclk)
      if (!aresetn) begin
         gbr_sm_en_q[31:0] <= 32'h0000_0000;
      end
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 16'h14)) begin
         gbr_sm_en_q[31:0] <= cfg_wdata_q[31:0];
      end
      else begin
         gbr_sm_en_q[31:0] <= gbr_sm_en_q[31:0];
      end

	// ----------------------
   	// xor enable reg write 
   	// ----------------------

	always_ff @(posedge aclk)
      if (!aresetn) begin
         gbr_sm_xor_en_q[31:0] <= 32'h0000_0000;
      end
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 16'h18)) begin
         gbr_sm_xor_en_q[31:0] <= cfg_wdata_q[31:0];
      end
      else begin
         gbr_sm_xor_en_q[31:0] <= gbr_sm_xor_en_q[31:0];
      end
	
	// ----------------------
   	// garble core input addresses 
   	// ----------------------

//->garble_input_addr

	////////////////////////////////////////////////


//->garble_output_addr

//->garble_table_out_addr


      always_ff @(posedge aclk)
      if (!aresetn) begin
         R1_q <= 32'h0000_0000;
      end
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 16'hD0)) begin
         R1_q <= cfg_wdata_q[31:0];
      end
      else begin
         R1_q <= R1_q;
      end
	
      always_ff @(posedge aclk)
      if (!aresetn) begin
         R2_q <= 32'h0000_0000;
      end
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 16'hD4)) begin
         R2_q <= cfg_wdata_q[31:0];
      end
      else begin
         R2_q <= R2_q;
      end

      always_ff @(posedge aclk)
      if (!aresetn) begin
         R3_q <= 32'h0000_0000;
      end
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 16'hD8)) begin
         R3_q <= cfg_wdata_q[31:0];
      end
      else begin
         R3_q <= R3_q;
      end
//->gate_id	


      assign R= {R1_q[31:0], R2_q[31:0], R3_q[31:16]};
// -----------------------------------------------------------------------------
// AXI Master State Machine
// -----------------------------------------------------------------------------

   // States
   // ----------------------------
   // 0. Idle           - Waiting for command
   // 1. Write          - Sending write address request (awvalid)
   // 2. Write Data     - Sending write data (wvalid)
   // 3. Write Response - Waiting for write response (bvalid)
   // 4. Read           - Sending read address request (arvalid)
   // 5. Read Data      - Waiting for read data (rvalid)

   always_comb begin
     // Default
     axi_mstr_sm_ns[2:0]  = AXI_MSTR_SM_IDLE;

     case (axi_mstr_sm_q[2:0])

       AXI_MSTR_SM_IDLE: begin
         if (cmd_go_q & ~cmd_done_q)
           if (cmd_rd_wrb_q) axi_mstr_sm_ns[2:0] = AXI_MSTR_SM_RD;
           else              axi_mstr_sm_ns[2:0] = AXI_MSTR_SM_WR;
         else                axi_mstr_sm_ns[2:0] = AXI_MSTR_SM_IDLE;
       end

       AXI_MSTR_SM_WR: begin
         if (cl_axi_mstr_bus.awready) axi_mstr_sm_ns[2:0] = AXI_MSTR_SM_WR_DATA;
         else                         axi_mstr_sm_ns[2:0] = AXI_MSTR_SM_WR;
       end

       AXI_MSTR_SM_WR_DATA: begin
         if (cl_axi_mstr_bus.wready) axi_mstr_sm_ns[2:0]  = AXI_MSTR_SM_WR_RESP;
         else                        axi_mstr_sm_ns[2:0]  = AXI_MSTR_SM_WR_DATA;
       end

       AXI_MSTR_SM_WR_RESP: begin
         if (cl_axi_mstr_bus.bvalid)  axi_mstr_sm_ns[2:0] = AXI_MSTR_SM_IDLE;
         else                         axi_mstr_sm_ns[2:0] = AXI_MSTR_SM_WR_RESP;
       end

       AXI_MSTR_SM_RD: begin
         if (cl_axi_mstr_bus.arready) axi_mstr_sm_ns[2:0] = AXI_MSTR_SM_RD_DATA;
         else                         axi_mstr_sm_ns[2:0] = AXI_MSTR_SM_RD;
       end

       AXI_MSTR_SM_RD_DATA: begin
         if (cl_axi_mstr_bus.rvalid)  axi_mstr_sm_ns[2:0] = AXI_MSTR_SM_IDLE;
         else                         axi_mstr_sm_ns[2:0] = AXI_MSTR_SM_RD_DATA;
       end

       default: axi_mstr_sm_ns[2:0]  = AXI_MSTR_SM_IDLE;

     endcase
   end

   // AXI Master SM Flop
   always_ff @(posedge aclk)
      if (!aresetn) begin
         axi_mstr_sm_q[2:0] <= 3'h0;
      end
      else begin
         axi_mstr_sm_q[2:0] <= axi_mstr_sm_ns[2:0];
      end

   // State nets
   assign axi_mstr_sm_idle     = (axi_mstr_sm_q[2:0] == AXI_MSTR_SM_IDLE);
   assign axi_mstr_sm_wr       = (axi_mstr_sm_q[2:0] == AXI_MSTR_SM_WR);
   assign axi_mstr_sm_wr_data  = (axi_mstr_sm_q[2:0] == AXI_MSTR_SM_WR_DATA);
   assign axi_mstr_sm_wr_resp  = (axi_mstr_sm_q[2:0] == AXI_MSTR_SM_WR_RESP);
   assign axi_mstr_sm_rd       = (axi_mstr_sm_q[2:0] == AXI_MSTR_SM_RD);
   assign axi_mstr_sm_rd_data  = (axi_mstr_sm_q[2:0] == AXI_MSTR_SM_RD_DATA);

//////////////////////////////////////////////////////////////////////////////////////////////////
	
// -----------------------------------------------------------------------------
// MY GARBLE AND State Machine
// -----------------------------------------------------------------------------

   // States
   // ----------------------------
   // 0. IDLE           - Waiting for command
   // 1. GA DATA LOAD   - load data issue to gbr_sm_cmd(001) and wait for cmd_done 
   // 2. GB DATA LOAD   - load data issue to gbr_sm_cmd(001) and wait for cmd_done
   // 3. PROCESS		- wait for garble and valid
   // 4. DONE           - collect results back
   // 5. RESET	        - reset to clear the garble and core

//->states

   // AXI Master SM Flop
//->axi_sm_flop
//->assign_sm

//////////////////////////////////////////////////////////////////////////////////////////////////
	
// -----------------------------------------------------------------------------
// MY GARBLE AND core Machine
// -----------------------------------------------------------------------------
	
//->dec_inputs
	
//->instantiate
	assign gbr_output1 = Gc_0_q;
	assign gbr_output2 = toSend01_0_q;

	
	assign garbler_sm_core_done_ns = garbler_sm_core_done_q | garbler_sm_reset; // (axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid);
	 always_ff @(posedge aclk)
                if(!aresetn) begin
                        garbler_sm_core_done_q <= 1'b0;
                end
		else if((cfg_wr_stretch & ~axi_mstr_cfg_bus.ack) & (cfg_addr_q == 16'hE8)) begin
			 garbler_sm_core_done_q <= 1'b0;
		end
                else begin
                        garbler_sm_core_done_q <= garbler_sm_core_done_ns;
                end
	
//->assign_wb

// -----------------------------------------------------------------------------
// AXI Bus Connections
// -----------------------------------------------------------------------------

   // Write Address
   assign cl_axi_mstr_bus.awid[15:0]   = 16'b0;                     // Only 1 outstanding command
   assign cl_axi_mstr_bus.awaddr[63:0] = {cmd_addr_hi_q[31:0], cmd_addr_lo_q[31:0]};
   assign cl_axi_mstr_bus.awlen[7:0]   = 8'h00;                     // Always 1 burst
   assign cl_axi_mstr_bus.awsize[2:0]  = 3'b100;                    // Always 4 bytes, change to 16 bytes write
   assign cl_axi_mstr_bus.awvalid      = axi_mstr_sm_wr;

   // Write Data
   assign cl_axi_mstr_bus.wid[15:0]    = 16'b0;                        // Only 1 outstanding command
   assign cl_axi_mstr_bus.wdata[511:0] = data_write_back_q[511:0] << (8 * cmd_addr_lo_q[5:0]); //{toSend01[79:0], 48'b0, toSend10[79:0], 48'b0, toSend11[79:0], 48'b0, Gc_q[79:0], 48'b0} << (8 * cmd_addr_lo_q[5:0]);  // {480'b0, cmd_wr_data_q[31:0]}
   assign cl_axi_mstr_bus.wstrb[63:0]  = 64'h0000_0000_0000_FFFF << cmd_addr_lo_q[5:0];      // Always 4 bytes   64'h0000_0000_0000_000F
   assign cl_axi_mstr_bus.wlast        = 1'b1;                         // Always 1 burst
   assign cl_axi_mstr_bus.wvalid       = axi_mstr_sm_wr_data;

   // Write Response
   assign cl_axi_mstr_bus.bready       = axi_mstr_sm_wr_resp;

   // Read Address
   assign cl_axi_mstr_bus.arid[15:0]   = 16'b0;                     // Only 1 outstanding command
   assign cl_axi_mstr_bus.araddr[63:0] = {cmd_addr_hi_q[31:0], cmd_addr_lo_q[31:0]};
   assign cl_axi_mstr_bus.arlen[7:0]   = 8'h00;                     // Always 1 burst     change to 2 
   assign cl_axi_mstr_bus.arsize[2:0]  = 3'b110;                    // Always 4 bytes     change to 64 bytes
   assign cl_axi_mstr_bus.arvalid      = axi_mstr_sm_rd;

   // Read Data
   assign cl_axi_mstr_bus.rready       = axi_mstr_sm_rd_data;

endmodule   
