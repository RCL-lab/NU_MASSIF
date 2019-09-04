#/bin/bash
# this script get timings from to output files of the tests which have .out ending
# and create table for each file output
grep -He core *.out |awk ' {print $0 $7/1000}'|column -t > results_table.txt
