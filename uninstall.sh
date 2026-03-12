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
  BEGIN { 
    marker1 = "# lajeng completion"; 
    marker2 = "# lajeng completion (zsh bridge)";
    zsh_bridge = "autoload -U +X bashcompinit && bashcompinit";
    pending = 0 
  }

  {
    if ($0 == marker1 || $0 == marker2) {
      pending = $0
      next
    }

    if (pending) {
      if ($0 == source_line || $0 == zsh_bridge) {
        if ($0 == zsh_bridge) {
          # skip the next line too if it is the source line
          getline next_line
          if (next_line != source_line) {
            print next_line
          }
        }
        pending = 0
        next
      }
      print pending
      pending = 0
    }

    if ($0 == source_line || $0 == zsh_bridge) {
      next
    }

    print
  }

  END {
    if (pending) {
      print pending
    }
  }
' "$rc_file" > "$tmp_file"

mv "$tmp_file" "$rc_file"
echo "removed lajeng completion from $rc_file"
