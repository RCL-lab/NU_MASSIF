import argparse

#
# create vhdl file
#
#def file_create(name):
#    vhdl_file = open("gc_comp_gen.vhdl","w")
#    return 
#
# indent funtion
#
INDENT_STRING = " "
#INDENT_STRING = " "
def indent(s,num):
    '''Add indentation to a string'''
    z = num * INDENT_STRING
    lastline = False
    if s[-1]=="\n":
        s = s[:-1]
        lastline = True
    s = z + s
    s = s.replace("\n","\n"+z)
    if lastline:
        s = s + "\n"
    return s

def create_assign_wb(and_gates, xor_gates):
    main_str ="assign data_write_back_q = " 
    for i in range(0,and_gates):
        if(i != 0):
            main_str +=" "*27
        main_str +="(gbr_sm_en_q[{0}] == 1'b1 & garbler_sm_{0}_collect)?    \n\
                           {{384'b0, Gc_{0}_q[79:0], 48'b0}} : \n\
                           (gbr_sm_en_q[{0}] == 1'b1 & garbler_sm_{0}_collect_ts01)?\n\
                           {{384'b0, toSend01_{0}_q[79:0],48'b0}}: \n\
                           (gbr_sm_en_q[{0}] == 1'b1 & garbler_sm_{0}_collect_ts10)?\n\
                           {{384'b0, toSend10_{0}_q[79:0],48'b0}}: \n\
                           (gbr_sm_en_q[{0}] == 1'b1 & garbler_sm_{0}_collect_ts11)?\n\
                           {{384'b0, toSend11_{0}_q[79:0],48'b0}}: \n".format(i)
    for i in range(0,xor_gates):
        main_str +=" "*27
        main_str +="(gbr_sm_en_q[{0}] == 1'b1 & garbler_sm_{0}_collect)?    \n\
                           {{384'b0, Gc_xor_out_{1}[79:0], 48'b0}} :".format((i + and_gates),i)
        if(i < xor_gates-1):
            main_str +="\n"
    main_str +=" 512'b0;\n"
    return main_str

def create_inst( num_of_and,num_of_xor):
    main_str=''
    for i in range(0, num_of_and):
        main_str +="\n\
assign and_valid_{0}_q = garbler_sm_{0}_valid & gbr_sm_en_q[{0}] == 1'b1;\n".format(i)
    for i in range(0, num_of_xor):
        main_str +="\n\
assign xor_valid_{0}_q = garbler_sm_{1}_valid & gbr_sm_en_q[{1}] == 1'b1;\n"\
    .format(i,num_of_and + i)

    for i in range(0,num_of_and):
        main_str+="\n\
garbler_and  GARBLER_AND_INST{0}(\n\
.clk(aclk),\n\
.reset_n(garble_and_aresetn),           //should be as garble_and_aresetn\n\
.input_valid(and_valid_{0}_q),\n\
.R(R),\n\
.Ga(Ga_{0}_q),   ///Ga_q  80'hc6179d4cde33a0efea38\n\
.Gb(Gb_{0}_q),   ///Gb_q  80'h09f8ca84831c624e73e7\n\
.g_id({{32\'b0, gate_id_q{0}[31:0]}}),\n\
.output_valid(output_valid_{0}_q),\n\
.ready(),\n\
.Gc(Gc_{0}_q),\n\
.toSend01(toSend01_{0}_q),\n\
.toSend10(toSend10_{0}_q),\n\
.toSend11(toSend11_{0}_q)\n\
);\n".format(i)

    for i in range(0,num_of_xor):
        main_str+="\n\
xor_gate XOR_GATE_INST{0}(\n\
.Ga(Ga_{1}_q),\n\
.Gb(Gb_{1}_q),\n\
.aclk(aclk),\n\
.aresetn(garble_and_aresetn),\n\
.input_valid(xor_valid_{0}_q),\n\
.Gc_xor_out(Gc_xor_out_{0})\n\
);\n".format(i,i+num_of_xor)
 
    return main_str



def create_dec_inputs(num_of_gates):
    main_str="assign garble_and_aresetn = aresetn & (garbler_sm_q != GABLER_SM_RESET);\n"
    for i in range(0,num_of_gates):
        main_str +="\n\
assign Ga_{0}_ns[79:0] =\n\
(garbler_sm_{0}_ga_ld_bram_done) ?\n\
                                        (bram_qb_rd[79:0]) : \n\
(garbler_sm_{0}_ga_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? \n\
                                        (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Ga_{0}_q[79:0];\n\
\n\
always_ff @(posedge aclk)\n\
        if(!aresetn) begin\n\
                Ga_{0}_q[79:0] <= 80'h0;\n\
        end\n\
        else begin\n\
                Ga_{0}_q[79:0] <= Ga_{0}_ns[79:0];\n\
        end\n\
\n\
assign Gb_{0}_ns[79:0] = \n\
(garbler_sm_{0}_gb_ld_bram_done) ?\n\
                                        (bram_qb_rd[79:0]) :\n\
(garbler_sm_{0}_gb_ld & axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) ? \n\
                                        (cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) :  Gb_{0}_q[79:0];\n\
\n\
always_ff @(posedge aclk)\n\
        if(!aresetn) begin\n\
                Gb_{0}_q[79:0] <= 80'h0;\n\
        end\n\
        else begin\n\
                Gb_{0}_q[79:0] <= Gb_{0}_ns[79:0];\n\
        end\n".format(i)
    return main_str

