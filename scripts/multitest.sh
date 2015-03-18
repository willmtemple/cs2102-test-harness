#!/bin/bash

JDK_PATH=/opt/oracle/jdk-current/bin/
TESTER_LIB=/home/wmtemple/.bin/libs/testerV1_3_5.jar
COVERAGE_AGENT=/_dev/libs/jacoco-0.7.4.201502262128/lib/jacocoagent.jar
COVERAGE_REPORT=/_dev/libs/coverage.jar

for D in `find . -mindepth 1 -maxdepth 1 -type d`; do
    cd $D
    
    echo "Grading for user group: $(basename $(pwd))"

    for f in *.zip; do
    	unzip -a $f &> /dev/null
    	rm $f &> /dev/null
    done

    for f in *.rar; do
    	unrar x $f &> /dev/null
    	rm $f &> /dev/null
    done

    for f in *.tar*; do
    	tar -xf $f &> /dev/null
    	rm $f &> /dev/null
    done
    
    for f in `find . -mindepth 1 -name *.java`; do
    	cp $f .
    done

    for nd in `find . -mindepth 1 -maxdepth 1 -type d`; do
    	rm -rf $nd &> /dev/null
    done
    
    mkdir -p bin
    mkdir -p log
    
    ${JDK_PATH}javac -cp ${TESTER_LIB} -d bin *.java > log/compile.out
    if [[ $? -ne 0 ]]; then
    	echo "FAILED TO COMPILE"
    else
    	${JDK_PATH}java -cp ${TESTER_LIB}:bin tester.Main > log/tests.out 2>&1
        ${JDK_PATH}java -cp ${TESTER_LIB}\;bin -javaagent:${COVERAGE_AGENT} tester.Main > /dev/null 2>&1
        ${JDK_PATH}java -jar ${COVERAGE_REPORT} > log/coverage.txt
    fi
    
    cd ..
    
done
