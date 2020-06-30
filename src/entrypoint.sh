#!/bin/sh

HAD_ERRORS=0

function lint() {
  LOCAL_INPUT_FILES="$1"
  LOCAL_INPUT_PATH="$2"

  if [[ ! -d "$LOCAL_INPUT_PATH" ]]; then
    echo "ERROR: path '$INPUT_PATH' dont exist"
    exit 1
  fi

  echo "Linting '${LOCAL_INPUT_FILES}' files in directory '${LOCAL_INPUT_PATH}'..."
  FILES=$(find ${LOCAL_INPUT_PATH} -name "*${LOCAL_INPUT_FILES}")
  for FILE in $FILES; do

    # do not grep for null ;)
    if [[ ! -z "${INPUT_EXCLUDE}" ]]; then
      if echo "${FILE}" | grep -q ${INPUT_EXCLUDE}
      then
          echo "skip -> ${FILE}"
          continue
      fi
    fi

    echo "lint ${FILE}"
    po-lint "${FILE}"
    RETVAL=$?
    if [ $RETVAL -ne 0 ]; then
      HAD_ERRORS=$(($HAD_ERRORS+1))
    fi
  done
}

if [[ -z "$INPUT_PATH" ]]; then
  echo "ERROR: input variable 'path' is not set"
  exit 1
fi

if [[ -z "$INPUT_FILES" ]]; then
  echo "ERROR: input variable 'files' is not set"
  exit 1
fi

# split path to arry
INPUT_PATHS=$(echo $INPUT_PATH | tr "," "\n")

for THEPATH in $INPUT_PATHS
do
  lint $INPUT_FILES $THEPATH
done

exit ${HAD_ERRORS}
