#!/usr/bin/env bash

# Static command grammar for lajeng completion.
_LAJENG_SUBCOMMANDS=(deploy config logs auth help)

# Subcommand -> supported flags.
declare -Ag _LAJENG_SUBCOMMAND_FLAGS=(
  [deploy]="--env --profile --namespace --dry-run --target --help"
  [config]="--profile --set --get --list --help"
  [logs]="--env --tail --since --follow --help"
  [auth]="--profile --login --logout --help"
  [help]=""
)

# Subcommand -> positional values (MVP: first positional argument).
declare -Ag _LAJENG_SUBCOMMAND_POSITIONAL=(
  [deploy]="api web worker cron"
)

# Flags that expect a value.
_LAJENG_VALUE_FLAGS=(--env --profile --namespace --target --set --get --tail --since)

# Static defaults used when local config does not provide values.
declare -Ag _LAJENG_DEFAULT_FLAG_VALUES=(
  [--env]="dev staging prod"
  [--profile]="default"
  [--namespace]="core"
  [--target]="api web worker cron"
)

_lajeng_spec_has_subcommand() {
  local needle="$1"
  local item
  for item in "${_LAJENG_SUBCOMMANDS[@]}"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

_lajeng_spec_is_value_flag() {
  local needle="$1"
  local item
  for item in "${_LAJENG_VALUE_FLAGS[@]}"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

_lajeng_spec_flags_for_subcommand() {
  local subcommand="$1"
  local flags="${_LAJENG_SUBCOMMAND_FLAGS["$subcommand"]:-}"
  local -a flag_tokens=()

  [[ -z "$flags" ]] && return 0
  read -r -a flag_tokens <<< "$flags"
  printf '%s\n' "${flag_tokens[@]}"
}
