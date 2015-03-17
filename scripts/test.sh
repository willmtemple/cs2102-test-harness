#!/bin/sh

function usage {
    printf "${0} - Run a test on a file, and log its results\n"
    printf "\nUsage:\t${0} directory testname logfile\n"
    printf "\t\tdirectory - the student you wish to evaluate\n"
    printf "\t\ttestname - which unit test you want to run (by filename, omit extension)\n"
    printf "\t\tlogfile - the comment file name (will be prepended with student name and appended with .txt)"
}

function unpack {
    for jf in `find -mindepth 1 -name *.java 
}
