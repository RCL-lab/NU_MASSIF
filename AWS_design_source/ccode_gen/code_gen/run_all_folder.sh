#/bin/bash
FOLDER=$1
FILES=$FOLDER*.out
OUT_FOLDER="$2"
echo $OUT_FOLDER
for i in {1..2}
do
    #mkdir -p $CL_DIR/software/runtime/circuit_results/"$OUT_FOLDER"_$i
    for FILE in $FILES
    do
        cd $CL_DIR/ccode_gen/code_gen_v3.0/ &&\
>>>>>>> 29ae3a8dc34b8c4424fc3aa423f6ad5977009a71
        cp -f $FILE output.txt &&\
        echo $FILE &&\
        echo $(basename $FILE)&&\
        python code_gen.py &&\
        mkdir -p output/4and4xor/$FILE &&\
        cp -f test_garbler.c dataSource.txt output/4and4xor/$FILE/ &&\
#        ./copy_to_runtime.sh &&\
#        cd $CL_DIR/software/runtime/ && make && sudo ./test_garbler > circuit_results/"$OUT_FOLDER"_$i/$(basename $FILE)  
        echo "done $i"
    done
done
echo "done"

