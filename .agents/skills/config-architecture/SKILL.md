---
name: config-architecture
description: Evolve completion config schema and parsing in lajeng-config.sh safely.
---

# Config Architecture Skill

Use this skill when changing local config behavior.

## Scope
- `lajeng-config.sh`
- Related defaults in `lajeng-spec.sh`
- Test fixtures in `test/fixtures/*.conf`

## Rules
1. Keep unknown keys non-fatal.
2. Keep static defaults as fallback when config is missing or empty.
3. Preserve caching + reload semantics (`LAJENG_COMPLETION_RELOAD`).
4. Update fixtures and tests for any schema change.

## Validation
- `./test/run-tests.sh`
