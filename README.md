# lajeng Bash Completion (MVP)

Native Bash completion for a sample internal CLI named `lajeng`.

See architecture and flow visuals: [VISUAL.md](./VISUAL.md)

## Features

- Subcommand suggestions
- Context-aware flags per subcommand
- Value suggestions for selected flags
- Local config support with static fallback
- Idempotent install/uninstall scripts

## File layout

- `lajeng-completion.sh` main completion entrypoint
- `lajeng-spec.sh` static CLI grammar
- `lajeng-config.sh` local config loader and value providers
- `install.sh` install into `~/.bashrc`
- `uninstall.sh` remove from `~/.bashrc`

## Install

```bash
cd bash-completion-lajeng
chmod +x install.sh uninstall.sh test/run-tests.sh
./install.sh
source ~/.bashrc
```

## Bind to your real command

Default binding is `lajeng`. To bind completion to your command (for example `niora`),
set `LAJENG_COMPLETION_COMMANDS` before sourcing:

```bash
export LAJENG_COMPLETION_COMMANDS="niora"
source /home/lilletboy/Desktop/Playground/bash-completion-lajeng/lajeng-completion.sh
```

You can bind multiple commands:

```bash
export LAJENG_COMPLETION_COMMANDS="niora lajeng"
```

## Optional local config

Create `~/.config/lajeng/completion.conf`:

```ini
ENVIRONMENTS=dev,staging,prod
PROFILES=default,alpha,beta
NAMESPACES=core,platform,data
```

Unknown keys are ignored. Empty/missing config falls back to static defaults.

## Test

```bash
cd bash-completion-lajeng
./test/run-tests.sh
```

## Debug

```bash
export LAJENG_COMPLETION_DEBUG=1
lajeng_completion_debug
```

## Notes

- Requires Bash 4.2+
- Default command bound: `lajeng`
