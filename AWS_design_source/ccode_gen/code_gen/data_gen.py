import os
import sys

circuit_fileName = "output.txt"
dataInput_fileName = "data_raw.txt"
dataOutput_fileName = "dataSource.txt"

if __name__ == "__main__":

	data_loc = []
	f1 = open(circuit_fileName, 'r')
	for line in f1: 
		words = line.split(":")
		if words[0] == '0':
			data_loc.append(int(words[1]))
		else:
			break
	f1.close

	#############################################

	data_raw = []
	f2 = open(dataInput_fileName, 'r')
	for line in f2: 
		data_raw.append(line)

	f2.close

	##############################################
	
	if len(data_loc) != len(data_raw):
		print("data source must be of equal length!")
		sys.exit()

	data_2Write = [[x[18:20], x[16:18], x[14:16], x[12:14], x[10:12], x[8:10],x[6:8],x[4:6],x[2:4],x[0:2]] for x in data_raw]
	#print data_2Write

	Len = int(data_loc[-1])
	print Len

	f_out = open(dataOutput_fileName,'w+')	
	pos = 0
	for i in range (0, Len+1):
		if i not in data_loc:
			f_out.write("00000000\n")
			f_out.write("00000000\n")
			f_out.write("00000000\n")
			f_out.write("00000000\n")						
		else:
			f_out.write("00000000\n")
			f_out.write("0000"+data_2Write[pos][0]+data_2Write[pos][1]+"\n")
			f_out.write(data_2Write[pos][2]+data_2Write[pos][3]+data_2Write[pos][4]+data_2Write[pos][5]+"\n")
			f_out.write(data_2Write[pos][6]+data_2Write[pos][7]+data_2Write[pos][8]+data_2Write[pos][9]+"\n")
			pos = pos+1
		
	f_out.close
