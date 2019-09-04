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
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   typedef enum logic[7:0] { 
                   GABLER_SM_IDLE                           = 8'd0, 
                   GABLER_SM_0_PREP                         = 8'd1,
                   GABLER_SM_0_GA_ARLD                      = 8'd2,
                   GABLER_SM_0_GA_LD                        = 8'd3,
                   GABLER_SM_0_GA_ARLD_BRAM                 = 8'd4,
                   GABLER_SM_0_GA_LD_BRAM                   = 8'd5,
                   GABLER_SM_0_GB_ARLD                      = 8'd6,
                   GABLER_SM_0_GB_LD                        = 8'd7,
                   GABLER_SM_0_GB_ARLD_BRAM                 = 8'd8,
                   GABLER_SM_0_GB_LD_BRAM                   = 8'd9,
                   GABLER_SM_0_VALID                        = 8'd10,
                   GABLER_SM_0_PROC                         = 8'd11,
                   GABLER_SM_0_DONE                         = 8'd12,
                   GABLER_SM_0_COLLECT                      = 8'd13,
                   GABLER_SM_0_COLLECT_DONE                 = 8'd14,
                   GABLER_SM_0_COLLECT_BRAM                 = 8'd15,
                   GABLER_SM_0_COLLECT_BRAM_DONE            = 8'd16,
                   GABLER_SM_0_COLLECT_TS01                 = 8'd17,
                   GABLER_SM_0_COLLECT_TS01_DONE            = 8'd18,
                   GABLER_SM_0_COLLECT_TS01_BRAM            = 8'd19,
                   GABLER_SM_0_COLLECT_TS01_BRAM_DONE       = 8'd20,
                   GABLER_SM_0_COLLECT_TS10                 = 8'd21,
                   GABLER_SM_0_COLLECT_TS10_DONE            = 8'd22,
                   GABLER_SM_0_COLLECT_TS10_BRAM            = 8'd23,
                   GABLER_SM_0_COLLECT_TS10_BRAM_DONE       = 8'd24,
                   GABLER_SM_0_COLLECT_TS11                 = 8'd25,
                   GABLER_SM_0_COLLECT_TS11_DONE            = 8'd26,
                   GABLER_SM_0_COLLECT_TS11_BRAM            = 8'd27,
                   GABLER_SM_0_COLLECT_TS11_BRAM_DONE       = 8'd28,
   
                   GABLER_SM_1_PREP                         = 8'd29,
                   GABLER_SM_1_GA_ARLD                      = 8'd30,
                   GABLER_SM_1_GA_LD                        = 8'd31,
                   GABLER_SM_1_GA_ARLD_BRAM                 = 8'd32,
                   GABLER_SM_1_GA_LD_BRAM                   = 8'd33,
                   GABLER_SM_1_GB_ARLD                      = 8'd34,
                   GABLER_SM_1_GB_LD                        = 8'd35,
                   GABLER_SM_1_GB_ARLD_BRAM                 = 8'd36,
                   GABLER_SM_1_GB_LD_BRAM                   = 8'd37,
                   GABLER_SM_1_VALID                        = 8'd38,
                   GABLER_SM_1_PROC                         = 8'd39,
                   GABLER_SM_1_DONE                         = 8'd40,
                   GABLER_SM_1_COLLECT                      = 8'd41,
                   GABLER_SM_1_COLLECT_DONE                 = 8'd42,
                   GABLER_SM_1_COLLECT_BRAM                 = 8'd43,
                   GABLER_SM_1_COLLECT_BRAM_DONE            = 8'd44,
                   GABLER_SM_1_COLLECT_TS01                 = 8'd45,
                   GABLER_SM_1_COLLECT_TS01_DONE            = 8'd46,
                   GABLER_SM_1_COLLECT_TS01_BRAM            = 8'd47,
                   GABLER_SM_1_COLLECT_TS01_BRAM_DONE       = 8'd48,
                   GABLER_SM_1_COLLECT_TS10                 = 8'd49,
                   GABLER_SM_1_COLLECT_TS10_DONE            = 8'd50,
                   GABLER_SM_1_COLLECT_TS10_BRAM            = 8'd51,
                   GABLER_SM_1_COLLECT_TS10_BRAM_DONE       = 8'd52,
                   GABLER_SM_1_COLLECT_TS11                 = 8'd53,
                   GABLER_SM_1_COLLECT_TS11_DONE            = 8'd54,
                   GABLER_SM_1_COLLECT_TS11_BRAM            = 8'd55,
                   GABLER_SM_1_COLLECT_TS11_BRAM_DONE       = 8'd56,

                   GABLER_SM_2_PREP                         = 8'd57,
                   GABLER_SM_2_GA_ARLD                      = 8'd58,
                   GABLER_SM_2_GA_LD                        = 8'd59,
                   GABLER_SM_2_GA_ARLD_BRAM                 = 8'd60,
                   GABLER_SM_2_GA_LD_BRAM                   = 8'd61,
                   GABLER_SM_2_GB_ARLD                      = 8'd62,
                   GABLER_SM_2_GB_LD                        = 8'd63,
                   GABLER_SM_2_GB_ARLD_BRAM                 = 8'd64,
                   GABLER_SM_2_GB_LD_BRAM                   = 8'd65,
                   GABLER_SM_2_VALID                        = 8'd66,
                   GABLER_SM_2_PROC                         = 8'd67,
                   GABLER_SM_2_DONE                         = 8'd68,
                   GABLER_SM_2_COLLECT                      = 8'd69,
                   GABLER_SM_2_COLLECT_DONE                 = 8'd70,
                   GABLER_SM_2_COLLECT_BRAM                 = 8'd71,
                   GABLER_SM_2_COLLECT_BRAM_DONE            = 8'd72,
                   GABLER_SM_2_COLLECT_TS01                 = 8'd73,
                   GABLER_SM_2_COLLECT_TS01_DONE            = 8'd74,
                   GABLER_SM_2_COLLECT_TS01_BRAM            = 8'd75,
                   GABLER_SM_2_COLLECT_TS01_BRAM_DONE       = 8'd76,
                   GABLER_SM_2_COLLECT_TS10                 = 8'd77,
                   GABLER_SM_2_COLLECT_TS10_DONE            = 8'd78,
                   GABLER_SM_2_COLLECT_TS10_BRAM            = 8'd79,
                   GABLER_SM_2_COLLECT_TS10_BRAM_DONE       = 8'd80,
                   GABLER_SM_2_COLLECT_TS11                 = 8'd81,
                   GABLER_SM_2_COLLECT_TS11_DONE            = 8'd82,
                   GABLER_SM_2_COLLECT_TS11_BRAM            = 8'd83,
                   GABLER_SM_2_COLLECT_TS11_BRAM_DONE       = 8'd84,

                   GABLER_SM_3_PREP                         = 8'd85,
                   GABLER_SM_3_GA_ARLD                      = 8'd86,
                   GABLER_SM_3_GA_LD                        = 8'd87,
                   GABLER_SM_3_GA_ARLD_BRAM                 = 8'd88,
                   GABLER_SM_3_GA_LD_BRAM                   = 8'd89,
                   GABLER_SM_3_GB_ARLD                      = 8'd90,
                   GABLER_SM_3_GB_LD                        = 8'd91,
                   GABLER_SM_3_GB_ARLD_BRAM                 = 8'd92,
                   GABLER_SM_3_GB_LD_BRAM                   = 8'd93,
                   GABLER_SM_3_VALID                        = 8'd94,
                   GABLER_SM_3_PROC                         = 8'd95,
                   GABLER_SM_3_DONE                         = 8'd96,
                   GABLER_SM_3_COLLECT                      = 8'd97,
                   GABLER_SM_3_COLLECT_DONE                 = 8'd98,
                   GABLER_SM_3_COLLECT_BRAM                 = 8'd99,
                   GABLER_SM_3_COLLECT_BRAM_DONE            = 8'd100,
                   GABLER_SM_3_COLLECT_TS01                 = 8'd101,
                   GABLER_SM_3_COLLECT_TS01_DONE            = 8'd102,
                   GABLER_SM_3_COLLECT_TS01_BRAM            = 8'd103,
                   GABLER_SM_3_COLLECT_TS01_BRAM_DONE       = 8'd104,
                   GABLER_SM_3_COLLECT_TS10                 = 8'd105,
                   GABLER_SM_3_COLLECT_TS10_DONE            = 8'd106,
                   GABLER_SM_3_COLLECT_TS10_BRAM            = 8'd107,
                   GABLER_SM_3_COLLECT_TS10_BRAM_DONE       = 8'd108,
                   GABLER_SM_3_COLLECT_TS11                 = 8'd109,
                   GABLER_SM_3_COLLECT_TS11_DONE            = 8'd110,
                   GABLER_SM_3_COLLECT_TS11_BRAM            = 8'd111,
                   GABLER_SM_3_COLLECT_TS11_BRAM_DONE       = 8'd112,

                   GABLER_SM_4_PREP                         = 8'd113,
                   GABLER_SM_4_GA_ARLD                      = 8'd114,
                   GABLER_SM_4_GA_LD                        = 8'd115,
                   GABLER_SM_4_GA_ARLD_BRAM                 = 8'd116,
                   GABLER_SM_4_GA_LD_BRAM                   = 8'd117,
                   GABLER_SM_4_GB_ARLD                      = 8'd118,
                   GABLER_SM_4_GB_LD                        = 8'd119,
                   GABLER_SM_4_GB_ARLD_BRAM                 = 8'd120,
                   GABLER_SM_4_GB_LD_BRAM                   = 8'd121,
                   GABLER_SM_4_VALID                        = 8'd122,
                   GABLER_SM_4_PROC                         = 8'd123,
                   GABLER_SM_4_DONE                         = 8'd124,
                   GABLER_SM_4_COLLECT                      = 8'd125,
                   GABLER_SM_4_COLLECT_BRAM                 = 8'd126,
                   
                   GABLER_SM_5_PREP                         = 8'd127,
                   GABLER_SM_5_GA_ARLD                      = 8'd128,
                   GABLER_SM_5_GA_LD                        = 8'd129,
                   GABLER_SM_5_GA_ARLD_BRAM                 = 8'd130,
                   GABLER_SM_5_GA_LD_BRAM                   = 8'd131,
                   GABLER_SM_5_GB_ARLD                      = 8'd132,
                   GABLER_SM_5_GB_LD                        = 8'd133,
                   GABLER_SM_5_GB_ARLD_BRAM                 = 8'd134,
                   GABLER_SM_5_GB_LD_BRAM                   = 8'd135,
                   GABLER_SM_5_VALID                        = 8'd136,
                   GABLER_SM_5_PROC                         = 8'd137,
                   GABLER_SM_5_DONE                         = 8'd138,
                   GABLER_SM_5_COLLECT                      = 8'd139,
                   GABLER_SM_5_COLLECT_BRAM                 = 8'd140,
                   
                   GABLER_SM_6_PREP                         = 8'd141,
                   GABLER_SM_6_GA_ARLD                      = 8'd142,
                   GABLER_SM_6_GA_LD                        = 8'd143,
                   GABLER_SM_6_GA_ARLD_BRAM                 = 8'd144,
                   GABLER_SM_6_GA_LD_BRAM                   = 8'd145,
                   GABLER_SM_6_GB_ARLD                      = 8'd146,
                   GABLER_SM_6_GB_LD                        = 8'd147,
                   GABLER_SM_6_GB_ARLD_BRAM                 = 8'd148,
                   GABLER_SM_6_GB_LD_BRAM                   = 8'd149,
                   GABLER_SM_6_VALID                        = 8'd150,
                   GABLER_SM_6_PROC                         = 8'd151,
                   GABLER_SM_6_DONE                         = 8'd152,
                   GABLER_SM_6_COLLECT                      = 8'd153,
                   GABLER_SM_6_COLLECT_BRAM                 = 8'd154,
                   
                   GABLER_SM_7_PREP                         = 8'd155,
                   GABLER_SM_7_GA_ARLD                      = 8'd156,
                   GABLER_SM_7_GA_LD                        = 8'd157,
                   GABLER_SM_7_GA_ARLD_BRAM                 = 8'd158,
                   GABLER_SM_7_GA_LD_BRAM                   = 8'd159,
                   GABLER_SM_7_GB_ARLD                      = 8'd160,
                   GABLER_SM_7_GB_LD                        = 8'd161,
                   GABLER_SM_7_GB_ARLD_BRAM                 = 8'd162,
                   GABLER_SM_7_GB_LD_BRAM                   = 8'd163,
                   GABLER_SM_7_VALID                        = 8'd164,
                   GABLER_SM_7_PROC                         = 8'd165,
                   GABLER_SM_7_DONE                         = 8'd166,
                   GABLER_SM_7_COLLECT                      = 8'd167,
                   GABLER_SM_7_COLLECT_BRAM                 = 8'd168,
                   
                   GABLER_SM_0_GA_LD_BRAM_DONE                   = 8'd169,
                   GABLER_SM_0_GB_LD_BRAM_DONE                   = 8'd170,
                   
                   GABLER_SM_1_GA_LD_BRAM_DONE                   = 8'd171,
                   GABLER_SM_1_GB_LD_BRAM_DONE                   = 8'd172,
                   
                   GABLER_SM_2_GA_LD_BRAM_DONE                   = 8'd173,
                   GABLER_SM_2_GB_LD_BRAM_DONE                   = 8'd174,
                   
                   GABLER_SM_3_GA_LD_BRAM_DONE                   = 8'd175,
                   GABLER_SM_3_GB_LD_BRAM_DONE                   = 8'd176,
                   
                   GABLER_SM_4_GA_LD_BRAM_DONE                   = 8'd177,
                   GABLER_SM_4_GB_LD_BRAM_DONE                   = 8'd178,
                   
                   GABLER_SM_5_GA_LD_BRAM_DONE                   = 8'd179,
                   GABLER_SM_5_GB_LD_BRAM_DONE                   = 8'd180,
                   
                   GABLER_SM_6_GA_LD_BRAM_DONE                   = 8'd181,
                   GABLER_SM_6_GB_LD_BRAM_DONE                   = 8'd182,
                   
                   GABLER_SM_7_GA_LD_BRAM_DONE                   = 8'd183,
                   GABLER_SM_7_GB_LD_BRAM_DONE                   = 8'd184,
                   
   
                   GABLER_SM_RESET                          = 8'd185 } garbler_sm_states;
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////
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

   logic [ 7:0] cfg_addr_q  = 0; // Only care about lower 8-bits of address. Upper bits are decoded somewhere else.
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
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   
   logic [31:0]gbr_0_output_ts01;
   logic [31:0]gbr_0_output_ts10;
   logic [31:0]gbr_0_output_ts11;
   
   logic [31:0]gbr_1_output_ts01;
   logic [31:0]gbr_1_output_ts10;
   logic [31:0]gbr_1_output_ts11;
   
   logic [31:0]gbr_2_output_ts01;
   logic [31:0]gbr_2_output_ts10;
   logic [31:0]gbr_2_output_ts11;
   
   logic [31:0]gbr_3_output_ts01;
   logic [31:0]gbr_3_output_ts10;
   logic [31:0]gbr_3_output_ts11;
   logic garbler_sm_reset;
   logic garbler_sm_idle;
   
   logic garbler_sm_0_ga_arld;
   logic garbler_sm_0_ga_ld;
   logic garbler_sm_0_ga_arld_bram;
   logic garbler_sm_0_ga_ld_bram;
   logic garbler_sm_0_ga_ld_bram_done;
   logic garbler_sm_0_gb_arld;
   logic garbler_sm_0_gb_ld;
   logic garbler_sm_0_gb_arld_bram;
   logic garbler_sm_0_gb_ld_bram;
   logic garbler_sm_0_gb_ld_bram_done;
   logic garbler_sm_0_valid;
   logic garbler_sm_0_proc;
   logic garbler_sm_0_done;
   logic garbler_sm_0_collect;
   logic garbler_sm_0_collect_bram;
   logic garbler_sm_0_collect_done;
   logic garbler_sm_0_collect_ts01;
   logic garbler_sm_0_collect_ts01_bram;
   logic garbler_sm_0_collect_ts01_done;
   logic garbler_sm_0_collect_ts10;
   logic garbler_sm_0_collect_ts10_bram;
   logic garbler_sm_0_collect_ts10_done;
   logic garbler_sm_0_collect_ts11;
   logic garbler_sm_0_collect_ts11_bram;
   
   logic garbler_sm_1_ga_arld;
   logic garbler_sm_1_ga_ld;
   logic garbler_sm_1_ga_arld_bram;
   logic garbler_sm_1_ga_ld_bram;
   logic garbler_sm_1_ga_ld_bram_done;
   logic garbler_sm_1_gb_arld;
   logic garbler_sm_1_gb_ld;
   logic garbler_sm_1_gb_arld_bram;
   logic garbler_sm_1_gb_ld_bram;
   logic garbler_sm_1_gb_ld_bram_done;
   logic garbler_sm_1_valid;
   logic garbler_sm_1_proc;
   logic garbler_sm_1_done;
   logic garbler_sm_1_collect;
   logic garbler_sm_1_collect_bram;
   logic garbler_sm_1_collect_done;
   logic garbler_sm_1_collect_ts01;
   logic garbler_sm_1_collect_ts01_bram;
   logic garbler_sm_1_collect_ts01_done;
   logic garbler_sm_1_collect_ts10;
   logic garbler_sm_1_collect_ts10_bram;
   logic garbler_sm_1_collect_ts10_done;
   logic garbler_sm_1_collect_ts11;
   logic garbler_sm_1_collect_ts11_bram;
   
   logic garbler_sm_2_ga_arld;
   logic garbler_sm_2_ga_ld;
   logic garbler_sm_2_ga_arld_bram;
   logic garbler_sm_2_ga_ld_bram;
   logic garbler_sm_2_ga_ld_bram_done;
   logic garbler_sm_2_gb_arld;
   logic garbler_sm_2_gb_ld;
   logic garbler_sm_2_gb_arld_bram;
   logic garbler_sm_2_gb_ld_bram;
   logic garbler_sm_2_gb_ld_bram_done;
   logic garbler_sm_2_valid;
   logic garbler_sm_2_proc;
   logic garbler_sm_2_done;
   logic garbler_sm_2_collect;
   logic garbler_sm_2_collect_bram;
   logic garbler_sm_2_collect_done;
   logic garbler_sm_2_collect_ts01;
   logic garbler_sm_2_collect_ts01_bram;
   logic garbler_sm_2_collect_ts01_done;
   logic garbler_sm_2_collect_ts10;
   logic garbler_sm_2_collect_ts10_bram;
   logic garbler_sm_2_collect_ts10_done;
   logic garbler_sm_2_collect_ts11;
   logic garbler_sm_2_collect_ts11_bram;
   
   logic garbler_sm_3_ga_arld;
   logic garbler_sm_3_ga_ld;
   logic garbler_sm_3_ga_arld_bram;
   logic garbler_sm_3_ga_ld_bram;
   logic garbler_sm_3_ga_ld_bram_done;
   logic garbler_sm_3_gb_arld;
   logic garbler_sm_3_gb_ld;
   logic garbler_sm_3_gb_arld_bram;
   logic garbler_sm_3_gb_ld_bram;
   logic garbler_sm_3_gb_ld_bram_done;
   logic garbler_sm_3_valid;
   logic garbler_sm_3_proc;
   logic garbler_sm_3_done;
   logic garbler_sm_3_collect;
   logic garbler_sm_3_collect_bram;
   logic garbler_sm_3_collect_done;
   logic garbler_sm_3_collect_ts01;
   logic garbler_sm_3_collect_ts01_bram;
   logic garbler_sm_3_collect_ts01_done;
   logic garbler_sm_3_collect_ts10;
   logic garbler_sm_3_collect_ts10_bram;
   logic garbler_sm_3_collect_ts10_done;
   logic garbler_sm_3_collect_ts11;
   logic garbler_sm_3_collect_ts11_bram;


   logic garbler_sm_4_ga_arld;
   logic garbler_sm_4_ga_ld;
   logic garbler_sm_4_ga_arld_bram;
   logic garbler_sm_4_ga_ld_bram;
   logic garbler_sm_4_ga_ld_bram_done;
   logic garbler_sm_4_gb_arld;
   logic garbler_sm_4_gb_ld;
   logic garbler_sm_4_gb_arld_bram;
   logic garbler_sm_4_gb_ld_bram;
   logic garbler_sm_4_gb_ld_bram_done;
   logic garbler_sm_4_valid;
   logic garbler_sm_4_proc;
   logic garbler_sm_4_done;
   logic garbler_sm_4_collect;
   logic garbler_sm_4_collect_bram;
   

   logic garbler_sm_5_ga_arld;
   logic garbler_sm_5_ga_ld;
   logic garbler_sm_5_ga_arld_bram;
   logic garbler_sm_5_ga_ld_bram;
   logic garbler_sm_5_ga_ld_bram_done;
   logic garbler_sm_5_gb_arld;
   logic garbler_sm_5_gb_ld;
   logic garbler_sm_5_gb_arld_bram;
   logic garbler_sm_5_gb_ld_bram;
   logic garbler_sm_5_gb_ld_bram_done;
   logic garbler_sm_5_valid;
   logic garbler_sm_5_proc;
   logic garbler_sm_5_done;
   logic garbler_sm_5_collect;
   logic garbler_sm_5_collect_bram;
   

   logic garbler_sm_6_ga_arld;
   logic garbler_sm_6_ga_ld;
   logic garbler_sm_6_ga_arld_bram;
   logic garbler_sm_6_ga_ld_bram;
   logic garbler_sm_6_ga_ld_bram_done;
   logic garbler_sm_6_gb_arld;
   logic garbler_sm_6_gb_ld;
   logic garbler_sm_6_gb_arld_bram;
   logic garbler_sm_6_gb_ld_bram;
   logic garbler_sm_6_gb_ld_bram_done;
   logic garbler_sm_6_valid;
   logic garbler_sm_6_proc;
   logic garbler_sm_6_done;
   logic garbler_sm_6_collect;
   logic garbler_sm_6_collect_bram;
   

   logic garbler_sm_7_ga_arld;
   logic garbler_sm_7_ga_ld;
   logic garbler_sm_7_ga_arld_bram;
   logic garbler_sm_7_ga_ld_bram;
   logic garbler_sm_7_ga_ld_bram_done;
   logic garbler_sm_7_gb_arld;
   logic garbler_sm_7_gb_ld;
   logic garbler_sm_7_gb_arld_bram;
   logic garbler_sm_7_gb_ld_bram;
   logic garbler_sm_7_gb_ld_bram_done;
   logic garbler_sm_7_valid;
   logic garbler_sm_7_proc;
   logic garbler_sm_7_done;
   logic garbler_sm_7_collect;
   logic garbler_sm_7_collect_bram;
   
   logic input_valid_0_q, output_valid_0_q,
         input_valid_1_q, output_valid_1_q,
         input_valid_2_q, output_valid_2_q,
         input_valid_3_q, output_valid_3_q,
         input_valid_4_q, output_valid_4_q,
         input_valid_5_q, output_valid_5_q,
         input_valid_6_q, output_valid_6_q,
         input_valid_7_q, output_valid_7_q;
   
   logic [79:0] Ga_0_q, Ga_0_ns, Ga_1_q, Ga_1_ns, Ga_2_q, Ga_2_ns, Ga_3_q, Ga_3_ns, Ga_4_q, Ga_4_ns, Ga_5_q, Ga_5_ns, Ga_6_q, Ga_6_ns, Ga_7_q, Ga_7_ns;
   
   logic [79:0] Gb_0_q, Gb_0_ns, Gb_1_q, Gb_1_ns, Gb_2_q, Gb_2_ns, Gb_3_q, Gb_3_ns, Gb_4_q, Gb_4_ns, Gb_5_q, Gb_5_ns, Gb_6_q, Gb_6_ns, Gb_7_q, Gb_7_ns;
   
   logic [79:0] Gc_0_q, Gc_1_q, Gc_2_q, Gc_3_q;
   
   logic [79:0] toSend01_0_q, toSend10_0_q, toSend11_0_q,
                toSend01_1_q, toSend10_1_q, toSend11_1_q,
                toSend01_2_q, toSend10_2_q, toSend11_2_q,
                toSend01_3_q, toSend10_3_q, toSend11_3_q;
   
   logic [31:0] gate_id_q0 , gate_id_q1 , gate_id_q2 , gate_id_q3 ;
   
   logic [79:0] Gc_xor_out_0, Gc_xor_out_1, Gc_xor_out_2, Gc_xor_out_3;
   
   logic and_valid_0_q , and_valid_1_q , and_valid_2_q , and_valid_3_q ;
   
   logic xor_valid_0_q , xor_valid_1_q , xor_valid_2_q , xor_valid_3_q ;
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////
   logic 		garbler_sm_core_done_q, garbler_sm_core_done_ns;	

   logic [31:0] 	gbr_input_addr_arr [15:0];
   logic [31:0] 	gbr_output_addr_arr [7:0];
	
   logic [31:0]     gbr_output_ts_addr_arr [12:0];
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


logic [511:0] test_val = 512'hA;
logic [511:0] test_out = 512'b0;
logic bram_wea = 1'b1;
logic [31:0] bram_addra_wr ;
logic [31:0] bram_addrb_rd ;
logic [511:0] bram_da_wr,bram_qa_wr,bram_qb_rd;
logic isBram = 1'b1;
logic test_write = 1'b1;
logic cmd_bram_go_q = 1'b1;
logic cmd_bram_rd_en = 1'b1;
logic cmd_bram_wr_en = 1'b1;
logic read_bram;
logic bram_write_en;
logic bram_read_en;
logic [511:0] bram_qb_rd_ps = 0;
logic [31:0] bram_addrb_rd_ps =0;

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


// always_ff @(posedge aclk)
// begin
//     if (garbler_sm_0_ga_ld_bram |garbler_sm_0_gb_ld_bram |      
//       garbler_sm_1_ga_ld_bram |garbler_sm_1_gb_ld_bram |      
//       garbler_sm_2_ga_ld_bram |garbler_sm_2_gb_ld_bram |      
//       garbler_sm_3_ga_ld_bram |garbler_sm_3_gb_ld_bram |      
//       garbler_sm_4_ga_ld_bram |garbler_sm_4_gb_ld_bram |      
//       garbler_sm_5_ga_ld_bram |garbler_sm_5_gb_ld_bram |      
//       garbler_sm_6_ga_ld_bram |garbler_sm_6_gb_ld_bram |      
//       garbler_sm_7_ga_ld_bram |garbler_sm_7_gb_ld_bram 
//       ) 
//            bram_update <= 1'b1;
//       else
//            bram_update <= 1'b0;
//   end

       //bram_qb_rd_ps <= bram_qb_rd;
       //bram_addrb_rd_ps <= bram_addrb_rd;
  // end
// write read bram
   always_ff @(posedge aclk)
   begin 
    if (!aresetn) begin
        bram_addrb_rd <=32'h00000000;
    end

    else if(garbler_sm_0_collect_bram) begin
        bram_addra_wr <= gbr_output_addr_arr[0][30:0];
        bram_da_wr    <= Gc_0_q;
    end
    else if(garbler_sm_0_collect_ts01_bram) begin
        bram_addra_wr <= gbr_output_ts_addr_arr[0][30:0];
        bram_da_wr    <= toSend01_0_q;
    end
    else if(garbler_sm_0_collect_ts10_bram) begin
        bram_addra_wr <= gbr_output_ts_addr_arr[1][30:0];
        bram_da_wr    <= toSend10_0_q;
    end
    else if(garbler_sm_0_collect_ts11_bram) begin
        bram_addra_wr <= gbr_output_ts_addr_arr[2][30:0];
        bram_da_wr    <= toSend11_0_q;
    end 
    else if(garbler_sm_1_collect_bram) begin
        bram_addra_wr <= gbr_output_addr_arr[1][30:0];
        bram_da_wr    <= Gc_1_q;
    end
    else if(garbler_sm_1_collect_ts01_bram) begin
        bram_addra_wr <= gbr_output_ts_addr_arr[3][30:0];
        bram_da_wr    <= toSend01_1_q;
    end
    else if(garbler_sm_1_collect_ts10_bram) begin
        bram_addra_wr <= gbr_output_ts_addr_arr[4][30:0];
        bram_da_wr    <= toSend10_1_q;
    end
    else if(garbler_sm_1_collect_ts11_bram) begin
        bram_addra_wr <= gbr_output_ts_addr_arr[5][30:0];
        bram_da_wr    <= toSend11_1_q;
    end
    else if(garbler_sm_2_collect_bram) begin
        bram_addra_wr <= gbr_output_addr_arr[2][30:0];
        bram_da_wr    <= Gc_2_q;
    end
    else if(garbler_sm_2_collect_ts01_bram) begin
        bram_addra_wr <= gbr_output_ts_addr_arr[6][30:0];
        bram_da_wr    <= toSend01_2_q;
    end
    else if(garbler_sm_2_collect_ts10_bram) begin
        bram_addra_wr <= gbr_output_ts_addr_arr[7][30:0];
        bram_da_wr    <= toSend10_2_q;
    end
    else if(garbler_sm_2_collect_ts11_bram) begin
        bram_addra_wr <= gbr_output_ts_addr_arr[8][30:0];
        bram_da_wr    <= toSend11_2_q;
    end
    else if(garbler_sm_3_collect_bram) begin
        bram_addra_wr <= gbr_output_addr_arr[3][30:0];
        bram_da_wr    <= Gc_3_q;
    end
    else if(garbler_sm_3_collect_ts01_bram) begin
        bram_addra_wr <= gbr_output_ts_addr_arr[9][30:0];
        bram_da_wr    <= toSend01_3_q;
    end
    else if(garbler_sm_3_collect_ts10_bram) begin
        bram_addra_wr <= gbr_output_ts_addr_arr[10][30:0];
        bram_da_wr    <= toSend10_3_q;
    end
    else if(garbler_sm_3_collect_ts11_bram) begin
        bram_addra_wr <= gbr_output_ts_addr_arr[11][30:0];
        bram_da_wr    <= toSend11_3_q;
    end
    else if(garbler_sm_4_collect_bram) begin
        bram_addra_wr <= gbr_output_addr_arr[4][30:0];
        bram_da_wr    <= Gc_xor_out_0;
    end
    else if(garbler_sm_5_collect_bram) begin
        bram_addra_wr <= gbr_output_addr_arr[5][30:0];
        bram_da_wr    <= Gc_xor_out_1;
    end
    else if(garbler_sm_6_collect_bram) begin
        bram_addra_wr <= gbr_output_addr_arr[6][30:0];
        bram_da_wr    <= Gc_xor_out_2;
    end
    else if(garbler_sm_7_collect_bram) begin
        bram_addra_wr <= gbr_output_addr_arr[7][30:0];
        bram_da_wr    <= Gc_xor_out_3;
    end
// read bram
    else if( garbler_sm_0_ga_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[0][30:0];
    else if( garbler_sm_0_gb_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[1][30:0];
    else if( garbler_sm_1_ga_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[2][30:0];
    else if( garbler_sm_1_gb_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[3][30:0];
    else if( garbler_sm_2_ga_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[4][30:0];
    else if( garbler_sm_2_gb_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[5][30:0];
    else if( garbler_sm_3_ga_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[6][30:0];
    else if( garbler_sm_3_gb_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[7][30:0];
    else if( garbler_sm_4_ga_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[8][30:0];
    else if( garbler_sm_4_gb_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[9][30:0];
    else if( garbler_sm_5_ga_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[10][30:0];
    else if( garbler_sm_5_gb_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[11][30:0];
    else if( garbler_sm_6_ga_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[12][30:0];
    else if( garbler_sm_6_gb_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[13][30:0];
    else if( garbler_sm_7_ga_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[14][30:0];
    else if( garbler_sm_7_gb_arld_bram)
       bram_addrb_rd <= gbr_input_addr_arr[15][30:0];
   end
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
            cfg_addr_q  <= axi_mstr_cfg_bus.addr[7:0];
            cfg_wdata_q <= axi_mstr_cfg_bus.wdata[31:0];
         end
      end
   
   //Readback mux
   always @(posedge aclk)
   begin
         case (cfg_addr_q)
            8'h00:      axi_mstr_cfg_bus.rdata[31:0] <= {29'b0, cmd_rd_wrb_q, cmd_done_q, cmd_go_q};
            8'h04:      axi_mstr_cfg_bus.rdata[31:0] <= cmd_addr_hi_q[31:0];
            8'h08:      axi_mstr_cfg_bus.rdata[31:0] <= cmd_addr_lo_q[31:0];
            8'h0C:      axi_mstr_cfg_bus.rdata[31:0] <= cmd_wr_data_q[31:0];
            8'h10:      axi_mstr_cfg_bus.rdata[31:0] <= cmd_rd_data_q[31:0];
            8'h14:	    axi_mstr_cfg_bus.rdata[31:0] <= gbr_sm_en_q[31:0];
            8'h18:	    axi_mstr_cfg_bus.rdata[31:0] <= gbr_sm_xor_en_q[31:0];
            8'h1C:	    axi_mstr_cfg_bus.rdata[31:0] <= gbr_output[31:0];
            8'hE0: 	    axi_mstr_cfg_bus.rdata[31:0] <= gbr_output1[31:0];
            8'hE4:	    axi_mstr_cfg_bus.rdata[31:0] <= gbr_output2[31:0];
            8'hE8: 	    axi_mstr_cfg_bus.rdata[31:0] <= {31'b0, garbler_sm_core_done_q};
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
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   
   always_ff @(posedge aclk)
         if (!aresetn) begin
            cmd_go_q <= 1'b0;
         end
         else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CCR_ADDR)) begin
            cmd_go_q <= cfg_wdata_q[0];
         end
         else if (garbler_sm_0_ga_arld | garbler_sm_0_gb_arld | garbler_sm_0_done |
                      garbler_sm_0_collect_done|garbler_sm_0_collect_ts01_done | garbler_sm_0_collect_ts10_done |
                      garbler_sm_1_ga_arld | garbler_sm_1_gb_arld | garbler_sm_1_done |
                      garbler_sm_1_collect_done|garbler_sm_1_collect_ts01_done | garbler_sm_1_collect_ts10_done |
                      garbler_sm_2_ga_arld | garbler_sm_2_gb_arld | garbler_sm_2_done |
                      garbler_sm_2_collect_done|garbler_sm_2_collect_ts01_done | garbler_sm_2_collect_ts10_done |
                      garbler_sm_3_ga_arld | garbler_sm_3_gb_arld | garbler_sm_3_done |
                      garbler_sm_3_collect_done|garbler_sm_3_collect_ts01_done | garbler_sm_3_collect_ts10_done |
                      garbler_sm_4_ga_arld | garbler_sm_4_gb_arld | garbler_sm_4_done |
                      garbler_sm_5_ga_arld | garbler_sm_5_gb_arld | garbler_sm_5_done |
                      garbler_sm_6_ga_arld | garbler_sm_6_gb_arld | garbler_sm_6_done |
                      garbler_sm_7_ga_arld | garbler_sm_7_gb_arld | garbler_sm_7_done ) begin
                cmd_go_q <= 1'b1;
                end
         else begin
            cmd_go_q <= cmd_go_q & ~axi_mstr_sm_idle;
         end
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////


   // ----------------------
   // Command Done
   // ----------------------

//->cmd_done
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   assign cmd_done_ns = cmd_done_q | (axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) |
                                     (axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid) ;
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        cmd_done_q <= 1'b0;
     end 
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CCR_ADDR)) begin
        cmd_done_q <= cfg_wdata_q[1];
     end
           else if (garbler_sm_0_ga_arld | garbler_sm_0_gb_arld | garbler_sm_0_done |
                    garbler_sm_0_collect_done|garbler_sm_0_collect_ts01_done | garbler_sm_0_collect_ts10_done |
                    garbler_sm_1_ga_arld | garbler_sm_1_gb_arld | garbler_sm_1_done |
                    garbler_sm_1_collect_done|garbler_sm_1_collect_ts01_done | garbler_sm_1_collect_ts10_done |
                    garbler_sm_2_ga_arld | garbler_sm_2_gb_arld | garbler_sm_2_done |
                    garbler_sm_2_collect_done|garbler_sm_2_collect_ts01_done | garbler_sm_2_collect_ts10_done |
                    garbler_sm_3_ga_arld | garbler_sm_3_gb_arld | garbler_sm_3_done |
                    garbler_sm_3_collect_done|garbler_sm_3_collect_ts01_done | garbler_sm_3_collect_ts10_done |
                    garbler_sm_4_ga_arld | garbler_sm_4_gb_arld | garbler_sm_4_done |
                    garbler_sm_5_ga_arld | garbler_sm_5_gb_arld | garbler_sm_5_done |
                    garbler_sm_6_ga_arld | garbler_sm_6_gb_arld | garbler_sm_6_done |
                    garbler_sm_7_ga_arld | garbler_sm_7_gb_arld | garbler_sm_7_done ) begin
              cmd_done_q <= 1'b0;
         end
     else begin
        cmd_done_q <= cmd_done_ns;
     end
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////

   // ----------------------
   // Command Rd/Wr_B
   // ----------------------

//->cmd_rw
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        cmd_rd_wrb_q <= 1'b0;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CCR_ADDR)) begin
        cmd_rd_wrb_q <= cfg_wdata_q[2];
     end
     else if (garbler_sm_0_ga_arld | garbler_sm_0_gb_arld |
              garbler_sm_1_ga_arld | garbler_sm_1_gb_arld |
              garbler_sm_2_ga_arld | garbler_sm_2_gb_arld |
              garbler_sm_3_ga_arld | garbler_sm_3_gb_arld |
              garbler_sm_4_ga_arld | garbler_sm_4_gb_arld |
              garbler_sm_5_ga_arld | garbler_sm_5_gb_arld |
              garbler_sm_6_ga_arld | garbler_sm_6_gb_arld |
              garbler_sm_7_ga_arld | garbler_sm_7_gb_arld ) begin
              cmd_rd_wrb_q <= 1'b1;
     end
      else if (garbler_sm_0_collect_done|garbler_sm_0_collect_ts01_done | garbler_sm_0_collect_ts10_done|
               garbler_sm_1_collect_done|garbler_sm_1_collect_ts01_done | garbler_sm_1_collect_ts10_done|
               garbler_sm_2_collect_done|garbler_sm_2_collect_ts01_done | garbler_sm_2_collect_ts10_done|
               garbler_sm_3_collect_done|garbler_sm_3_collect_ts01_done | garbler_sm_3_collect_ts10_done|
               garbler_sm_0_done| garbler_sm_1_done| garbler_sm_2_done| garbler_sm_3_done|
               garbler_sm_4_done| garbler_sm_5_done| garbler_sm_6_done| garbler_sm_7_done) begin
              cmd_rd_wrb_q <= 1'b0;
     end
     else begin
        cmd_rd_wrb_q <= cmd_rd_wrb_q;
     end
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////

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
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        cmd_addr_lo_q[31:0] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CALR_ADDR)) begin
        cmd_addr_lo_q[31:0] <= cfg_wdata_q[31:0];
     end
     else if (garbler_sm_0_ga_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[0];
     end
     else if (garbler_sm_0_gb_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[1];
     end
   
     else if (garbler_sm_1_ga_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[2];
     end
     else if (garbler_sm_1_gb_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[3];
     end
   
     else if (garbler_sm_2_ga_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[4];
     end
     else if (garbler_sm_2_gb_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[5];
     end
   
     else if (garbler_sm_3_ga_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[6];
     end
     else if (garbler_sm_3_gb_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[7];
     end
     else if (garbler_sm_4_ga_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[8];
     end
     else if (garbler_sm_4_gb_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[9];
     end
   
     else if (garbler_sm_5_ga_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[10];
     end
     else if (garbler_sm_5_gb_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[11];
     end
   
     else if (garbler_sm_6_ga_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[12];
     end
     else if (garbler_sm_6_gb_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[13];
     end
   
     else if (garbler_sm_7_ga_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[14];
     end
     else if (garbler_sm_7_gb_arld) begin
            cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[15];
     end
   
     else if (garbler_sm_0_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_addr_arr[0];
     end
   
     else if (garbler_sm_1_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_addr_arr[1];
     end
   
     else if (garbler_sm_2_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_addr_arr[2];
     end
   
     else if (garbler_sm_3_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_addr_arr[3];
     end
   
     else if (garbler_sm_4_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_addr_arr[4];
     end
   
     else if (garbler_sm_5_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_addr_arr[5];
     end
   
     else if (garbler_sm_6_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_addr_arr[6];
     end
   
     else if (garbler_sm_7_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_addr_arr[7];
     end
   
     else if (garbler_sm_0_collect_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[0];
     end
     else if (garbler_sm_0_collect_ts01_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[1];
     end
     else if (garbler_sm_0_collect_ts10_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[2];
     end
   
     else if (garbler_sm_1_collect_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[3];
     end
     else if (garbler_sm_1_collect_ts01_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[4];
     end
     else if (garbler_sm_1_collect_ts10_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[5];
     end
   
     else if (garbler_sm_2_collect_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[6];
     end
     else if (garbler_sm_2_collect_ts01_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[7];
     end
     else if (garbler_sm_2_collect_ts10_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[8];
     end
   
     else if (garbler_sm_3_collect_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[9];
     end
     else if (garbler_sm_3_collect_ts01_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[10];
     end
     else if (garbler_sm_3_collect_ts10_done) begin
            cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[11];
     end
   
     else begin
        cmd_addr_lo_q[31:0] <= cmd_addr_lo_q[31:0];
     end
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////
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
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h14)) begin
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
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h18)) begin
         gbr_sm_xor_en_q[31:0] <= cfg_wdata_q[31:0];
      end
      else begin
         gbr_sm_xor_en_q[31:0] <= gbr_sm_xor_en_q[31:0];
      end
	
	// ----------------------
   	// garble core input addresses 
   	// ----------------------

//->garble_input_addr
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[0] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h20)) begin
        gbr_input_addr_arr[0] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_input_addr_arr[0] <= gbr_input_addr_arr[0];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[1] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h24)) begin
        gbr_input_addr_arr[1] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_input_addr_arr[1] <= gbr_input_addr_arr[1];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[2] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h28)) begin
        gbr_input_addr_arr[2] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_input_addr_arr[2] <= gbr_input_addr_arr[2];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[3] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h2C)) begin
        gbr_input_addr_arr[3] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_input_addr_arr[3] <= gbr_input_addr_arr[3];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[4] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h30)) begin
        gbr_input_addr_arr[4] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_input_addr_arr[4] <= gbr_input_addr_arr[4];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[5] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h34)) begin
        gbr_input_addr_arr[5] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_input_addr_arr[5] <= gbr_input_addr_arr[5];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[6] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h38)) begin
        gbr_input_addr_arr[6] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_input_addr_arr[6] <= gbr_input_addr_arr[6];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[7] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h3C)) begin
        gbr_input_addr_arr[7] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_input_addr_arr[7] <= gbr_input_addr_arr[7];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[8] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h40)) begin
        gbr_input_addr_arr[8] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_input_addr_arr[8] <= gbr_input_addr_arr[8];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[9] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h44)) begin
        gbr_input_addr_arr[9] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_input_addr_arr[9] <= gbr_input_addr_arr[9];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[10] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h48)) begin
        gbr_input_addr_arr[10] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_input_addr_arr[10] <= gbr_input_addr_arr[10];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[11] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h4C)) begin
        gbr_input_addr_arr[11] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_input_addr_arr[11] <= gbr_input_addr_arr[11];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[12] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h50)) begin
        gbr_input_addr_arr[12] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_input_addr_arr[12] <= gbr_input_addr_arr[12];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[13] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h54)) begin
        gbr_input_addr_arr[13] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_input_addr_arr[13] <= gbr_input_addr_arr[13];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[14] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h58)) begin
        gbr_input_addr_arr[14] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_input_addr_arr[14] <= gbr_input_addr_arr[14];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_input_addr_arr[15] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h5C)) begin
        gbr_input_addr_arr[15] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_input_addr_arr[15] <= gbr_input_addr_arr[15];
     end
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////

	////////////////////////////////////////////////


//->garble_output_addr
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_addr_arr[0] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hA0)) begin
        gbr_output_addr_arr[0] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_output_addr_arr[0] <= gbr_output_addr_arr[0];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_addr_arr[1] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hA4)) begin
        gbr_output_addr_arr[1] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_output_addr_arr[1] <= gbr_output_addr_arr[1];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_addr_arr[2] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hA8)) begin
        gbr_output_addr_arr[2] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_output_addr_arr[2] <= gbr_output_addr_arr[2];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_addr_arr[3] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hAC)) begin
        gbr_output_addr_arr[3] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_output_addr_arr[3] <= gbr_output_addr_arr[3];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_addr_arr[4] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hB0)) begin
        gbr_output_addr_arr[4] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_output_addr_arr[4] <= gbr_output_addr_arr[4];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_addr_arr[5] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hB4)) begin
        gbr_output_addr_arr[5] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_output_addr_arr[5] <= gbr_output_addr_arr[5];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_addr_arr[6] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hB8)) begin
        gbr_output_addr_arr[6] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_output_addr_arr[6] <= gbr_output_addr_arr[6];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_addr_arr[7] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hBC)) begin
        gbr_output_addr_arr[7] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_output_addr_arr[7] <= gbr_output_addr_arr[7];
     end
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////

