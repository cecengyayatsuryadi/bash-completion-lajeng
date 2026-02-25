---
name: security-audit
description: Audit bash completion scripts for command-injection, unsafe parsing, and rc-file safety risks.
---

# Security Audit Skill

Use this skill for security reviews in this shell-based repository.

## Risks to Check
1. Command injection via untrusted config values.
2. Unsafe eval/word-splitting/globbing.
3. Insecure file operations in install/uninstall scripts.
4. Accidental corruption of shell rc files.

## Workflow
1. Inspect config parsing in `lajeng-config.sh`.
2. Inspect completion candidate generation in `lajeng-completion.sh`.
3. Inspect write operations in `install.sh` and `uninstall.sh`.
4. Report findings with severity and exploitability.
