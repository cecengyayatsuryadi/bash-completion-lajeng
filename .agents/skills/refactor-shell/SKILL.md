---
name: refactor-shell
description: Refactor shell scripts to improve modularity, readability, and testability.
---

# Refactor Shell Skill

Use this skill for structural cleanup of shell code.

## Heuristics
1. Extract repeated parsing/filtering logic into small functions.
2. Keep functions single-purpose and side-effect-aware.
3. Prefer array-safe patterns over string-based parsing.
4. Preserve public function names used by tests unless migration is included.

## Workflow
1. Add or update tests that guard current behavior.
2. Refactor in small steps.
3. Run `bash -n`, `shellcheck`, and `./test/run-tests.sh`.