# create signal
def create_signals(and_gates, xor_gates):
    num_of_gates = and_gates + xor_gates 

    gate_signals_str ="logic garbler_sm_reset;\n\
logic garbler_sm_idle;\n"
    for i in range(0,num_of_gates):
        gate_signals_str +="\n\
logic garbler_sm_{0}_ga_arld;\n\
logic garbler_sm_{0}_ga_ld;\n\
logic garbler_sm_{0}_ga_arld_bram;\n\
logic garbler_sm_{0}_ga_ld_bram;\n\
logic garbler_sm_{0}_ga_ld_bram_done;\n\
logic garbler_sm_{0}_gb_arld;\n\
logic garbler_sm_{0}_gb_ld;\n\
logic garbler_sm_{0}_gb_arld_bram;\n\
logic garbler_sm_{0}_gb_ld_bram;\n\
logic garbler_sm_{0}_gb_ld_bram_done;\n\
logic garbler_sm_{0}_valid;\n\
logic garbler_sm_{0}_proc;\n\
logic garbler_sm_{0}_done;\n\
logic garbler_sm_{0}_collect;\n\
logic garbler_sm_{0}_collect_bram;\n".format(i)
        if(i < and_gates):
            gate_signals_str +="\
logic garbler_sm_{0}_collect_done;\n\
logic garbler_sm_{0}_collect_ts01;\n\
logic garbler_sm_{0}_collect_ts01_bram;\n\
logic garbler_sm_{0}_collect_ts01_done;\n\
logic garbler_sm_{0}_collect_ts10;\n\
logic garbler_sm_{0}_collect_ts10_bram;\n\
logic garbler_sm_{0}_collect_ts10_done;\n\
logic garbler_sm_{0}_collect_ts11;\n\
logic garbler_sm_{0}_collect_ts11_bram;\n".format(i)

    gbr_out_signals= ""
    for i in range(0,and_gates):
        gbr_out_signals +="\n\
logic [31:0]gbr_{0}_output_ts01;\n\
logic [31:0]gbr_{0}_output_ts10;\n\
logic [31:0]gbr_{0}_output_ts11;\n".format(i)

    valid_signals ="\nlogic "
    for i in range(0,num_of_gates):
       valid_signals +="input_valid_{0}_q, output_valid_{0}_q".format(i)
       if(i == num_of_gates - 1):
           valid_signals +=";\n"
       else:
           valid_signals +=",\n      "

    Ga_signals ="\nlogic [79:0] "
    for i in range(0,num_of_gates):
        Ga_signals +="Ga_{0}_q, Ga_{0}_ns".format(i)
        if(i == num_of_gates - 1):
            Ga_signals +=";\n"
        else:
            Ga_signals +=", "
    
    Gb_signals ="\nlogic [79:0] "
    for i in range(0,num_of_gates):
        Gb_signals +="Gb_{0}_q, Gb_{0}_ns".format(i)
        if(i == num_of_gates - 1):
            Gb_signals +=";\n"
        else:
            Gb_signals +=", "

    Gc_signals ="\nlogic [79:0] "
    for i in range(0,and_gates):
        Gc_signals +="Gc_{0}_q".format(i)
        if(i == and_gates  - 1):
            Gc_signals +=";\n"
        else:
            Gc_signals +=", "
    Gc_xor_signals ="\nlogic [79:0] "
    for i in range(0,xor_gates):
        Gc_xor_signals +="Gc_xor_out_{0}".format(i)
        if(i == xor_gates - 1):
            Gc_xor_signals +=";\n"
        else:
            Gc_xor_signals +=", "
    
    toSend_signals ="\nlogic [79:0] "
    for i in range(0,and_gates):
        toSend_signals +="toSend01_{0}_q, toSend10_{0}_q, toSend11_{0}_q".format(i)
        if(i == and_gates - 1):
            toSend_signals +=";\n"
        else:
            toSend_signals +=",\n             "
    
    gate_id_signals="\nlogic [31:0] "
    for i in range(0,and_gates ):
       gate_id_signals +="gate_id_q{0} ".format(i)
       if(i == and_gates- 1):
           gate_id_signals +=";\n"
       else:
           if (i+1)%4 == 0:
               gate_id_signals +=",\n      "
           else:
               gate_id_signals +=", "

    and_valid = "\nlogic "

    for i in range(0,and_gates ):
       and_valid +="and_valid_{0}_q ".format(i)
       if(i == and_gates- 1):
           and_valid +=";\n"
       else:
           if (i+1)%4 == 0:
               and_valid +=",\n      "
           else:
               and_valid +=", "
    
    xor_valid = "\nlogic "

    for i in range(0,and_gates ):
       xor_valid +="xor_valid_{0}_q ".format(i)
       if(i == and_gates- 1):
           xor_valid +=";\n"
       else:
           if (i+1)%4 == 0:
               xor_valid +=",\n      "
           else:
               xor_valid +=", "
    Gbr_input=    "logic [31:0] gbr_input_addr_arr     [{0}:0];\n".format(2*num_of_gates-1)
    Gbr_output=   "logic [31:0] gbr_output_addr_arr    [{0}:0];\n".format(num_of_gates-1)
    Gbr_output_ts="logic [31:0] gbr_output_ts_addr_arr [{0}:0];\n".format(and_gates*3-1)
    return gbr_out_signals  + gate_signals_str + valid_signals +\
            Ga_signals + Gb_signals +Gc_signals+ toSend_signals\
            + gate_id_signals + Gc_xor_signals + and_valid +xor_valid\
            + Gbr_input + Gbr_output + Gbr_output_ts

def create_bram_write_read(and_gates, xor_gates):
    num_of_gates=and_gates+xor_gates
    main_str="\n\
always_ff @(posedge aclk)\n\
begin \n\
 if (!aresetn) begin\n\
     bram_addrb_rd <=32'h00000000;\n\
 end\n\
\n"
# Gc output
    for i in range(0,and_gates):
        main_str +="\
 else if(garbler_sm_{0}_collect_bram) begin\n\
     bram_addra_wr <= gbr_output_addr_arr[{0}][30:0];\n\
     bram_da_wr    <= Gc_{0}_q;\n\
 end\n".format(i)
 #xor gates
    for i in range(0,xor_gates):
        main_str +="\
 else if(garbler_sm_{0}_collect_bram) begin\n\
     bram_addra_wr <= gbr_output_addr_arr[{0}][30:0];\n\
     bram_da_wr    <= Gc_xor_out_{1};\n\
 end\n".format(i+and_gates,i)
    for i in range(0,and_gates):
        main_str+="\
 else if(garbler_sm_{0}_collect_ts01_bram) begin\n\
     bram_addra_wr <= gbr_output_ts_addr_arr[{1}][30:0];\n\
     bram_da_wr    <= toSend01_{0}_q;\n\
 end\n\
 else if(garbler_sm_{0}_collect_ts10_bram) begin\n\
     bram_addra_wr <= gbr_output_ts_addr_arr[{2}][30:0];\n\
     bram_da_wr    <= toSend10_{0}_q;\n\
 end\n\
 else if(garbler_sm_{0}_collect_ts11_bram) begin\n\
     bram_addra_wr <= gbr_output_ts_addr_arr[{3}][30:0];\n\
     bram_da_wr    <= toSend11_{0}_q;\n\
 end\n".format(i,3*i,3*i+1,3*i+2)
    for i in range(0,num_of_gates):
        main_str+="\
 else if( garbler_sm_{0}_ga_arld_bram)\n\
    bram_addrb_rd <= gbr_input_addr_arr[{1}][30:0];\n\
 else if( garbler_sm_{0}_gb_arld_bram)\n\
    bram_addrb_rd <= gbr_input_addr_arr[{2}][30:0];\n".format(i,2*i,2*i+1)
    main_str+="\
end\n"
    return main_str


