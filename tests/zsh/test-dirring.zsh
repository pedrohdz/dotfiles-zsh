#! /usr/bin/env zsh

_SCRIPT_DIR=$(cd "$(dirname "${(%):-%x}")" && pwd)
source "$_SCRIPT_DIR/ztester.zsh"


#------------------------------------------------------------------------------
# Setup/teardown fixtures
#------------------------------------------------------------------------------
TERM=dumb
source "$_SCRIPT_DIR/../../home/.local/etc/zsh/config.d/800-dirring.zsh"

() {
  local _test_script_name
  _test_script_name=$(basename "${(%):-%x}")
  _TEST_DIRS="$(mktemp --directory -t $_test_script_name.XXXXXX)" \
    || exit 1

  printf "\nTest working directory: %s" "$_TEST_DIRS\n"

  mkdir -p "$_TEST_DIRS/a"
  mkdir -p "$_TEST_DIRS/b"
  mkdir -p "$_TEST_DIRS/c"
  mkdir -p "$_TEST_DIRS/d"
  mkdir -p "$_TEST_DIRS/e"
  mkdir -p "$_TEST_DIRS/f"
  mkdir -p "$_TEST_DIRS/g"
}

teardown() {
  if [[ -n "$_TEST_DIRS" ]] && [[ -d "$_TEST_DIRS" ]]; then
    rm -Rf "$_TEST_DIRS"
  fi
}
trap teardown EXIT

setup_each() {
  emulate -L zsh
  setopt localoptions no_unset no_auto_pushd

  pushd "$_TEST_DIRS/g"
  dirs -c
  pushd "$_TEST_DIRS/f"
  pushd "$_TEST_DIRS/e"
  pushd "$_TEST_DIRS/d"
  pushd "$_TEST_DIRS/c"
  pushd "$_TEST_DIRS/b"
  pushd "$_TEST_DIRS/a"
  pushd "$_TEST_DIRS"
}

#------------------------------------------------------------------------------
# Happy tests
#------------------------------------------------------------------------------
() {
  test_description "Happy test for 'd' command"
  setup_each

  local _expected_blob=
  IFS= read -r -d '' _expected_blob <<-EOT
		IdxF  IdxB  Path
		----  ----  ------------------------------
		            $_TEST_DIRS
		   1    -7  $_TEST_DIRS/a
		   2    -6  $_TEST_DIRS/b
		   3    -5  $_TEST_DIRS/c
		   4    -4  $_TEST_DIRS/d
		   5    -3  $_TEST_DIRS/e
		   6    -2  $_TEST_DIRS/f
		   7    -1  $_TEST_DIRS/g
		EOT

  local _expected_list=(
    "$_TEST_DIRS/a"
    "$_TEST_DIRS/b"
    "$_TEST_DIRS/c"
    "$_TEST_DIRS/d"
    "$_TEST_DIRS/e"
    "$_TEST_DIRS/f"
    "$_TEST_DIRS/g"
  )

  run_capture d

  assert_run_succeeded
  assert_run_stderr_equals ""
  assert_run_stdout_equals "$_expected_blob"
  assert_cwd_equals "$_TEST_DIRS"
  assert_dirstack_equals _expected_list
}

() {
  test_description "Happy test for 'd 0' command"
  setup_each

  local _expected_blob=
  IFS= read -r -d '' _expected_blob <<-EOT
		IdxF  IdxB  Path
		----  ----  ------------------------------
		            $_TEST_DIRS
		   1    -7  $_TEST_DIRS/a
		   2    -6  $_TEST_DIRS/b
		   3    -5  $_TEST_DIRS/c
		   4    -4  $_TEST_DIRS/d
		   5    -3  $_TEST_DIRS/e
		   6    -2  $_TEST_DIRS/f
		   7    -1  $_TEST_DIRS/g
		EOT

  local _expected_list=(
    "$_TEST_DIRS/a"
    "$_TEST_DIRS/b"
    "$_TEST_DIRS/c"
    "$_TEST_DIRS/d"
    "$_TEST_DIRS/e"
    "$_TEST_DIRS/f"
    "$_TEST_DIRS/g"
  )

  run_capture d 0

  assert_run_succeeded
  assert_run_stderr_equals ""
  assert_run_stdout_equals "$_expected_blob"
  assert_cwd_equals "$_TEST_DIRS"
  assert_dirstack_equals _expected_list
}

