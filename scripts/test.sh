#!/bin/sh

if [ -z "$JDK_PATH" ];
then
    JDK_PATH="/usr/lib/jvm/java-8-openjdk/bin/";
fi

if [ -z "$TESTER_PATH" ];
then
    TESTER_PATH="/home/wmtemple/.bin/libs/testerV1_3_5.jar";
fi

function usage {
    printf "${0} - Run a test on a file, and log its results\n"
    printf "\nUsage:\t${0} student testname logfile\n"
    printf "\t\tstudent - the path to the student's classes you wish to evaluate\n"
    printf "\t\ttestname - which unit test you want to run (by filename, omit extension)\n"
    printf "\t\tlogfile - the comment file name (will be prepended with student name and appended with .txt)"
}

if [ "$#" -ne "3" ];
then
    usage;
    exit 1;
fi

if [ ! -d "$1" ];
then
    echo "No such student directory at ${1}.";
    exit 1;
elif [ ! -e "$2" ];
then
    echo "No such test file ${2}.";
    exit 1;
elif [ ! -e "$3" ];
then
    echo "Creating log file ${3}.";
    touch ${3};
fi

CLASSNAME=$(basename ${2} ".java")

# TODO: Need to find a way to handle arbitrary package structures.
# Maybe have a control sequence in the java sources in each import which can be replaced with the package namespace?

printf "Compiling the test file: ${2}\n" >> ${3}
javac -cp "${1}:${TESTER_PATH}" ${2} &>> ${3}

if [ ! -z $? ];
then
    printf "Coule not successfully compile the test. Aborting test of ${CLASSNAME}.\n" >> ${3};
    exit 1;
fi

printf "Testing ${CLASSNAME}...\n" >> ${3}
java -cp "${1}:$(dirname ${2}):${TESTER_PATH}" tester.Main ${CLASSNAME} >> ${3}

if [ -z $? ];
then
    printf "Successfully passed all portions of ${2}\n" >> ${3};
else;
then
    printf "${2} failed. See above report for information about these tests.\n" >> ${3};
fi

