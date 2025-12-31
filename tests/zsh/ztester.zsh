#! /usr/bin/env zsh

run_return_code=0
run_stderr_lines=()
run_stderr_blob=""
run_stdout_lines=()
run_stdout_blob=""

run_capture() {
  emulate -L zsh
  local _cmd_array=("$@")

  # Reset globals
  run_return_code=0
  run_stderr_lines=()
  run_stdout_lines=()
  run_stderr_blob=""
  run_stdout_blob=""

  local _tmp_stdout _tmp_stderr
  _tmp_stdout="$(mktemp -t zsh_run_capture_stdout.XXXXXX)" \
    || return 1
  _tmp_stderr="$(mktemp -t zsh_run_capture_stderr.XXXXXX)" \
    || { rm -f -- "$_tmp_stdout"; return 1 }

  {
    #----
    # Run the wrapped command
    #----
    "${_cmd_array[@]}" \
      >"$_tmp_stdout" \
      2>"$_tmp_stderr"
    local _return_code=$?

    #----
    # Extract the stdout and stderr lines into arrays
    #----
    local _stdout_line=""
    if [[ -s "$_tmp_stdout" ]]; then
      while IFS= read -r _stdout_line || [[ -n $_stdout_line ]]; do
        run_stdout_lines+=("$_stdout_line")
      done <"$_tmp_stdout"
    fi

    local _stderr_line=""
    if [[ -s "$_tmp_stderr" ]]; then
      while IFS= read -r _stderr_line || [[ -n $_stderr_line ]]; do
        run_stderr_lines+=("$_stderr_line")
      done <"$_tmp_stderr"
    fi

    #----
    # Extract scalars
    #----
    # NOTE - Things might break if stdout or stderr contain NULLs.
    # run_stdout_blob=$(cat -- "$_tmp_stdout")
    run_stdout_blob=$(cat -- "$_tmp_stdout"; printf '\0')
    run_stdout_blob=${run_stdout_blob%$'\0'}

    run_stderr_blob=$(cat -- "$_tmp_stderr"; printf '\0')
    run_stderr_blob=${run_stderr_blob%$'\0'}

    run_return_code=$_return_code
  } always {
    rm -f -- "$_tmp_stdout" "$_tmp_stderr"
  }

  return $_return_code
}


fail_count=0
fail() {
  (( fail_count++ ))
  local _message _first_line _rest
  _message=$(printf "$@")
  _first_line=${_message%%$'\n'*}

  if [[ $_message == *$'\n'* ]]; then
    _rest=${_message#"$_first_line"$'\n'}
    printf "FAILED(%d) - %s\n" "$fail_count" "$_first_line"
    printf '>>>>\n%s\n<<<<\n\n' "$_rest"
  else
    printf "FAILED(%d) - %s\n" "$fail_count" "$_message"
  fi
}

pass_count=0
pass() {
  (( pass_count++ ))
  local _message
  _message=$(printf "$@")

  printf "PASSED(%d) - %s\n" "$pass_count" "$_message"
}

assert_run_succeeded() {
  if [[ $run_return_code -eq 0 ]]; then
    pass "Command succeeded as expected."
  else
    fail "Expected command to succeed, but it failed with code %d.\nSTDOUT:\n%s\nSTDERR:\n%s\n" \
      "$run_return_code" \
      "$(printf '%s\n' "$run_stdout_blob")" \
      "$(printf '%s\n' "$run_stderr_blob")"
  fi
}

assert_run_failed() {
  if [[ $run_return_code -ne 0 ]]; then
    pass "Command failed as expected."
  else
    fail "Expected command to failed, but it succeeded with code %d.\nSTDOUT:\n%s\nSTDERR:\n%s\n" \
      "$run_return_code" \
      "$(printf '%s\n' "$run_stdout_blob")" \
      "$(printf '%s\n' "$run_stderr_blob")"
  fi
}

assert_dirstack_equals() {
  local _expected_dirstack=( "${(P)1[@]}" )
  local -a _actual_dirstack=( "${dirstack[@]}" )

  if [[ ${#_expected_dirstack[@]} -ne ${#_actual_dirstack[@]} ]]; then
    fail "Length mismatch %d != %d\nExpected list:\n%s\n\nGot list:\n%s\n" \
      ${#_expected_dirstack[@]} \
      ${#_actual_dirstack[@]} \
      "$(printf '%s\n' "${_expected_dirstack[@]}")" \
      "$(printf '%s\n' "${_actual_dirstack[@]}")"
    return 1
  fi

  for i in {1..$#_expected_dirstack}; do
    if [[ ${_expected_dirstack[i]} != ${_actual_dirstack[i]} ]]; then
      fail "Different at index [%d]\n%s !=\n%s\n\nExpected list:\n%s\n\nGot list:\n%s\n" \
        "$i" \
        "${_expected_dirstack[$i]}" \
        "${_actual_dirstack[$i]}" \
        "$(printf '%s\n' "${_expected_dirstack[@]}")" \
        "$(printf '%s\n' "${_actual_dirstack[@]}")"
      return 1
    fi
  done

  pass "Items in 'dirstack' matches expected."
}

assert_cwd_equals() {
  local _expected_cwd=$1
  if [[ "$PWD" != "$_expected_cwd" ]]; then
    fail "CWD does not match expected.\n%s !=\n%s" \
      "$_expected_cwd" \
      "$PWD"
    return 1
  fi

  pass "CWD matches expected."
}

_assert_run_blob_equals() {
  local _stream_label="$1"
  local _actual_blob="$2"
  local _expected_blob="$3"

  local _diff_output _diff_status
  _diff_output=$(
    diff -u \
      <(printf '%s\n' "$_actual_blob") \
      <(printf '%s\n' "$_expected_blob")
  )
  _diff_status=$?

  if [[ $_diff_status -eq 0 ]]; then
    pass "$_stream_label matched expected output."
  else
    fail "$_stream_label did not match expected output.\nDiff:\n%s\nExpected:\n%s\nGot:\n%s\n" \
      "$(printf '%s\n' "$_diff_output")" \
      "$(printf '%s\n' "$_expected_blob")" \
      "$(printf '%s\n' "$_actual_blob")"
  fi
}

assert_run_stdout_equals() {
  _assert_run_blob_equals "STDOUT" "$run_stdout_blob" "$1"
}

assert_run_stderr_equals() {
  _assert_run_blob_equals "STDERR" "$run_stderr_blob" "$1"
}

test_description() {
  local _desc="$1"
  printf "\n=== TEST: %s ===\n" "$_desc"
}

finalize_tests() {
  printf '\n===============================================================================\n'
  printf "Tests completed:\n  Passed asserts: %d\n  Failed asserts: %d\n  Total asserts:  %d\n" \
    $pass_count \
    $fail_count \
    $(( fail_count + pass_count ))

  if [[ $fail_count == 0 ]]; then
    exit 0
  else
    exit 1
  fi

}
