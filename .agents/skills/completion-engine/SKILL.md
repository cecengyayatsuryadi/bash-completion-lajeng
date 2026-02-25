---
name: completion-engine
description: Maintain and extend completion routing logic in lajeng-completion.sh.
---

# Completion Engine Skill

Use this skill when editing completion flow.

## Scope
- `lajeng-completion.sh`
- Integration points with `lajeng-spec.sh` and `lajeng-config.sh`

## Rules
1. Keep `_lajeng_get_candidates` as the source of candidate generation.
2. Preserve matching strategy: prefix first, then case-insensitive contains fallback.
3. Do not break used-flag filtering (`_lajeng_collect_used_flags` + `_lajeng_filter_unused_flags`).
4. Keep duplicate suppression with `_lajeng_unique_lines`.

## Validation
1. Run `./test/run-tests.sh`.
2. Manually smoke-check at least one interactive completion path in Bash if behavior changed.