def create_gate_id(and_gates):
    val = 16384
    main_str =""
    for i in range(0,and_gates):
        hx_str = hex(val)[2:].upper()
        main_str +="\n\
always_ff @(posedge aclk)\n\
    if (!aresetn) begin\n\
        gate_id_q{0} <= 32'h0000_0000;\n\
    end\n\
    else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 16'h{hx_str})) begin\n\
        gate_id_q{0} <= cfg_wdata_q[31:0];\n\
    end\n\
    else begin\n\
        gate_id_q{0} <= gate_id_q{0};\n\
    end\n".format(i,hx_str = hx_str)
        val = val + 4

    return main_str


def create_cmd_go(and_gates,num_of_gates):
    
    cmd_go_str = "\n\
always_ff @(posedge aclk)\n\
      if (!aresetn) begin\n\
         cmd_go_q <= 1'b0;\n\
      end\n\
      else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CCR_ADDR)) begin\n\
         cmd_go_q <= cfg_wdata_q[0];\n\
      end\n\
          else if ("
    for i in range(0,num_of_gates):
        cmd_go_str += "garbler_sm_{0}_ga_arld | garbler_sm_{0}_gb_arld | garbler_sm_{0}_done ".format(i)
        
        if(i < and_gates) :
            cmd_go_str += "|\n                   garbler_sm_{0}_collect_done|garbler_sm_{0}_collect_ts01_done | garbler_sm_{0}_collect_ts10_done ".format(i)
                      
        if(i == num_of_gates - 1):
            cmd_go_str +=") begin\n           "
        else:
            cmd_go_str +="|\n                   "

    cmd_go_str +="cmd_go_q <= 1'b1;\n\
          end\n\
      else begin\n\
         cmd_go_q <= cmd_go_q & ~axi_mstr_sm_idle;\n\
      end\n"
    return cmd_go_str

def create_cmd_done(and_gates, num_of_gates):
    cmd_done_str ="assign cmd_done_ns = cmd_done_q | (axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid) |\n\
                                  (axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid) ;\n"
    cmd_done_str +="\n\
always_ff @(posedge aclk)\n\
  if (!aresetn) begin\n\
     cmd_done_q <= 1'b0;\n\
  end \n\
  else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CCR_ADDR)) begin\n\
     cmd_done_q <= cfg_wdata_q[1];\n\
  end\n\
        else if ("
    for i in range(0,num_of_gates):
        cmd_done_str += "garbler_sm_{0}_ga_arld | garbler_sm_{0}_gb_arld | garbler_sm_{0}_done ".format(i)
        if(i < and_gates) :
            cmd_done_str += "|\n                 garbler_sm_{0}_collect_done|garbler_sm_{0}_collect_ts01_done | garbler_sm_{0}_collect_ts10_done ".format(i)
                      
        if(i == num_of_gates - 1):
            cmd_done_str +=") begin\n           "
        else:
            cmd_done_str +="|\n                 "

             
    cmd_done_str +="cmd_done_q <= 1'b0;\n\
      end\n\
  else begin\n\
     cmd_done_q <= cmd_done_ns;\n\
  end\n"

    return cmd_done_str

def create_cmd_rw(and_gates, num_of_gates):
    cmd_rw_str="\n\
always_ff @(posedge aclk)\n\
  if (!aresetn) begin\n\
     cmd_rd_wrb_q <= 1'b0;\n\
  end\n\
  else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CCR_ADDR)) begin\n\
     cmd_rd_wrb_q <= cfg_wdata_q[2];\n\
  end\n\
  else if ("
    for i in range(0,num_of_gates):
        cmd_rw_str += "garbler_sm_{0}_ga_arld | garbler_sm_{0}_gb_arld ".format(i)
        if(i == num_of_gates - 1):
            cmd_rw_str +=") begin\n           "
        else:
            cmd_rw_str +="|\n           "


    cmd_rw_str += "cmd_rd_wrb_q <= 1'b1;\n\
  end\n\
   else if ("
    for i in range(0, and_gates):
        cmd_rw_str +="garbler_sm_{0}_collect_done|garbler_sm_{0}_collect_ts01_done | garbler_sm_{0}_collect_ts10_done".format(i) 
        #if((i+1)%3 == 0):
        cmd_rw_str +="|\n            "
        #else:
        #    cmd_rw_str +="| "
    for i in range(0, num_of_gates):
        
        cmd_rw_str += "garbler_sm_{0}_done".format(i)
        if(i == num_of_gates -1):
            cmd_rw_str +=") begin\n           "
        else:
            if((i+1)%4 == 0):
                cmd_rw_str +="|\n            "
            else:
                cmd_rw_str +="| "
            
    cmd_rw_str +="cmd_rd_wrb_q <= 1'b0;\n\
  end\n\
  else begin\n\
     cmd_rd_wrb_q <= cmd_rd_wrb_q;\n\
  end\n"
    return cmd_rw_str

def create_axi_sm_flop():
    main_str ="\n\
always_ff @(posedge aclk)\n\
  if (!aresetn) begin\n\
     garbler_sm_q[{bit_size0}:0] <= {bit_size}'h0;\n\
  end\n\
  else begin\n\
     garbler_sm_q[{bit_size0}:0] <= garbler_sm_ns[{bit_size0}:0];\n\
  end\n".format(bit_size0 =bit_size -1,bit_size=bit_size)
    return main_str

