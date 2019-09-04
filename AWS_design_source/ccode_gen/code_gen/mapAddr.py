import os
import argparse
from numpy import uint32
from collections import OrderedDict 

circuit_fileName = "output.txt"
dataInput_fileName = "data.txt"
ops_out_fileName = "ops_outCodes.txt"

def and_xor_setEnableNum(tmp_ops_list, n):
	'''	
	and_loc = [i for i,x in enumerate(tmp_ops_list) if x=='AND']
	xor_loc = [i for i,x in enumerate(tmp_ops_list) if x=='XOR']
	and_num = 0
	xor_num = 0	
	if and_loc != []:
		and_num = sum([2**x for x in and_loc])
	if xor_loc != []:	
		xor_num = sum([2**x for x in xor_loc])
	'''
	and_loc = [i for i,x in enumerate(tmp_ops_list) if x=='AND']
	xor_loc = [i for i,x in enumerate(tmp_ops_list) if x=='XOR']
	and_num = 0
	xor_num = 0	
	if and_loc != []:
		and_num = sum([2**x for x in range(0,len(and_loc))]) 
	if xor_loc != []:	
		xor_num = sum([2**x for x in range(0,len(xor_loc))])
	enable = and_num + (xor_num << n)
	op_id_map_list = and_loc
	op_id_map_list.extend([x+n-len(and_loc) for x in xor_loc])
	return enable, op_id_map_list 


