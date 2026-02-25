#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
completion_file="$script_dir/lajeng-completion.sh"
rc_file="${1:-$HOME/.bashrc}"
source_line="source \"$completion_file\""

if [[ ! -f "$completion_file" ]]; then
  echo "completion file not found: $completion_file" >&2
  exit 1
fi

touch "$rc_file"

if grep -Fqx "$source_line" "$rc_file"; then
  echo "lajeng completion already installed in $rc_file"
  exit 0
fi

printf '\n# lajeng completion\n%s\n' "$source_line" >> "$rc_file"
echo "installed lajeng completion to $rc_file"