def create_cmd_addr_low(and_gates, num_of_gates):
    main_str="\n\
always_ff @(posedge aclk)\n\
  if (!aresetn) begin\n\
     cmd_addr_lo_q[31:0] <= 32'h0000_0000;\n\
  end\n\
  else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CALR_ADDR)) begin\n\
     cmd_addr_lo_q[31:0] <= cfg_wdata_q[31:0];\n\
  end"
    for i in range(0,num_of_gates):
        main_str +="\n\
  else if (garbler_sm_{i}_ga_arld) begin\n\
         cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[{val1}];\n\
  end\n\
  else if (garbler_sm_{i}_gb_arld) begin\n\
         cmd_addr_lo_q[31:0] <= gbr_input_addr_arr[{val2}];\n\
  end\n".format(i=i,val1 = i*2, val2 = (i*2)+1) 
  
    for i in range(0,num_of_gates):
        main_str +="\n\
  else if (garbler_sm_{i}_done) begin\n\
         cmd_addr_lo_q[31:0] <= gbr_output_addr_arr[{val}];\n\
  end\n".format(i=i,val = i)
  
    for i in range(0,and_gates):
        main_str +="\n\
  else if (garbler_sm_{i}_collect_done) begin\n\
         cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[{val1}];\n\
  end\n\
  else if (garbler_sm_{i}_collect_ts01_done) begin\n\
         cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[{val2}];\n\
  end\n\
  else if (garbler_sm_{i}_collect_ts10_done) begin\n\
         cmd_addr_lo_q[31:0] <= gbr_output_ts_addr_arr[{val3}];\n\
  end\n".format(i=i,val1 = i*3, val2=(i*3)+1, val3=(i*3)+2)

    main_str +="\n\
  else begin\n\
     cmd_addr_lo_q[31:0] <= cmd_addr_lo_q[31:0];\n\
  end\n"
    return main_str

def create_assign(and_gates, num_of_gates):
    main_str ="\n\
assign garbler_sm_idle = (garbler_sm_q[15:0] == GABLER_SM_IDLE);\n\
assign garbler_sm_reset = (garbler_sm_q[15:0] == GABLER_SM_RESET);\n"
    for i in range(0,num_of_gates):
        main_str +="\n\
assign garbler_sm_{0}_ga_arld           = (garbler_sm_q[15:0]  == GABLER_SM_{0}_GA_ARLD);\n\
assign garbler_sm_{0}_ga_ld             = (garbler_sm_q[15:0]  == GABLER_SM_{0}_GA_LD);\n\
assign garbler_sm_{0}_ga_arld_bram      = (garbler_sm_q[15:0]  == GABLER_SM_{0}_GA_ARLD_BRAM);\n\
assign garbler_sm_{0}_ga_ld_bram        = (garbler_sm_q[15:0]  == GABLER_SM_{0}_GA_LD_BRAM);\n\
assign garbler_sm_{0}_ga_ld_bram_done   = (garbler_sm_q[15:0]  == GABLER_SM_{0}_GA_LD_BRAM_DONE);\n\
assign garbler_sm_{0}_gb_arld           = (garbler_sm_q[15:0]  == GABLER_SM_{0}_GB_ARLD);\n\
assign garbler_sm_{0}_gb_ld             = (garbler_sm_q[15:0]  == GABLER_SM_{0}_GB_LD);\n\
assign garbler_sm_{0}_gb_arld_bram      = (garbler_sm_q[15:0]  == GABLER_SM_{0}_GB_ARLD_BRAM);\n\
assign garbler_sm_{0}_gb_ld_bram        = (garbler_sm_q[15:0]  == GABLER_SM_{0}_GB_LD_BRAM);\n\
assign garbler_sm_{0}_gb_ld_bram_done   = (garbler_sm_q[15:0]  == GABLER_SM_{0}_GB_LD_BRAM_DONE);\n\
assign garbler_sm_{0}_valid             = (garbler_sm_q[15:0]  == GABLER_SM_{0}_VALID);\n\
assign garbler_sm_{0}_proc              = (garbler_sm_q[15:0]  == GABLER_SM_{0}_PROC);\n\
assign garbler_sm_{0}_done              = (garbler_sm_q[15:0]  == GABLER_SM_{0}_DONE);\n\
assign garbler_sm_{0}_collect           = (garbler_sm_q[15:0]  == GABLER_SM_{0}_COLLECT);\n\
assign garbler_sm_{0}_collect_bram      = (garbler_sm_q[15:0]  == GABLER_SM_{0}_COLLECT_BRAM);\n".format(i)

        if(i < and_gates):
            main_str += "\n\
assign garbler_sm_{0}_collect_done      = (garbler_sm_q[15:0] == GABLER_SM_{0}_COLLECT_DONE);\n\
assign garbler_sm_{0}_collect_ts01      = (garbler_sm_q[15:0] == GABLER_SM_{0}_COLLECT_TS01);\n\
assign garbler_sm_{0}_collect_ts01_bram = (garbler_sm_q[15:0] == GABLER_SM_{0}_COLLECT_TS01_BRAM);\n\
assign garbler_sm_{0}_collect_ts01_done = (garbler_sm_q[15:0] == GABLER_SM_{0}_COLLECT_TS01_DONE);\n\
assign garbler_sm_{0}_collect_ts10      = (garbler_sm_q[15:0] == GABLER_SM_{0}_COLLECT_TS10);\n\
assign garbler_sm_{0}_collect_ts10_bram = (garbler_sm_q[15:0] == GABLER_SM_{0}_COLLECT_TS10_BRAM);\n\
assign garbler_sm_{0}_collect_ts10_done = (garbler_sm_q[15:0] == GABLER_SM_{0}_COLLECT_TS10_DONE);\n\
assign garbler_sm_{0}_collect_ts11      = (garbler_sm_q[15:0] == GABLER_SM_{0}_COLLECT_TS11);\n\
assign garbler_sm_{0}_collect_ts11_bram = (garbler_sm_q[15:0] == GABLER_SM_{0}_COLLECT_TS11_BRAM);\n\
".format(i)
    return main_str

#
# put indentation
#
def indent_tab(num_of_tabs):
    ''' put indentation'''
    for i in range(0,num_of_tabs):
        vhdl_file.write("\t")
    return

def preamble(num_of_gates):
    vhdl_file.write( "%d" %num_of_gates)
    return

