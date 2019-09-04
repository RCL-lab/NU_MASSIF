#/bin/bash
FOLDER=$1
#while read -r line
#do
#    echo $line |awk -F '[:=\ ]' '{print $2" "$4" "$7}'
#done < $FILE
for FILE in $FOLDER*
do
echo $FILE
cat $FILE |awk -F '[:= ]' 'BEGIN{max=0}{if ($2>max) {max=$2};if ($4>max){max=$4 }; if ($7>max) {max=$7 }} END{print max-2147483648}' 
done
