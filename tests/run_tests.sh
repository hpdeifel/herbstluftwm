#!/bin/bash

# A simple test driver that starts herbstluftwm inside a Xephyr server, runs
# custom autostart files and compares the output against the content of a file.
#
# Test scripts are expected to be called *.test.sh. For each test NAME.test.sh,
# a file NAME.test.sh.out with the expected output of the test has to exist.
#
# Tests are passed to herbstluftwm as --autostart, with the environment
# variables HERBSTCLIENT and HERBSTLUFTWM pointing to the respective binaries.
#
# A test usually calls herbstclient to set up some state and then uses 'dump' or
# similar to extract the resulting configuration. Also, each test MUST call
# herbstclient quit for the test suite to complete.
#
# Usage: run_tests.sh [test_script.test.sh...]
#
# If run without argument, all *.test.sh scripts in the current directory are
# executed.

XEPHYR_DISPLAY=:666

export HERBSTCLIENT=../herbstclient
export HERBSTLUFTWM=../herbstluftwm

failed_count=0
success_count=0

failed() {
    echo "#### TEST FAILED:" "$@";
    ((failed_count++));
}

run_test() {
    Xephyr $XEPHYR_DISPLAY -br -reset -terminate &
    sleep 0.2
    (DISPLAY=${XEPHYR_DISPLAY} ${HERBSTLUFTWM} --autostart ${1} 2>&1 | diff ${1}.out -) \
	&& ((success_count++)) \
	|| failed ${1}
}

if (( $# == 0));
then
    for tst in *.test.sh;
    do
	run_test $tst;
    done
else
    for tst in "$@";
    do
	run_test $tst;
    done
fi

echo
echo "##################################################"
echo "### TEST SUMMARY:"
echo
echo "### FAILED: ${failed_count}"
echo "### SUCCEDED: ${success_count}"
echo

if (( $failed_count > 0 ));
then
    exit 1
fi
