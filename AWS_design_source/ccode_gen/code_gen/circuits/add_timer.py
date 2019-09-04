import argparse
import re
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

DEFINE_1B_STR ="#define BILLION 1000000000L"
DEFINE_TIMER_OFFSETS_STR="\n\
static uint32_t timer1_offset = 0x5EC;\n\
static uint32_t timer2_offset = 0x5F0;\n\
static uint32_t timer3_offset = 0x5F4;\n\
static uint32_t timer4_offset = 0x5F8;\n\
static uint32_t timer5_offset = 0x5FC;\n\
\n"
DEFINE_COUNTER_STR="\n\
uint32_t counter1 = 0;\n\
uint32_t counter2 = 0;\n\
uint32_t counter3 = 0;\n\
uint32_t counter4 = 0;\n\
uint32_t counter5 = 0;\n\
"
#uint64_t diff = 0;\n\
#"
DEFINE_DIFF ="uint64_t diff = 0;\n"

TIMER_STRUCT_STR="struct timespec start, end;"
CLOCK_START_STR="clock_gettime(CLOCK_MONOTONIC, &start);"
CLOCK_END_STR="clock_gettime(CLOCK_MONOTONIC, &end);"
CLOCK_DIFF_STR="diff = BILLION * (end.tv_sec - start.tv_sec) + end.tv_nsec - start.tv_nsec;"
PRINT_DIFF_WR_STR='printf("elapsed time to write registers  = %llu nanoseconds \\n", (long long unsigned int) diff);'
PRINT_DIFF_PR_STR='printf("elapsed time to process  = %llu nanoseconds \\n", (long long unsigned int) diff);'
PRINT_COUNTER_STR="printf(\"counter1: %x counter2: %x counter3: %x counter4: %x counter5: %x\\n \",\
counter1,counter2,counter3,counter4,counter5);"

GET_COUNTER_REG_STR="\n\
do{\n\
    rc =fpga_pci_peek(pci_bar_handle,timer1_offset,&counter1);\n\
    fail_on(rc, out, \"Unable to read AXI Master CCR from the fpga !\");\n\
    poll_limit--;\n\
} while (!counter1 && poll_limit > 0); \n\
\n\
do{\n\
    rc =fpga_pci_peek(pci_bar_handle,timer2_offset,&counter2);\n\
    fail_on(rc, out, \"Unable to read AXI Master CCR from the fpga !\"); \n\
    poll_limit--; \n\
} while (!counter2 && poll_limit > 0); \n\
\n\
do{\n\
    rc =fpga_pci_peek(pci_bar_handle,timer3_offset,&counter3);\n\
    fail_on(rc, out, \"Unable to read AXI Master CCR from the fpga !\"); \n\
    poll_limit--; \n\
} while (!counter3 && poll_limit > 0); \n\
\n\
do{\n\
    rc =fpga_pci_peek(pci_bar_handle,timer4_offset,&counter4);\n\
    fail_on(rc, out, \"Unable to read AXI Master CCR from the fpga !\"); \n\
    poll_limit--; \n\
} while (!counter4 && poll_limit > 0); \n\
\n\
do{\n\
    rc =fpga_pci_peek(pci_bar_handle,timer5_offset,&counter5);\n\
    fail_on(rc, out, \"Unable to read AXI Master CCR from the fpga !\"); \n\
    poll_limit--; \n\
} while (!counter5 && poll_limit > 0); \n"
#MATCH_STR_REG = 'fail_on(rc, out, "Unable to write to AXI Master done bit register!");'
MATCH_STR_REG = ' Issue AXI Master'
#MATCH_STR_PROC= 'fail_on((rc = !read_data), out, "core did not complete. Done bit not set.");'
MATCH_STR_PROC= 'Poll for done'
MATCH_STR_PROC_END ='fail_on((rc = !read_data), out, "AXI Master SM operations did not complete. Done bit not set in State Machine.");'
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

if __name__=="__main__":
    parser = argparse.ArgumentParser(description= 'Put timer code ',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--input',type=str,default='test_garbler.c',help='c file file')
    parser.add_argument('--output',type=str,default='test_garbler_t.c',help='generated file')
    args = parser.parse_args()
    
    ##printout(args.gates)
    write_str =""
    with open(args.input,"r") as orig_file:
        for line in orig_file:
            if re.search("#define buffer_size", line):
                line = line + "\n" + DEFINE_1B_STR + "\n"
                #print line
            if re.search("#endif",line):
                line= line + "\n"
                line= line + DEFINE_TIMER_OFFSETS_STR +"\n"
                line= line + DEFINE_COUNTER_STR + "\n"
                line = line + TIMER_STRUCT_STR + "\n"
                line = line + DEFINE_DIFF
                #print line
            if re.search('//\[.*[XOR || AND]', line):
                line = line + 'printf("' + line[:-1] + '\\n");\n'
                line = line + "\n" + CLOCK_START_STR + "\n"
            if MATCH_STR_REG in line:
                line = line +"\n" +CLOCK_START_STR + "\n"
             
            #    line = line + CLOCK_DIFF_STR + "\n"
            #    line = line + PRINT_DIFF_WR_STR +"\n"
                #line = line + CLOCK_START_STR + "\n"
            if MATCH_STR_PROC in line:
                line = line + "\n" + CLOCK_END_STR + "\n"
                line = line + CLOCK_DIFF_STR + "\n"
                line = line + PRINT_DIFF_WR_STR +"\n"
                line = line +"\n" +CLOCK_START_STR + "\n"
            if MATCH_STR_PROC_END in line:
                line = line + "\n" + CLOCK_END_STR + "\n"
                line = line + CLOCK_DIFF_STR + "\n"
                line = line + PRINT_DIFF_PR_STR +"\n"
            #    line = line + CLOCK_DIFF_STR + "\n"
            #    line = line + PRINT_DIFF_PR_STR +"\n"
                line = line + GET_COUNTER_REG_STR + "\n"
                line = line + PRINT_COUNTER_STR +"\n"
            if "//end partial" in line:
                line = line + "\n" + CLOCK_END_STR + "\n"
                line = line + CLOCK_DIFF_STR + "\n"
            #    line = line + PRINT_DIFF_PR_STR +"\n"
               
            write_str = write_str + line
    #print write_str
    file_write = open("test_garbler_t.c","w")
    file_write.write(write_str)
    file_write.close
