---
name: cli-ux
description: Improve completion discoverability and user experience without reducing correctness.
---

# CLI UX Skill

Use this skill when adjusting completion suggestions and ergonomics.

## UX Principles
1. Suggest the most relevant candidates early (prefix-first behavior).
2. Keep fallback matching useful but predictable.
3. Avoid noisy suggestions that hide likely intent.
4. Preserve compatibility with native Bash completion expectations.

## Change Checklist
1. Explain why UX behavior changes.
2. Add or update tests for the user-visible outcome.
3. Verify no regressions on existing completion paths.
