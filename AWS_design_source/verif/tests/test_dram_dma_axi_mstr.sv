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

module test_dram_dma_axi_mstr();

   import tb_type_defines_pkg::*;
   
    int            error_count;
    int            timeout_count;
    int            fail;
    logic [3:0]    status;
    logic my_status;
    int my_timeout_count; 	

    // AXI Master Command Register Addresses
    localparam AXI_MSTR_CCR_ADDR   = 32'h0005_0000;
    localparam AXI_MSTR_CAHR_ADDR  = 32'h0005_0004;
    localparam AXI_MSTR_CALR_ADDR  = 32'h0005_0008;
    localparam AXI_MSTR_CWDR_ADDR  = 32'h0005_000C;
    localparam AXI_MSTR_CRDR_ADDR  = 32'h0005_0010;

    localparam DDRA_HI_ADDR = 32'h0000_0001;
    localparam DDRA_LO_ADDR = 32'hA021_F700;
    localparam DDRA_DATA    = 32'hA5A6_1A2A;

    localparam DDRB_HI_ADDR = 32'h0000_0004;
    localparam DDRB_LO_ADDR = 32'h529C_8400;
    localparam DDRB_DATA    = 32'h1B80_C948;

    localparam DDRC_HI_ADDR = 32'h0000_0008;
    localparam DDRC_LO_ADDR = 32'h2078_BC00;
    localparam DDRC_DATA    = 32'h8BD1_8801;

    localparam DDRD_HI_ADDR = 32'h0000_000C;
    localparam DDRD_LO_ADDR = 32'hD016_7700;
    localparam DDRD_DATA    = 32'hCA02_183D;


    initial begin

       logic [63:0] host_memory_buffer_address;
       

       tb.power_up(.clk_recipe_a(ClockRecipe::A1), 
                   .clk_recipe_b(ClockRecipe::B0), 
                   .clk_recipe_c(ClockRecipe::C0));

       tb.nsec_delay(1000);
       tb.poke_stat(.addr(8'h0c), .ddr_idx(0), .data(32'h0000_0000));
       tb.poke_stat(.addr(8'h0c), .ddr_idx(1), .data(32'h0000_0000));
       tb.poke_stat(.addr(8'h0c), .ddr_idx(2), .data(32'h0000_0000));

       // de-select the ATG hardware
       
       tb.poke_ocl(.addr(64'h130), .data(0));
       tb.poke_ocl(.addr(64'h230), .data(0));
       tb.poke_ocl(.addr(64'h330), .data(0));
       tb.poke_ocl(.addr(64'h430), .data(0));

       // allow memory to initialize
       tb.nsec_delay(27000);

       // issuing flr
       tb.issue_flr();

 	// $display("[%t] : starting H2C DMA channels ", $realtime);
	
	$display("[%t] : Initializing buffers ", $realtime);	
	host_memory_buffer_address = 64'h0;
	
	tb.que_buffer_to_cl(.chan(0), .src_addr(host_memory_buffer_address), .cl_addr(64'h0000_0000_0000_2000), .len(256));
	
	// PIXEL 0
	tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
	tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
	tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
	tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;	
	// PIXEL 1
	tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h77));
                host_memory_buffer_address++;
	tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
	// PIXEL 2   
	tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h55));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h1a));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h3f));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h4c));
                host_memory_buffer_address++;
	// PIXEL 3
	tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h1d));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h30));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h38));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h21));
                host_memory_buffer_address++;
	
	 /////////////////////////////////////////////////////////////////////////////////////////////////
	// PIXEL 0
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        // PIXEL 1
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'haa));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'haa));
                host_memory_buffer_address++;
        // PIXEL 2
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'haa));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'haa));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'haa));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'haa));
                host_memory_buffer_address++;
        // PIXEL 3
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'haa));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'haa));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'haa));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'haa));
                host_memory_buffer_address++;
	
	 /////////////////////////////////////////////////////////////////////////////////////////////////
	
	 // PIXEL 0
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        // PIXEL 1
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hbb));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hbb));
                host_memory_buffer_address++;
        // PIXEL 2
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hbb));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hbb));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hbb));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hbb));
                host_memory_buffer_address++;
        // PIXEL 3
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hbb));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hbb));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hbb));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hbb));
                host_memory_buffer_address++;

	/////////////////////////////////////////////////////////////////////////////////////////////////
	// PIXEL 4
	tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
	// PIXEL 5
	tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h0a));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h65));
                host_memory_buffer_address++;
	// PIXEL 6
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h18));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'ha5));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h6a));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hd0));
                host_memory_buffer_address++;
	// PIXEL 7
	tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'he0));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h06));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h2f));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h13));
                host_memory_buffer_address++;
	
	////////////////////////////////////////////////////////////////////////////////////////////////
	
	// PIXEL 0
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        // PIXEL 1
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        // PIXEL 2
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        // PIXEL 3
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;

	//////////////////////////////////////////////////////////////////////////////////////////////
	
	// PIXEL 0
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        // PIXEL 1
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hb5));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h6a));
                host_memory_buffer_address++;
        // PIXEL 2
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h81));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h6c));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h19));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h9f));
                host_memory_buffer_address++;
        // PIXEL 3
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h1d));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h3c));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h36));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h15));
                host_memory_buffer_address++;

	//////////////////////////////////////////////////////////////////////////////////////////

	// PIXEL 0
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        // PIXEL 1
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h00));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h23));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h7a));
                host_memory_buffer_address++;
        // PIXEL 2
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h3f));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hf1));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h50));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h15));
                host_memory_buffer_address++;
        // PIXEL 3
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'ha1));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hd7));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'hf2));
                host_memory_buffer_address++;
        tb.hm_put_byte(.addr(host_memory_buffer_address), .d(8'h7e));
                host_memory_buffer_address++;
			
	/////////////////////////////////////////////////////////////////////////////////////////////////	
	tb.start_que_to_cl(.chan(0));


//    $monitor("state: %d counter : %d",tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.garbler_sm_q,tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.counter);
   // $monitor(" : state: 0x%d ",
   //                      (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.garbler_sm_q) );
    $display("----------------");
    $monitor(" monitor is wr data: 0x%h",
                            tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.bram_da_wr);
    $monitor(" monitor bram_addra_wr : 0x%h",
                            tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.bram_addra_wr);
    $monitor(" monitor is read data: 0x%h",
                            tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.bram_qb_rd);
    	  $monitor(" : Gbr_input[0] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[0]) );
    	  $monitor(" : Gbr_input[1] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[1]) );
    	  $monitor(" : Gbr_input[2] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[2]) );
    	  $monitor(" : Gbr_input[3] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[3]) );
    	  $monitor(" : Gbr_input[4] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[4]) );
    	  $monitor(" : Gbr_input[5] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[5]) );
    	  $monitor(" : Gbr_input[6] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[6]) );
    	  $monitor(" : Gbr_input[7] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[7]) );
    	  $monitor(" : Gbr_input[8] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[8]) );
    	  $monitor(" : Gbr_input[9] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[9]) );
    	  $monitor(" : Gbr_input[10] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[10]) );
    	  $monitor(" : Gbr_input[11] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[11]) );
    	  $monitor(" : Gbr_input[12] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[12]) );
    	  $monitor(" : Gbr_input[13] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[13]) );
    	  $monitor(" : Gbr_input[14] adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[14]) );
    	  $monitor(" : Gbr_input[15] adress: 0x%h ",
                    (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_input_addr_arr[15]) );
    	  
                    $monitor(" : bram_read adress: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.bram_addrb_rd) );
    	  $monitor(" : bram read data: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.bram_qb_rd) );
    	  $monitor(" : enable_bits: 0x%d ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_sm_en_q) );
     	  $monitor(" :axi_mstr_sm_wr_resp : 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.axi_mstr_sm_wr_resp) );
     	  $monitor(" : bvalid : 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cl_axi_mstr_bus.bvalid) );
      	  $monitor(" : axi_mstr_states : 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.axi_mstr_sm_q) );
         
    	  $monitor(" : Ga ns: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Ga_0_ns) );
    	  $monitor(" : Ga 0: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Ga_0_q) );
    	  $monitor(" : Ga 1: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Ga_1_q) );
    	  $monitor(" : Ga 2: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Ga_2_q) );
    	  $monitor(" : Ga 3: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Ga_3_q) );
    	  $monitor(" : Ga 4: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Ga_4_q) );
    	  $monitor(" : Ga 5: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Ga_5_q) );
    	  $monitor(" : Ga 6: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Ga_6_q) );
    	  $monitor(" : Ga 7: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Ga_7_q) );
    	  $monitor(" : Gb 0: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gb_0_q) );
    	  $monitor(" : Gb 1: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gb_1_q) );
    	  $monitor(" : Gb 2: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gb_2_q) );
    	  $monitor(" : Gb 3: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gb_3_q) );
    	  $monitor(" : Gb 4: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gb_4_q) );
    	  $monitor(" : Gb 5: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gb_5_q) );
    	  $monitor(" : Gb 6: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gb_6_q) );
    	  $monitor(" : Gb 7: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gb_7_q) );
    	  $monitor(" : Gc_xor 0: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gc_xor_out_0) );
    	  $monitor(" : Gc_xor 1: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gc_xor_out_1) );
    	  $monitor(" : Gc_xor 2: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gc_xor_out_2) );
    	  $monitor(" : Gc_xor 3: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gc_xor_out_3) );
                            
    	  $monitor(" : Gc 0: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gc_0_q) );
    	  $monitor(" : Gc 1: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gc_1_q) );
    	  $monitor(" : Gc 2: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gc_2_q) );
    	  $monitor(" : Gc 3: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gc_3_q) );
    	  $monitor(" : toSend01: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend01_0_q) );
    	  $monitor(" : toSend10: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend10_0_q) );
    	  $monitor(" : toSend11: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend11_0_q) );
    	  $monitor(" : Ga: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Ga_1_q) );
                            
    	  $monitor(" : Gb: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gb_1_q) );
    	  $monitor(" : Gc: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.Gc_1_q) );
    	  $monitor(" : toSend01: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend01_1_q) );
    	  $monitor(" : toSend10: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend10_1_q) );
    	  $monitor(" : toSend11: 0x%h ",
                         (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend11_1_q) );
	my_timeout_count = 0;
	do begin
		my_status = tb.is_dma_to_cl_done(.chan(0));
		#10ns;
		my_timeout_count++;		
	end while((my_status != 1'b1) && (my_timeout_count < 4000));
	
            
	if(my_timeout_count >= 4000) begin
		$display("[%t] : *** ERROR *** Timeout waiting for dma transfer to cl", $realtime);
		error_count++;
	end
	
	$display("[%t] : starting H2C DMA channels ", $realtime);
	$display("[%t] : Setting DDRA Command Registers ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(32'h0000_0000));  // Set High Address -- DDR A
       //tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(DDRA_LO_ADDR));  // Set Low  Address
       //tb.poke_ocl(.addr(AXI_MSTR_CWDR_ADDR), .data(DDRA_DATA));     // Set Write Data
       //tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR),  .data(32'h0000_0001)); // Issue Write Command
	//tb.poke_ocl(.addr(32'h0000_05D0), .data(32'h8472_d6bf));  // Set R[79:48]
	//tb.poke_ocl(.addr(32'h0000_05D4), .data(32'h5d38_7efa));  // Set R[47:16]
	//tb.poke_ocl(.addr(32'h0000_05D8), .data(32'ha64b_0000));  // Set R[15:0]
	
	tb.poke_ocl(.addr(32'h0005_00D0), .data(32'hca44_9238));  // Set R[79:48]
	tb.poke_ocl(.addr(32'h0005_00D4), .data(32'h68e9_d4c4));  // Set R[47:16]
	tb.poke_ocl(.addr(32'h0005_00D8), .data(32'h9c31_0000));  // Set R[15:0]
    tb.poke_ocl(.addr(32'h0005_4000), .data(32'h0000_0000));  // Set gate_id[31:0]
    //tb.poke_ocl(.addr(32'h0005_00C8), .data(32'h0000_0001));  // Set gate_id[31:0]
	//tb.poke_ocl(.addr(32'h0005_00C4), .data(32'h0000_0002));  // Set gate_id[31:0]
	//tb.poke_ocl(.addr(32'h0005_00C0), .data(32'h0000_0003));  // Set gate_id[31:0]

    $display("[%t] : setting R and gate id's done",$realtime);
    $display("[%t] : setting layer 0 addresses ",$realtime);

	  //set addresses
        tb.poke_ocl(.addr(32'h0005_1000), .data(32'h0000_2056));  // Set addr 0
        tb.poke_ocl(.addr(32'h0005_1004), .data(32'h0000_2066));     // Set addr 1
        tb.poke_ocl(.addr(32'h0005_2000), .data(32'h8000_0010));     // Set out addr

        tb.poke_ocl(.addr(32'h0005_3000), .data(32'h0000_2080));     // Set out addr
        tb.poke_ocl(.addr(32'h0005_3004), .data(32'h0000_2090));     // Set out addr
        tb.poke_ocl(.addr(32'h0005_3008), .data(32'h0000_20a0));     // Set out addr
        
	//  //set addresses
    //    tb.poke_ocl(.addr(32'h0000_0528), .data(32'h0000_2056));  // Set addr 0
    //    tb.poke_ocl(.addr(32'h0000_052c), .data(32'h0000_2066));     // Set addr 1
    //    tb.poke_ocl(.addr(32'h0000_05A4), .data(32'h8000_0020));     // Set out addr
    //    tb.poke_ocl(.addr(32'h0000_056c), .data(32'h0000_20b0));     // Set out addr
    //    tb.poke_ocl(.addr(32'h0000_0570), .data(32'h0000_20c0));     // Set out addr
    //    tb.poke_ocl(.addr(32'h0000_0574), .data(32'h0000_20d0));     // Set out addr
    //    
	//  //set addresses
    //    tb.poke_ocl(.addr(32'h0000_0530), .data(32'h0000_2056));  // Set addr 0
    //    tb.poke_ocl(.addr(32'h0000_0534), .data(32'h0000_2066));     // Set addr 1
    //    tb.poke_ocl(.addr(32'h0000_05A8), .data(32'h8000_0030));     // Set out addr
    //    tb.poke_ocl(.addr(32'h0000_0578), .data(32'h0000_2100));     // Set out addr
    //    tb.poke_ocl(.addr(32'h0000_057c), .data(32'h0000_2110));     // Set out addr
    //    tb.poke_ocl(.addr(32'h0000_0580), .data(32'h0000_2120));     // Set out addr
    //    
	//  //set addresses
    //    tb.poke_ocl(.addr(32'h0000_0538), .data(32'h0000_2056));  // Set addr 0
    //    tb.poke_ocl(.addr(32'h0000_053c), .data(32'h0000_2066));     // Set addr 1
    //    tb.poke_ocl(.addr(32'h0000_05b0), .data(32'h8000_0040));     // Set out addr
    //    tb.poke_ocl(.addr(32'h0000_0584), .data(32'h0000_2130));     // Set out addr
    //    tb.poke_ocl(.addr(32'h0000_0588), .data(32'h0000_2140));     // Set out addr
    //    tb.poke_ocl(.addr(32'h0000_058c), .data(32'h0000_2150));     // Set out addr
    //    
    //    tb.poke_ocl(.addr(32'h0000_0540), .data(32'h0000_2006));  // Set addr 0
    //    tb.poke_ocl(.addr(32'h0000_0544), .data(32'h0000_2066));     // Set addr 1
    //    tb.poke_ocl(.addr(32'h0000_05B0), .data(32'h8000_0050));     // Set out addr
    //    
    //    tb.poke_ocl(.addr(32'h0000_0548), .data(32'h0000_2016));  // Set addr 0
    //    tb.poke_ocl(.addr(32'h0000_054C), .data(32'h0000_2066));     // Set addr 1
    //    tb.poke_ocl(.addr(32'h0000_05B4), .data(32'h8000_0060));     // Set out addr
    //    
    //    tb.poke_ocl(.addr(32'h0000_0550), .data(32'h0000_2026));  // Set addr 0
    //    tb.poke_ocl(.addr(32'h0000_0554), .data(32'h0000_2066));     // Set addr 1
    //    tb.poke_ocl(.addr(32'h0000_05B8), .data(32'h8000_0070));     // Set out addr
    //    
    //    tb.poke_ocl(.addr(32'h0000_0558), .data(32'h0000_2036));  // Set addr 0
    //    tb.poke_ocl(.addr(32'h0000_055C), .data(32'h0000_2066));     // Set addr 1
    //    tb.poke_ocl(.addr(32'h0000_05BC), .data(32'h8000_0080));     // Set out addr
        
        tb.poke_ocl(.addr(32'h0005_0014), .data(32'h0000_0001));     // clear and
 
        //tb.poke_ocl(.addr(32'h0000_056C), .data(32'h0000_20A0));     // Set out addr
        //tb.poke_ocl(.addr(32'h0000_0570), .data(32'h0000_20B0));     // Set out addr
        //tb.poke_ocl(.addr(32'h0000_0574), .data(32'h0000_20C0));     // Set out addr
	    //   //tb.poke_ocl(.addr(32'h0000_0518), .data(32'h0000_0000));     // set xor

    $display("[%t] : setting done signal",$realtime);
        tb.poke_ocl(.addr(32'h0005_00E8), .data(32'h0000_0000));     // clear done

        $display("[%t] : Waiting for core command to complete.  ", $realtime);
       do begin
          #450ns;
          //#500
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.garbler_sm_core_done_q);
	
    $display("[%t] : layer 0 done",$realtime);

 //   $display("[%t] : setting layer 1 addresses ",$realtime);
 //     //set addresses
 //       tb.poke_ocl(.addr(32'h0000_0520), .data(32'h8000_0010));  // Set addr 0
 //       tb.poke_ocl(.addr(32'h0000_0524), .data(32'h8000_0020));     // Set addr 1
 //       tb.poke_ocl(.addr(32'h0000_05A0), .data(32'h8000_0010));     // Set out addr
 //       tb.poke_ocl(.addr(32'h0000_0560), .data(32'h0000_2080));     // Set out addr
 //       tb.poke_ocl(.addr(32'h0000_0564), .data(32'h0000_2090));     // Set out addr
 //       tb.poke_ocl(.addr(32'h0000_0568), .data(32'h0000_20a0));     // Set out addr
 //       
 //     //set addresses
 //       tb.poke_ocl(.addr(32'h0000_0528), .data(32'h8000_0010));  // Set addr 0
 //       tb.poke_ocl(.addr(32'h0000_052c), .data(32'h8000_0020));     // Set addr 1
 //       tb.poke_ocl(.addr(32'h0000_05A4), .data(32'h8000_0020));     // Set out addr
 //       tb.poke_ocl(.addr(32'h0000_056c), .data(32'h0000_20b0));     // Set out addr
 //       tb.poke_ocl(.addr(32'h0000_0570), .data(32'h0000_20c0));     // Set out addr
 //       tb.poke_ocl(.addr(32'h0000_0574), .data(32'h0000_20d0));     // Set out addr
 //       
 //     //set addresses
 //       tb.poke_ocl(.addr(32'h0000_0530), .data(32'h8000_0010));  // Set addr 0
 //       tb.poke_ocl(.addr(32'h0000_0534), .data(32'h8000_0020));     // Set addr 1
 //       tb.poke_ocl(.addr(32'h0000_05A8), .data(32'h8000_0030));     // Set out addr
 //       tb.poke_ocl(.addr(32'h0000_0578), .data(32'h0000_2100));     // Set out addr
 //       tb.poke_ocl(.addr(32'h0000_057c), .data(32'h0000_2110));     // Set out addr
 //       tb.poke_ocl(.addr(32'h0000_0580), .data(32'h0000_2120));     // Set out addr
 //       
 //     //set addresses
 //       tb.poke_ocl(.addr(32'h0000_0538), .data(32'h8000_0010));  // Set addr 0
 //       tb.poke_ocl(.addr(32'h0000_053c), .data(32'h8000_0020));     // Set addr 1
 //       tb.poke_ocl(.addr(32'h0000_05b0), .data(32'h8000_0040));     // Set out addr
 //       tb.poke_ocl(.addr(32'h0000_0584), .data(32'h0000_2130));     // Set out addr
 //       tb.poke_ocl(.addr(32'h0000_0588), .data(32'h0000_2140));     // Set out addr
 //       tb.poke_ocl(.addr(32'h0000_058c), .data(32'h0000_2150));     // Set out addr
 //       
 //       tb.poke_ocl(.addr(32'h0000_0540), .data(32'h8000_0010));  // Set addr 0
 //       tb.poke_ocl(.addr(32'h0000_0544), .data(32'h8000_2006));     // Set addr 1
 //       tb.poke_ocl(.addr(32'h0000_05B0), .data(32'h8000_2070));     // Set out addr
 //       
 //       tb.poke_ocl(.addr(32'h0000_0548), .data(32'h8000_0020));  // Set addr 0
 //       tb.poke_ocl(.addr(32'h0000_054C), .data(32'h8000_2066));     // Set addr 1
 //       tb.poke_ocl(.addr(32'h0000_05B4), .data(32'h8000_2080));     // Set out addr
 //       
 //       tb.poke_ocl(.addr(32'h0000_0550), .data(32'h8000_0030));  // Set addr 0
 //       tb.poke_ocl(.addr(32'h0000_0554), .data(32'h8000_2066));     // Set addr 1
 //       tb.poke_ocl(.addr(32'h0000_05B8), .data(32'h8000_2090));     // Set out addr
 //       
 //       tb.poke_ocl(.addr(32'h0000_0558), .data(32'h8000_0040));  // Set addr 0
 //       tb.poke_ocl(.addr(32'h0000_055C), .data(32'h8000_2066));     // Set addr 1
 //       tb.poke_ocl(.addr(32'h0000_05BC), .data(32'h8000_20A0));     // Set out addr
 //       
 //       tb.poke_ocl(.addr(32'h0000_0514), .data(32'h0000_00ff));     // clear and
 //
 //   //    //tb.poke_ocl(.addr(32'h0000_056C), .data(32'h0000_20A0));     // Set out addr
 //   //    //tb.poke_ocl(.addr(32'h0000_0570), .data(32'h0000_20B0));     // Set out addr
 //   //    //tb.poke_ocl(.addr(32'h0000_0574), .data(32'h0000_20C0));     // Set out addr
 //   //    //   //tb.poke_ocl(.addr(32'h0000_0518), .data(32'h0000_0000));     // set xor
 //       tb.poke_ocl(.addr(32'h0000_05E8), .data(32'h0000_0000));     // clear done

 //       $display("[%t] : Waiting for core command to complete.  ", $realtime);
 //      do begin
 //         #450ns;
 //         //#500
 //      end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.garbler_sm_core_done_q);
 //   $display("[%t] : layer 1 done",$realtime);
    //$display("[%t] : setting layer 2 addresses ",$realtime);
	  //set addresses
      //  tb.poke_ocl(.addr(32'h0000_0520), .data(32'h8000_0006));  // Set addr 0
      //  tb.poke_ocl(.addr(32'h0000_0524), .data(32'h8000_0007));     // Set addr 1

      //  tb.poke_ocl(.addr(32'h0000_05A0), .data(32'h0000_20A0));     // Set out addr
      //  tb.poke_ocl(.addr(32'h0000_0514), .data(32'h0000_0001));     // clear and
 
       // tb.poke_ocl(.addr(32'h0000_0560), .data(32'h0000_2070));     // Set out addr
       // tb.poke_ocl(.addr(32'h0000_0564), .data(32'h0000_2080));     // Set out addr
       // tb.poke_ocl(.addr(32'h0000_0568), .data(32'h0000_2090));     // Set out addr
       // tb.poke_ocl(.addr(32'h0000_056C), .data(32'h0000_20A0));     // Set out addr
       // tb.poke_ocl(.addr(32'h0000_0570), .data(32'h0000_20B0));     // Set out addr
       // tb.poke_ocl(.addr(32'h0000_0574), .data(32'h0000_20C0));     // Set out addr
	   //    //tb.poke_ocl(.addr(32'h0000_0518), .data(32'h0000_0000));     // set xor
      //  tb.poke_ocl(.addr(32'h0000_05E8), .data(32'h0000_0000));     // clear done

      //  $display("[%t] : Waiting for core command to complete.  ", $realtime);
     //  do begin
    //      #450ns;
    //      //#500
    //   end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.garbler_sm_core_done_q);
    //    tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2026));  // Set Low  Address
   
    //    $display("[%t] : Issuing DDRA read command.  ", $realtime);
    //   tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

    //   // Wait for read command to complet
    //   $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
    //   do begin
    //      #10ns;
    //   end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
    //   $display("[%t] : DDRA read command completed.  ", $realtime);
    //    $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
    //                    $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
    //                               (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
    //                               (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

    //    #10ns;
	////////////////////////////////////////////////////////////////////////////////////////
	//  //set addresses
    //    tb.poke_ocl(.addr(32'h0000_0528), .data(32'h0000_2016));  // Set addr 0
    //    tb.poke_ocl(.addr(32'h0000_052C), .data(32'h0000_2036));     // Set addr 1
    //    tb.poke_ocl(.addr(32'h0000_05A0), .data(32'h0000_2040));     // Set out addr
    //    tb.poke_ocl(.addr(32'h0000_0514), .data(32'h0000_0003));     // clear and
    //    //tb.poke_ocl(.addr(32'h0000_0518), .data(32'h0000_0000));     // set xor
    //    tb.poke_ocl(.addr(32'h0000_05E8), .data(32'h0000_0000));     // clear done

    //    $display("[%t] : Waiting for core command to complete.  ", $realtime);
    //   do begin
    //      #450ns;
    //   end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.garbler_sm_core_done_q);

	//tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2046));  // Set Low  Address
   
    //    $display("[%t] : Issuing DDRA read command.  ", $realtime);
    //   tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

    //   // Wait for read command to complet
    //   $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
    //   do begin
    //      #10ns;
    //   end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
    //   $display("[%t] : DDRA read command completed.  ", $realtime);
    //    $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
    //                    $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
    //                               (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
    //                               (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	//

	////////////////////////////////////////////////////////////////////////////////////////
	////set addresses 
	//tb.poke_ocl(.addr(32'h0000_0520), .data(32'h0000_2026));  // Set for gate0 addr 0
    //tb.poke_ocl(.addr(32'h0000_0524), .data(32'h0000_2046));     // Set for gate0 addr 1
	//
    //tb.poke_ocl(.addr(32'h0000_0528), .data(32'h0000_2026));  // Set addr for gate1 0
    //tb.poke_ocl(.addr(32'h0000_052C), .data(32'h0000_2046));  // Set addr for gate1 1
	//
  
    //tb.poke_ocl(.addr(32'h0000_0530), .data(32'h0000_2026));  // Set addr for gate2 0
    //tb.poke_ocl(.addr(32'h0000_0534), .data(32'h0000_2046));  // Set addr for gate2 1
	//
    //tb.poke_ocl(.addr(32'h0000_0538), .data(32'h0000_2026));  // Set addr for gate3 0
    //tb.poke_ocl(.addr(32'h0000_053C), .data(32'h0000_2046));  // Set addr for gate3 1
	//   
    //tb.poke_ocl(.addr(32'h0000_05A0), .data(32'h0000_2060));     // Set out addr
    //tb.poke_ocl(.addr(32'h0000_05A4), .data(32'h0000_2070));     // Set out addr
    //tb.poke_ocl(.addr(32'h0000_05A8), .data(32'h0000_2080));     // Set out addr
    //tb.poke_ocl(.addr(32'h0000_05AC), .data(32'h0000_2090));     // Set out addr
	//
	//   
    //tb.poke_ocl(.addr(32'h0000_0540), .data(32'h0000_2110));     // Set out addr
    //tb.poke_ocl(.addr(32'h0000_0544), .data(32'h0000_2120));     // Set out addr
    //tb.poke_ocl(.addr(32'h0000_0548), .data(32'h0000_2130));     // Set out addr
    //tb.poke_ocl(.addr(32'h0000_054C), .data(32'h0000_2140));     // Set out addr
    //tb.poke_ocl(.addr(32'h0000_0550), .data(32'h0000_2150));     // Set out addr
    //tb.poke_ocl(.addr(32'h0000_0554), .data(32'h0000_2160));     // Set out addr
	//
    //tb.poke_ocl(.addr(32'h0000_0514), .data(32'h0000_0001));     // clear and
    ////tb.poke_ocl(.addr(32'h0000_0518), .data(32'h0000_0001));     // set xor
    //tb.poke_ocl(.addr(32'h0000_05E8), .data(32'h0000_0000));     // clear done
	

	//$display("[%t] : Waiting for core command to complete.  ", $realtime);
    //   do begin
    //      #450ns;
    //   end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.garbler_sm_core_done_q);
  
	$display("[%t] : output1 read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_output1) );
	$display("[%t] : output2 read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_output2) );
	
    $display("[%t] : sm read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.garbler_sm_q) );


	$display("[%t] : output low addr read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q) );
	$display("[%t] : cmd_done read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	//$display("[%t] : cmd_done read data is: 0x%h ",

    //                    $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.garbler_sm_done) );
//	$display("[%t] : cmd_done read data is: 0x%h ",
//                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend01) );
//	$display("[%t] : cmd_done read data is: 0x%h ",
//                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend10) );
//	$display("[%t] : cmd_done read data is: 0x%h ",
//                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend11) );

//    $display(" [%t] : counter1 is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.counter1));
//    $display(" [%t] : counter2 is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.counter2));	
//    $display(" [%t] : counter3 is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.counter3));	
//    $display(" [%t] : counter4 is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.counter4));	
//    $display(" [%t] : counter5 is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.counter5));	
//
//    $display(" [%t] : gbr output   is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_output_ts_addr_arr));	
//    $display(" [%t] : gbr_sm_en_q   is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_sm_en_q));	
//    $display(" [%t] : and_valid_0   is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.and_valid_0_q));	
//    $display(" [%t] : and_valid_1   is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.and_valid_1_q));	
//    $display(" [%t] : xor_valid_0   is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.xor_valid_0_q));	
//
//    $display(" [%t] : and_valid_1   is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.xor_valid_1_q));	


//    $display(" [%t] : test_val is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.test_val));
//    $display(" [%t] : test_out is : 0x%h",
//                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.test_out));	





    $display(" [%t] : toSend01_0   is : 0x%h",
                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend01_0_q));	


    $display(" [%t] : toSend10_0   is : 0x%h",
                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend10_0_q));	


    $display(" [%t] : toSend11_0   is : 0x%h",
                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend11_0_q));	


    $display(" [%t] : toSend01_1   is : 0x%h",
                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend01_1_q));	


    $display(" [%t] : toSend10_1   is : 0x%h",
                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend10_1_q));	


    $display(" [%t] : toSend11_1   is : 0x%h",
                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend11_1_q));	

    $display(" [%t] : R value   is : 0x%h",
                            $realtime,(tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.R));	






	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2006));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2010));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;
	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2014));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;
	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2036));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2040));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;
	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2044));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;
	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2060));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2064));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2068));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_206C));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2070));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2074));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2078));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_207C));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2080));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2084));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2088));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_208C));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;
	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2090));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;
	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2094));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_209C));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;
	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20A0));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20A1));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20A2));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20A3));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20A4));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;
	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20A0));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;
	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20B0));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;
	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20C0));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;
	tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20D0));  // Set Low  Address
	$display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
				   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	#10ns;

	/*
	 tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2016));  // Set Low  Address

        $display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

        #10ns;

	 tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2026));  // Set Low  Address

        $display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

        #10ns;

	 tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_2036));  // Set Low  Address

        $display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

	#10ns;
			
	////////////////////////////////////////////////////////////////////////

	 //set addresses
        tb.poke_ocl(.addr(32'h0000_0520), .data(32'h0000_2006));  // Set addr 0
        tb.poke_ocl(.addr(32'h0000_0524), .data(32'h0000_2016));     // Set addr 1
        tb.poke_ocl(.addr(32'h0000_0540), .data(32'h0000_20C0));     // Set out addr
	tb.poke_ocl(.addr(32'h0000_0514), .data(32'h0000_0000));     // clear and
	tb.poke_ocl(.addr(32'h0000_0518), .data(32'h0000_0001));     // set xor
	tb.poke_ocl(.addr(32'h0000_05E8), .data(32'h0000_0000));     // clear done 

        $display("[%t] : Waiting for core command to complete.  ", $realtime);
       do begin
          #450ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.garbler_sm_core_done_q);

        $display("[%t] : output1 read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_output1) );
        $display("[%t] : output2 read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.gbr_output2) );
        $display("[%t] : output low addr read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q) );
        $display("[%t] : cmd_done read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
        $display("[%t] : cmd_done read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.garbler_sm_done) );
        $display("[%t] : cmd_done read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend01) );
        $display("[%t] : cmd_done read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend10) );
        $display("[%t] : cmd_done read data is: 0x%h ",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.toSend11) );


	        tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20C6));  // Set Low  Address
        tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR),  .data(32'h0000_0005)); // Issue Write Command


        $display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

        #10ns;

         tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20D6));  // Set Low  Address

        $display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

        #10ns;

	        tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20E6));  // Set Low  Address
        tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR),  .data(32'h0000_0005)); // Issue Write Command


        $display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

        #10ns;

         tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'h0000_20F6));  // Set Low  Address

        $display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

        #10ns;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//  ddr testbence
       // ------------------------------------
       // DDR A
       // ------------------------------------
       $display("[%t] : ******* DDR A *******", $realtime);

       // Set AXI Master Command Registers
       $display("[%t] : Setting DDRA Command Registers ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(32'h0000_0000));  // Set High Address -- DDR A
       tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(DDRA_LO_ADDR));  // Set Low  Address
       tb.poke_ocl(.addr(AXI_MSTR_CWDR_ADDR), .data(DDRA_DATA));     // Set Write Data
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR),  .data(32'h0000_0001)); // Issue Write Command

       // Wait for write command to complete
       $display("[%t] : Waiting for DDRA write command to complete.  ", $realtime);
       do begin
          #1000ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.garbler_sm_done);    //cmd_done_q
       $display("[%t] : DDRA write command completed.  ", $realtime);
	 $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	

	// ===========================================
	// my changes
	// ===========================================
	$display("[%t] : Setting DDRA Command Registers ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(32'h0000_0001));  // Set High Address -- DDR A
       tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'hA021_F704));  // Set Low  Address
       tb.poke_ocl(.addr(AXI_MSTR_CWDR_ADDR), .data(32'hB5B6_1B2B));     // Set Write Data
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR),  .data(32'h0000_0001)); // Issue Write Command

       // Wait for write command to complete
       $display("[%t] : Waiting for DDRA write command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA write command completed.  ", $realtime);
	 $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	 $display("[%t] : Setting DDRA Command Registers ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(32'h0000_0001));  // Set High Address -- DDR A
       tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'hA021_F708));  // Set Low  Address
       tb.poke_ocl(.addr(AXI_MSTR_CWDR_ADDR), .data(32'hC5C6_1C2C));     // Set Write Data
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR),  .data(32'h0000_0001)); // Issue Write Command

       // Wait for write command to complete
       $display("[%t] : Waiting for DDRA write command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA write command completed.  ", $realtime);
         $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

	 $display("[%t] : Setting DDRA Command Registers ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(32'h0000_0001));  // Set High Address -- DDR A
       tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'hA021_F704));  // Set Low  Address
       tb.poke_ocl(.addr(AXI_MSTR_CWDR_ADDR), .data(32'hD5D6_1D2D));     // Set Write Data
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR),  .data(32'h0000_0001)); // Issue Write Command

       // Wait for write command to complete
       $display("[%t] : Waiting for DDRA write command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA write command completed.  ", $realtime);
         $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(32'h0000_0001));  // Set High Address -- DDR A
       tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'hA021_F70C));  // Set Low  Address
       tb.poke_ocl(.addr(AXI_MSTR_CWDR_ADDR), .data(32'hE5E6_1E2E));     // Set Write Data
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR),  .data(32'h0000_0001)); // Issue Write Command

       // Wait for write command to complete
       $display("[%t] : Waiting for DDRA write command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA write command completed.  ", $realtime);
         $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

	tb.poke_ocl(.addr(AXI_MSTR_CWDR_ADDR), .data(32'h00000000));     // Set Write Data

	// ===========================================
        // my changes
        // ===========================================

	//tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(DDRA_LO_ADDR));  // Set Low  Address
	
	tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(32'h0000_0001));  // Set High Address -- DDR A
       tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'hA021_F700));  // Set Low  Address
       #40ns;
	$display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

	// Issue read transaction
       $display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
	
	 #40ns;
        $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	 tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(32'h0000_0001));  // Set High Address -- DDR A
       tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'hA021_F708));  // Set Low  Address

        // Issue read transaction
       $display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
        $display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

	 tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(32'h0000_0001));  // Set High Address -- DDR A
       tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'hA021_F704));  // Set Low  Address

        // Issue read transaction
       $display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
	
	  tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(32'h0000_0001));  // Set High Address -- DDR A
       tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(32'hA021_F70C));  // Set Low  Address
        // Issue read transaction
       $display("[%t] : Issuing DDRA read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRA read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRA read command completed.  ", $realtime);
        $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );

	
       // wait for dma transfers to complete
       timeout_count = 0;       
       do begin
          #10ns;
          timeout_count++;          
       end while ((status != 4'hf) && (timeout_count < 1000));
       
       if (timeout_count >= 1000) begin
          $display("[%t] : *** ERROR *** Timeout waiting for dma transfers from cl", $realtime);
          error_count++;
       end

       #1us;

       // Compare write and read data
       $display("[%t] : Comparing DDRA write and read data.  ", $realtime);
       $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
       if (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q[31:0] !== tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q[31:0]) begin
         $display("[%t] : *** ERROR *** Data mismatch, addr:0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q[31:0],
                                   tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q[31:0],
                                   tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q[31:0],
                                   tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q[31:0] );
         error_count++;
       end
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////
       // ------------------------------------
       // DDR B
       // ------------------------------------
       $display("[%t] : ******* DDR B *******", $realtime);

       // Set AXI Master Command Registers
       $display("[%t] : Setting DDRB Command Registers ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(DDRB_HI_ADDR));  // Set High Address -- DDR B
       tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(DDRB_LO_ADDR));  // Set Low  Address
       tb.poke_ocl(.addr(AXI_MSTR_CWDR_ADDR), .data(DDRB_DATA));     // Set Write Data
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR),  .data(32'h0000_0001)); // Issue Write Command

       // Wait for write command to complete
       $display("[%t] : DDRB write command completed.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRB write command completed.  ", $realtime);

       // Issue read transaction
       $display("[%t] : Issuing DDRB read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRB read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRB read command completed.  ", $realtime);

       // wait for dma transfers to complete
       timeout_count = 0;       
       do begin
          #10ns;
          timeout_count++;          
       end while ((status != 4'hf) && (timeout_count < 1000));
       
       if (timeout_count >= 1000) begin
          $display("[%t] : *** ERROR *** Timeout waiting for dma transfers from cl", $realtime);
          error_count++;
       end

       #1us;

       // Compare write and read data
       $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
       if (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q[31:0] !== tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q[31:0]) begin
         $display("[%t] : *** ERROR *** Data mismatch, addr:0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q[31:0],
                                   tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q[31:0],
                                   tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q[31:0],
                                   tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q[31:0] );
         error_count++;
       end

       // ------------------------------------
       // DDR C
       // ------------------------------------
       $display("[%t] : ******* DDR C *******", $realtime);

       // Set AXI Master Command Registers
       $display("[%t] : Setting DDRC Command Registers ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(DDRC_HI_ADDR));  // Set High Address -- DDR C
       tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(DDRC_LO_ADDR));  // Set Low  Address
       tb.poke_ocl(.addr(AXI_MSTR_CWDR_ADDR), .data(DDRC_DATA));     // Set Write Data
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR),  .data(32'h0000_0001)); // Issue Write Command

       // Wait for write command to complete
       $display("[%t] : Waiting for DDRC write command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRC write command completed.  ", $realtime);

       // Issue read transaction
       $display("[%t] : Issuing DDRC read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRC read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRC read command completed.  ", $realtime);

       // wait for dma transfers to complete
       timeout_count = 0;       
       do begin
          #10ns;
          timeout_count++;          
       end while ((status != 4'hf) && (timeout_count < 1000));
       
       if (timeout_count >= 1000) begin
          $display("[%t] : *** ERROR *** Timeout waiting for dma transfers from cl", $realtime);
          error_count++;
       end

       #1us;

       // Compare write and read data
       $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
       if (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q[31:0] !== tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q[31:0]) begin
         $display("[%t] : *** ERROR *** Data mismatch, addr:0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q[31:0],
                                   tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q[31:0],
                                   tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q[31:0],
                                   tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q[31:0] );
         error_count++;
       end

       // ------------------------------------
       // DDR D
       // ------------------------------------
       $display("[%t] : ******* DDR D *******", $realtime);

       // Set AXI Master Command Registers
       $display("[%t] : Setting DDRD Command Registers ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CAHR_ADDR), .data(DDRD_HI_ADDR));  // Set High Address -- DDR D
       tb.poke_ocl(.addr(AXI_MSTR_CALR_ADDR), .data(DDRD_LO_ADDR));  // Set Low  Address
       tb.poke_ocl(.addr(AXI_MSTR_CWDR_ADDR), .data(DDRD_DATA));     // Set Write Data
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR),  .data(32'h0000_0001)); // Issue Write Command

       // Wait for write command to complete
       $display("[%t] : Waiting for DDRD write command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRD write command completed.  ", $realtime);

       // Issue read transaction
       $display("[%t] : Issuing DDRD read command.  ", $realtime);
       tb.poke_ocl(.addr(AXI_MSTR_CCR_ADDR), .data(32'h0000_0005)); // Issue Read Command

       // Wait for read command to complete
       $display("[%t] : Waiting for DDRD read command to complete.  ", $realtime);
       do begin
          #10ns;
       end while (!tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_done_q);
       $display("[%t] : DDRD read command completed.  ", $realtime);

       // wait for dma transfers to complete
       timeout_count = 0;       
       do begin
          #10ns;
          timeout_count++;          
       end while ((status != 4'hf) && (timeout_count < 1000));
       
       if (timeout_count >= 1000) begin
          $display("[%t] : *** ERROR *** Timeout waiting for dma transfers from cl", $realtime);
          error_count++;
       end

       #1us;

       // Compare write and read data
       $display("[%t] : addr: 0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q),
                                   (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q) );
       if (tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q[31:0] !== tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q[31:0]) begin
         $display("[%t] : *** ERROR *** Data mismatch, addr:0x%0h_%0h write data is: 0x%h read data is: 0x%h",
                        $realtime, tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_hi_q[31:0],
                                   tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_addr_lo_q[31:0],
                                   tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_wr_data_q[31:0],
                                   tb.card.fpga.CL.CL_DRAM_DMA_AXI_MSTR.cmd_rd_data_q[31:0] );
         error_count++;
       end
	*/
       // Power down
       #500ns;
       tb.power_down();

       //---------------------------
       // Report pass/fail status
       //---------------------------
       $display("[%t] : Checking total error count...", $realtime);
       if (error_count > 0) begin
         fail = 1;
       end
       $display("[%t] : Detected %3d errors during this test", $realtime, error_count);

       if (fail || (tb.chk_prot_err_stat())) begin
         $display("[%t] : *** TEST FAILED ***", $realtime);
       end else begin
         $display("[%t] : *** TEST PASSED ***", $realtime);
       end

       $finish;
    end // initial begin

endmodule // test_dram_dma
   
