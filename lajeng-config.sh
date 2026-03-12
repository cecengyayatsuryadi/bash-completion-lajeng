#!/usr/bin/env bash

# Cached config state for completion lookups.
_LAJENG_CONFIG_LOADED=0
_LAJENG_CONFIG_MTIME=""
_LAJENG_CONFIG_PATH="${LAJENG_COMPLETION_CONFIG:-$HOME/.config/lajeng/completion.conf}"

_LAJENG_CFG_ENVIRONMENTS=()
_LAJENG_CFG_PROFILES=()
_LAJENG_CFG_NAMESPACES=()

_lajeng_debug() {
  if [[ "${LAJENG_COMPLETION_DEBUG:-0}" == "1" ]]; then
    printf 'lajeng-completion: %s\n' "$*" >&2
  fi
}

_lajeng_trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

_lajeng_eval_dynamic() {
  local raw="$1"
  # Check if value starts with $( and ends with )
  if [[ "$raw" =~ ^\$\((.*)\)$ ]]; then
    local cmd="${BASH_REMATCH[1]}"
    _lajeng_debug "evaluating dynamic command: $cmd"
    eval "$cmd" 2>/dev/null
  else
    printf '%s\n' "$raw"
  fi
}

_lajeng_split_csv() {
  local raw="$1"
  local token
  local -a parsed_tokens=()

  # Support dynamic evaluation before splitting
  raw="$(_lajeng_eval_dynamic "$raw")"

  IFS=',' read -r -a parsed_tokens <<< "$raw"
  for token in "${parsed_tokens[@]}"; do
    token="$(_lajeng_trim "$token")"
    [[ -n "$token" ]] && printf '%s\n' "$token"
  done
}

_lajeng_file_mtime() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    printf '__missing__'
    return 0
  fi

  local mtime
  if mtime=$(stat -c '%Y' "$path" 2>/dev/null); then
    printf '%s' "$mtime"
    return 0
  fi

  if mtime=$(stat -f '%m' "$path" 2>/dev/null); then
    printf '%s' "$mtime"
    return 0
  fi

  # Unknown stat implementation: mark as uncacheable so completion stays correct.
  printf '__uncacheable__'
}

_lajeng_load_user_config() {
  local path="${LAJENG_COMPLETION_CONFIG:-$_LAJENG_CONFIG_PATH}"
  local force_reload="${LAJENG_COMPLETION_RELOAD:-0}"
  local mtime
  local line key value

  mtime="$(_lajeng_file_mtime "$path")"

  if [[ "$force_reload" != "1" ]] &&
    [[ "$_LAJENG_CONFIG_LOADED" == "1" ]] &&
    [[ "$mtime" != "__uncacheable__" ]] &&
    [[ "$mtime" == "$_LAJENG_CONFIG_MTIME" ]]; then
    return 0
  fi

  _LAJENG_CFG_ENVIRONMENTS=()
  _LAJENG_CFG_PROFILES=()
  _LAJENG_CFG_NAMESPACES=()

  if [[ -f "$path" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="$(_lajeng_trim "$line")"
      [[ -z "$line" ]] && continue
      [[ "${line:0:1}" == "#" ]] && continue
      [[ "$line" != *=* ]] && continue

      key="$(_lajeng_trim "${line%%=*}")"
      value="$(_lajeng_trim "${line#*=}")"

      case "$key" in
        ENVIRONMENTS)
          mapfile -t _LAJENG_CFG_ENVIRONMENTS < <(_lajeng_split_csv "$value")
          ;;
        PROFILES)
          mapfile -t _LAJENG_CFG_PROFILES < <(_lajeng_split_csv "$value")
          ;;
        NAMESPACES)
          mapfile -t _LAJENG_CFG_NAMESPACES < <(_lajeng_split_csv "$value")
          ;;
        *)
          _lajeng_debug "ignoring unknown key '$key' in $path"
          ;;
      esac
    done < "$path"
  else
    _lajeng_debug "config not found at $path, using static defaults"
  fi

  if [[ "$mtime" == "__uncacheable__" ]]; then
    _LAJENG_CONFIG_MTIME=""
    _LAJENG_CONFIG_LOADED=0
  else
    _LAJENG_CONFIG_MTIME="$mtime"
    _LAJENG_CONFIG_LOADED=1
  fi

  if [[ "$force_reload" == "1" ]]; then
    # One-shot reload flag to avoid forcing reload on every completion.
    unset LAJENG_COMPLETION_RELOAD
  fi
}

_lajeng_values_for_flag() {
  local flag="$1"
  case "$flag" in
    --env|-e)
      if [[ "${#_LAJENG_CFG_ENVIRONMENTS[@]}" -gt 0 ]]; then
        printf '%s\n' "${_LAJENG_CFG_ENVIRONMENTS[@]}"
      else
        local -a default_env=()
        read -r -a default_env <<< "${_LAJENG_DEFAULT_FLAG_VALUES[--env]}"
        printf '%s\n' "${default_env[@]}"
      fi
      ;;
    --profile|-p)
      if [[ "${#_LAJENG_CFG_PROFILES[@]}" -gt 0 ]]; then
        printf '%s\n' "${_LAJENG_CFG_PROFILES[@]}"
      else
        local -a default_profiles=()
        read -r -a default_profiles <<< "${_LAJENG_DEFAULT_FLAG_VALUES[--profile]}"
        printf '%s\n' "${default_profiles[@]}"
      fi
      ;;
    --namespace|-n)
      if [[ "${#_LAJENG_CFG_NAMESPACES[@]}" -gt 0 ]]; then
        printf '%s\n' "${_LAJENG_CFG_NAMESPACES[@]}"
      else
        local -a default_namespaces=()
        read -r -a default_namespaces <<< "${_LAJENG_DEFAULT_FLAG_VALUES[--namespace]}"
        printf '%s\n' "${default_namespaces[@]}"
      fi
      ;;
    --target|-t)
      local -a default_targets=()
      read -r -a default_targets <<< "${_LAJENG_DEFAULT_FLAG_VALUES[--target]}"
      printf '%s\n' "${default_targets[@]}"
      ;;
  esac
}
