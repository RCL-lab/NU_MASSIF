import os
import sys

out_fileName = 'test_garbler.c'

if __name__ == "__main__":
    
    ###################################
    os.system('python key_gen.py')
    print("generate raw keys done!\n")

    ###################################
    os.system('python data_gen.py') 
    print("generate source data done!\n")

    ###################################
    os.system('mapAddr.py --andN 4 --xorN 4')
    print("generate netlist mapping done!\n")
    
    f_out = open(out_fileName,'w+') 
    
    fin_1_1 = open("code_part1_1.txt", "r")
    data_part1_1 = fin_1_1.read()
    fin_1_1.close()
    f_out.write(data_part1_1)
    
    #size_num = 40
    #f_out.write("#define buffer_size  ("+str(size_num)+"*4*4)\n")
    lines = int(os.popen('cat dataSource.txt| wc -l').read())/4 *3
    size_num = lines
    f_out.write("#define buffer_size  ("+str(size_num)+"*6*4*4)\n")


    fin_1_2 = open("code_part1_2.txt", "r")
    data_part1_2 = fin_1_2.read()
    fin_1_2.close()
    f_out.write(data_part1_2)

    fin_2 = None
    try:
        fin_2 = open("ops_outCodes_tst.txt", "r") 
    except IOError:
        print("cannot open operation codes")
    else:
        data_part2 = fin_2.read()
        fin_2.close()
        f_out.write(data_part2)

    fin_3 = open("code_part2.txt", "r")
    data_part3 = fin_3.read()
    fin_3.close()
    f_out.write(data_part3)
    f_out.close
    