if __name__ == "__main__":
	
	parser = argparse.ArgumentParser(description = 'netlist mapping',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
	parser.add_argument('--andN',default='stdin',type=int, help = 'number of and cores')
	parser.add_argument('--xorN',default='stdin',type=int, help = 'number of xor cores')
	args = parser.parse_args()
	
	and_Num = args.andN
	xor_Num = args.xorN
	
	write_start_addr = 0  # denote the low 32 bit address
	'''	
	fpga_local_reg_map_addr = '500'
	fpga_local_and_addr = '514'
	fpga_local_xor_addr = '518'
	fpga_local_done_addr = '5E8'
	fpga_gate_id_addrs = []
	fpga_gate_id_addrs.append('5CC')
	fpga_gate_id_addrs.append('5C8')
	fpga_local_cores_addrs = [[],[]]
	fpga_local_cores_addrs_out = []
	fpga_local_cores_addrs[0].append('520')
	fpga_local_cores_addrs[0].append('524')
	fpga_local_cores_addrs_out.append('5A0')
	fpga_local_cores_addrs[1].append('528') 
	fpga_local_cores_addrs[1].append('52C') 
	fpga_local_cores_addrs_out.append('5A4')
	fpga_local_cores_addrs[2].append('530') 
	fpga_local_cores_addrs[2].append('534') 
	fpga_local_cores_addrs_out.append('5A8')
	fpga_local_cores_addrs[3].append('538') 
	fpga_local_cores_addrs[3].append('53C') 
	fpga_local_cores_addrs_out.append('5AC')
	'''
	#############################	
	
	ops_bunch_dict = {}
	LOCAL_GATE_ID_MODE = 0
	local_gate_id = 0
	layer_numbers = []
	operations = []
	f1 = open(circuit_fileName, 'r')
	for line in f1:
		if line == "":
			break 
		words = line.split(":")
		if words[0] == '0':
			continue
		else:
			layer_numbers.append(int(words[0]))
			operations.append(line.rstrip())
	
	f_gencode = open(ops_out_fileName, 'w+')
	total_OpsNum = len(operations)	
        max_addr = hex(write_start_addr +total_OpsNum*3*16 + 16)
        gbr_out_addr = int(max_addr,16)
	ops_pointer = 0
	cur_layer_num = 1
	cur_and_n = 0
	cur_xor_n = 0
	cur_and_bunch_id = 0
	cur_xor_bunch_id = 0
	while ops_pointer < total_OpsNum:
		tmp_dict_op = operations[ops_pointer]
		tmp_op = tmp_dict_op.split(":")[1].split()[1]
		#print(tmp_dict_op)
		if(layer_numbers[ops_pointer] == cur_layer_num):
			if(tmp_op == 'AND'):
				if(cur_and_n < and_Num):
					if cur_and_bunch_id not in ops_bunch_dict:
						ops_bunch_dict[cur_and_bunch_id] = [tmp_dict_op]
					else:
						ops_bunch_dict[cur_and_bunch_id].append(tmp_dict_op)						
					cur_and_n = cur_and_n+1	
				else:		
					cur_and_bunch_id = cur_and_bunch_id+1
					if cur_and_bunch_id not in ops_bunch_dict:
						ops_bunch_dict[cur_and_bunch_id] = [tmp_dict_op]
					else:
						ops_bunch_dict[cur_and_bunch_id].append(tmp_dict_op)	
					cur_and_n = 1

			if(tmp_op == 'XOR'):
				if(cur_xor_n < xor_Num):
					if cur_xor_bunch_id not in ops_bunch_dict:
						ops_bunch_dict[cur_xor_bunch_id] = [tmp_dict_op]
					else:
						ops_bunch_dict[cur_xor_bunch_id].append(tmp_dict_op)	
					cur_xor_n = cur_xor_n+1
				else:
					cur_xor_bunch_id = cur_xor_bunch_id+1
					if cur_xor_bunch_id not in ops_bunch_dict:
						ops_bunch_dict[cur_xor_bunch_id] = [tmp_dict_op]
					else:
						ops_bunch_dict[cur_xor_bunch_id].append(tmp_dict_op)	
					cur_xor_n = 1
				
			ops_pointer = ops_pointer+1	
		else:
			cur_layer_num = cur_layer_num +1
			tmp_v = max(cur_and_bunch_id, cur_xor_bunch_id)
			cur_and_bunch_id = tmp_v + 1 
			cur_xor_bunch_id = tmp_v + 1
			cur_and_n = 0
			cur_xor_n = 0
		
	#print(ops_bunch_dict)
	max_op_bunch_id = ops_bunch_dict.keys()[-1]
	
	for i in range(0, max_op_bunch_id+1):	
		#print([k for (k,v) in ops_bunch_dict.items() if v == i])
		#print('----------')
		
		tmp_ops = [x.split(":")[1] for x in ops_bunch_dict[i]]
		tmp_ops = sorted(tmp_ops, key = lambda x:x.split()[1])
		
		tmp_ops_label_tuple = [(x.split()[0],x.split()[2],x.split()[4]) for x in tmp_ops]
		tmp_ops_list = [x.split()[1] for x in tmp_ops]
		tmp_len = len(tmp_ops)		
		and_num = tmp_ops_list.count("AND")
		xor_num = tmp_ops_list.count("XOR")
		
		#print([len(x.split()) for x in tmp_ops])
		if max([len(x.split()) for x in tmp_ops]) == 6 and 'AND' in tmp_ops_list:
			LOCAL_GATE_ID_MODE = 0
		elif max([len(x.split()) for x in tmp_ops]) == 5 and 'AND' in tmp_ops_list:
			LOCAL_GATE_ID_MODE = 1
	    
		AND_loc = [i for i,x in enumerate(tmp_ops_list) if x == 'AND']
		if LOCAL_GATE_ID_MODE == 0:
			tmp_gate_id = [x.split()[5] for x in tmp_ops if x.split()[1] == 'AND']
			tmp_gate_id_len = len(tmp_gate_id)
			assert len(AND_loc) == tmp_gate_id_len
			gate_id_pos = 0	
		#########################################	
		## write codes for garble core mapping 					
		f_gencode.write('\t//'+str([x for x in tmp_ops])+'\n')
		
		enable_num, op_id_map_list = and_xor_setEnableNum(tmp_ops_list, and_Num)
		#print(op_id_map_list)
		assert len(op_id_map_list) == tmp_len

		f_gencode.write('\t//'+str([x for x in op_id_map_list])+'\n')			
		
		for i in range (0, tmp_len):
			if uint32(tmp_ops_label_tuple[i][0]) >> 31 == 0 and uint32(tmp_ops_label_tuple[i][0]) < 1048576:
				wr_str_line = '\tddr_input_addrs[' + str(2*op_id_map_list[i]) + '] = ' + hex(write_start_addr + int(tmp_ops_label_tuple[i][0])*16+6)+ ';\n'	
			elif uint32(tmp_ops_label_tuple[i][0]) >> 31 == 0 and uint32(tmp_ops_label_tuple[i][0]) >= 1048576:
				wr_str_line = '\tddr_input_addrs[' + str(2*op_id_map_list[i]) + '] = ' + hex(write_start_addr + (int(tmp_ops_label_tuple[i][0])-1048576)*16+6+1048576)+ ';\n'
			else: 
				wr_str_line = '\tddr_input_addrs[' + str(2*op_id_map_list[i]) + '] = 0x' + format((uint32(tmp_ops_label_tuple[i][0])-2147483648)*16+6+2147483648, 'x')+ ';\n'	
			f_gencode.write(wr_str_line)

			if uint32(tmp_ops_label_tuple[i][1]) >> 31 == 0 and uint32(tmp_ops_label_tuple[i][1]) < 1048576:
				wr_str_line = '\tddr_input_addrs[' + str(2*op_id_map_list[i]+1) + '] = ' + hex(write_start_addr+ int(tmp_ops_label_tuple[i][1])*16+6)+ ';\n'
			elif uint32(tmp_ops_label_tuple[i][1]) >> 31 == 0 and uint32(tmp_ops_label_tuple[i][1]) >= 1048576:
				wr_str_line = '\tddr_input_addrs[' + str(2*op_id_map_list[i]+1) + '] = ' + hex(write_start_addr+ (int(tmp_ops_label_tuple[i][1])-1048576)*16+6+1048576)+ ';\n'
			else:
				wr_str_line = '\tddr_input_addrs[' + str(2*op_id_map_list[i]+1) + '] = 0x' + format((uint32(tmp_ops_label_tuple[i][1])-2147483648)*16+6+2147483648, 'x')+ ';\n'					
			f_gencode.write(wr_str_line)

			if uint32(tmp_ops_label_tuple[i][2]) >> 31 == 0 and uint32(tmp_ops_label_tuple[i][2]) < 1048576:
				wr_str_line = '\tddr_output_addrs[' + str(op_id_map_list[i]) + '] = ' + hex(write_start_addr+ int(tmp_ops_label_tuple[i][2])*16)+ ';\n'
			elif uint32(tmp_ops_label_tuple[i][2]) >> 31 == 0 and uint32(tmp_ops_label_tuple[i][2]) >= 1048576:
				wr_str_line = '\tddr_output_addrs[' + str(op_id_map_list[i]) + '] = ' + hex(write_start_addr+ (int(tmp_ops_label_tuple[i][2])-1048576)*16+1048576)+ ';\n'				
			else:
				wr_str_line = '\tddr_output_addrs[' + str(op_id_map_list[i]) + '] = 0x' + format((uint32(tmp_ops_label_tuple[i][2])-2147483648)*16+2147483648, 'x')+ ';\n'
		
			f_gencode.write(wr_str_line)

                for i in range (0, len(AND_loc)):
                    if LOCAL_GATE_ID_MODE == 0:
                        f_gencode.write('\tgate_ids[' + str(AND_loc[i]) + '] = ' + hex(int(tmp_gate_id[i])) + ';\n')
                        
                        f_gencode.write('\tddr_gbr_o_addr[' + str(3*i) + '] = ' + hex(gbr_out_addr ) + ';\n')
                        f_gencode.write('\tddr_gbr_o_addr[' + str(3*i+1) + '] = ' + hex(gbr_out_addr+16) + ';\n')
                        print(hex(gbr_out_addr))
                        print(gbr_out_addr)
                        f_gencode.write('\tddr_gbr_o_addr[' + str(3*i+2) + '] = ' + hex(gbr_out_addr+32) + ';\n')
                        gbr_out_addr = gbr_out_addr + 3*16
                    else:
                        f_gencode.write('\tgate_ids[' + str(i) + '] = ' + hex(local_gate_id) + ';\n')
                        local_gate_id = local_gate_id + 1
    
                        f_gencode.write('\tddr_gbr_o_addr[' + str(3*i) + '] = ' + hex(gbr_out_addr ) + ';\n')
                        f_gencode.write('\tddr_gbr_o_addr[' + str(3*i+1) + '] = ' + hex(gbr_out_addr+16) + ';\n')
                        f_gencode.write('\tddr_gbr_o_addr[' + str(3*i+2) + '] = ' + hex(gbr_out_addr+32) + ';\n')
                        gbr_out_addr = gbr_out_addr + 3*16
                    

                wr_str_line = '\taxi_mstr_sm_access(slot_id , pci_bar_handle, &ddr_input_addrs[0], &ddr_output_addrs[0], &ddr_gbr_o_addr[0] ,&gate_ids[0] ,' + str(and_Num + xor_Num)+' ,'+str(tmp_len)+ ', '+ str(hex(enable_num)) + ');\n'
		f_gencode.write(wr_str_line)
		f_gencode.write('\t//end partial code segments\n')
		f_gencode.write('\n')

	f1.close
	f_gencode.close

	