//->garble_table_out_addr
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_ts_addr_arr[0] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h60)) begin
        gbr_output_ts_addr_arr[0] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_output_ts_addr_arr[0] <= gbr_output_ts_addr_arr[0];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_ts_addr_arr[1] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h64)) begin
        gbr_output_ts_addr_arr[1] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_output_ts_addr_arr[1] <= gbr_output_ts_addr_arr[1];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_ts_addr_arr[2] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h68)) begin
        gbr_output_ts_addr_arr[2] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_output_ts_addr_arr[2] <= gbr_output_ts_addr_arr[2];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_ts_addr_arr[3] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h6C)) begin
        gbr_output_ts_addr_arr[3] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_output_ts_addr_arr[3] <= gbr_output_ts_addr_arr[3];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_ts_addr_arr[4] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h70)) begin
        gbr_output_ts_addr_arr[4] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_output_ts_addr_arr[4] <= gbr_output_ts_addr_arr[4];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_ts_addr_arr[5] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h74)) begin
        gbr_output_ts_addr_arr[5] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_output_ts_addr_arr[5] <= gbr_output_ts_addr_arr[5];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_ts_addr_arr[6] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h78)) begin
        gbr_output_ts_addr_arr[6] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_output_ts_addr_arr[6] <= gbr_output_ts_addr_arr[6];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_ts_addr_arr[7] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h7C)) begin
        gbr_output_ts_addr_arr[7] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_output_ts_addr_arr[7] <= gbr_output_ts_addr_arr[7];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_ts_addr_arr[8] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h80)) begin
        gbr_output_ts_addr_arr[8] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_output_ts_addr_arr[8] <= gbr_output_ts_addr_arr[8];
     end
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_ts_addr_arr[9] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h84)) begin
        gbr_output_ts_addr_arr[9] <= cfg_wdata_q[31:0];
     end
     else begin
       gbr_output_ts_addr_arr[9] <= gbr_output_ts_addr_arr[9];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_ts_addr_arr[10] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h88)) begin
        gbr_output_ts_addr_arr[10] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_output_ts_addr_arr[10] <= gbr_output_ts_addr_arr[10];
     end
   always_ff @(posedge aclk)
     if (!aresetn) begin
        gbr_output_ts_addr_arr[11] <= 32'h0000_0000;
     end
     else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'h8C)) begin
        gbr_output_ts_addr_arr[11] <= cfg_wdata_q[31:0];
     end
     else begin
        gbr_output_ts_addr_arr[11] <= gbr_output_ts_addr_arr[11];
     end
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////


      always_ff @(posedge aclk)
      if (!aresetn) begin
         R1_q <= 32'h0000_0000;
      end
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hD0)) begin
         R1_q <= cfg_wdata_q[31:0];
      end
      else begin
         R1_q <= R1_q;
      end
	
      always_ff @(posedge aclk)
      if (!aresetn) begin
         R2_q <= 32'h0000_0000;
      end
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hD4)) begin
         R2_q <= cfg_wdata_q[31:0];
      end
      else begin
         R2_q <= R2_q;
      end

      always_ff @(posedge aclk)
      if (!aresetn) begin
         R3_q <= 32'h0000_0000;
      end
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hD8)) begin
         R3_q <= cfg_wdata_q[31:0];
      end
      else begin
         R3_q <= R3_q;
      end