#
# generate state type
#
#def create_state_type(num_of_gates,name):
#    ''' generate state type'''
#    state_type_str = "type %s is (" %(name) + "S0,"
#    for i in range(1,num_of_gates+1):
#        state_type_str += "\n\t S%s_P0,S%s_P0_LBRAM,S%s_P0_LDDR,S%s_P1,S%s_P1_LBRAM,S%s_P1_LDDR,"\
#                %(i,i,i,i,i,i)
#    for i in range(1,num_of_gates+1):
#        if i != num_of_gates:
#            state_type_str += "\n\t WS_%s,WS_%s_1,WS_%s_2,"%(i,i,i)
#        else:
#            state_type_str += "\n\t WS_%s,WS_%s_1,WS_%s_2"%(i,i,i)
#    state_type_str += ");"
#    return state_type_str
def create_state_type(and_gates,xor_gates,bit_size = 16):
    ''' generate typedef for states'''
    #bit_size = 4;
    num = 0
    state_type_str ="typedef enum logic[{bit_size0}:0] {{ \n\
                GABLER_SM_IDLE                           = {bit_size}'d0,\n".format(bit_size0 = bit_size-1,bit_size=bit_size)
    for i in range(0, and_gates):
        kwargs = dict([('num%d'%k,k+num) for k in range(1,26)])
        kwargs['bit_size'] = bit_size
        kwargs['S_No'] = i
        state_type_str +="\n\
                GABLER_SM_{S_No}_PREP              = {bit_size}'d{num1},\n\
                GABLER_SM_{S_No}_GA_ARLD           = {bit_size}'d{num2},\n\
                GABLER_SM_{S_No}_GA_LD             = {bit_size}'d{num3},\n\
                GABLER_SM_{S_No}_GA_ARLD_BRAM      = {bit_size}'d{num4},\n\
                GABLER_SM_{S_No}_GA_LD_BRAM        = {bit_size}'d{num5},\n\
                GABLER_SM_{S_No}_GA_LD_BRAM_DONE   = {bit_size}'d{num6},\n\
                GABLER_SM_{S_No}_GB_ARLD           = {bit_size}'d{num7},\n\
                GABLER_SM_{S_No}_GB_LD             = {bit_size}'d{num8},\n\
                GABLER_SM_{S_No}_GB_ARLD_BRAM      = {bit_size}'d{num9},\n\
                GABLER_SM_{S_No}_GB_LD_BRAM        = {bit_size}'d{num10},\n\
                GABLER_SM_{S_No}_GB_LD_BRAM_DONE   = {bit_size}'d{num11},\n\
                GABLER_SM_{S_No}_VALID             = {bit_size}'d{num12},\n\
                GABLER_SM_{S_No}_PROC              = {bit_size}'d{num13},\n\
                GABLER_SM_{S_No}_DONE              = {bit_size}'d{num14},\n\
                GABLER_SM_{S_No}_COLLECT           = {bit_size}'d{num15},\n\
                GABLER_SM_{S_No}_COLLECT_BRAM      = {bit_size}'d{num16},\n\
                GABLER_SM_{S_No}_COLLECT_DONE      = {bit_size}'d{num17},\n\
                GABLER_SM_{S_No}_COLLECT_TS01      = {bit_size}'d{num18},\n\
                GABLER_SM_{S_No}_COLLECT_TS01_BRAM = {bit_size}'d{num19},\n\
                GABLER_SM_{S_No}_COLLECT_TS01_DONE = {bit_size}'d{num20},\n\
                GABLER_SM_{S_No}_COLLECT_TS10      = {bit_size}'d{num21},\n\
                GABLER_SM_{S_No}_COLLECT_TS10_BRAM = {bit_size}'d{num22},\n\
                GABLER_SM_{S_No}_COLLECT_TS10_DONE = {bit_size}'d{num23},\n\
                GABLER_SM_{S_No}_COLLECT_TS11      = {bit_size}'d{num24},\n\
                GABLER_SM_{S_No}_COLLECT_TS11_BRAM = {bit_size}'d{num25},\n".format(**kwargs)
                #GABLER_SM_{S_No}_COLLECT_TS11_BRAM            = {bit_size}'d{num12},\n\
                #GABLER_SM_{S_No}_COLLECT_TS11_BRAM_DONE            = {bit_size}'d{num12},\n\

        num = num + 25
    for i in range(and_gates, xor_gates+and_gates):
        kwargs = dict([('num%d'%k,k+num) for k in range(1,17)])
        kwargs['bit_size'] = bit_size
        kwargs['S_No'] = i
        state_type_str +="\n\
                GABLER_SM_{S_No}_PREP            = {bit_size}'d{num1},\n\
                GABLER_SM_{S_No}_GA_ARLD         = {bit_size}'d{num2},\n\
                GABLER_SM_{S_No}_GA_LD           = {bit_size}'d{num3},\n\
                GABLER_SM_{S_No}_GA_ARLD_BRAM    = {bit_size}'d{num4},\n\
                GABLER_SM_{S_No}_GA_LD_BRAM      = {bit_size}'d{num5},\n\
                GABLER_SM_{S_No}_GA_LD_BRAM_DONE = {bit_size}'d{num6},\n\
                GABLER_SM_{S_No}_GB_ARLD         = {bit_size}'d{num7},\n\
                GABLER_SM_{S_No}_GB_LD           = {bit_size}'d{num8},\n\
                GABLER_SM_{S_No}_GB_ARLD_BRAM    = {bit_size}'d{num9},\n\
                GABLER_SM_{S_No}_GB_LD_BRAM      = {bit_size}'d{num10},\n\
                GABLER_SM_{S_No}_GB_LD_BRAM_DONE = {bit_size}'d{num11},\n\
                GABLER_SM_{S_No}_VALID           = {bit_size}'d{num12},\n\
                GABLER_SM_{S_No}_PROC            = {bit_size}'d{num13},\n\
                GABLER_SM_{S_No}_DONE            = {bit_size}'d{num14},\n\
                GABLER_SM_{S_No}_COLLECT         = {bit_size}'d{num15},\n\
                GABLER_SM_{S_No}_COLLECT_BRAM    = {bit_size}'d{num16},\n".format(**kwargs)

        num = num + 16
    state_type_str +="\n\
                GABLER_SM_RESET                          = {bit_size}'d{num} }} garbler_sm_states;\n".format(bit_size= bit_size,num=num+1)

                        
    return state_type_str

