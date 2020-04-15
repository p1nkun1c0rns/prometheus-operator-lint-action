#!/bin/sh

INPUT_PATH=$1
if [[ -z "$INPUT_PATH" ]]; then
  echo "ERROR: input variable 'path' is not set"
  exit 1
fi

if [[ ! -d "$INPUT_PATH" ]]; then
  echo "ERROR: path '$INPUT_PATH' dont exist"
  exit 1
fi

INPUT_FILES=$2
if [[ -z "$INPUT_FILES" ]]; then
  echo "ERROR: input variable 'files' is not set"
  exit 1
fi

INPUT_EXCLUDE=$3

echo "Linting '${INPUT_FILES}' files in directory '${INPUT_PATH}'..."
had_errors=0
for file in $(find ${INPUT_PATH} -name ${INPUT_FILES}); do
  # Exclude Grafana dashboards

  # do not grep for null ;)
  if [[ ! -z "${INPUT_EXCLUDE}" ]]; then
    if echo "${file}" | grep -q ${INPUT_EXCLUDE}
    then
        echo "skip -> ${file}"
        continue
    fi
  fi

  po-lint "${file}"
  retval=$?
  if [ $retval -ne 0 ]; then
    had_errors=1
  fi
done
exit ${had_errors}