//->gate_id	
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   
   always_ff @(posedge aclk)
       if (!aresetn) begin
           gate_id_q0 <= 32'h0000_0000;
       end
       else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hCC)) begin
           gate_id_q0 <= cfg_wdata_q[31:0];
       end
       else begin
           gate_id_q0 <= gate_id_q0;
       end
   
   always_ff @(posedge aclk)
       if (!aresetn) begin
           gate_id_q1 <= 32'h0000_0000;
       end
       else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hC8)) begin
           gate_id_q1 <= cfg_wdata_q[31:0];
       end
       else begin
           gate_id_q1 <= gate_id_q1;
       end
   
   always_ff @(posedge aclk)
       if (!aresetn) begin
           gate_id_q2 <= 32'h0000_0000;
       end
       else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hC4)) begin
           gate_id_q2 <= cfg_wdata_q[31:0];
       end
       else begin
           gate_id_q2 <= gate_id_q2;
       end
   
   always_ff @(posedge aclk)
       if (!aresetn) begin
           gate_id_q3 <= 32'h0000_0000;
       end
       else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 8'hC0)) begin
           gate_id_q3 <= cfg_wdata_q[31:0];
       end
       else begin
           gate_id_q3 <= gate_id_q3;
       end
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////


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
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   
    always_comb begin 
        // Default
        garbler_sm_ns[7:0]  = GABLER_SM_IDLE;
   
        case (garbler_sm_q[7:0]) 
                   GABLER_SM_IDLE: begin 
                   if(gbr_sm_en_q[31:0] != 32'b0 & ~garbler_sm_core_done_q)   garbler_sm_ns[7:0]  = GABLER_SM_0_PREP;
                   else                                                       garbler_sm_ns[7:0]  = GABLER_SM_IDLE;
                   end
   // state machine 0 laod 
                   GABLER_SM_0_PREP: begin
                           if(gbr_sm_en_q[0] == 1'b1)        
                                if(gbr_input_addr_arr[0][31])                   garbler_sm_ns[7:0]  = GABLER_SM_0_GA_ARLD_BRAM;
                                else                                            garbler_sm_ns[7:0]  = GABLER_SM_0_GA_ARLD;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_1_PREP;
                   end 
                   
                   GABLER_SM_0_GA_ARLD: begin 
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_0_GA_LD;
                   end
                   
                   GABLER_SM_0_GA_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    
                                if(gbr_input_addr_arr[1][31])                  garbler_sm_ns[7:0]  = GABLER_SM_0_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_0_GB_ARLD;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_0_GA_LD;
                   end             
                   GABLER_SM_0_GA_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_0_GA_LD_BRAM;
                   end
                   GABLER_SM_0_GA_LD_BRAM: begin
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_0_GA_LD_BRAM_DONE;
                   end
                   GABLER_SM_0_GA_LD_BRAM_DONE:begin
                       if(gbr_input_addr_arr[1][31])
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_0_GB_ARLD_BRAM;
                       else                                                     garbler_sm_ns[7:0]  = GABLER_SM_0_GB_ARLD;
                   end                   
                   GABLER_SM_0_GB_ARLD: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_0_GB_LD;
                   end             
   
                   GABLER_SM_0_GB_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    garbler_sm_ns[7:0]  = GABLER_SM_0_VALID;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_0_GB_LD;
                   end             
           
                   GABLER_SM_0_GB_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_0_GB_LD_BRAM;
                   end             
   
                   GABLER_SM_0_GB_LD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  =GABLER_SM_0_GB_LD_BRAM_DONE;
                   end
                   GABLER_SM_0_GB_LD_BRAM_DONE: begin
                       //if(bram_update)
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_0_VALID;
                      // else                                                    garbler_sm_ns[7:0]   = GABLER_SM_0_GB_LD_BRAM;
                   end             
                   GABLER_SM_0_VALID: begin
                                                                               garbler_sm_ns[7:0] = GABLER_SM_1_PREP;
                   end
   // state machine 1 laod 
                   GABLER_SM_1_PREP: begin
                           if(gbr_sm_en_q[1] == 1'b1)        
                                if(gbr_input_addr_arr[2][31])                   garbler_sm_ns[7:0]  = GABLER_SM_1_GA_ARLD_BRAM;
                                else                                            garbler_sm_ns[7:0]  = GABLER_SM_1_GA_ARLD;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_2_PREP;
   
                   end 
                   
                   GABLER_SM_1_GA_ARLD: begin 
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_1_GA_LD;
                   end
                   
                   GABLER_SM_1_GA_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    
                                if(gbr_input_addr_arr[3][31])                  garbler_sm_ns[7:0]  = GABLER_SM_1_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_1_GB_ARLD;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_1_GA_LD;
                   end             
                   GABLER_SM_1_GA_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_1_GA_LD_BRAM;
                   end
                   GABLER_SM_1_GA_LD_BRAM: begin
                                                                                garbler_sm_ns[7:0]  =GABLER_SM_1_GA_LD_BRAM_DONE;
                   end
                   GABLER_SM_1_GA_LD_BRAM_DONE: begin
                                if(gbr_input_addr_arr[3][31])                  
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_1_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_1_GB_ARLD;
                   end
                   GABLER_SM_1_GB_ARLD: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_1_GB_LD;
                   end             
   
                   GABLER_SM_1_GB_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    garbler_sm_ns[7:0]  = GABLER_SM_1_VALID;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_1_GB_LD;
                   end             
           
                   GABLER_SM_1_GB_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_1_GB_LD_BRAM;
                   end             
   
                   GABLER_SM_1_GB_LD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  =GABLER_SM_1_GB_LD_BRAM_DONE;
                   end
                   GABLER_SM_1_GB_LD_BRAM_DONE: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_1_VALID;
                   end             
                   GABLER_SM_1_VALID: begin
                                                                               garbler_sm_ns[7:0] = GABLER_SM_2_PREP;
                   end

   // state machine 2 laod 
                   GABLER_SM_2_PREP: begin
                           if(gbr_sm_en_q[2] == 1'b1)        
                                if(gbr_input_addr_arr[4][31])                   garbler_sm_ns[7:0]  = GABLER_SM_2_GA_ARLD_BRAM;
                                else                                            garbler_sm_ns[7:0]  = GABLER_SM_2_GA_ARLD;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_3_PREP;
   
                   end 
                   
                   GABLER_SM_2_GA_ARLD: begin 
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_2_GA_LD;
                   end
                   
                   GABLER_SM_2_GA_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    
                                if(gbr_input_addr_arr[5][31])                  garbler_sm_ns[7:0]  = GABLER_SM_2_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_2_GB_ARLD;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_2_GA_LD;
                   end             
                   GABLER_SM_2_GA_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_2_GA_LD_BRAM;
                   end
                   GABLER_SM_2_GA_LD_BRAM: begin
                                                                                garbler_sm_ns[7:0]  =GABLER_SM_2_GA_LD_BRAM_DONE;
                   end
                   GABLER_SM_2_GA_LD_BRAM_DONE: begin
                                if(gbr_input_addr_arr[5][31])                  
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_2_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_2_GB_ARLD;
                   end
                   GABLER_SM_2_GB_ARLD: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_2_GB_LD;
                   end             
   
                   GABLER_SM_2_GB_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    garbler_sm_ns[7:0]  = GABLER_SM_2_VALID;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_2_GB_LD;
                   end             
           
                   GABLER_SM_2_GB_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_2_GB_LD_BRAM;
                   end             
   
                   GABLER_SM_2_GB_LD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  =GABLER_SM_2_GB_LD_BRAM_DONE;
                   end
                   GABLER_SM_2_GB_LD_BRAM_DONE: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_2_VALID;
                   end             
                   GABLER_SM_2_VALID: begin
                                                                               garbler_sm_ns[7:0] = GABLER_SM_3_PREP;
                   end

   // state machine 3 laod 
                   GABLER_SM_3_PREP: begin
                           if(gbr_sm_en_q[3] == 1'b1)        
                                if(gbr_input_addr_arr[6][31])                   garbler_sm_ns[7:0]  = GABLER_SM_3_GA_ARLD_BRAM;
                                else                                            garbler_sm_ns[7:0]  = GABLER_SM_3_GA_ARLD;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_4_PREP;
   
                   end 
                   
                   GABLER_SM_3_GA_ARLD: begin 
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_3_GA_LD;
                   end
                   
                   GABLER_SM_3_GA_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    
                                if(gbr_input_addr_arr[7][31])                  garbler_sm_ns[7:0]  = GABLER_SM_3_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_3_GB_ARLD;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_3_GA_LD;
                   end             
                   GABLER_SM_3_GA_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_3_GA_LD_BRAM;
                   end
                   GABLER_SM_3_GA_LD_BRAM: begin
                                                                                garbler_sm_ns[7:0]  =GABLER_SM_3_GA_LD_BRAM_DONE;
                   end
                   GABLER_SM_3_GA_LD_BRAM_DONE: begin
                                if(gbr_input_addr_arr[7][31])      
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_3_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_3_GB_ARLD;
                   end
                   GABLER_SM_3_GB_ARLD: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_3_GB_LD;
                   end             
   
                   GABLER_SM_3_GB_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    garbler_sm_ns[7:0]  = GABLER_SM_3_VALID;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_3_GB_LD;
                   end             
           
                   GABLER_SM_3_GB_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_3_GB_LD_BRAM;
                   end             
   
                   GABLER_SM_3_GB_LD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  =GABLER_SM_3_GB_LD_BRAM_DONE;
                   end
                   GABLER_SM_3_GB_LD_BRAM_DONE: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_3_VALID;
                   end             
                   GABLER_SM_3_VALID: begin
                                                                               garbler_sm_ns[7:0] = GABLER_SM_4_PREP;
                   end

   // state machine 4 laod 
                   GABLER_SM_4_PREP: begin
                           if(gbr_sm_en_q[4] == 1'b1)        
                                if(gbr_input_addr_arr[8][31])                   garbler_sm_ns[7:0]  = GABLER_SM_4_GA_ARLD_BRAM;
                                else                                            garbler_sm_ns[7:0]  = GABLER_SM_4_GA_ARLD;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_5_PREP;
   
                   end 
                   
                   GABLER_SM_4_GA_ARLD: begin 
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_4_GA_LD;
                   end
                   
                   GABLER_SM_4_GA_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    
                                if(gbr_input_addr_arr[9][31])                  garbler_sm_ns[7:0]  = GABLER_SM_4_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_4_GB_ARLD;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_4_GA_LD;
                   end             
                   GABLER_SM_4_GA_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_4_GA_LD_BRAM;
                   end
                   GABLER_SM_4_GA_LD_BRAM: begin
                                                                                garbler_sm_ns[7:0]  =GABLER_SM_4_GA_LD_BRAM_DONE;
                   end
                   GABLER_SM_4_GA_LD_BRAM_DONE: begin
                                if(gbr_input_addr_arr[9][31])      
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_4_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_4_GB_ARLD;
                   end
                   GABLER_SM_4_GB_ARLD: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_4_GB_LD;
                   end             
   
                   GABLER_SM_4_GB_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    garbler_sm_ns[7:0]  = GABLER_SM_4_VALID;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_4_GB_LD;
                   end             
           
                   GABLER_SM_4_GB_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_4_GB_LD_BRAM;
                   end             
   
                   GABLER_SM_4_GB_LD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  =GABLER_SM_4_GB_LD_BRAM_DONE;
                   end
                   GABLER_SM_4_GB_LD_BRAM_DONE: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_4_VALID;
                   end             
                   GABLER_SM_4_VALID: begin
                                                                               garbler_sm_ns[7:0] = GABLER_SM_5_PREP;
                   end
   // state machine 5 laod 
                   GABLER_SM_5_PREP: begin
                           if(gbr_sm_en_q[5] == 1'b1)        
                                if(gbr_input_addr_arr[10][31])                   garbler_sm_ns[7:0]  = GABLER_SM_5_GA_ARLD_BRAM;
                                else                                            garbler_sm_ns[7:0]  = GABLER_SM_5_GA_ARLD;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_6_PREP;
   
                   end 
                   
                   GABLER_SM_5_GA_ARLD: begin 
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_5_GA_LD;
                   end
                   
                   GABLER_SM_5_GA_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    
                                if(gbr_input_addr_arr[11][31])                  garbler_sm_ns[7:0]  = GABLER_SM_5_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_5_GB_ARLD;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_5_GA_LD;
                   end             
                   GABLER_SM_5_GA_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_5_GA_LD_BRAM;
                   end
                   GABLER_SM_5_GA_LD_BRAM: begin
                                                                                garbler_sm_ns[7:0]  =GABLER_SM_5_GA_LD_BRAM_DONE;
                   end
                   GABLER_SM_5_GA_LD_BRAM_DONE: begin
                                if(gbr_input_addr_arr[11][31])
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_5_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_5_GB_ARLD;
                   end
                   GABLER_SM_5_GB_ARLD: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_5_GB_LD;
                   end             
   
                   GABLER_SM_5_GB_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    garbler_sm_ns[7:0]  = GABLER_SM_5_VALID;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_5_GB_LD;
                   end             
           
                   GABLER_SM_5_GB_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_5_GB_LD_BRAM;
                   end             
   
                   GABLER_SM_5_GB_LD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  =GABLER_SM_5_GB_LD_BRAM_DONE;
                   end
                   GABLER_SM_5_GB_LD_BRAM_DONE: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_5_VALID;
                   end             
                   GABLER_SM_5_VALID: begin
                                                                               garbler_sm_ns[7:0] = GABLER_SM_6_PREP;
                   end
   // state machine 6 laod 
                   GABLER_SM_6_PREP: begin
                           if(gbr_sm_en_q[6] == 1'b1)        
                                if(gbr_input_addr_arr[12][31])                   garbler_sm_ns[7:0]  = GABLER_SM_6_GA_ARLD_BRAM;
                                else                                            garbler_sm_ns[7:0]  = GABLER_SM_6_GA_ARLD;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_7_PREP;
   
                   end 
                   
                   GABLER_SM_6_GA_ARLD: begin 
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_6_GA_LD;
                   end
                   
                   GABLER_SM_6_GA_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    
                                if(gbr_input_addr_arr[13][31])                  garbler_sm_ns[7:0]  = GABLER_SM_6_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_6_GB_ARLD;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_6_GA_LD;
                   end             
                   GABLER_SM_6_GA_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_6_GA_LD_BRAM;
                   end
                   GABLER_SM_6_GA_LD_BRAM: begin
                                                                                garbler_sm_ns[7:0]  =GABLER_SM_6_GA_LD_BRAM_DONE;
                   end
                   GABLER_SM_6_GA_LD_BRAM_DONE: begin
                                if(gbr_input_addr_arr[13][31])
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_6_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_6_GB_ARLD;
                   end
                   GABLER_SM_6_GB_ARLD: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_6_GB_LD;
                   end             
   
                   GABLER_SM_6_GB_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    garbler_sm_ns[7:0]  = GABLER_SM_6_VALID;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_6_GB_LD;
                   end             
           
                   GABLER_SM_6_GB_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_6_GB_LD_BRAM;
                   end             
   
                   GABLER_SM_6_GB_LD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  =GABLER_SM_6_GB_LD_BRAM_DONE;
                   end
                   GABLER_SM_6_GB_LD_BRAM_DONE: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_6_VALID;
                   end             
                   GABLER_SM_6_VALID: begin
                                                                               garbler_sm_ns[7:0] = GABLER_SM_7_PREP;
                   end
   // state machine 7 laod 
                   GABLER_SM_7_PREP: begin
                           if(gbr_sm_en_q[7] == 1'b1)        
                                if(gbr_input_addr_arr[14][31])                  garbler_sm_ns[7:0]  = GABLER_SM_7_GA_ARLD_BRAM;
                                else                                            garbler_sm_ns[7:0]  = GABLER_SM_7_GA_ARLD;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_0_PROC;
   
                   end 
                   
                   GABLER_SM_7_GA_ARLD: begin 
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_7_GA_LD;
                   end
                   
                   GABLER_SM_7_GA_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    
                                if(gbr_input_addr_arr[15][31])                  garbler_sm_ns[7:0]  = GABLER_SM_7_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_7_GB_ARLD;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_7_GA_LD;
                   end             
                   GABLER_SM_7_GA_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_7_GA_LD_BRAM;
                   end
                   GABLER_SM_7_GA_LD_BRAM: begin
                                                                                garbler_sm_ns[7:0]  =GABLER_SM_7_GA_LD_BRAM_DONE;
                   end
                   GABLER_SM_7_GA_LD_BRAM_DONE: begin
                                if(gbr_input_addr_arr[15][31])
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_7_GB_ARLD_BRAM;
                                else                                           garbler_sm_ns[7:0]  = GABLER_SM_7_GB_ARLD;
                   end
                   GABLER_SM_7_GB_ARLD: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_7_GB_LD;
                   end             
   
                   GABLER_SM_7_GB_LD: begin
                           if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    garbler_sm_ns[7:0]  = GABLER_SM_7_VALID;
                           else                                                garbler_sm_ns[7:0]  = GABLER_SM_7_GB_LD;
                   end             
           
                   GABLER_SM_7_GB_ARLD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_7_GB_LD_BRAM;
                   end             
   
                   GABLER_SM_7_GB_LD_BRAM: begin
                                                                               garbler_sm_ns[7:0]  =GABLER_SM_7_GB_LD_BRAM_DONE;
                   end
                   GABLER_SM_7_GB_LD_BRAM_DONE: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_7_VALID;
                   end             
                   GABLER_SM_7_VALID: begin
                                                                               garbler_sm_ns[7:0] = GABLER_SM_0_PROC;
                   end
// and core 0                  
                   GABLER_SM_0_PROC: begin
                           if(gbr_sm_en_q[0] == 1'b0)                           garbler_sm_ns[7:0]  = GABLER_SM_1_PROC;
                           else if(gbr_sm_en_q[0] == 1'b1 & output_valid_0_q)   
                       if(gbr_output_addr_arr[0][31])                                  garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_0_DONE;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_0_PROC;              
                   end
   
   
                   GABLER_SM_0_DONE: begin
                                                                                   garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT;
                   end
                   GABLER_SM_0_COLLECT: begin
                            if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_DONE;
                            else
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT;
                   end
                   GABLER_SM_0_COLLECT_BRAM: begin                              garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_DONE;
                                                                    
                   end
   
                  GABLER_SM_0_COLLECT_DONE: begin
                       if(gbr_output_ts_addr_arr[0][31])                        garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS01_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS01;
                  end
                  GABLER_SM_0_COLLECT_TS01: begin
                          if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS01_DONE;
                          else                                                garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS01;
                  end
   
   
                  GABLER_SM_0_COLLECT_TS01_BRAM: begin
                                                                              garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS01_DONE;
                  end
   
                  GABLER_SM_0_COLLECT_TS01_DONE: begin
                       if(gbr_output_ts_addr_arr[1][31])                        garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS10_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS10;
   
                  end
   
                  GABLER_SM_0_COLLECT_TS10: begin
                       if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS10_DONE;
                       else                                                garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS10;
                  end
                  GABLER_SM_0_COLLECT_TS10_BRAM:begin
                                                                              garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS10_DONE;

                  end
   
                  GABLER_SM_0_COLLECT_TS10_DONE: begin
                       if(gbr_output_ts_addr_arr[2][31])                        garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS11_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS11;
                  end
                  GABLER_SM_0_COLLECT_TS11: begin
                          if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_1_PROC;
                          else                                                garbler_sm_ns[7:0]  = GABLER_SM_0_COLLECT_TS11;
                  end
   
                  GABLER_SM_0_COLLECT_TS11_BRAM:begin
                                                                              garbler_sm_ns[7:0]  = GABLER_SM_1_PROC;
                  end

// and core 1                  
                   GABLER_SM_1_PROC: begin
                           if(gbr_sm_en_q[1] == 1'b0)                           garbler_sm_ns[7:0]  = GABLER_SM_2_PROC;
                           else if(gbr_sm_en_q[1] == 1'b1 & output_valid_1_q)   
                       if(gbr_output_addr_arr[1][31])                                  garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_1_DONE;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_1_PROC;              
                   end
   
   
                   GABLER_SM_1_DONE: begin
                                                                                   garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT;
                   end
                   GABLER_SM_1_COLLECT: begin
                            if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)
                                                                                           garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_DONE;
   
                            else
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT;
                   end
                   GABLER_SM_1_COLLECT_BRAM: begin                              garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_DONE;
                                                                    
                   end
   
                  GABLER_SM_1_COLLECT_DONE: begin
                       if(gbr_output_ts_addr_arr[3][31])                        garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS01_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS01;
                  end
                  GABLER_SM_1_COLLECT_TS01: begin
                          if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS01_DONE;
                          else                                                garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS01;
                  end
   
   
                  GABLER_SM_1_COLLECT_TS01_BRAM: begin
                                                                              garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS01_DONE;
                  end
   
                  GABLER_SM_1_COLLECT_TS01_DONE: begin
                       if(gbr_output_ts_addr_arr[4][31])                        garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS10_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS10;
   
                  end
   
                  GABLER_SM_1_COLLECT_TS10: begin
                       if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS10_DONE;
                       else                                                garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS10;
                  end
                  GABLER_SM_1_COLLECT_TS10_BRAM:begin
                                                                              garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS10_DONE;

                  end
   
                  GABLER_SM_1_COLLECT_TS10_DONE: begin
                       if(gbr_output_ts_addr_arr[5][31])                        garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS11_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS11;
                  end
                  GABLER_SM_1_COLLECT_TS11: begin
                          if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_2_PROC;
                          else                                                garbler_sm_ns[7:0]  = GABLER_SM_1_COLLECT_TS11;
                  end
   
                  GABLER_SM_1_COLLECT_TS11_BRAM:begin
                                                                              garbler_sm_ns[7:0]  = GABLER_SM_2_PROC;
                  end
// and core 2                  
                   GABLER_SM_2_PROC: begin
                           if(gbr_sm_en_q[2] == 1'b0)                           garbler_sm_ns[7:0]  = GABLER_SM_3_PROC;
                           else if(gbr_sm_en_q[2] == 1'b1 & output_valid_2_q)   
                       if(gbr_output_addr_arr[2][31])                                  garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_2_DONE;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_2_PROC;              
                   end
   
   
                   GABLER_SM_2_DONE: begin
                                                                                   garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT;
                   end
                   GABLER_SM_2_COLLECT: begin
                            if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)
                                                                                           garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_DONE;
   
                            else
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT;
                   end
                   GABLER_SM_2_COLLECT_BRAM: begin                              garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_DONE;
                                                                    
                   end
   
                  GABLER_SM_2_COLLECT_DONE: begin
                       if(gbr_output_ts_addr_arr[6][31])                        garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS01_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS01;
                  end
                  GABLER_SM_2_COLLECT_TS01: begin
                          if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS01_DONE;
                          else                                                garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS01;
                  end
   
   
                  GABLER_SM_2_COLLECT_TS01_BRAM: begin
                                                                              garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS01_DONE;
                  end
   
                  GABLER_SM_2_COLLECT_TS01_DONE: begin
                       if(gbr_output_ts_addr_arr[7][31])                        garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS10_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS10;
   
                  end
   
                  GABLER_SM_2_COLLECT_TS10: begin
                       if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS10_DONE;
                       else                                                garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS10;
                  end
                  GABLER_SM_2_COLLECT_TS10_BRAM:begin
                                                                              garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS10_DONE;

                  end
   
                  GABLER_SM_2_COLLECT_TS10_DONE: begin
                       if(gbr_output_ts_addr_arr[8][31])                        garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS11_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS11;
                  end
                  GABLER_SM_2_COLLECT_TS11: begin
                          if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_3_PROC;
                          else                                                garbler_sm_ns[7:0]  = GABLER_SM_2_COLLECT_TS11;
                  end
   
                  GABLER_SM_2_COLLECT_TS11_BRAM:begin
                                                                              garbler_sm_ns[7:0]  = GABLER_SM_3_PROC;
                  end
// and core 3                  
                   GABLER_SM_3_PROC: begin
                           if(gbr_sm_en_q[3] == 1'b0)                           garbler_sm_ns[7:0]  = GABLER_SM_4_PROC;
                           else if(gbr_sm_en_q[3] == 1'b1 & output_valid_3_q)   
                       if(gbr_output_addr_arr[3][31])                                  garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_3_DONE;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_3_PROC;              
                   end
   
   
                   GABLER_SM_3_DONE: begin
                                                                                   garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT;
                   end
                   GABLER_SM_3_COLLECT: begin
                            if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)
                                                                                           garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_DONE;
   
                            else
                                                                                garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT;
                   end
                   GABLER_SM_3_COLLECT_BRAM: begin                              garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_DONE;
                                                                    
                   end
   
                  GABLER_SM_3_COLLECT_DONE: begin
                       if(gbr_output_ts_addr_arr[9][31])                        garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS01_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS01;
                  end
                  GABLER_SM_3_COLLECT_TS01: begin
                          if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS01_DONE;
                          else                                                garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS01;
                  end
   
   
                  GABLER_SM_3_COLLECT_TS01_BRAM: begin
                                                                              garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS01_DONE;
                  end
   
                  GABLER_SM_3_COLLECT_TS01_DONE: begin
                       if(gbr_output_ts_addr_arr[10][31])                        garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS10_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS10;
   
                  end
   
                  GABLER_SM_3_COLLECT_TS10: begin
                       if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS10_DONE;
                       else                                                garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS10;
                  end
                  GABLER_SM_3_COLLECT_TS10_BRAM:begin
                                                                              garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS10_DONE;

                  end
   
                  GABLER_SM_3_COLLECT_TS10_DONE: begin
                       if(gbr_output_ts_addr_arr[11][31])                        garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS11_BRAM;
                       else                                                            garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS11;
                  end
                  GABLER_SM_3_COLLECT_TS11: begin
                          if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[7:0]  = GABLER_SM_4_PROC;
                          else                                                garbler_sm_ns[7:0]  = GABLER_SM_3_COLLECT_TS11;
                  end
   
                  GABLER_SM_3_COLLECT_TS11_BRAM:begin
                                                                              garbler_sm_ns[7:0]  = GABLER_SM_4_PROC;
                  end
   
// xor core 0 collect                   
                   GABLER_SM_4_PROC: begin
                           if(gbr_sm_en_q[4] == 1'b0)                           garbler_sm_ns[7:0]  = GABLER_SM_5_PROC;
                           else if(gbr_output_addr_arr[4][31])                  garbler_sm_ns[7:0]  = GABLER_SM_4_COLLECT_BRAM;
                           else                                                 garbler_sm_ns[7:0]  = GABLER_SM_4_DONE;              
                   end
   
   
                   GABLER_SM_4_DONE: begin
                                                                           garbler_sm_ns[7:0]  = GABLER_SM_4_COLLECT;
                   end
                   GABLER_SM_4_COLLECT: begin
                   
                           if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)
                                                                                           garbler_sm_ns[7:0]  = GABLER_SM_5_PROC;
                           else
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_4_COLLECT;
                   end
   
                   GABLER_SM_4_COLLECT_BRAM: begin
                                                                                           garbler_sm_ns[7:0]  = GABLER_SM_5_PROC;
                   end
// xor core 1 collect
                   GABLER_SM_5_PROC: begin
                           if(gbr_sm_en_q[5] == 1'b0)                                 garbler_sm_ns[7:0]  = GABLER_SM_6_PROC;
                           else if(gbr_output_addr_arr[5][31])                  garbler_sm_ns[7:0]  = GABLER_SM_5_COLLECT_BRAM;
                           else                                                            garbler_sm_ns[7:0]  = GABLER_SM_5_DONE;              
                   end
   
   
                   GABLER_SM_5_DONE: begin
                                                                           garbler_sm_ns[7:0]  = GABLER_SM_5_COLLECT;
                   end
                   GABLER_SM_5_COLLECT: begin
                           if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)
                                                                                           garbler_sm_ns[7:0]  = GABLER_SM_6_PROC;
                           else
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_5_COLLECT;
                   end
                   GABLER_SM_5_COLLECT_BRAM: begin
                                                                                           garbler_sm_ns[7:0]  = GABLER_SM_6_PROC;
                   end
   
                   
                   GABLER_SM_6_PROC: begin
                           if(gbr_sm_en_q[6] == 1'b0)                                 garbler_sm_ns[7:0]  = GABLER_SM_7_PROC;
                           else if(gbr_output_addr_arr[6][31])                  garbler_sm_ns[7:0]  = GABLER_SM_6_COLLECT_BRAM;
                           else                                                            garbler_sm_ns[7:0]  = GABLER_SM_6_DONE;              
                   end
   
   
                   GABLER_SM_6_DONE: begin
                                                                           garbler_sm_ns[7:0]  = GABLER_SM_6_COLLECT;
                   end
                   GABLER_SM_6_COLLECT: begin
                   
                           if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)
                                                                                           garbler_sm_ns[7:0]  = GABLER_SM_7_PROC;
   
                           else
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_6_COLLECT;
                   end
                   GABLER_SM_6_COLLECT_BRAM: begin
                                                                                           garbler_sm_ns[7:0]  = GABLER_SM_7_PROC;
                   end
   
                   
                   GABLER_SM_7_PROC: begin
                           if(gbr_sm_en_q[7] == 1'b0)
                                                                                           garbler_sm_ns[7:0]  = GABLER_SM_RESET;
                           else if(gbr_output_addr_arr[7][31])                  garbler_sm_ns[7:0]  = GABLER_SM_7_COLLECT_BRAM;
                           else                                                            garbler_sm_ns[7:0]  = GABLER_SM_7_DONE;              
                   end
   
   
                   GABLER_SM_7_DONE: begin
                                                                           garbler_sm_ns[7:0]  = GABLER_SM_7_COLLECT;
                   end
                   GABLER_SM_7_COLLECT: begin
                           if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid) garbler_sm_ns[7:0]     = GABLER_SM_RESET;
                           else
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_7_COLLECT;
                   end
                   GABLER_SM_7_COLLECT_BRAM: begin
                                                                                           garbler_sm_ns[7:0]  = GABLER_SM_RESET;
                   end
   
                   GABLER_SM_RESET: begin
                                                                               garbler_sm_ns[7:0]  = GABLER_SM_IDLE;
                   end
   
                   default:                                                    garbler_sm_ns[7:0] = GABLER_SM_IDLE;
               endcase
           end
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////

   // AXI Master SM Flop
//->axi_sm_flop
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   
   always_ff @(posedge aclk)
     if (!aresetn) begin
        garbler_sm_q[7:0] <= 8'h0;
     end
     else begin
        garbler_sm_q[7:0] <= garbler_sm_ns[7:0];
     end
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////
//->assign_sm
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   
   assign garbler_sm_idle = (garbler_sm_q[7:0] == GABLER_SM_IDLE);
   assign garbler_sm_reset = (garbler_sm_q[7:0] == GABLER_SM_RESET);
   
   assign garbler_sm_0_ga_arld           = (garbler_sm_q[7:0]  == GABLER_SM_0_GA_ARLD);
   assign garbler_sm_0_ga_ld             = (garbler_sm_q[7:0]  == GABLER_SM_0_GA_LD);
   assign garbler_sm_0_ga_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_0_GA_ARLD_BRAM);
   assign garbler_sm_0_ga_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_0_GA_LD_BRAM);
   assign garbler_sm_0_ga_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_0_GA_LD_BRAM_DONE);
   assign garbler_sm_0_gb_arld           = (garbler_sm_q[7:0]  == GABLER_SM_0_GB_ARLD);
   assign garbler_sm_0_gb_ld             = (garbler_sm_q[7:0]  == GABLER_SM_0_GB_LD);
   assign garbler_sm_0_gb_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_0_GB_ARLD_BRAM);
   assign garbler_sm_0_gb_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_0_GB_LD_BRAM);
   assign garbler_sm_0_gb_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_0_GB_LD_BRAM_DONE);
   assign garbler_sm_0_valid             = (garbler_sm_q[7:0]  == GABLER_SM_0_VALID);
   assign garbler_sm_0_proc              = (garbler_sm_q[7:0]  == GABLER_SM_0_PROC);
   assign garbler_sm_0_done              = (garbler_sm_q[7:0]  == GABLER_SM_0_DONE);
   assign garbler_sm_0_collect           = (garbler_sm_q[7:0]  == GABLER_SM_0_COLLECT);
   assign garbler_sm_0_collect_bram           = (garbler_sm_q[7:0]  == GABLER_SM_0_COLLECT_BRAM);
   
   assign garbler_sm_0_collect_done      = (garbler_sm_q[7:0] == GABLER_SM_0_COLLECT_DONE);
   assign garbler_sm_0_collect_ts01      = (garbler_sm_q[7:0] == GABLER_SM_0_COLLECT_TS01);
   assign garbler_sm_0_collect_ts01_bram      = (garbler_sm_q[7:0] == GABLER_SM_0_COLLECT_TS01_BRAM);
   assign garbler_sm_0_collect_ts01_done = (garbler_sm_q[7:0] == GABLER_SM_0_COLLECT_TS01_DONE);
   
   assign garbler_sm_0_collect_ts10      = (garbler_sm_q[7:0] == GABLER_SM_0_COLLECT_TS10);
   assign garbler_sm_0_collect_ts10_bram      = (garbler_sm_q[7:0] == GABLER_SM_0_COLLECT_TS10_BRAM);
   assign garbler_sm_0_collect_ts10_done = (garbler_sm_q[7:0] == GABLER_SM_0_COLLECT_TS10_DONE);
   assign garbler_sm_0_collect_ts11      = (garbler_sm_q[7:0] == GABLER_SM_0_COLLECT_TS11);
   assign garbler_sm_0_collect_ts11_bram      = (garbler_sm_q[7:0] == GABLER_SM_0_COLLECT_TS11_BRAM);
   
   
   assign garbler_sm_1_ga_arld           = (garbler_sm_q[7:0]  == GABLER_SM_1_GA_ARLD);
   assign garbler_sm_1_ga_ld             = (garbler_sm_q[7:0]  == GABLER_SM_1_GA_LD);
   assign garbler_sm_1_ga_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_1_GA_ARLD_BRAM);
   assign garbler_sm_1_ga_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_1_GA_LD_BRAM);
   assign garbler_sm_1_ga_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_1_GA_LD_BRAM_DONE);
   assign garbler_sm_1_gb_arld           = (garbler_sm_q[7:0]  == GABLER_SM_1_GB_ARLD);
   assign garbler_sm_1_gb_ld             = (garbler_sm_q[7:0]  == GABLER_SM_1_GB_LD);
   assign garbler_sm_1_gb_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_1_GB_ARLD_BRAM);
   assign garbler_sm_1_gb_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_1_GB_LD_BRAM);
   assign garbler_sm_1_gb_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_1_GB_LD_BRAM_DONE);
   assign garbler_sm_1_valid             = (garbler_sm_q[7:0]  == GABLER_SM_1_VALID);
   assign garbler_sm_1_proc              = (garbler_sm_q[7:0]  == GABLER_SM_1_PROC);
   assign garbler_sm_1_done              = (garbler_sm_q[7:0]  == GABLER_SM_1_DONE);
   assign garbler_sm_1_collect           = (garbler_sm_q[7:0]  == GABLER_SM_1_COLLECT);
   assign garbler_sm_1_collect_bram           = (garbler_sm_q[7:0]  == GABLER_SM_1_COLLECT_BRAM);
   
   assign garbler_sm_1_collect_done      = (garbler_sm_q[7:0] == GABLER_SM_1_COLLECT_DONE);
   assign garbler_sm_1_collect_ts01      = (garbler_sm_q[7:0] == GABLER_SM_1_COLLECT_TS01);
   assign garbler_sm_1_collect_ts01_bram      = (garbler_sm_q[7:0] == GABLER_SM_1_COLLECT_TS01_BRAM);
   assign garbler_sm_1_collect_ts01_done = (garbler_sm_q[7:0] == GABLER_SM_1_COLLECT_TS01_DONE);
   
   assign garbler_sm_1_collect_ts10      = (garbler_sm_q[7:0] == GABLER_SM_1_COLLECT_TS10);
   assign garbler_sm_1_collect_ts10_bram      = (garbler_sm_q[7:0] == GABLER_SM_1_COLLECT_TS10_BRAM);
   assign garbler_sm_1_collect_ts10_done = (garbler_sm_q[7:0] == GABLER_SM_1_COLLECT_TS10_DONE);
   assign garbler_sm_1_collect_ts11      = (garbler_sm_q[7:0] == GABLER_SM_1_COLLECT_TS11);
   assign garbler_sm_1_collect_ts11_bram      = (garbler_sm_q[7:0] == GABLER_SM_1_COLLECT_TS11_BRAM);
   
   
   assign garbler_sm_2_ga_arld           = (garbler_sm_q[7:0]  == GABLER_SM_2_GA_ARLD);
   assign garbler_sm_2_ga_ld             = (garbler_sm_q[7:0]  == GABLER_SM_2_GA_LD);
   assign garbler_sm_2_ga_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_2_GA_ARLD_BRAM);
   assign garbler_sm_2_ga_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_2_GA_LD_BRAM);
   assign garbler_sm_2_ga_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_2_GA_LD_BRAM_DONE);
   assign garbler_sm_2_gb_arld           = (garbler_sm_q[7:0]  == GABLER_SM_2_GB_ARLD);
   assign garbler_sm_2_gb_ld             = (garbler_sm_q[7:0]  == GABLER_SM_2_GB_LD);
   assign garbler_sm_2_gb_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_2_GB_ARLD_BRAM);
   assign garbler_sm_2_gb_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_2_GB_LD_BRAM);
   assign garbler_sm_2_gb_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_2_GB_LD_BRAM_DONE);
   assign garbler_sm_2_valid             = (garbler_sm_q[7:0]  == GABLER_SM_2_VALID);
   assign garbler_sm_2_proc              = (garbler_sm_q[7:0]  == GABLER_SM_2_PROC);
   assign garbler_sm_2_done              = (garbler_sm_q[7:0]  == GABLER_SM_2_DONE);
   assign garbler_sm_2_collect           = (garbler_sm_q[7:0]  == GABLER_SM_2_COLLECT);
   assign garbler_sm_2_collect_bram           = (garbler_sm_q[7:0]  == GABLER_SM_2_COLLECT_BRAM);
   
   assign garbler_sm_2_collect_done      = (garbler_sm_q[7:0] == GABLER_SM_2_COLLECT_DONE);
   assign garbler_sm_2_collect_ts01      = (garbler_sm_q[7:0] == GABLER_SM_2_COLLECT_TS01);
   assign garbler_sm_2_collect_ts01_bram      = (garbler_sm_q[7:0] == GABLER_SM_2_COLLECT_TS01_BRAM);
   assign garbler_sm_2_collect_ts01_done = (garbler_sm_q[7:0] == GABLER_SM_2_COLLECT_TS01_DONE);
   
   assign garbler_sm_2_collect_ts10      = (garbler_sm_q[7:0] == GABLER_SM_2_COLLECT_TS10);
   assign garbler_sm_2_collect_ts10_bram      = (garbler_sm_q[7:0] == GABLER_SM_2_COLLECT_TS10_BRAM);
   assign garbler_sm_2_collect_ts10_done = (garbler_sm_q[7:0] == GABLER_SM_2_COLLECT_TS10_DONE);
   assign garbler_sm_2_collect_ts11      = (garbler_sm_q[7:0] == GABLER_SM_2_COLLECT_TS11);
   assign garbler_sm_2_collect_ts11_bram      = (garbler_sm_q[7:0] == GABLER_SM_2_COLLECT_TS11_BRAM);
   
   
   assign garbler_sm_3_ga_arld           = (garbler_sm_q[7:0]  == GABLER_SM_3_GA_ARLD);
   assign garbler_sm_3_ga_ld             = (garbler_sm_q[7:0]  == GABLER_SM_3_GA_LD);
   assign garbler_sm_3_ga_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_3_GA_ARLD_BRAM);
   assign garbler_sm_3_ga_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_3_GA_LD_BRAM);
   assign garbler_sm_3_ga_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_3_GA_LD_BRAM_DONE);
   assign garbler_sm_3_gb_arld           = (garbler_sm_q[7:0]  == GABLER_SM_3_GB_ARLD);
   assign garbler_sm_3_gb_ld             = (garbler_sm_q[7:0]  == GABLER_SM_3_GB_LD);
   assign garbler_sm_3_gb_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_3_GB_ARLD_BRAM);
   assign garbler_sm_3_gb_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_3_GB_LD_BRAM);
   assign garbler_sm_3_gb_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_3_GB_LD_BRAM_DONE);
   assign garbler_sm_3_valid             = (garbler_sm_q[7:0]  == GABLER_SM_3_VALID);
   assign garbler_sm_3_proc              = (garbler_sm_q[7:0]  == GABLER_SM_3_PROC);
   assign garbler_sm_3_done              = (garbler_sm_q[7:0]  == GABLER_SM_3_DONE);
   assign garbler_sm_3_collect           = (garbler_sm_q[7:0]  == GABLER_SM_3_COLLECT);
   assign garbler_sm_3_collect_bram           = (garbler_sm_q[7:0]  == GABLER_SM_3_COLLECT_BRAM);
   
   assign garbler_sm_3_collect_done      = (garbler_sm_q[7:0] == GABLER_SM_3_COLLECT_DONE);
   assign garbler_sm_3_collect_ts01      = (garbler_sm_q[7:0] == GABLER_SM_3_COLLECT_TS01);
   assign garbler_sm_3_collect_ts01_bram      = (garbler_sm_q[7:0] == GABLER_SM_3_COLLECT_TS01_BRAM);
   assign garbler_sm_3_collect_ts01_done = (garbler_sm_q[7:0] == GABLER_SM_3_COLLECT_TS01_DONE);
   
   assign garbler_sm_3_collect_ts10      = (garbler_sm_q[7:0] == GABLER_SM_3_COLLECT_TS10);
   assign garbler_sm_3_collect_ts10_bram      = (garbler_sm_q[7:0] == GABLER_SM_3_COLLECT_TS10_BRAM);
   assign garbler_sm_3_collect_ts10_done = (garbler_sm_q[7:0] == GABLER_SM_3_COLLECT_TS10_DONE);
   assign garbler_sm_3_collect_ts11      = (garbler_sm_q[7:0] == GABLER_SM_3_COLLECT_TS11);
   assign garbler_sm_3_collect_ts11_bram      = (garbler_sm_q[7:0] == GABLER_SM_3_COLLECT_TS11_BRAM);
   


   
   assign garbler_sm_4_ga_arld           = (garbler_sm_q[7:0]  == GABLER_SM_4_GA_ARLD);
   assign garbler_sm_4_ga_ld             = (garbler_sm_q[7:0]  == GABLER_SM_4_GA_LD);
   assign garbler_sm_4_ga_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_4_GA_ARLD_BRAM);
   assign garbler_sm_4_ga_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_4_GA_LD_BRAM);
   assign garbler_sm_4_ga_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_4_GA_LD_BRAM_DONE);
   assign garbler_sm_4_gb_arld           = (garbler_sm_q[7:0]  == GABLER_SM_4_GB_ARLD);
   assign garbler_sm_4_gb_ld             = (garbler_sm_q[7:0]  == GABLER_SM_4_GB_LD);
   assign garbler_sm_4_gb_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_4_GB_ARLD_BRAM);
   assign garbler_sm_4_gb_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_4_GB_LD_BRAM);
   assign garbler_sm_4_gb_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_4_GB_LD_BRAM_DONE);
   assign garbler_sm_4_valid             = (garbler_sm_q[7:0]  == GABLER_SM_4_VALID);
   assign garbler_sm_4_proc              = (garbler_sm_q[7:0]  == GABLER_SM_4_PROC);
   assign garbler_sm_4_done              = (garbler_sm_q[7:0]  == GABLER_SM_4_DONE);
   assign garbler_sm_4_collect           = (garbler_sm_q[7:0]  == GABLER_SM_4_COLLECT);
   assign garbler_sm_4_collect_bram           = (garbler_sm_q[7:0]  == GABLER_SM_4_COLLECT_BRAM);
   
   
   assign garbler_sm_5_ga_arld           = (garbler_sm_q[7:0]  == GABLER_SM_5_GA_ARLD);
   assign garbler_sm_5_ga_ld             = (garbler_sm_q[7:0]  == GABLER_SM_5_GA_LD);
   assign garbler_sm_5_ga_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_5_GA_ARLD_BRAM);
   assign garbler_sm_5_ga_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_5_GA_LD_BRAM);
   assign garbler_sm_5_ga_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_5_GA_LD_BRAM_DONE);
   assign garbler_sm_5_gb_arld           = (garbler_sm_q[7:0]  == GABLER_SM_5_GB_ARLD);
   assign garbler_sm_5_gb_ld             = (garbler_sm_q[7:0]  == GABLER_SM_5_GB_LD);
   assign garbler_sm_5_gb_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_5_GB_ARLD_BRAM);
   assign garbler_sm_5_gb_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_5_GB_LD_BRAM);
   assign garbler_sm_5_gb_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_5_GB_LD_BRAM_DONE);
   assign garbler_sm_5_valid             = (garbler_sm_q[7:0]  == GABLER_SM_5_VALID);
   assign garbler_sm_5_proc              = (garbler_sm_q[7:0]  == GABLER_SM_5_PROC);
   assign garbler_sm_5_done              = (garbler_sm_q[7:0]  == GABLER_SM_5_DONE);
   assign garbler_sm_5_collect           = (garbler_sm_q[7:0]  == GABLER_SM_5_COLLECT);
   assign garbler_sm_5_collect_bram           = (garbler_sm_q[7:0]  == GABLER_SM_5_COLLECT_BRAM);
   
   assign garbler_sm_6_ga_arld           = (garbler_sm_q[7:0]  == GABLER_SM_6_GA_ARLD);
   assign garbler_sm_6_ga_ld             = (garbler_sm_q[7:0]  == GABLER_SM_6_GA_LD);
   assign garbler_sm_6_ga_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_6_GA_ARLD_BRAM);
   assign garbler_sm_6_ga_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_6_GA_LD_BRAM);
   assign garbler_sm_6_ga_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_6_GA_LD_BRAM_DONE);
   assign garbler_sm_6_gb_arld           = (garbler_sm_q[7:0]  == GABLER_SM_6_GB_ARLD);
   assign garbler_sm_6_gb_ld             = (garbler_sm_q[7:0]  == GABLER_SM_6_GB_LD);
   assign garbler_sm_6_gb_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_6_GB_ARLD_BRAM);
   assign garbler_sm_6_gb_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_6_GB_LD_BRAM);
   assign garbler_sm_6_gb_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_6_GB_LD_BRAM_DONE);
   assign garbler_sm_6_valid             = (garbler_sm_q[7:0]  == GABLER_SM_6_VALID);
   assign garbler_sm_6_proc              = (garbler_sm_q[7:0]  == GABLER_SM_6_PROC);
   assign garbler_sm_6_done              = (garbler_sm_q[7:0]  == GABLER_SM_6_DONE);
   assign garbler_sm_6_collect           = (garbler_sm_q[7:0]  == GABLER_SM_6_COLLECT);
   assign garbler_sm_6_collect_bram           = (garbler_sm_q[7:0]  == GABLER_SM_6_COLLECT_BRAM);
   
   assign garbler_sm_7_ga_arld           = (garbler_sm_q[7:0]  == GABLER_SM_7_GA_ARLD);
   assign garbler_sm_7_ga_ld             = (garbler_sm_q[7:0]  == GABLER_SM_7_GA_LD);
   assign garbler_sm_7_ga_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_7_GA_ARLD_BRAM);
   assign garbler_sm_7_ga_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_7_GA_LD_BRAM);
   assign garbler_sm_7_ga_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_7_GA_LD_BRAM_DONE);
   assign garbler_sm_7_gb_arld           = (garbler_sm_q[7:0]  == GABLER_SM_7_GB_ARLD);
   assign garbler_sm_7_gb_ld             = (garbler_sm_q[7:0]  == GABLER_SM_7_GB_LD);
   assign garbler_sm_7_gb_arld_bram           = (garbler_sm_q[7:0]  == GABLER_SM_7_GB_ARLD_BRAM);
   assign garbler_sm_7_gb_ld_bram             = (garbler_sm_q[7:0]  == GABLER_SM_7_GB_LD_BRAM);
   assign garbler_sm_7_gb_ld_bram_done             = (garbler_sm_q[7:0]  == GABLER_SM_7_GB_LD_BRAM_DONE);
   assign garbler_sm_7_valid             = (garbler_sm_q[7:0]  == GABLER_SM_7_VALID);
   assign garbler_sm_7_proc              = (garbler_sm_q[7:0]  == GABLER_SM_7_PROC);
   assign garbler_sm_7_done              = (garbler_sm_q[7:0]  == GABLER_SM_7_DONE);
   assign garbler_sm_7_collect           = (garbler_sm_q[7:0]  == GABLER_SM_7_COLLECT);
   assign garbler_sm_7_collect_bram           = (garbler_sm_q[7:0]  == GABLER_SM_7_COLLECT_BRAM);
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////
	
