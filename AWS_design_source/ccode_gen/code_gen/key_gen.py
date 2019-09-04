import os
import random
import sys

circuit_fileName = "output.txt"
dataToWrite_fileName = "data_raw.txt"

def ranbin(d):
    return ''.join(str(random.randint(0, 1)) 
                for x in xrange(d))

if __name__ == "__main__":

	key_len = 0
	f1 = open(circuit_fileName, 'r')
	for line in f1: 
		words = line.split(":")
		if words[0] == '0':
			key_len += 1
		else:
			break
	f1.close

	#############################################
	data_raw = []
	f2 = open(dataToWrite_fileName, 'w')
	for i in range(0, key_len): 
		c = ranbin(80)
		strToWrite = hex(int(c,2))[2:-1].zfill(len(c)//4) + '\n'
		f2.write(strToWrite) 

	f2.close

