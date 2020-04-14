#!/bin/sh

INPUT_PATH=$1
INPUT_FILES=$2
INPUT_EXCLUDE=$3

echo "Linting '${INPUT_FILES}' files in directory '${INPUT_PATH}'..."
had_errors=0
for file in $(find ${INPUT_PATH} -name ${INPUT_FILES}); do
  # Exclude Grafana dashboards
  if echo "${file}" | grep -q ${INPUT_EXCLUDE}
  then
      echo "skip -> ${file}"
      continue
  fi

  po-lint "${file}"
  retval=$?
  if [ $retval -ne 0 ]; then
    had_errors=1
  fi
done
exit ${had_errors}
