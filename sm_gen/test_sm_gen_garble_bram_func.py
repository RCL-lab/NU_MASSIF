import sm_gen_garble_bram
import sys

func_name = sys.argv[1]
#print len(sys.argv)
if(len(sys.argv) == 3):
    print getattr(sm_gen_garble_bram,func_name)(int(sys.argv[2]))
if(len(sys.argv) == 4):
    print getattr(sm_gen_garble_bram,func_name)(int(sys.argv[2]),int(sys.argv[3]))
