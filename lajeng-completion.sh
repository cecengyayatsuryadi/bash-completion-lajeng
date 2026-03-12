#!/usr/bin/env bash

_lajeng_completion_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_lajeng_completion_dir/lajeng-spec.sh"
source "$_lajeng_completion_dir/lajeng-config.sh"

_lajeng_unique_lines() {
  local line
  declare -A seen=()

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ -n "${seen[$line]+x}" ]] && continue
    seen["$line"]=1
    printf '%s\n' "$line"
  done
}

_lajeng_get_subcommand() {
  local idx word
  for ((idx = 1; idx < COMP_CWORD; idx++)); do
    word="${COMP_WORDS[idx]}"
    [[ "$word" == -* ]] && continue
    if _lajeng_spec_has_subcommand "$word"; then
      printf '%s' "$word"
      return 0
    fi
  done
  return 1
}

_lajeng_collect_used_flags() {
  local idx word
  for ((idx = 1; idx < COMP_CWORD; idx++)); do
    word="${COMP_WORDS[idx]}"
    [[ "$word" == --* ]] && printf '%s\n' "$word"
  done
  return 0
}

_lajeng_filter_unused_flags() {
  local used="$1"
  local used_flag
  local candidate
  declare -A used_set=()

  while IFS= read -r used_flag; do
    [[ -z "$used_flag" ]] && continue
    used_set["$used_flag"]=1
  done <<< "$used"

  while IFS= read -r candidate; do
    [[ -z "$candidate" ]] && continue
    [[ -n "${used_set[$candidate]+x}" ]] && continue
    printf '%s\n' "$candidate"
  done
}

_lajeng_get_candidates() {
  local cur prev subcommand used_flags positional_tokens
  local -a positional_list=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # If previous token is a path flag, suggest files/folders.
  if _lajeng_spec_is_path_flag "$prev"; then
    compgen -f -- "$cur"
    return 0
  fi

  # If previous token is a value flag, suggest values for that flag.
  if _lajeng_spec_is_value_flag "$prev"; then
    _lajeng_load_user_config
    _lajeng_values_for_flag "$prev" | _lajeng_unique_lines
    return 0
  fi

  # Discover subcommand context from earlier tokens.
  if ! subcommand="$(_lajeng_get_subcommand)"; then
    printf '%s\n' "${_LAJENG_SUBCOMMANDS[@]}" | _lajeng_unique_lines
    return 0
  fi

  # If current token starts with '-', suggest remaining flags for the active subcommand.
  if [[ "$cur" == -* ]]; then
    used_flags="$(_lajeng_collect_used_flags)"
    _lajeng_spec_flags_for_subcommand "$subcommand" | _lajeng_filter_unused_flags "$used_flags" | _lajeng_unique_lines
    return 0
  fi

  # Positional suggestions for subcommands that define them.
  positional_tokens="${_LAJENG_SUBCOMMAND_POSITIONAL[$subcommand]:-}"
  if [[ -n "$positional_tokens" ]]; then
    read -r -a positional_list <<< "$positional_tokens"
    printf '%s\n' "${positional_list[@]}" | _lajeng_unique_lines
  fi
}

_lajeng_completion() {
  local cur
  local subcommand
  local -a all_candidates=()
  local -a prefix_matches=()
  local -a contains_matches=()
  local candidate
  local cur_lc candidate_lc
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  cur_lc="${cur,,}"

  mapfile -t all_candidates < <(_lajeng_get_candidates)

  # Keep native prefix behavior first.
  for candidate in "${all_candidates[@]}"; do
    [[ "$candidate" == "$cur"* ]] && prefix_matches+=("$candidate")
  done

  if [[ "${#prefix_matches[@]}" -gt 0 ]]; then
    COMPREPLY=("${prefix_matches[@]}")
    return 0
  fi

  # Contains fallback is only for root command discovery to avoid noisy matches
  # inside subcommand contexts.
  if subcommand="$(_lajeng_get_subcommand)"; then
    COMPREPLY=()
    return 0
  fi

  # If no prefix hit, fallback to case-insensitive contains matching.
  for candidate in "${all_candidates[@]}"; do
    candidate_lc="${candidate,,}"
    [[ "$candidate_lc" == *"$cur_lc"* ]] && contains_matches+=("$candidate")
  done

  COMPREPLY=("${contains_matches[@]}")
}

lajeng_completion_debug() {
  _lajeng_load_user_config
  printf 'Loaded config: %s\n' "${LAJENG_COMPLETION_CONFIG:-$HOME/.config/lajeng/completion.conf}"
  printf 'Environments: %s\n' "${_LAJENG_CFG_ENVIRONMENTS[*]:-(none)}"
  printf 'Profiles: %s\n' "${_LAJENG_CFG_PROFILES[*]:-(none)}"
  printf 'Namespaces: %s\n' "${_LAJENG_CFG_NAMESPACES[*]:-(none)}"
}

_lajeng_register_completion() {
  local commands="${LAJENG_COMPLETION_COMMANDS:-lajeng}"
  local cmd
  for cmd in $commands; do
    complete -o default -o nosort -F _lajeng_completion "$cmd"
  done
}

_lajeng_register_completion
