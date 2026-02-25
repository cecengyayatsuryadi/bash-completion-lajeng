---
name: test-guard
description: Protect behavior with bash-based tests for completion, config parsing, and install flow.
---

# Test Guard Skill

Use this skill whenever behavior changes.

## Test Targets
1. Completion candidates at root and per-subcommand.
2. Flag filtering and value suggestions.
3. Config parsing fallback behavior.
4. Install/uninstall idempotency.

## Commands
- `./test/run-tests.sh`

## Rules
1. Reproduce bugs with a failing test first when practical.
2. Keep tests deterministic and independent from user machine state.