def create_states(and_gates,num_of_gates,bit_size=16):
    ''' create states'''
    state_str ="\n always_comb begin \n\
     // Default\n\
     garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_IDLE;\n\
\n\
     case (garbler_sm_q[{bit_size0}:0]) \n\
                GABLER_SM_IDLE: begin \n\
                if(gbr_sm_en_q[31:0] != 32'b0 & ~garbler_sm_core_done_q)   garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_0_PREP;\n\
                else                                                       garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_IDLE;\n\
                end\n".format(bit_size0 =bit_size-1)

    for i in range(0,num_of_gates):
        S_No = i
        if i == (num_of_gates - 1):
            NS_string ="                                                    garbler_sm_ns[{bit_size0}:0] = GABLER_SM_0_PROC;".format(bit_size0=bit_size-1)
            prep_string="else                                   garbler_sm_ns[{bit_size0}:0] = GABLER_SM_0_PROC;\n".format(bit_size0=bit_size-1)
        else:
            NS_string ="                                                    garbler_sm_ns[{bit_size0}:0] = GABLER_SM_{NS_No}_PREP;".format(bit_size0=bit_size-1,NS_No=S_No+1)
            prep_string="else                                   garbler_sm_ns[{bit_size0}:0] = GABLER_SM_{NS_No}_PREP;\n".format(NS_No = i+1,bit_size0=bit_size-1)
        
        state_str += "// state machine {S_No} laod \n\
                GABLER_SM_{S_No}_PREP: begin\n\
                        if(gbr_sm_en_q[{S_No}] == 1'b1)\n\
                            if(gbr_input_addr_arr[{i_addr}][31])                    garbler_sm_ns[{bit_size0}:0] = GABLER_SM_{S_No}_GA_ARLD_BRAM;\n\
                            else                                            garbler_sm_ns[{bit_size0}:0] = GABLER_SM_{S_No}_GA_ARLD;\n\
                        {prep_string}\n\
                end \n\
                \n\
                GABLER_SM_{S_No}_GA_ARLD: begin \n\
                                                                            garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_GA_LD;\n\
                end\n\
                \n\
                GABLER_SM_{S_No}_GA_LD: begin\n\
                        if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    \n\
                            if(gbr_input_addr_arr[{ni_addr}][31])                    garbler_sm_ns[{bit_size0}:0] = GABLER_SM_{S_No}_GB_ARLD_BRAM;\n\
                            else                                            garbler_sm_ns[{bit_size0}:0] = GABLER_SM_{S_No}_GB_ARLD;\n\
                        else                                                garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_GA_LD;\n\
                end             \n\
                GABLER_SM_{S_No}_GA_ARLD_BRAM: begin \n\
                                                                            garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_GA_LD_BRAM;\n\
                end\n\
                GABLER_SM_{S_No}_GA_LD_BRAM: begin \n\
                                                                            garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_GA_LD_BRAM_DONE;\n\
                end\n\
        \n\
                GABLER_SM_{S_No}_GA_LD_BRAM_DONE:begin\n\
                    if(gbr_input_addr_arr[{ni_addr}][31])\n\
                                                                             garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_GB_ARLD_BRAM;\n\
                    else                                                     garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_GB_ARLD;\n\
                end                   \n\
\n\
                GABLER_SM_{S_No}_GB_ARLD: begin\n\
                                                                            garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_GB_LD;\n\
                end             \n\
\n\
                GABLER_SM_{S_No}_GB_LD: begin\n\
                        if(axi_mstr_sm_rd_data & cl_axi_mstr_bus.rvalid)    garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_VALID;\n\
                        else                                                garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_GB_LD;\n\
                end             \n\
                GABLER_SM_{S_No}_GB_ARLD_BRAM: begin \n\
                                                                            garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_GB_LD_BRAM;\n\
                end\n\
                GABLER_SM_{S_No}_GB_LD_BRAM: begin \n\
                                                                            garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_GB_LD_BRAM_DONE;\n\
                end\n\
        \n\
                GABLER_SM_{S_No}_GB_LD_BRAM_DONE:begin\n\
                                                                             garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_VALID;\n\
                end                   \n\
        \n\
                GABLER_SM_{S_No}_VALID: begin\n\
                        {NS_string}\n\
                end\n".format(S_No =S_No,NS_No = S_No + 1, bit_size0 = bit_size-1,NS_string = NS_string,prep_string=prep_string,i_addr=2*i, ni_addr=2*i+1)

    for i in range(0,num_of_gates):
        if i == num_of_gates - 1:
            NS_string="GABLER_SM_IDLE"
            collect_str = "if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid) garbler_sm_ns[{bit_size0}:0]     = GABLER_SM_RESET;\n".format(bit_size0 = bit_size -1)
            collect_bram_str ="\
               GABLER_SM_{S_No}_COLLECT_BRAM: begin\n\
                                                                           garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_RESET;\n\
               end\n".format(bit_size0=bit_size-1,S_No=i)
        else:
            NS_string="GABLER_SM_{S_No}_COLLECT".format(S_No = i+1)
            if(i < and_gates): 
                collect_str = "\
if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)         garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_DONE;\n".format(S_No=i,NS_No = i+1,bit_size0 = bit_size-1)

                collect_bram_str="\
                GABLER_SM_{S_No}_COLLECT_BRAM: begin\n\
                                                                           garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_DONE;\n\
               end\n".format(S_No=i,NS_No = i+1,bit_size0 = bit_size-1)
            else:
                collect_str = "\
if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)         garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{NS_No}_PROC;\n".format(NS_No = i+1,bit_size0 = bit_size-1)
                collect_bram_str ="\
               GABLER_SM_{S_No}_COLLECT_BRAM: begin\n\
                                                                           garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{NS_No}_PROC;\n\
               end\n".format(S_No=i,NS_No = i+1,bit_size0 = bit_size-1)
        if (i < and_gates) :
            proc_str ="\n\
                GABLER_SM_{S_No}_PROC: begin\n\
                        if(gbr_sm_en_q[{S_No}] == 1'b0)                                 garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{NS_No}_PROC;\n\
                        else if(gbr_sm_en_q[{S_No}] == 1'b1 & output_valid_{S_No}_q)\n\
                                if(gbr_output_addr_arr[{o_addr}][31])                    garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_BRAM;\n\
                                else                                                    garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_DONE;\n\
                        else                                                            garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_PROC;              \n\
                end\n".format(bit_size0 = bit_size-1,S_No=i,NS_No =i+1,o_addr=i)
        else :
            if(i == num_of_gates -1 ):
            
                proc_str ="\n\
                GABLER_SM_{S_No}_PROC: begin\n\
                        if(gbr_sm_en_q[{S_No}] == 1'b0)                                 garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_RESET;\n\
                        else if(gbr_output_addr_arr[{S_No}][31])                         garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_BRAM;\n\
                        else                                                            garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_DONE;              \n\
                end\n".format(bit_size0 = bit_size-1,S_No=i,NS_No =i+1)
                
            else :
                proc_str ="\n\
                GABLER_SM_{S_No}_PROC: begin\n\
                        if(gbr_sm_en_q[{S_No}] == 1'b0)                                 garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{NS_No}_PROC;\n\
                        else if(gbr_output_addr_arr[{S_No}][31])                         garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_BRAM;\n\
                        else                                                            garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_DONE;\n\
                end\n".format(bit_size0 = bit_size-1,S_No=i,NS_No =i+1)
        state_str +="\n\
                {proc_str}\n\
\n\
                GABLER_SM_{S_No}_DONE: begin\n\
                                                                            garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT;\n\
                end\n\
                GABLER_SM_{S_No}_COLLECT: begin\n\
                \n\
                        {collect_str}\n\
                        else\n\
                                                                            garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT;\n\
                end\n\
 {collect_bram_str}\n\
                ".format(S_No = i,NS_string = NS_string,bit_size0 = bit_size-1,NS_No = i+1,collect_str=collect_str,proc_str=proc_str,collect_bram_str=collect_bram_str)               
        if(i < and_gates):
            state_str +="\n\
               GABLER_SM_{S_No}_COLLECT_DONE: begin\n\
                      if(gbr_output_ts_addr_arr[{ts_addr}][31])             garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS01_BRAM;\n\
                      else                                                 garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS01;\n\
               end\n\
               GABLER_SM_{S_No}_COLLECT_TS01: begin\n\
                       if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS01_DONE;\n\
                       else                                                garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS01;\n\
               end\n\
\n\
               GABLER_SM_{S_No}_COLLECT_TS01_BRAM: begin\n\
                                                                           garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS01_DONE;\n\
               end\n\
               GABLER_SM_{S_No}_COLLECT_TS01_DONE: begin\n\
                      if(gbr_output_ts_addr_arr[{ts_addr1}][31])           garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS10_BRAM;\n\
                      else                                                 garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS10;\n\
               end\n\
\n\
               GABLER_SM_{S_No}_COLLECT_TS10: begin\n\
                       if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS10_DONE;\n\
                       else                                                garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS10;\n\
               end\n\
\n\
               GABLER_SM_{S_No}_COLLECT_TS10_BRAM: begin\n\
                                                                           garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS10_DONE;\n\
               end\n\
               GABLER_SM_{S_No}_COLLECT_TS10_DONE: begin\n\
                      if(gbr_output_ts_addr_arr[{ts_addr2}][31])           garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS11_BRAM;\n\
                      else                                                 garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS11;\n\
\n\
               end\n\
               GABLER_SM_{S_No}_COLLECT_TS11: begin\n\
                       if(axi_mstr_sm_wr_resp & cl_axi_mstr_bus.bvalid)    garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{NS_No}_PROC;\n\
                       else                                                garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_{S_No}_COLLECT_TS11;\n\
               end\n".format(S_No = i,NS_string = NS_string,bit_size0 = bit_size-1,NS_No = i+1,collect_str=collect_str,proc_str=proc_str,\
                       ts_addr=3*i,ts_addr1=3*i+1,ts_addr2=3*i+2)
    state_str +="\n\
                GABLER_SM_RESET: begin\n\
                                                                            garbler_sm_ns[{bit_size0}:0]  = GABLER_SM_IDLE;\n\
                end\n\
\n\
                default:                                                    garbler_sm_ns[{bit_size0}:0] = GABLER_SM_IDLE;\n\
            endcase\n\
        end\n".format(bit_size0 = bit_size-1)

    return state_str

