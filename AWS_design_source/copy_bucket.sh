#!/bin/bash
#this script copies last build project to s3 bucket
aws s3 cp $CL_DIR/build/checkpoints/to_aws/*.Developer_CL.tar s3://mgfpgabucket/dcp/
