---
description: Run shell lint and syntax checks
---

# Workflow: Shell Lint

1. Run shellcheck for all shell scripts.
2. Fix lint findings without changing behavior.
3. Run `bash -n` syntax checks.
4. Run `./test/run-tests.sh` to confirm no regressions.
