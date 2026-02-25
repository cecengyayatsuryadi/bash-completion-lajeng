#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
completion_file="$script_dir/lajeng-completion.sh"
rc_file="${1:-$HOME/.bashrc}"
source_line="source \"$completion_file\""

if [[ ! -f "$rc_file" ]]; then
  echo "rc file does not exist: $rc_file"
  exit 0
fi

tmp_file="$(mktemp)"
awk -v source_line="$source_line" '
  BEGIN { marker = "# lajeng completion"; pending_marker = 0 }

  {
    if ($0 == marker) {
      pending_marker = 1
      next
    }

    if (pending_marker) {
      if ($0 == source_line) {
        pending_marker = 0
        next
      }
      print marker
      pending_marker = 0
    }

    if ($0 == source_line) {
      next
    }

    print
  }

  END {
    if (pending_marker) {
      print marker
    }
  }
' "$rc_file" > "$tmp_file"

mv "$tmp_file" "$rc_file"
echo "removed lajeng completion from $rc_file"