#------------------------------------------------------------------------------
# Normal ring operations
#------------------------------------------------------------------------------
() {
  test_description "backwards '+1' with 'd' command"
  setup_each

  local _expected=(
    "$_TEST_DIRS/b"
    "$_TEST_DIRS/c"
    "$_TEST_DIRS/d"
    "$_TEST_DIRS/e"
    "$_TEST_DIRS/f"
    "$_TEST_DIRS/g"
    "$_TEST_DIRS"
  )

  run_capture d +1
  # run_capture pushd -6

  assert_run_succeeded
  assert_run_stderr_equals \
    "Rotated forward to: $_TEST_DIRS/a"$'\n'
  assert_run_stdout_equals ""
  assert_cwd_equals "$_TEST_DIRS/a"
  assert_dirstack_equals _expected
}

() {
  test_description "Forward '+3' with 'd' command"
  setup_each

  local _expected=(
    "$_TEST_DIRS/d"
    "$_TEST_DIRS/e"
    "$_TEST_DIRS/f"
    "$_TEST_DIRS/g"
    "$_TEST_DIRS"
    "$_TEST_DIRS/a"
    "$_TEST_DIRS/b"
  )

  run_capture d +3

  assert_run_succeeded
  assert_run_stderr_equals \
    "Rotated forward to: $_TEST_DIRS/c"$'\n'
  assert_run_stdout_equals ""
  assert_cwd_equals "$_TEST_DIRS/c"
  assert_dirstack_equals _expected
}

() {
  test_description "Forward '+7' with 'd' command"
  setup_each

  local _expected=(
    "$_TEST_DIRS"
    "$_TEST_DIRS/a"
    "$_TEST_DIRS/b"
    "$_TEST_DIRS/c"
    "$_TEST_DIRS/d"
    "$_TEST_DIRS/e"
    "$_TEST_DIRS/f"
  )

  run_capture d +7

  assert_run_succeeded
  assert_run_stderr_equals \
    "Rotated forward to: $_TEST_DIRS/g"$'\n'
  assert_run_stdout_equals ""
  assert_cwd_equals "$_TEST_DIRS/g"
  assert_dirstack_equals _expected
}

() {
  test_description "backwards '-3' with 'd' command"
  setup_each

  local _expected=(
    "$_TEST_DIRS/f"
    "$_TEST_DIRS/g"
    "$_TEST_DIRS"
    "$_TEST_DIRS/a"
    "$_TEST_DIRS/b"
    "$_TEST_DIRS/c"
    "$_TEST_DIRS/d"
  )

  run_capture d -3
  # run_capture pushd -2

  assert_run_succeeded
  assert_run_stderr_equals \
    "Rotated backward to: $_TEST_DIRS/e"$'\n'
  assert_run_stdout_equals ""
  assert_cwd_equals "$_TEST_DIRS/e"
  assert_dirstack_equals _expected
}

() {
  test_description "backwards '-7' with 'd' command"
  setup_each

  local _expected=(
    "$_TEST_DIRS/b"
    "$_TEST_DIRS/c"
    "$_TEST_DIRS/d"
    "$_TEST_DIRS/e"
    "$_TEST_DIRS/f"
    "$_TEST_DIRS/g"
    "$_TEST_DIRS"
  )

  run_capture d -7
  # run_capture pushd -6

  assert_run_succeeded
  assert_run_stderr_equals \
    "Rotated backward to: $_TEST_DIRS/a"$'\n'
  assert_run_stdout_equals ""
  assert_cwd_equals "$_TEST_DIRS/a"
  assert_dirstack_equals _expected
}


