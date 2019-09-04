#!/bin/bash
# Author : Mehmet Gungor
# email : gungor.m@husky.neu.edu
#
# This script checks the afi info with a given name
HELP="check_afi <name>   : get afi info for the  <name>"
if [[ "$1" == "-h" ]]
then
    echo "Usage :"
    echo "check_afi <name>   : get afi info for the  <name>"
    echo "-agfi <name>       : get agfi "
    echo "-names             : get names of afis"
elif [[ "$1" == "-agfi" ]]
then
    if [[ "$2" != "" ]]
    then
    AGFI=$(aws ec2 describe-fpga-images --owner self | grep -A 18 "$2"|\
        awk -F ':' '/agfi/ {print $2}')
        echo "${AGFI:2:-3}"
    else
    echo "please enter name"
    fi
elif [[ "$1" == "-names" ]]
then
        aws ec2 describe-fpga-images --owner self | grep Name
elif [[ "$1" != "" ]]
then

    aws ec2 describe-fpga-images --owner self | grep -A 18 "$1"
else
    aws ec2 describe-fpga-images --owner self
fi
