# `bash-completion-lajeng` Project Visuals

## Component Architecture
```mermaid
flowchart LR
  A[User Presses TAB in Bash] --> B[_lajeng_completion]
  B --> C[_lajeng_get_candidates]
  C --> D[lajeng-spec.sh]
  C --> E[lajeng-config.sh]
  D --> F[Subcommands, Flags, Positionals, Default Values]
  E --> G[Local Config + MTime Cache]
  F --> H[Candidate List]
  G --> H
  H --> I[Prefix Match]
  I -->|Found| J[COMPREPLY]
  I -->|Not Found + Root Context| K[Contains Fallback]
  K --> J
```

## Completion Decision Flow
```mermaid
flowchart TD
  A[Start _lajeng_get_candidates] --> B{Is previous token a value flag?}
  B -->|Yes| C[Load config + suggest value candidates]
  B -->|No| D{Is subcommand already detected?}
  D -->|No| E[Suggest root subcommands]
  D -->|Yes| F{Does current token start with '-'?}
  F -->|Yes| G[Suggest unused flags]
  F -->|No| H[Suggest positionals if defined]
```

## File Responsibility Mapping

- `lajeng-completion.sh`: completion routing and matching engine (`prefix first`, controlled fallback).
- `lajeng-spec.sh`: static CLI grammar (subcommands, flags, positionals, value flags).
- `lajeng-config.sh`: user config parser + default fallback + cache.
- `install.sh` / `uninstall.sh`: add and remove source line in `~/.bashrc`.
- `test/run-tests.sh`: regression guard for UX and correctness.
