#!/usr/bin/env bats

# global variables ############################################################
CONTAINER_NAME="prometheus-operator-lint-action"
CST_VERSION="latest" # version of GoogleContainerTools/container-structure-test
HADOLINT_VERSION="v1.18.0"

# build container to test the behavior ########################################
@test "build container" {
  docker build -t $CONTAINER_NAME -f src/Dockerfile . >&2
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

function start_container() {
  run docker run --rm \
  -v "$(pwd)/test/data:/mnt/" \
  -e INPUT_PATH=$INPUT_PATH \
  -e INPUT_FILES=$INPUT_FILES \
  -e INPUT_EXCLUDE=$INPUT_EXCLUDE \
  -i $CONTAINER_NAME
}

###############################################################################
## test cases #################################################################
###############################################################################

## linter #####################################################################
###############################################################################

# TODO: Add Superlinter
# https://github.com/github/super-linter/blob/master/docs/run-linter-locally.md
# docker run -e RUN_LOCAL=true -v $(pwd):/tmp/lint/file github/super-linter

@test "start hadolint" {
  docker run --rm -i hadolint/hadolint:$HADOLINT_VERSION < src/Dockerfile
  debug "${status}" "${output}" "${lines}"
  [[ "${status}" -eq 0 ]]
}

@test "start container-structure-test" {

  # init
  mkdir -p $HOME/bin
  export PATH=$PATH:$HOME/bin

  # check the os
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
          cst_os="linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
          cst_os="darwin"
  else
          skip "This test is not supported on your OS platform 😒"
  fi

  # donwload the container-structure-test binary
  cst_bin_name="container-structure-test-$cst_os-amd64"
  cst_download_url="https://storage.googleapis.com/container-structure-test/$CST_VERSION/$cst_bin_name"

  if [ ! -f "$HOME/bin/container-structure-test" ]; then
    curl -LO $cst_download_url
    chmod +x $cst_bin_name
    mv $cst_bin_name $HOME/bin/container-structure-test
  fi

  bash -c container-structure-test test --image ${IMAGE} -q --config test/structure_test.yaml

  debug "${status}" "${output}" "${lines}"

  [[ "${status}" -eq 0 ]]
}

## general cases ##############################################################
###############################################################################

@test "YAMLfiles are valid" {
  INPUT_PATH="/mnt/good_case_1"
  INPUT_FILES=".yaml"
  INPUT_EXCLUDE="skip"

  start_container

  debug "${status}" "${output}" "${lines}"

  [[ "${status}" -eq 0 ]]
}

@test "YAMLfiles are NOT valid" {
  INPUT_PATH="/mnt/bad_case_1"
  INPUT_FILES=".yaml"
  INPUT_EXCLUDE="skip"

  start_container

  debug "${status}" "${output}" "${lines}"

  [[ "${status}" -gt 0 ]]
}

## INPUT_FILES ################################################################
###############################################################################
@test "INPUT_FILES: lint .yaml" {
  INPUT_PATH="/mnt/good_case_1"
  INPUT_FILES=".yaml"
  INPUT_EXCLUDE="skip"

  start_container

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
  
  start_container

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

  start_container

  debug "${status}" "${output}" "${lines}"

  echo $output | grep -q "skip -> /mnt/good_case_1/skip/skip.yaml"
  [[ "${status}" -eq 0 ]]
}

@test "INPUT_EXCLUDE: directory has files which should be skipped" {
  INPUT_PATH="/mnt/good_case_1"
  INPUT_FILES=".yaml"

  start_container

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

  start_container

  debug "${status}" "${output}" "${lines}"

  echo $output | grep -q "ERROR: path '/foo/bar' dont exist"
  [[ "${status}" -eq 1 ]]
}

@test "INPUT_PATH: not defined" {
  INPUT_PATH=""

  start_container

  debug "${status}" "${output}" "${lines}"

  echo $output | grep -q "ERROR: input variable 'path' is not set"
  [[ "${status}" -eq 1 ]]
}

@test "INPUT_PATH: split by comma" {
  INPUT_PATH="/mnt/good_case_2,/mnt/good_case_3"
  INPUT_FILES=".yml"
  INPUT_EXCLUDE="skip"

  start_container

  debug "${status}" "${output}" "${lines}"

  echo $output | grep -q "lint /mnt/good_case_2/rules.yml"
  echo $output | grep -q "lint /mnt/good_case_3/rules.yml"
  [[ "${status}" -eq 0 ]]
}
