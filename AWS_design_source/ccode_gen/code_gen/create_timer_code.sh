#!/bin/bash

TEST_FOLDER="/home/centos/src/project_data/MASSIF/AWS_design_source/software/runtime"
CURRENT_DIR="/home/centos/src/project_data/MASSIF/AWS_design_source/ccode_gen/new_code_gen_v2.1"
FOLDER_NAME="ham"

read -p "enter result folder name : " RESULT_FOLDER
echo "$RESULT_FOLDER"
cp -f $FOLDER_NAME/*.out ./output.txt &&python code_gen.py &&python add_timer.py &&\
cp -f $CURRENT_DIR/dataSource.txt $CURRENT_DIR/test_garbler_t.c ./$FOLDER_NAME/ && \
echo "dataSource : "
echo $(cat $TEST_FOLDER/dataSource.txt|wc -l)


FOLDER_NAME="mill"
cp -f $CURRENT_DIR/$FOLDER_NAME/*.out ./output.txt &&python code_gen.py &&python add_timer.py &&\
cp -f $CURRENT_DIR/dataSource.txt test_garbler_t.c ./$FOLDER_NAME/ && \
echo "dataSource : "
echo $(cat $TEST_FOLDER/dataSource.txt|wc -l)


FOLDER_NAME="add_two_6bits"
cp -f $CURRENT_DIR/$FOLDER_NAME/*.out ./output.txt &&python code_gen.py &&python add_timer.py &&\
cp -f $CURRENT_DIR/dataSource.txt $CURRENT_DIR/test_garbler_t.c ./$FOLDER_NAME/ && \
echo "dataSource : "
echo $(cat $TEST_FOLDER/dataSource.txt|wc -l)


FOLDER_NAME="add_two"
cp -f $CURRENT_DIR/$FOLDER_NAME/*.out ./output.txt &&python code_gen.py &&python add_timer.py &&\
cp -f $CURRENT_DIR/dataSource.txt $CURRENT_DIR/test_garbler_t.c ./$FOLDER_NAME/ && \
echo "dataSource : "
echo $(cat $TEST_FOLDER/dataSource.txt|wc -l)


FOLDER_NAME="sort"
cp -f $CURRENT_DIR/$FOLDER_NAME/*.out ./output.txt &&python code_gen.py &&python add_timer.py &&\
cp -f $CURRENT_DIR/dataSource.txt $CURRENT_DIR/test_garbler_t.c ./$FOLDER_NAME/ && \

echo "dataSource : "
echo $(cat $TEST_FOLDER/dataSource.txt|wc -l)

cd $TEST_FOLDER


FOLDER_NAME="ham"
echo $FOLDER_NAME
cp -f $CURRENT_DIR/$FOLDER_NAME/dataSource.txt $CURRENT_DIR/$FOLDER_NAME/test_garbler_t.c $TEST_FOLDER/ &&\
cd $TEST_FOLDER/ && make && \
mkdir -p $TEST_FOLDER/$RESULT_FOLDER/$FOLDER_NAME && \
sudo ./test_garbler_t > $TEST_FOLDER/$RESULT_FOLDER/$FOLDER_NAME/results.txt
FOLDER_NAME="mill"
echo $FOLDER_NAME
cp -f $CURRENT_DIR/$FOLDER_NAME/dataSource.txt $CURRENT_DIR/$FOLDER_NAME/test_garbler_t.c $TEST_FOLDER/ &&\
cd $TEST_FOLDER/ && make && \
mkdir -p $TEST_FOLDER/$RESULT_FOLDER/$FOLDER_NAME && \
sudo ./test_garbler_t > $TEST_FOLDER/$RESULT_FOLDER/$FOLDER_NAME/results.txt
FOLDER_NAME="add_two_6bits"
echo $FOLDER_NAME
cp -f $CURRENT_DIR/$FOLDER_NAME/dataSource.txt $CURRENT_DIR/$FOLDER_NAME/test_garbler_t.c $TEST_FOLDER/ &&\
cd $TEST_FOLDER/ && make && \
mkdir -p $TEST_FOLDER/$RESULT_FOLDER/$FOLDER_NAME && \
sudo ./test_garbler_t > $TEST_FOLDER/$RESULT_FOLDER/$FOLDER_NAME/results.txt
FOLDER_NAME="add_two"
echo $FOLDER_NAME
cp -f $CURRENT_DIR/$FOLDER_NAME/dataSource.txt $CURRENT_DIR/$FOLDER_NAME/test_garbler_t.c $TEST_FOLDER/ &&\
cd $TEST_FOLDER/ && make && \
mkdir -p $TEST_FOLDER/$RESULT_FOLDER/$FOLDER_NAME && \
sudo ./test_garbler_t > $TEST_FOLDER/$RESULT_FOLDER/$FOLDER_NAME/results.txt
FOLDER_NAME="sort"
echo $FOLDER_NAME
cp -f $CURRENT_DIR/$FOLDER_NAME/dataSource.txt $CURRENT_DIR/$FOLDER_NAME/test_garbler_t.c $TEST_FOLDER/ &&\
cd $TEST_FOLDER/ && make && \
mkdir -p $TEST_FOLDER/$RESULT_FOLDER/$FOLDER_NAME && \
sudo ./test_garbler_t > $TEST_FOLDER/$RESULT_FOLDER/$FOLDER_NAME/results.txt

