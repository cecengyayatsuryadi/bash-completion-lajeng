---
name: code-review
description: Review bash-completion changes for correctness, portability, and regressions.
---

# Code Review Skill

Use this skill when reviewing changes in this repository.

## Focus Areas
1. Completion behavior stays correct for root command, subcommands, flags, and flag values.
2. Bash safety is preserved (`set -euo pipefail`, quoting, array handling, no unsafe word-splitting).
3. Cross-file consistency between `lajeng-completion.sh`, `lajeng-spec.sh`, and `lajeng-config.sh`.
4. Install/uninstall scripts remain idempotent and safe for `~/.bashrc` edits.
5. Tests in `test/run-tests.sh` cover the changed behavior.

## Review Workflow
1. Inspect changed files.
2. Classify findings by severity: Critical, Major, Minor.
3. Reference exact file/line for each issue.
4. Call out missing tests or edge cases.
