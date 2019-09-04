#!/bin/bash
#this generates csv file to show all variables in a vhdl file
echo "Constants,">signals.out.csv
echo " , " >> signals.out.csv
cat gc_comp.vhdl | awk -F ":" '/constant/ { print $1","$2$3}' |sed s/constant//g >>signals.out.csv
echo " , " >> signals.out.csv
echo "Types," >>signals.out.csv
echo " , " >> signals.out.csv
cat gc_comp.vhd | awk -F "IS" '/TYPE/ { split($1,a," ");print a[2]","$2}' >> signals.out.csv
echo " , " >> signals.out.csv
echo "Signals, " >> signals.out.csv
echo " , " >> signals.out.csv
cat gc_comp.vhd | grep  '^\ *signal'  | awk -F '[:,;]' '{split($1,a,"");sub(/\t*/,"",$2);print a[2]","$2}' >>signals.out.csv
#this shows all the generated variables in a vhdl file
# in a simple format
cat gc_comp.vhd | grep -e constant -e TYPE -e '^\ *signal' > signals.out.data
