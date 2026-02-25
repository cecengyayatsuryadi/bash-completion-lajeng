---
name: completion-performance
description: Keep bash completion responsive by avoiding expensive operations on every keypress.
---

# Completion Performance Skill

Use this skill when optimizing completion responsiveness.

## Priorities
1. Minimize subprocess calls in hot paths (`grep`, `awk`, `stat`) where possible.
2. Preserve config caching behavior in `lajeng-config.sh`.
3. Avoid repeated full-list recomputation when state is unchanged.
4. Keep logic readable; do not micro-optimize at the cost of maintainability.

## Checkpoints
1. Verify behavior parity with existing tests.
2. Compare before/after using quick repeated completion calls in a local shell session.
