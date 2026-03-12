# lajeng Bash Completion (Pro)

Native Bash and Zsh completion for a sample internal CLI named `lajeng`.

See architecture and flow visuals: [VISUAL.md](./VISUAL.md)

## Features

- **Subcommand suggestions**: Auto-complete commands like `deploy`, `config`, etc.
- **Context-aware flags**: Suggestions based on the current subcommand.
- **Short Flag Support**: Quickly use aliases like `-e` (env), `-p` (profile), `-n` (ns), and `-t` (target).
- **Smart Path Completion**: Seamlessly find files/folders using `-f` or `--file`.
- **Dynamic Value Providers**: Evaluate shell commands in config (e.g., `ENVIRONMENTS=$(ls)`) for real-time suggestions.
- **Cross-Shell Compatibility**: Works natively on **Bash** and **Zsh** (via automatic bridge).
- **Local config support**: Customizable via `~/.config/lajeng/completion.conf`.

## File layout

- `lajeng-completion.sh`: Main logic and candidate generation.
- `lajeng-spec.sh`: CLI grammar, flags, and static defaults.
- `lajeng-config.sh`: Config loader with dynamic command evaluation support.
- `install.sh`: Intelligent installer for `.bashrc` or `.zshrc`.
- `uninstall.sh`: Clean removal from your shell configuration.

## Install

```bash
cd bash-completion-lajeng
chmod +x install.sh uninstall.sh test/run-tests.sh
./install.sh
# Restart your shell or source your rc file
```

## Advanced Config: Dynamic Values

You can make `lajeng` aware of your project structure by using subshells in `~/.config/lajeng/completion.conf`:

```ini
# Real-time environment discovery
ENVIRONMENTS=$(ls -d environments/*/ | sed 's/\///g')
PROFILES=default,admin,guest
```

## Test

```bash
cd bash-completion-lajeng
./test/run-tests.sh
```

## License

MIT. See [LICENSE](./LICENSE).
