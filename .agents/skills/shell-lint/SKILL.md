---
name: shell-lint
description: Lint bash scripts with shellcheck and fix warnings without changing behavior.
---

# Shell Lint Skill

Use this skill for linting and formatting shell scripts in this repo.

## Commands
- `shellcheck lajeng-completion.sh lajeng-spec.sh lajeng-config.sh install.sh uninstall.sh test/run-tests.sh`
- `bash -n lajeng-completion.sh lajeng-spec.sh lajeng-config.sh install.sh uninstall.sh test/run-tests.sh`

## Rules
1. Fix high-signal shellcheck warnings first (quoting, arrays, unbound vars, globbing).
2. Avoid style-only churn when it harms readability.
3. Re-run tests after lint fixes.
