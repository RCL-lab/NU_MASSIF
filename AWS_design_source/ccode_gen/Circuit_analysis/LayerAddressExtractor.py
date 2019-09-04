import os
import random,sys
import numpy as np
import logging,argparse
from collections import defaultdict
from collections import deque

def parseString(s):
	logging.debug('Processing '+s)
	iw1, op, iw2, eqsign, ow = s.split(" ")
	logging.debug('Got '+str(op)+' with inputs '+str(iw1)+','+ str(iw2)+' and output '+str(ow ) )
	iw1 = int(iw1)
	iw2 = int(iw2)
	ow = int(ow)
	return op, iw1, iw2, ow

def layerNumbers(fileName, make_seq):
	"""output layer numbers
	"""	
	bram_tot_size = 10000
	intermediate_key_ddr_addr = 1 << 20	
	wire_dict = {}
	op_dict = {}
	wire_dict_used_times = {}
	bram_addr_stor_dict = {}
	ddr_addr_stor_dict = {}
	global_wire_id = 0
	output_netlist = []

	bram_addr = 1 << 31
	de = deque([bram_addr])
	
	with open(fileName, 'r') as f:
		for l in f:	    
			try:
				op, iw1, iw2, ow = parseString(l)
			except Exception as e:
				logging.error('Line '+l+' raised exception: '+str(e))
				logging.error('skipping line '+l)
				l = f.readline()    
				continue

			layer_num = 0
			for x in [iw1,iw2]:
				if x not in wire_dict:
					wire_dict[x] = 0
					wire_dict_used_times[x] = 1
				else:
					layer_num = max(layer_num, wire_dict[x])
					wire_dict_used_times[x] += 1
							
			layer_num = layer_num+1
							
			wire_dict[ow] = layer_num
			wire_dict_used_times[ow] = 0
			
			str_to_wrt = str(layer_num) + ":" + str(iw1) + " " + str(op) + " " + str(iw2) + " = " +str(ow) 
			op_dict[str_to_wrt] = layer_num	
	
		
	d = dict((k,v) for k,v in wire_dict.items() if v == 0)
	max_layer = layer_num
	#print(max_layer)
	# add the input wires
	'''
	d = dict((k,v) for k,v in wire_dict.items() if v == 0)
	
	for k, v in d.iteritems():
		print(str(v) + ":" + str(k))
	'''
	# sort the dict
	dict_sorted = sorted(op_dict.iteritems(), key=lambda (k,v): (v,k))
	#for key, value in dict_sorted if value == 1:
	batch_list = []
	bram_wire_list = []
	bram_addr_dict = {}
	
	for i in range(1, max_layer+1):
		tmp_list = [key for key, val in dict_sorted if val == i]
		for op in tmp_list:
			layer_str= op.split(":")[0]
			iw1 = int(op.split(":")[1].split(" ")[0])
			op_gate = op.split(":")[1].split(" ")[1]
			iw2 = int(op.split(":")[1].split(" ")[2])
			ow = int(op.split(":")[1].split(" ")[4]) 
			
			#print(wire_dict_used_times)
			#print(bram_addr_stor_dict)
			if iw1 in d:
				layer_str += ":"+ str(iw1) + " " + op_gate + " " 
			elif iw1 in bram_addr_stor_dict:
				wire_dict_used_times[iw1] -= 1	
				#print(str(iw1) + ": " + str(wire_dict_used_times[iw1]))
				bram_reuse_addr = bram_addr_stor_dict[iw1]
				layer_str += ":"+ str(bram_reuse_addr) + " " + op_gate + " " 
				if wire_dict_used_times[iw1] == 0:
					#print("add back the addr " + str(bram_reuse_addr))	
					de.append(bram_reuse_addr)				
			else:
				layer_str += ":"+ str(ddr_addr_stor_dict[iw1]) + " " + op_gate + " " 
	
			if iw2 in d:
				layer_str += str(iw2) + " = "
			elif iw2 in bram_addr_stor_dict:
			 	wire_dict_used_times[iw2] -= 1	
				bram_reuse_addr = bram_addr_stor_dict[iw2]	
				layer_str += str(bram_reuse_addr) + " = " 
				if wire_dict_used_times[iw2] == 0:		
					de.append(bram_reuse_addr)		
			else:
				layer_str += str(ddr_addr_stor_dict[iw2]) + " = "
			
			#print("-----------------------------")
			#print(de)
			try: 
				avail_addr = de.popleft() 
				bram_addr_stor_dict[ow] = avail_addr
				layer_str += str(avail_addr)
			except Exception as e:
				#print(bram_addr)
				if bram_addr < 2147483648 + bram_tot_size-1:
					bram_addr += 1
					bram_addr_stor_dict[ow] = bram_addr
					layer_str += str(bram_addr)
				else:				
					ddr_addr_stor_dict[ow] = intermediate_key_ddr_addr
					layer_str += str(intermediate_key_ddr_addr)
					intermediate_key_ddr_addr += 1
	
			output_netlist.append(layer_str)	
	
	#print(output_netlist)
	#print(wire_dict_used_times)
	#print(bram_addr_stor_dict)
	
	d = dict((k,v) for k,v in wire_dict.items() if v == 0)
	
	
	for k, v in d.iteritems():
		print(str(v) + ":" + str(k))
	
	for item in output_netlist:
		print item

	#print(bram_addr_stor_dict)
	'''
		for op in tmp_list:
			str_to_lst = ''+ op[0] 
			if wire_dict_used_times[int(op[0])] == 1:
				str_to_lst += '(B) '

			str_to_lst += ' ' + op[1] 
			if wire_dict_used_times[int(op[1])] == 1:
				str_to_lst += '(B)'

			op_tmp_lst.append(str_to_lst)	

		print(op_tmp_lst)		
	
		
		wires_list = [item for sub in tmp_list for item in sub]		
		counts = {}
		for n in wires_list:
			counts[n] = counts.get(n,0) + 1

		print(counts)
		
		for temp_op in temp_dic:
			iw1 = int(temp_op.split()[0])
			iw2 = int(temp_op.split()[1])
			print(wire_dict_used_times[iw1])

	for k,v in wire_dict_used_times.items():
		print("wire "+ str(k) + " used " + str(v) + " times.")
	'''

if __name__=="__main__":
	parser = argparse.ArgumentParser(description = 'Process a Binary Circuit',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
	parser.add_argument('--inputfile',default='stdin',type=str, help = 'input file')
	parser.add_argument('--debug_level',default='INFO',type=str,help='Debug Level', choices=['INFO','DEBUG'])
	parser.add_argument('--make_seq',default='no',type=str,help='sequential wire id', choices=['yes','no'])
	args = parser.parse_args()
   	
	args.debug_level= eval("logging."+args.debug_level)
	logging.basicConfig(level=args.debug_level)
	
	layerNumbers(args.inputfile, args.make_seq)
	'''	
	f_out = open("output_test.txt","w+")
	f_out.write(strings)
	f_out.close()
	'''
	