def create_garble_input_addr(and_gates,num_of_gates):
    val = 4096
    main_str=''
    for i in range(0,num_of_gates*2,2):
        val1 = hex(val)[2:].upper()
        val2 = hex(val+ 4)[2:].upper()
        
        main_str +="\n\
always_ff @(posedge aclk)\n\
  if (!aresetn) begin\n\
     gbr_input_addr_arr[{0}] <= 32'h0000_0000;\n\
  end\n\
  else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 16'h{val1})) begin\n\
     gbr_input_addr_arr[{0}] <= cfg_wdata_q[31:0];\n\
  end\n\
  else begin\n\
    gbr_input_addr_arr[{0}] <= gbr_input_addr_arr[{0}];\n\
  end\n\
always_ff @(posedge aclk)\n\
  if (!aresetn) begin\n\
     gbr_input_addr_arr[{1}] <= 32'h0000_0000;\n\
  end\n\
  else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 16'h{val2})) begin\n\
     gbr_input_addr_arr[{1}] <= cfg_wdata_q[31:0];\n\
  end\n\
  else begin\n\
     gbr_input_addr_arr[{1}] <= gbr_input_addr_arr[{1}];\n\
  end\n".format(i,i+1,val1=val1,val2=val2)
        val = val + 8
    return main_str

def create_garble_output_addr(num_of_gates):
    val = 8192
    main_str=''
    for i in range(0,num_of_gates):
        val1 = hex(val)[2:].upper()

        main_str +="\n\
always_ff @(posedge aclk)\n\
  if (!aresetn) begin\n\
     gbr_output_addr_arr[{0}] <= 32'h0000_0000;\n\
  end\n\
  else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 16'h{val1})) begin\n\
     gbr_output_addr_arr[{0}] <= cfg_wdata_q[31:0];\n\
  end\n\
  else begin\n\
    gbr_output_addr_arr[{0}] <= gbr_output_addr_arr[{0}];\n\
  end\n".format(i,val1=val1)
        val = val + 4
    return main_str