// -----------------------------------------------------------------------------
// MY GARBLE AND core Machine
// -----------------------------------------------------------------------------
	
//->dec_inputs
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   assign garble_and_aresetn = aresetn & (garbler_sm_q != GABLER_SM_RESET);
   
   assign Ga_0_ns[79:0] =
   (isBram & (garbler_sm_0_ga_ld_bram_done)) ? 
                                           (bram_qb_rd[79:0]) :
   (garbler_sm_0_ga_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Ga_0_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Ga_0_q[79:0] <= 80'h0;
           end
           else begin
                   Ga_0_q[79:0] <= Ga_0_ns[79:0];
           end
   
   assign Gb_0_ns[79:0] = 
   (isBram & garbler_sm_0_gb_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_0_gb_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Gb_0_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Gb_0_q[79:0] <= 80'h0;
           end
           else begin
                   Gb_0_q[79:0] <= Gb_0_ns[79:0];
           end
   
   assign Ga_1_ns[79:0] =
   (isBram & garbler_sm_1_ga_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_1_ga_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Ga_1_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Ga_1_q[79:0] <= 80'h0;
           end
           else begin
                   Ga_1_q[79:0] <= Ga_1_ns[79:0];
           end
   
   assign Gb_1_ns[79:0] = 
   (isBram & garbler_sm_1_gb_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_1_gb_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Gb_1_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Gb_1_q[79:0] <= 80'h0;
           end
           else begin
                   Gb_1_q[79:0] <= Gb_1_ns[79:0];
           end
   
   assign Ga_2_ns[79:0] =
   (isBram & garbler_sm_2_ga_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_2_ga_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Ga_2_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Ga_2_q[79:0] <= 80'h0;
           end
           else begin
                   Ga_2_q[79:0] <= Ga_2_ns[79:0];
           end
   
   assign Gb_2_ns[79:0] = 
   (isBram & garbler_sm_2_gb_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_2_gb_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Gb_2_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Gb_2_q[79:0] <= 80'h0;
           end
           else begin
                   Gb_2_q[79:0] <= Gb_2_ns[79:0];
           end
   
   assign Ga_3_ns[79:0] =
   (isBram & garbler_sm_3_ga_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_3_ga_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Ga_3_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Ga_3_q[79:0] <= 80'h0;
           end
           else begin
                   Ga_3_q[79:0] <= Ga_3_ns[79:0];
           end
   
   assign Gb_3_ns[79:0] = 
   (isBram & garbler_sm_3_gb_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_3_gb_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Gb_3_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Gb_3_q[79:0] <= 80'h0;
           end
           else begin
                   Gb_3_q[79:0] <= Gb_3_ns[79:0];
           end
   
   assign Ga_4_ns[79:0] =
   (isBram & (garbler_sm_4_ga_ld_bram_done)) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_4_ga_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Ga_4_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Ga_4_q[79:0] <= 80'h0;
           end
           else begin
                   Ga_4_q[79:0] <= Ga_4_ns[79:0];
           end
   
   assign Gb_4_ns[79:0] = 
   (isBram & garbler_sm_4_gb_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_4_gb_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Gb_4_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Gb_4_q[79:0] <= 80'h0;
           end
           else begin
                   Gb_4_q[79:0] <= Gb_4_ns[79:0];
           end
   
   assign Ga_5_ns[79:0] =
   (isBram & garbler_sm_5_ga_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_5_ga_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Ga_5_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Ga_5_q[79:0] <= 80'h0;
           end
           else begin
                   Ga_5_q[79:0] <= Ga_5_ns[79:0];
           end
   
   assign Gb_5_ns[79:0] = 
   (isBram & garbler_sm_5_gb_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_5_gb_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Gb_5_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Gb_5_q[79:0] <= 80'h0;
           end
           else begin
                   Gb_5_q[79:0] <= Gb_5_ns[79:0];
           end
   
   assign Ga_6_ns[79:0] =
   (isBram & garbler_sm_6_ga_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_6_ga_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Ga_6_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Ga_6_q[79:0] <= 80'h0;
           end
           else begin
                   Ga_6_q[79:0] <= Ga_6_ns[79:0];
           end
   
   assign Gb_6_ns[79:0] = 
   (isBram & garbler_sm_6_gb_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_6_gb_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Gb_6_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Gb_6_q[79:0] <= 80'h0;
           end
           else begin
                   Gb_6_q[79:0] <= Gb_6_ns[79:0];
           end
   
   assign Ga_7_ns[79:0] =
   (isBram & garbler_sm_7_ga_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_7_ga_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Ga_7_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Ga_7_q[79:0] <= 80'h0;
           end
           else begin
                   Ga_7_q[79:0] <= Ga_7_ns[79:0];
           end
   
   assign Gb_7_ns[79:0] = 
   (isBram & garbler_sm_7_gb_ld_bram_done) ? 
                                           ( bram_qb_rd[79:0]) :
   (garbler_sm_7_gb_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? 
                                           (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Gb_7_q[79:0];
   
   always_ff @(posedge aclk)
           if(!aresetn) begin
                   Gb_7_q[79:0] <= 80'h0;
           end
           else begin
                   Gb_7_q[79:0] <= Gb_7_ns[79:0];
           end
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////
	
//->instantiate
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   
   assign and_valid_0_q = garbler_sm_0_valid & gbr_sm_en_q[0] == 1'b1;
   
   assign and_valid_1_q = garbler_sm_1_valid & gbr_sm_en_q[1] == 1'b1;
   
   assign and_valid_2_q = garbler_sm_2_valid & gbr_sm_en_q[2] == 1'b1;
   
   assign and_valid_3_q = garbler_sm_3_valid & gbr_sm_en_q[3] == 1'b1;
   
   assign xor_valid_0_q = garbler_sm_4_valid & gbr_sm_en_q[4] == 1'b1;
   
   assign xor_valid_1_q = garbler_sm_5_valid & gbr_sm_en_q[5] == 1'b1;
   
   assign xor_valid_2_q = garbler_sm_6_valid & gbr_sm_en_q[6] == 1'b1;
   
   assign xor_valid_3_q = garbler_sm_7_valid & gbr_sm_en_q[7] == 1'b1;
   
   garbler_and  GARBLER_AND_INST0(
   .clk(aclk),
   .reset_n(garble_and_aresetn),           //should be as garble_and_aresetn
   .input_valid(and_valid_0_q),
   .R(R),
   .Ga(Ga_0_q),   ///Ga_q  80'hc6179d4cde33a0efea38
   .Gb(Gb_0_q),   ///Gb_q  80'h09f8ca84831c624e73e7
   .g_id({32'b0, gate_id_q0[31:0]}),
   .output_valid(output_valid_0_q),
   .ready(),
   .Gc(Gc_0_q),
   .toSend01(toSend01_0_q),
   .toSend10(toSend10_0_q),
   .toSend11(toSend11_0_q)
   );
   
   garbler_and  GARBLER_AND_INST1(
   .clk(aclk),
   .reset_n(garble_and_aresetn),           //should be as garble_and_aresetn
   .input_valid(and_valid_1_q),
   .R(R),
   .Ga(Ga_1_q),   ///Ga_q  80'hc6179d4cde33a0efea38
   .Gb(Gb_1_q),   ///Gb_q  80'h09f8ca84831c624e73e7
   .g_id({32'b0, gate_id_q1[31:0]}),
   .output_valid(output_valid_1_q),
   .ready(),
   .Gc(Gc_1_q),
   .toSend01(toSend01_1_q),
   .toSend10(toSend10_1_q),
   .toSend11(toSend11_1_q)
   );
   
   garbler_and  GARBLER_AND_INST2(
   .clk(aclk),
   .reset_n(garble_and_aresetn),           //should be as garble_and_aresetn
   .input_valid(and_valid_2_q),
   .R(R),
   .Ga(Ga_2_q),   ///Ga_q  80'hc6179d4cde33a0efea38
   .Gb(Gb_2_q),   ///Gb_q  80'h09f8ca84831c624e73e7
   .g_id({32'b0, gate_id_q2[31:0]}),
   .output_valid(output_valid_2_q),
   .ready(),
   .Gc(Gc_2_q),
   .toSend01(toSend01_2_q),
   .toSend10(toSend10_2_q),
   .toSend11(toSend11_2_q)
   );
   
   garbler_and  GARBLER_AND_INST3(
   .clk(aclk),
   .reset_n(garble_and_aresetn),           //should be as garble_and_aresetn
   .input_valid(and_valid_3_q),
   .R(R),
   .Ga(Ga_3_q),   ///Ga_q  80'hc6179d4cde33a0efea38
   .Gb(Gb_3_q),   ///Gb_q  80'h09f8ca84831c624e73e7
   .g_id({32'b0, gate_id_q3[31:0]}),
   .output_valid(output_valid_3_q),
   .ready(),
   .Gc(Gc_3_q),
   .toSend01(toSend01_3_q),
   .toSend10(toSend10_3_q),
   .toSend11(toSend11_3_q)
   );
   
   xor_gate XOR_GATE_INST0(
   .Ga(Ga_4_q),
   .Gb(Gb_4_q),
   .aclk(aclk),
   .aresetn(garble_and_aresetn),
   .input_valid(xor_valid_0_q),
   .Gc_xor_out(Gc_xor_out_0)
   );
   
   xor_gate XOR_GATE_INST1(
   .Ga(Ga_5_q),
   .Gb(Gb_5_q),
   .aclk(aclk),
   .aresetn(garble_and_aresetn),
   .input_valid(xor_valid_1_q),
   .Gc_xor_out(Gc_xor_out_1)
   );
   
   xor_gate XOR_GATE_INST2(
   .Ga(Ga_6_q),
   .Gb(Gb_6_q),
   .aclk(aclk),
   .aresetn(garble_and_aresetn),
   .input_valid(xor_valid_2_q),
   .Gc_xor_out(Gc_xor_out_2)
   );
   
   xor_gate XOR_GATE_INST3(
   .Ga(Ga_7_q),
   .Gb(Gb_7_q),
   .aclk(aclk),
   .aresetn(garble_and_aresetn),
   .input_valid(xor_valid_3_q),
   .Gc_xor_out(Gc_xor_out_3)
   );
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////
	assign gbr_output1 = Gc_0_q;
	assign gbr_output2 = toSend01_0_q;

	
	assign garbler_sm_core_done_ns = garbler_sm_core_done_q | garbler_sm_reset; // (axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid);
	 always_ff @(posedge aclk)
                if(!aresetn) begin
                        garbler_sm_core_done_q <= 1'b0;
                end
		else if((cfg_wr_stretch & ~axi_mstr_cfg_bus.ack) & (cfg_addr_q == 8'hE8)) begin
			 garbler_sm_core_done_q <= 1'b0;
		end
                else begin
                        garbler_sm_core_done_q <= garbler_sm_core_done_ns;
                end
	
//->assign_wb
//////////////////////////////////////////////////
// this is generated code
//////////////////////////////////////////////////
   assign data_write_back_q = (gbr_sm_en_q[0] == 1'b1 & garbler_sm_0_collect)?    
                              {384'b0, Gc_0_q[79:0], 48'b0} : 
                              (gbr_sm_en_q[0] == 1'b1 & garbler_sm_0_collect_ts01)?
                              {384'b0, toSend01_0_q[79:0],48'b0}: 
                              (gbr_sm_en_q[0] == 1'b1 & garbler_sm_0_collect_ts10)?
                              {384'b0, toSend10_0_q[79:0],48'b0}: 
                              (gbr_sm_en_q[0] == 1'b1 & garbler_sm_0_collect_ts11)?
                              {384'b0, toSend11_0_q[79:0],48'b0}: 
                              (gbr_sm_en_q[1] == 1'b1 & garbler_sm_1_collect)?    
                              {384'b0, Gc_1_q[79:0], 48'b0} : 
                              (gbr_sm_en_q[1] == 1'b1 & garbler_sm_1_collect_ts01)?
                              {384'b0, toSend01_1_q[79:0],48'b0}: 
                              (gbr_sm_en_q[1] == 1'b1 & garbler_sm_1_collect_ts10)?
                              {384'b0, toSend10_1_q[79:0],48'b0}: 
                              (gbr_sm_en_q[1] == 1'b1 & garbler_sm_1_collect_ts11)?
                              {384'b0, toSend11_1_q[79:0],48'b0}: 
                              (gbr_sm_en_q[2] == 1'b1 & garbler_sm_2_collect)?    
                              {384'b0, Gc_2_q[79:0], 48'b0} : 
                              (gbr_sm_en_q[2] == 1'b1 & garbler_sm_2_collect_ts01)?
                              {384'b0, toSend01_2_q[79:0],48'b0}: 
                              (gbr_sm_en_q[2] == 1'b1 & garbler_sm_2_collect_ts10)?
                              {384'b0, toSend10_2_q[79:0],48'b0}: 
                              (gbr_sm_en_q[2] == 1'b1 & garbler_sm_2_collect_ts11)?
                              {384'b0, toSend11_2_q[79:0],48'b0}: 
                              (gbr_sm_en_q[3] == 1'b1 & garbler_sm_3_collect)?    
                              {384'b0, Gc_3_q[79:0], 48'b0} : 
                              (gbr_sm_en_q[3] == 1'b1 & garbler_sm_3_collect_ts01)?
                              {384'b0, toSend01_3_q[79:0],48'b0}: 
                              (gbr_sm_en_q[3] == 1'b1 & garbler_sm_3_collect_ts10)?
                              {384'b0, toSend10_3_q[79:0],48'b0}: 
                              (gbr_sm_en_q[3] == 1'b1 & garbler_sm_3_collect_ts11)?
                              {384'b0, toSend11_3_q[79:0],48'b0}: 
                              (gbr_sm_en_q[4] == 1'b1 & garbler_sm_4_collect)?    
                              {384'b0, Gc_xor_out_0[79:0], 48'b0} :
                              (gbr_sm_en_q[5] == 1'b1 & garbler_sm_5_collect)?    
                              {384'b0, Gc_xor_out_1[79:0], 48'b0} :
                              (gbr_sm_en_q[6] == 1'b1 & garbler_sm_6_collect)?    
                              {384'b0, Gc_xor_out_2[79:0], 48'b0} :
                              (gbr_sm_en_q[7] == 1'b1 & garbler_sm_7_collect)?    
                              {384'b0, Gc_xor_out_3[79:0], 48'b0} : 512'b0;
//////////////////////////////////////////////////
// end of generated code
//////////////////////////////////////////////////

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
