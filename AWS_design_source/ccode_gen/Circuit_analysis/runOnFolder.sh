#/bin/bash

FOLDER=$1
FILES=$FOLDER/*.txt
for FILE in $FILES
do
echo "dirname '$FILE'"
echo $FILE.out
mkdir -p output/$FOLDER
python LayerAddressExtractor.py --inputfile $FILE > output/$FILE.out
done
