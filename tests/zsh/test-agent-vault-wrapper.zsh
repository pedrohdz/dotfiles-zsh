#! /usr/bin/env zsh

_SCRIPT_DIR=$(cd "$(dirname "${(%):-%x}")" && pwd)
source "$_SCRIPT_DIR/ztester.zsh"


#------------------------------------------------------------------------------
# Setup/teardown fixtures
#------------------------------------------------------------------------------
# The wrapper runs a fake agent-vault that prints its arguments one per line,
# so a test sees the vault, the final env(1) assignments and the command
# without running anything. faketool is a do-nothing command on PATH, and
# faketool-drounin is a symlink to the wrapper for symlink mode.
_REPO_HOME="$(cd "$_SCRIPT_DIR/../../home" && pwd)"
_WRAPPER="$_REPO_HOME/.local/bin/agent-vault-wrapper"
_VAULT=drounin-agent-read-only

() {
  local _test_script_name
  _test_script_name=$(basename "${(%):-%x}")
  _T="$(mktemp --directory -t $_test_script_name.XXXXXX)" \
    || exit 1

  printf "\nTest working directory: %s\n" "$_T"

  mkdir -p "$_T/bin"
  printf '#!/bin/sh\nprintf "%%s\\n" "$@"\n' > "$_T/bin/agent-vault"
  printf '#!/bin/sh\n' > "$_T/bin/faketool"
  chmod +x "$_T/bin/agent-vault" "$_T/bin/faketool"
  ln -s "$_WRAPPER" "$_T/bin/faketool-drounin"
  ln -s "$_WRAPPER" "$_T/bin/.x-drounin"
}

teardown() {
  if [[ -n "$_T" ]] && [[ -d "$_T" ]]; then
    rm -Rf "$_T"
  fi
}
trap teardown EXIT

# Fresh config directory with an empty envs/ and no tools/.
setup_each() {
  rm -Rf "$_T/config"
  mkdir -p "$_T/config/envs"
}

# write_lines <path under config/> [LINE...]
write_lines() {
  local _path="$_T/config/$1"
  shift
  mkdir -p "${_path:h}"
  printf '%s\n' "$@" > "$_path"
}

# avw <wrapper path> [ARGS...]: run the wrapper against the test config.
avw() {
  run_capture env \
    AGENT_VAULT_WRAPPER_DIR="$_T/config" \
    AGENT_VAULT_BIN="$_T/bin/agent-vault" \
    AGENT_VAULT_WRAPPER_LIB="$_REPO_HOME/.local/lib/agent-vault-wrapper" \
    PATH="$_T/bin:$PATH" \
    "$@"
}

# expected_exec <vault> <cmd> [KEY=VALUE...]: what the fake agent-vault
# prints, in REPLY.
expected_exec() {
  local _vault="$1"
  local _cmd="$2"
  shift 2
  REPLY="$(printf '%s\n' run --vault "$_vault" -- env "$@" "$_cmd")"$'\n'
}

# lines [LINE...]: the lines joined with a trailing newline, in REPLY.
lines() {
  REPLY="$(printf '%s\n' "$@")"$'\n'
}


#------------------------------------------------------------------------------
# Symlink mode: tool manifests
#------------------------------------------------------------------------------
() {
  test_description "Symlink mode, no manifest and no tool env: common.env only"
  setup_each
  write_lines envs/common.env "# comment" "C=1"

  avw "$_T/bin/faketool-drounin"

  assert_run_succeeded
  expected_exec "$_VAULT" faketool C=1
  assert_run_stdout_equals "$REPLY"
  lines "faketool-drounin: $_VAULT → faketool"
  assert_run_stderr_equals "$REPLY"
}

() {
  test_description "Symlink mode, no manifest: envs/<tool>.env after common.env"
  setup_each
  write_lines envs/common.env "C=1"
  write_lines envs/faketool.env "T=1"

  avw "$_T/bin/faketool-drounin" arg1

  assert_run_succeeded
  REPLY="$(printf '%s\n' run --vault "$_VAULT" -- env C=1 T=1 faketool arg1)"$'\n'
  assert_run_stdout_equals "$REPLY"
  lines "faketool-drounin: $_VAULT → faketool"
  assert_run_stderr_equals "$REPLY"
}

() {
  test_description "Symlink mode, manifest: listed envs in order, then the tool's own"
  setup_each
  write_lines envs/common.env "C=1"
  write_lines envs/b.env "B=1"
  write_lines envs/a.env "A=1"
  write_lines envs/sub/x.env "X=1"
  write_lines envs/faketool.env "T=1"
  write_lines tools/faketool "# shared envs" "" "b" "  # indented comment" "a" "sub/x"

  avw "$_T/bin/faketool-drounin"

  assert_run_succeeded
  expected_exec "$_VAULT" faketool C=1 B=1 A=1 X=1 T=1
  assert_run_stdout_equals "$REPLY"
  lines "faketool-drounin: $_VAULT → faketool"
  assert_run_stderr_equals "$REPLY"
}

() {
  test_description "Symlink mode, manifest naming a missing env fails"
  setup_each
  write_lines tools/faketool "nope"

  avw "$_T/bin/faketool-drounin"

  assert_run_failed
  assert_run_stdout_equals ""
  lines "FATAL - $_T/config/tools/faketool:1: no env file named 'nope': $_T/config/envs/nope.env"
  assert_run_stderr_equals "$REPLY"
}

