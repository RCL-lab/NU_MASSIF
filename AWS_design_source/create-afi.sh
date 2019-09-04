#!/bin/bash

#this is a script to create AFI 
#this script create AFI from the last copied .tar file in S3
echo "please enter parameters"
read -p 'name : ' NAME
read -p 'description : ' DESCRIPTION

NAME_DATE="$NAME"_"$(date +"%m_%d_%y-%H%M")"
echo "$NAME_DATE"
echo $DESCRIPTION

TAR_FILE=$(ls $CL_DIR/build/checkpoints/to_aws/ |grep tar| tail -n 1)
echo $TAR_FILE
AFI_INFO=$(aws ec2 create-fpga-image \
    --region us-east-1 \
    --name "$NAME_DATE" \
    --description "$DESCRIPTION"\
    --input-storage-location Bucket=mgfpgabucket,Key=dcp/$TAR_FILE\
    --logs-storage-location Bucket=mgfpgabucket,Key=logs) 
    #[ --client-token <value> ] \
    #[ --dry-run | --no-dry-run ]
echo "$AFI_INFO"
#cat "$AFI_INFO" >> afi_info_log.txt
#NOTE: <path-to-tarball> is <dcp-folder-name>/<tar-file-name>
#<path-to-logs> is <logs-folder-name>
AFI_NAME=$(echo $AFI_INFO|awk -F ":" '/afi/ {gsub("[\"|,| ]","",$2);print $2}')
echo $AFI_NAME
AFI_NAME=$(echo $AFI_NAME | sed s/FpgaImageGlobalId//g)
echo $AFI_NAME
wait_for_afi.py --afi "$AFI_NAME" --notify "$EMAIL"
