#!/usr/bin/env bats

# global variables ############################################################
CONTAINER_NAME="prometheus-operator-lint-action"

# build container to test the behavior ########################################
@test "build container" {
  docker build -t $CONTAINER_NAME . >&2
}

# functions ###################################################################
debug() {
  status="$1"
  output="$2"
  if [[ ! "${status}" -eq "0" ]]; then
  echo "status: ${status}"
  echo "output: ${output}"
  fi
}

## test cases #################################################################

@test "Happy path 🥰" {
  INPUT_PATH="/mnt/good_case_1"
  INPUT_FILES="*.yaml"
  INPUT_EXCLUDE="skip"

  run docker run --rm \
  -v "$(pwd)/tests/data:/mnt/" \
  -i $CONTAINER_NAME \
  $INPUT_PATH $INPUT_FILES $INPUT_EXCLUDE

  debug "${status}" "${output}" "${lines}"

  [[ "${status}" -eq 0 ]]
  echo $output | grep -q "$INPUT_PATH"
  echo $output | grep -q "$INPUT_FILES"
  echo $output | grep -q "$INPUT_EXCLUDE"
}

@test "INPUT_PATH directory has files which are skipped" {
  INPUT_PATH="/mnt/good_case_2"
  INPUT_FILES="*.yaml"
  INPUT_EXCLUDE="skip"

  run docker run --rm \
  -v "$(pwd)/tests/data:/mnt/" \
  -i $CONTAINER_NAME \
  $INPUT_PATH $INPUT_FILES $INPUT_EXCLUDE

  debug "${status}" "${output}" "${lines}"

  [[ "${status}" -eq 0 ]]
}

@test "YAMLfiles are not valid" {
  INPUT_PATH="/mnt/bad_case_1"
  INPUT_FILES="*.yaml"
  INPUT_EXCLUDE="skip"

  run docker run --rm \
  -v "$(pwd)/tests/data:/mnt/" \
  -i $CONTAINER_NAME \
  $INPUT_PATH $INPUT_FILES $INPUT_EXCLUDE

  debug "${status}" "${output}" "${lines}"

  [[ "${status}" -eq 1 ]]
}

@test "INPUT_PATH directory has files which should be skipped" {
  INPUT_PATH="/mnt/good_case_1"
  INPUT_FILES="*.yaml"

  run docker run --rm \
  -v "$(pwd)/tests/data:/mnt/" \
  -i $CONTAINER_NAME \
  $INPUT_PATH $INPUT_FILES $INPUT_EXCLUDE

  debug "${status}" "${output}" "${lines}"

  echo $output | grep -q "$INPUT_PATH"
  echo $output | grep -q "$INPUT_FILES"
  echo $output | grep -q "error unmarshaling JSON: json: cannot unmarshal string into Go value of type v1.TypeMeta"
  [[ "${status}" -eq 1 ]]
}
