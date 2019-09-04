mkdir -p bin
find . -name "*.java" > source.txt;
javac -Xlint:unchecked -cp bin:lib/* -d bin @source.txt;
