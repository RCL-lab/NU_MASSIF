# MaSSIF: Massively Scalable Secure Computation Infrastructure Using FPGAs
This project aims to apply and accelerate Secure Function Evaluation with garbled circuits to 
large problems by using FPGA overlay architecture on Amazon Web Services FPGA instances.


## Building hardware design

First clone the AWS EC2 FPGA Hardware and Software Development Kit repo to your instance and make sure you have AWS FPGA developer AMI v1.5.0

run `sm_gen_garble_bram.py` that is under `sm_gen` folder with number of garbled and gates and number of garbled xor gates arguments.

output file should be named `cl_dram_dma_axi_mstr.sv` to build as custom logic for AWS EC2 FPGA Hardware and Software Development Kit.

Ex: for 4 garbled AND and 4 garbled XOR gates 

`python sm_gen_garble_bram.py --and_gates 4 --xor_gates 4 --output cl_dram_dma_axi_mstr.sv`

the output file must be replaced with custom logic design file with the name `cl_dram_dma_axi_mstr.sv` under AWS EC2 FPGA Hardware and Software Development Kit repo.

to build custom logic, create AFI and load on AWS F1 instances, please refer to this link

https://github.com/aws/aws-fpga/tree/master/hdk

## Build and run host code

To build and run host code please follow these steps:

### 1- Generate netlist

https://github.com/wangxiao1254/FlexSC

### 2- Extract layers and addresses from netlist

the python program `LayerAddressExtractor.py` under the folder `AWS_design_source/ccode_gen/Circuit_analysis/` is used to extract layers and addresses from the netlist and outputs them to a file.
This program takes netlist as input and outputs a file with layers and addresses

### 3- Map addresses to the overlay design and generate host code

The output of the `LayerAddressExtractor.py` is used as an input of code_gen.py
`code_gen.py` generate random keys, generate random data and generates c code that runs on the host that sends data to the DDR and sends the addresses to the FPGA to generate garbled tables.

### 4- Run host code

On aws f1 instance make sure the overlay design AFI is loaded and AWS_design_source folder copied under aws-fpga/hdk/cl/examples/
copy the output of `code_gen.py` as `test_garbler.c` and dataSource.txt to the folder AWS_design_source/software/runtime folder
then run make to build the source code.
then run the executable binary with sudo and direct the output to a file

`sudo ./test_garbler > test_garbler_out.txt`

The output file includes the timings and generated garbled tables.


This project tested on AWS FPGA developer AMI v1.5.0