() {
  local _name
  for _name in "../x" "a//b" "a " "/a" ".a"; do
    test_description "Symlink mode, manifest with invalid name '$_name' fails"
    setup_each
    write_lines envs/a.env "A=1"
    write_lines tools/faketool "$_name"

    avw "$_T/bin/faketool-drounin"

    assert_run_failed
    assert_run_stdout_equals ""
    lines "FATAL - $_T/config/tools/faketool:1: invalid env name '$_name' (letters, digits, '.', '_', '-', with '/' between non-empty components; a component may not start with '.')"
    assert_run_stderr_equals "$REPLY"
  done
}

() {
  test_description "Symlink mode, manifest listing common, itself or a repeat: warned and skipped"
  setup_each
  write_lines envs/common.env "C=1"
  write_lines envs/a.env "A=1"
  write_lines envs/faketool.env "T=1"
  write_lines tools/faketool "a" "common" "faketool" "a"

  avw "$_T/bin/faketool-drounin"

  assert_run_succeeded
  expected_exec "$_VAULT" faketool C=1 A=1 T=1
  assert_run_stdout_equals "$REPLY"
  lines \
    "WARN - $_T/config/tools/faketool:2: 'common' always loads; skipped" \
    "WARN - $_T/config/tools/faketool:3: 'faketool' always loads; skipped" \
    "WARN - $_T/config/tools/faketool:4: 'a' already listed; skipped" \
    "faketool-drounin: $_VAULT → faketool"
  assert_run_stderr_equals "$REPLY"
}

() {
  test_description "Symlink mode, invalid tool name fails"
  setup_each

  avw "$_T/bin/.x-drounin"

  assert_run_failed
  assert_run_stdout_equals ""
  lines "FATAL - Invalid tool name '.x' (letters, digits, '.', '_'; may not start with '.')"
  assert_run_stderr_equals "$REPLY"
}


#------------------------------------------------------------------------------
# Overrides
#------------------------------------------------------------------------------
() {
  test_description "File over file: warns naming both places, later value used"
  setup_each
  write_lines envs/common.env "K=common" "C=1"
  write_lines envs/a.env "K=a"
  write_lines tools/faketool "a"

  avw "$_T/bin/faketool-drounin"

  assert_run_succeeded
  expected_exec "$_VAULT" faketool K=a C=1
  assert_run_stdout_equals "$REPLY"
  lines \
    "WARN - K set in $_T/config/envs/common.env:1 and $_T/config/envs/a.env:1; using $_T/config/envs/a.env:1 (fix the config)" \
    "faketool-drounin: $_VAULT → faketool"
  assert_run_stderr_equals "$REPLY"
}

() {
  test_description "File over file with the same value still warns"
  setup_each
  write_lines envs/common.env "K=same"
  write_lines envs/faketool.env "K=same"

  avw "$_T/bin/faketool-drounin"

  assert_run_succeeded
  expected_exec "$_VAULT" faketool K=same
  assert_run_stdout_equals "$REPLY"
  lines \
    "WARN - K set in $_T/config/envs/common.env:1 and $_T/config/envs/faketool.env:1; using $_T/config/envs/faketool.env:1 (fix the config)" \
    "faketool-drounin: $_VAULT → faketool"
  assert_run_stderr_equals "$REPLY"
}

() {
  test_description "--env wins over a file even when given first, and warns"
  setup_each
  write_lines f.env "K=file" "F=1"

  avw "$_WRAPPER" --vault v --env K=param --env-file "$_T/config/f.env" -- faketool

  assert_run_succeeded
  expected_exec v faketool K=param F=1
  assert_run_stdout_equals "$REPLY"
  lines \
    "WARN - K from $_T/config/f.env:1 overridden by --env" \
    "agent-vault-wrapper: v → faketool"
  assert_run_stderr_equals "$REPLY"
}

() {
  test_description "--env given twice: warns, last value used"
  setup_each

  avw "$_WRAPPER" --vault v --env K=1 --env K=2 -- faketool

  assert_run_succeeded
  expected_exec v faketool K=2
  assert_run_stdout_equals "$REPLY"
  lines \
    "WARN - K given twice with --env; using the last" \
    "agent-vault-wrapper: v → faketool"
  assert_run_stderr_equals "$REPLY"
}


#------------------------------------------------------------------------------
# Unchanged behaviour
#------------------------------------------------------------------------------
() {
  test_description "--env-all loads top-level envs except common, no subdirectories"
  setup_each
  write_lines envs/common.env "C=1"
  write_lines envs/b.env "B=1"
  write_lines envs/a.env "A=1"
  write_lines envs/sub/x.env "X=1"

  avw "$_WRAPPER" --vault v --env-all -- faketool

  assert_run_succeeded
  expected_exec v faketool C=1 A=1 B=1
  assert_run_stdout_equals "$REPLY"
  lines \
    "agent-vault-wrapper: --env-all loaded: a b" \
    "agent-vault-wrapper: v → faketool"
  assert_run_stderr_equals "$REPLY"
}


#------------------------------------------------------------------------------
# Finalize
#------------------------------------------------------------------------------
finalize_tests
