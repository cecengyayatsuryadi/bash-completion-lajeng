#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"

source "$project_dir/lajeng-completion.sh"

pass_count=0

assert_contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      pass_count=$((pass_count + 1))
      return 0
    fi
  done
  echo "FAIL: expected '$needle' in [${*}]" >&2
  exit 1
}

assert_not_contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      echo "FAIL: expected '$needle' NOT in [${*}]" >&2
      exit 1
    fi
  done
  pass_count=$((pass_count + 1))
}

assert_file_line_count() {
  local expected="$1"
  local needle="$2"
  local file="$3"
  local actual

  actual="$(grep -Fxc -- "$needle" "$file" || true)"
  if [[ "$actual" != "$expected" ]]; then
    echo "FAIL: expected $expected lines matching '$needle' in $file, got $actual" >&2
    exit 1
  fi
  pass_count=$((pass_count + 1))
}

assert_string_contains() {
  local needle="$1"
  local haystack="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "FAIL: expected text to contain '$needle': $haystack" >&2
    exit 1
  fi
  pass_count=$((pass_count + 1))
}

run_completion() {
  local -a words=("$@")
  COMP_WORDS=("${words[@]}")
  COMP_CWORD=$((${#words[@]} - 1))
  COMPREPLY=()
  _lajeng_completion
}

# Case 1: root subcommands.
export LAJENG_COMPLETION_CONFIG="$project_dir/test/fixtures/valid.conf"
LAJENG_COMPLETION_RELOAD=1
run_completion lajeng ""
assert_contains deploy "${COMPREPLY[@]}"
assert_contains config "${COMPREPLY[@]}"

# Case 2: subcommand flag filtering and context.
LAJENG_COMPLETION_RELOAD=1
run_completion lajeng deploy --
assert_contains --env "${COMPREPLY[@]}"
assert_contains --profile "${COMPREPLY[@]}"
assert_not_contains --set "${COMPREPLY[@]}"

# Case 3: value suggestion from config.
LAJENG_COMPLETION_RELOAD=1
run_completion lajeng deploy --env ""
assert_contains dev "${COMPREPLY[@]}"
assert_contains staging "${COMPREPLY[@]}"

# Case 4: unknown config key does not break parsing.
export LAJENG_COMPLETION_CONFIG="$project_dir/test/fixtures/unknown-key.conf"
LAJENG_COMPLETION_RELOAD=1
run_completion lajeng deploy --profile ""
assert_contains default "${COMPREPLY[@]}"
assert_contains qa "${COMPREPLY[@]}"

# Case 5: missing config fallback to defaults.
export LAJENG_COMPLETION_CONFIG="$project_dir/test/fixtures/does-not-exist.conf"
LAJENG_COMPLETION_RELOAD=1
run_completion lajeng deploy --namespace ""
assert_contains core "${COMPREPLY[@]}"

# Case 6: used flags are not re-suggested.
export LAJENG_COMPLETION_CONFIG="$project_dir/test/fixtures/valid.conf"
LAJENG_COMPLETION_RELOAD=1
run_completion lajeng deploy --env prod --
assert_not_contains --env "${COMPREPLY[@]}"

# Case 7: positional suggestions for deploy.
LAJENG_COMPLETION_RELOAD=1
run_completion lajeng deploy ""
assert_contains api "${COMPREPLY[@]}"
assert_contains web "${COMPREPLY[@]}"
assert_not_contains --env "${COMPREPLY[@]}"

# Case 8: single-letter prefix returns matches.
LAJENG_COMPLETION_RELOAD=1
run_completion lajeng d
assert_contains deploy "${COMPREPLY[@]}"

# Case 9: contains fallback works when prefix has no hit.
LAJENG_COMPLETION_RELOAD=1
run_completion lajeng ep
assert_contains deploy "${COMPREPLY[@]}"

# Case 10: no contains fallback noise in subcommand context.
LAJENG_COMPLETION_RELOAD=1
run_completion lajeng deploy pi
assert_not_contains api "${COMPREPLY[@]}"

# Case 11: no background suggestions for subcommands without positional values.
for subcmd in config logs auth help; do
  LAJENG_COMPLETION_RELOAD=1
  run_completion lajeng "$subcmd" ""
  if [[ "${#COMPREPLY[@]}" -ne 0 ]]; then
    echo "FAIL: expected no suggestions for 'lajeng $subcmd ' transition, got [${COMPREPLY[*]}]" >&2
    exit 1
  fi
  pass_count=$((pass_count + 1))
done

# Case 12: multiple command registration works.
LAJENG_COMPLETION_COMMANDS="lajeng niora"
_lajeng_register_completion
assert_string_contains "_lajeng_completion" "$(complete -p lajeng 2>/dev/null || true)"
assert_string_contains "_lajeng_completion" "$(complete -p niora 2>/dev/null || true)"
unset LAJENG_COMPLETION_COMMANDS

# Case 13: install/uninstall scripts are idempotent.
tmp_rc="$(mktemp)"
cleanup() {
  rm -f "$tmp_rc"
}
trap cleanup EXIT

"$project_dir/install.sh" "$tmp_rc"
"$project_dir/install.sh" "$tmp_rc"

source_line="source \"$project_dir/lajeng-completion.sh\""
assert_file_line_count 1 "# lajeng completion" "$tmp_rc"
assert_file_line_count 1 "$source_line" "$tmp_rc"

"$project_dir/uninstall.sh" "$tmp_rc"
assert_file_line_count 0 "# lajeng completion" "$tmp_rc"
assert_file_line_count 0 "$source_line" "$tmp_rc"

# Case 14: uninstall keeps unrelated marker comment.
printf '# lajeng completion\n# keep this unrelated line\n' > "$tmp_rc"
"$project_dir/uninstall.sh" "$tmp_rc"
assert_file_line_count 1 "# lajeng completion" "$tmp_rc"
assert_file_line_count 1 "# keep this unrelated line" "$tmp_rc"

# Case 15: config reload still works when file mtime is uncacheable.
tmp_conf="$(mktemp)"
printf 'ENVIRONMENTS=dev\n' > "$tmp_conf"
export LAJENG_COMPLETION_CONFIG="$tmp_conf"
LAJENG_COMPLETION_RELOAD=1
run_completion lajeng deploy --env ""
assert_contains dev "${COMPREPLY[@]}"

stat() { return 1; }
printf 'ENVIRONMENTS=prod\n' > "$tmp_conf"
run_completion lajeng deploy --env ""
unset -f stat

assert_contains prod "${COMPREPLY[@]}"
assert_not_contains dev "${COMPREPLY[@]}"
rm -f "$tmp_conf"

echo "PASS: $pass_count assertions"
