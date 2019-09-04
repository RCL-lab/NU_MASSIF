#!/bin/bash
#this scripts load AFI image to the FPGA on aws-f1 instance
#input is AGFI number
AGFI_NAME=$1
echo "Loading"
sudo fpga-load-local-image -S 0 -I "$AGFI_NAME"
