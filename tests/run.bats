#!/usr/bin/env bats

# global variables ############################################################
CONTAINER_NAME="prometheus-operator-lint-action"

# build container to test the behavior ########################################
@test "build container" {
  docker build -t $CONTAINER_NAME . >&2
}

# functions ###################################################################

function setup() {
  unset INPUT_PATH
  unset INPUT_FILES
  unset INPUT_EXCLUDE
}

function debug() {
  status="$1"
  output="$2"
  if [[ ! "${status}" -eq "0" ]]; then
  echo "status: ${status}"
  echo "output: ${output}"
  fi
}

###############################################################################
## test cases #################################################################
###############################################################################

## general cases ##############################################################
###############################################################################

@test "YAMLfiles are valid" {
  INPUT_PATH="/mnt/good_case_1"
  INPUT_FILES=".yaml"
  INPUT_EXCLUDE="skip"

  run docker run --rm \
  -v "$(pwd)/tests/data:/mnt/" \
  -i $CONTAINER_NAME \
  $INPUT_PATH $INPUT_FILES $INPUT_EXCLUDE

  debug "${status}" "${output}" "${lines}"

  [[ "${status}" -eq 0 ]]
}

@test "YAMLfiles are NOT valid" {
  INPUT_PATH="/mnt/bad_case_1"
  INPUT_FILES=".yaml"
  INPUT_EXCLUDE="skip"

  run docker run --rm \
  -v "$(pwd)/tests/data:/mnt/" \
  -i $CONTAINER_NAME \
  $INPUT_PATH $INPUT_FILES $INPUT_EXCLUDE

  debug "${status}" "${output}" "${lines}"

  [[ "${status}" -eq 1 ]]
}

## INPUT_FILES ################################################################
###############################################################################
@test "INPUT_FILES: lint .yaml" {
  INPUT_PATH="/mnt/good_case_1"
  INPUT_FILES=".yaml"
  INPUT_EXCLUDE="skip"

  run docker run --rm \
  -v "$(pwd)/tests/data:/mnt/" \
  -i $CONTAINER_NAME \
  $INPUT_PATH $INPUT_FILES $INPUT_EXCLUDE

  debug "${status}" "${output}" "${lines}"

  echo $output | grep -q "$INPUT_PATH"
  echo $output | grep -q "$INPUT_FILES"
  echo $output | grep -q "$INPUT_EXCLUDE"
  echo $output | grep -q "lint /mnt/good_case_1/servicemonitor.yaml"
  echo $output | grep -q "lint /mnt/good_case_1/rules.yaml"
  echo $output | grep -q "skip -> /mnt/good_case_1/skip/skip.yaml"
  [[ "${status}" -eq 0 ]]
}

@test "INPUT_FILES: lint .yml" {
  INPUT_PATH="/mnt/good_case_2"
  INPUT_FILES=".yml"

  run docker run --rm \
  -v "$(pwd)/tests/data:/mnt/" \
  -i $CONTAINER_NAME \
  $INPUT_PATH $INPUT_FILES

  echo "${status}" "${output}" "${lines}"

  echo $output | grep -q "$INPUT_PATH"
  echo $output | grep -q "$INPUT_FILES"
  echo $output | grep -q "lint /mnt/good_case_2/servicemonitor.yml"
  echo $output | grep -q "lint /mnt/good_case_2/rules.yml"
  [[ "${status}" -eq 0 ]]
}

## INPUT_EXCLUDE ##############################################################
###############################################################################

@test "INPUT_EXCLUDE: directory has files which are skipped" {
  INPUT_PATH="/mnt/good_case_1"
  INPUT_FILES=".yaml"
  INPUT_EXCLUDE="skip"

  run docker run --rm \
  -v "$(pwd)/tests/data:/mnt/" \
  -i $CONTAINER_NAME \
  $INPUT_PATH $INPUT_FILES $INPUT_EXCLUDE

  debug "${status}" "${output}" "${lines}"

  echo $output | grep -q "skip -> /mnt/good_case_1/skip/skip.yaml"
  [[ "${status}" -eq 0 ]]
}

@test "INPUT_EXCLUDE: directory has files which should be skipped" {
  INPUT_PATH="/mnt/good_case_1"
  INPUT_FILES=".yaml"

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

## INPUT_PATH #################################################################
###############################################################################

@test "INPUT_PATH: directory dont exist" {
  INPUT_PATH="/foo/bar"
  INPUT_FILES=".yaml"

  run docker run --rm \
  -v "$(pwd)/tests/data:/mnt/" \
  -i $CONTAINER_NAME \
  $INPUT_PATH $INPUT_FILES $INPUT_EXCLUDE

  debug "${status}" "${output}" "${lines}"

  echo $output | grep -q "ERROR: path '/foo/bar' dont exist"
  [[ "${status}" -eq 1 ]]
}

@test "INPUT_PATH: not defined" {
  INPUT_PATH=""

  run docker run --rm \
  -v "$(pwd)/tests/data:/mnt/" \
  -i $CONTAINER_NAME \
  $INPUT_PATH

  debug "${status}" "${output}" "${lines}"

  echo $output | grep -q "ERROR: input variable 'path' is not set"
  [[ "${status}" -eq 1 ]]
}