#------------------------------------------------------------------------------
# Indexes out of bounds tests
#------------------------------------------------------------------------------
() {
  test_description "Fail on above range on 'd' command"
  setup_each

  local _expected_list=(
    "$_TEST_DIRS/a"
    "$_TEST_DIRS/b"
    "$_TEST_DIRS/c"
    "$_TEST_DIRS/d"
    "$_TEST_DIRS/e"
    "$_TEST_DIRS/f"
    "$_TEST_DIRS/g"
  )

  run_capture d -8

  assert_run_failed
  assert_run_stderr_equals \
    "ERROR - Dirstack index of '-8' is out of range.  The index must be between '7' and '-7'."$'\n'
  assert_run_stdout_equals ""
  assert_cwd_equals "$_TEST_DIRS"
  assert_dirstack_equals _expected_list
}

() {
  test_description "Fail on below range on 'd' command"
  setup_each

  local _expected_list=(
    "$_TEST_DIRS/a"
    "$_TEST_DIRS/b"
    "$_TEST_DIRS/c"
    "$_TEST_DIRS/d"
    "$_TEST_DIRS/e"
    "$_TEST_DIRS/f"
    "$_TEST_DIRS/g"
  )

  run_capture d +8

  assert_run_failed
  assert_run_stderr_equals \
    "ERROR - Dirstack index of '8' is out of range.  The index must be between '7' and '-7'."$'\n'
  assert_run_stdout_equals ""
  assert_cwd_equals "$_TEST_DIRS"
  assert_dirstack_equals _expected_list
}


#------------------------------------------------------------------------------
# Test inverse operations
#------------------------------------------------------------------------------
_test_inverse_d_operations() {
  local _index=$1
  local _inverse_index=$(( -_index ))
  test_description "Inverse opetations with 'd' command ($_index/$_inverse_index)"
  setup_each

  local _expected_list=(
    "$_TEST_DIRS/a"
    "$_TEST_DIRS/b"
    "$_TEST_DIRS/c"
    "$_TEST_DIRS/d"
    "$_TEST_DIRS/e"
    "$_TEST_DIRS/f"
    "$_TEST_DIRS/g"
  )

  d "$_index" &> /dev/null \
    || fail "Failed to run 'd %s'." "$_index"
  d "$_inverse_index" &> /dev/null \
    || fail "Failed to run 'd %s'." "$_index"
  run_capture d

  assert_run_succeeded
  assert_run_stderr_equals ""
  assert_cwd_equals "$_TEST_DIRS"
  assert_dirstack_equals _expected_list
}

() {
  local _index
  for _index in 7 5 1; do
    _test_inverse_d_operations "$_index"
    _test_inverse_d_operations "$(( -_index ))"
  done
}


#------------------------------------------------------------------------------
# Test empty stack
#------------------------------------------------------------------------------
setup_each_empty_stack() {
  emulate -L zsh
  setopt localoptions no_unset no_auto_pushd

  pushd "$_TEST_DIRS"
  dirs -c
}

_test_fail_on_empty_stack() {
  local _index=$1
  test_description "Empty stack with 'd $_index'"
  setup_each_empty_stack

  local _expected_list=()

  run_capture d "$_index"

  assert_run_failed
  assert_run_stderr_equals \
    "ERROR - Dirstack is empty."$'\n'
  assert_run_stdout_equals ""
  assert_cwd_equals "$_TEST_DIRS"
  assert_dirstack_equals _expected_list
}

() {
  local _index
  for _index in 10000 6 1 -1 -4 -9999; do
    _test_fail_on_empty_stack "$_index"
  done
}

() {
  test_description "Empty stack displays list on 'd 0' command"
  setup_each_empty_stack

  IFS= read -r -d '' _expected_blob <<-EOT
		IdxF  IdxB  Path
		----  ----  ----------------------------
		            $_TEST_DIRS
		EOT

  local _expected_list=()

  run_capture d 0

  assert_run_succeeded
  assert_run_stderr_equals ""
  assert_run_stdout_equals "$_expected_blob"
  assert_cwd_equals "$_TEST_DIRS"
  assert_dirstack_equals _expected_list
}


#------------------------------------------------------------------------------
# Finalize
#------------------------------------------------------------------------------
finalize_tests
