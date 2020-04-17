#!/bin/bash

docker build -t prometheus-operator-lint-action .

error_count=0

# good case 1 #################################################################
###############################################################################
TESTCASE="good_case_1"
INPUT_PATH="/mnt/$TESTCASE"
INPUT_FILES="*.yaml"
INPUT_EXCLUDE="skip"

docker run --rm \
-v $(pwd)/test/test_data:/mnt/ \
prometheus-operator-lint-action $INPUT_PATH $INPUT_FILES $INPUT_EXCLUDE

RESULT=$?
if [ $RESULT == 0 ]; then
    echo "✅ $TESTCASE test passed"
else
    echo "❌ $TESTCASE test failed"
    error_count=$((error_count+1))
fi

unset TESTCASE

# good case 2 #################################################################
###############################################################################
TESTCASE="good_case_2"
INPUT_PATH="/mnt/$TESTCASE"
INPUT_FILES="*.yaml"
INPUT_EXCLUDE=""

docker run --rm \
-v $(pwd)/test/test_data:/mnt/ \
prometheus-operator-lint-action $INPUT_PATH $INPUT_FILES $INPUT_EXCLUDE

RESULT=$?
if [ $RESULT == 0 ]; then
    echo "✅ $TESTCASE test passed"
else
    echo "❌ $TESTCASE test failed"
    error_count=$((error_count+1))
fi

# test the bad case ###########################################################
###############################################################################
TESTCASE="bad_case_1"
INPUT_PATH="/mnt/$TESTCASE"
INPUT_FILES="*.yaml"
INPUT_EXCLUDE="skip"

docker run --rm \
-v $(pwd)/test/test_data:/mnt/ \
prometheus-operator-lint-action $INPUT_PATH $INPUT_FILES $INPUT_EXCLUDE

RESULT=$?
if [ $RESULT == 0 ]; then
    echo "❌ $TESTCASE test failed"
    error_count=$((error_count+1))
else
    echo "✅ $TESTCASE test passed"
fi

###############################################################################
# exit
###############################################################################
exit $error_count