def create_garble_table_out_addr(and_gates,num_of_gates):
    val = 12288
    main_str=''
    for i in range(0,and_gates*3,3):
        val1 = hex(val)[2:].upper()
        val2 = hex(val+ 4)[2:].upper()
        val3 = hex(val+ 8)[2:].upper()
        
        main_str +="\n\
always_ff @(posedge aclk)\n\
  if (!aresetn) begin\n\
     gbr_output_ts_addr_arr[{0}] <= 32'h0000_0000;\n\
  end\n\
  else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 16'h{val1})) begin\n\
     gbr_output_ts_addr_arr[{0}] <= cfg_wdata_q[31:0];\n\
  end\n\
  else begin\n\
    gbr_output_ts_addr_arr[{0}] <= gbr_output_ts_addr_arr[{0}];\n\
  end\n\
always_ff @(posedge aclk)\n\
  if (!aresetn) begin\n\
     gbr_output_ts_addr_arr[{1}] <= 32'h0000_0000;\n\
  end\n\
  else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 16'h{val2})) begin\n\
     gbr_output_ts_addr_arr[{1}] <= cfg_wdata_q[31:0];\n\
  end\n\
  else begin\n\
     gbr_output_ts_addr_arr[{1}] <= gbr_output_ts_addr_arr[{1}];\n\
  end\n\
always_ff @(posedge aclk)\n\
  if (!aresetn) begin\n\
     gbr_output_ts_addr_arr[{2}] <= 32'h0000_0000;\n\
  end\n\
  else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == 16'h{val3})) begin\n\
     gbr_output_ts_addr_arr[{2}] <= cfg_wdata_q[31:0];\n\
  end\n\
  else begin\n\
     gbr_output_ts_addr_arr[{2}] <= gbr_output_ts_addr_arr[{2}];\n\
  end\n".format(i,i+1,i+2,val1=val1,val2=val2,val3=val3)
        val = val + 12
    return main_str

def printOut(and_gates,xor_gates,num_of_gates):
    print "*"*50
    print "SIGNALS"
    print "*"*50

    print create_signals(and_gates, xor_gates)
    
    print "*"*50
    print "CMD_GO"
    print "*"*50


    print create_cmd_go(num_of_gates)
    
    print "*"*50
    print "CMD_DONE"
    print "*"*50


    print create_cmd_done(num_of_gates)
    print "*"*50
    print "CMD_RW"
    print "*"*50


    print create_cmd_rw(num_of_gates)
    
    print "*"*50
    print "CMD_ADDR_LOW"
    print "*"*50


    print create_cmd_addr_low(num_of_gates)
    
    print "*"*50
    print "ASSIGN"
    print "*"*50


    print create_assign(num_of_gates)
    print "*"*50
    print "STATE TYPE"
    print "*"*50


    print create_state_type(num_of_gates,bit_size)   
    print "*"*50
    print "STATES"
    print "*"*50


    print create_states(and_gates,num_of_gates,bit_size)
    
    print "*"*50
    print "DECLARE INPUTS"
    print "*"*50
    
    print create_dec_inputs(num_of_gates)
    
    print "*"*50
    print "INSTANTIATE"
    print "*"*50
    
    print create_inst(and_gates,xor_gates)
    
   
    print "*"*50
    print "ASSIGN WB"
    print "*"*50
    
    print create_assign_wb(and_gates,xor_gates)
 
def writeFile(and_gates,xor_gates,num_of_gates,ftemp,fOut):
    indnt_size = 3;
    with open(ftemp,"r") as temp_file:
        with open(fOut,"w") as write_file:
            for line in temp_file:
                write_file.write(line)
                if "->state_enum" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_state_type(and_gates,xor_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")


                if "->signals" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_signals(and_gates,xor_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")


                if "->cmd_go" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_cmd_go(and_gates,num_of_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")


                if "->cmd_done" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_cmd_done(and_gates, num_of_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")


                if "->cmd_rw" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_cmd_rw(and_gates,num_of_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")


                if "->cmd_addr_low" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_cmd_addr_low(and_gates, num_of_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")


                if "->assign_sm" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_assign(and_gates,num_of_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")


                if "->states" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_states(and_gates,num_of_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")


                if "->dec_inputs" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_dec_inputs(num_of_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")


                if "->instantiate" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_inst(and_gates,xor_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")


                if "->assign_wb" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_assign_wb(and_gates,xor_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")

                if "->gate_id" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_gate_id(and_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")
                
                if "->axi_sm_flop" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_axi_sm_flop(),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")
                if "->garble_input_addr" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_garble_input_addr(and_gates,num_of_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")
                if "->garble_output_addr" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_garble_output_addr(num_of_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")
                if "->garble_table_out_addr" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_garble_table_out_addr(and_gates,num_of_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")
                if "->bram_write_read" in line :
                    write_file.write("/"*50+"\n")
                    write_file.write("// this is generated code"+"\n")
                    write_file.write("/"*50+"\n")

                    write_file.write(indent(create_bram_write_read(and_gates,xor_gates),indnt_size))
                    write_file.write("/"*50+"\n")
                    write_file.write("// end of generated code"+"\n")
                    write_file.write("/"*50+"\n")
























if __name__=="__main__":
    parser = argparse.ArgumentParser(description= 'Generate Finite State Machine',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--xor_gates', default=4, type=int, help='Total number of  XOR gates')
    parser.add_argument('--and_gates', default=4, type=int, help='Total number of AND gates')
    parser.add_argument('--input',type=str,default='garble_bram_template.sv',help='template file')
    parser.add_argument('--output',type=str,default='testBramGarble.sv',help='generated file')
    parser.add_argument('--p',action='store_true',help='printout code')
    args = parser.parse_args()
    bit_size = 16
    num_of_gates = args.and_gates + args.xor_gates
    if args.p:
   #     print str(args.and_gates)
        printOut(args.and_gates,args.xor_gates,num_of_gates)
    else :
        writeFile(args.and_gates,args.xor_gates,num_of_gates,args.input,args.output)
    #with open("sm_gen.sv","w") as vhdl_file:

