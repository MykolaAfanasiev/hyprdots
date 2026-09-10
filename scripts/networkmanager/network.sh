#!/usr/bin/env bash

set -euo pipefail

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command is not installed: %s\n' "$command_name" >&2
    return 127
  fi
}

wifi_enabled() {
  [[ "$(LC_ALL=C nmcli radio wifi)" == "enabled" ]]
}

status() {
  require_command nmcli

  if wifi_enabled; then
    printf 'enabled\n'
  else
    printf 'disabled\n'
  fi
}

set_power() {
  local state="$1"

  require_command nmcli
  nmcli radio wifi "$state"
}

toggle() {
  if [[ "$(status)" == "enabled" ]]; then
    set_power off
  else
    set_power on
  fi
}

active_wifi_device() {
  LC_ALL=C nmcli \
    -t \
    -f DEVICE,TYPE,STATE \
    device status |
    awk -F: '
      $2 == "wifi" && $3 == "connected" {
        print $1
        exit
      }
    '
}

active_ssid() {
  LC_ALL=C nmcli \
    --escape no \
    -g GENERAL.CONNECTION \
    device show "$(active_wifi_device)" \
    2>/dev/null || true
}

saved_profile_uuids_for_ssid() {
  local wanted_ssid="$1"
  local uuid
  local connection_type
  local saved_ssid

  while IFS= read -r uuid; do
    [[ -n "$uuid" ]] || continue

    connection_type="$(
      LC_ALL=C nmcli \
        -g connection.type \
        connection show uuid "$uuid" \
        2>/dev/null || true
    )"

    [[ "$connection_type" == "802-11-wireless" ]] || continue

    saved_ssid="$(
      LC_ALL=C nmcli \
        --escape no \
        -g 802-11-wireless.ssid \
        connection show uuid "$uuid" \
        2>/dev/null || true
    )"

    if [[ "$saved_ssid" == "$wanted_ssid" ]]; then
      printf '%s\n' "$uuid"
    fi
  done < <(
    LC_ALL=C nmcli \
      --escape no \
      -g UUID \
      connection show
  )
}

is_saved() {
  local ssid="$1"
  local uuid

  uuid="$(saved_profile_uuids_for_ssid "$ssid" | head -n 1)"
  [[ -n "$uuid" ]]
}

list_networks() {
  require_command nmcli

  nmcli device wifi list --rescan auto >/dev/null 2>&1 || true

  local -a ssids=()
  local -a signals=()
  local -a securities=()
  local -a in_use=()
  local -A seen=()
  local index
  local ssid
  local saved=false

  mapfile -t ssids < <(
    LC_ALL=C nmcli --escape no -g SSID device wifi list
  )

  mapfile -t signals < <(
    LC_ALL=C nmcli --escape no -g SIGNAL device wifi list
  )

  mapfile -t securities < <(
    LC_ALL=C nmcli --escape no -g SECURITY device wifi list
  )

  mapfile -t in_use < <(
    LC_ALL=C nmcli --escape no -g IN-USE device wifi list
  )

  for ((index = 0; index < ${#ssids[@]}; index++)); do
    ssid="${ssids[index]:-}"
    [[ -n "$ssid" ]] || continue
    [[ -z "${seen[$ssid]:-}" ]] || continue
    seen["$ssid"]=1

    saved=false
    if is_saved "$ssid"; then
      saved=true
    fi

    printf '%s\t%s\t%s\t%s\t%s\n' \
      "${in_use[index]:-}" \
      "${signals[index]:-0}" \
      "${securities[index]:---}" \
      "$saved" \
      "$ssid"
  done
}

connect_network() {
  local ssid="$1"
  local password=""

  require_command nmcli

  if nmcli --wait 15 device wifi connect "$ssid" >/dev/null 2>&1; then
    return 0
  fi

  if [[ "${2:-}" == "--password-stdin" ]]; then
    IFS= read -r password || true
  fi

  [[ -n "$password" ]] || return 1

  nmcli \
    --wait 15 \
    device wifi connect "$ssid" \
    password "$password" \
    >/dev/null
}

disconnect_network() {
  local requested_ssid="${1:-}"
  local device

  require_command nmcli

  device="$(active_wifi_device)"
  [[ -n "$device" ]] || return 1

  if [[ -n "$requested_ssid" ]]; then
    local connected
    connected="$(active_ssid)"
    [[ "$connected" == "$requested_ssid" ]] || return 1
  fi

  nmcli --wait 10 device disconnect "$device" >/dev/null
}

forget_network() {
  local ssid="$1"
  local uuid
  local found=false

  require_command nmcli

  while IFS= read -r uuid; do
    [[ -n "$uuid" ]] || continue
    found=true
    nmcli connection delete uuid "$uuid" >/dev/null
  done < <(saved_profile_uuids_for_ssid "$ssid")

  [[ "$found" == "true" ]]
}

rescan() {
  require_command nmcli
  nmcli device wifi rescan >/dev/null
}

info() {
  local ssid="$1"
  local signal="${2:-}"
  local security="${3:-}"
  local saved="no"
  local state="disconnected"
  local device=""
  local ip=""
  local gateway=""
  local dns=""

  require_command nmcli

  if is_saved "$ssid"; then
    saved="yes"
  fi

  device="$(active_wifi_device)"

  if [[ -n "$device" && "$(active_ssid)" == "$ssid" ]]; then
    state="connected"
    ip="$(LC_ALL=C nmcli --escape no -g IP4.ADDRESS device show "$device" | head -n 1)"
    gateway="$(LC_ALL=C nmcli --escape no -g IP4.GATEWAY device show "$device" | head -n 1)"
    dns="$(LC_ALL=C nmcli --escape no -g IP4.DNS device show "$device" | paste -sd ',' -)"
  fi

  printf 'ssid=%s\n' "$ssid"
  printf 'signal=%s\n' "$signal"
  printf 'security=%s\n' "${security:---}"
  printf 'saved=%s\n' "$saved"
  printf 'state=%s\n' "$state"
  printf 'device=%s\n' "$device"
  printf 'ip=%s\n' "$ip"
  printf 'gateway=%s\n' "$gateway"
  printf 'dns=%s\n' "$dns"
}

usage() {
  cat <<'EOF_USAGE'
Usage:
  network.sh status
  network.sh on
  network.sh off
  network.sh toggle
  network.sh list
  network.sh connect <ssid> [--password-stdin]
  network.sh disconnect [ssid]
  network.sh forget <ssid>
  network.sh rescan
  network.sh info <ssid> [signal] [security]
EOF_USAGE
}

main() {
  local command_name="${1:-}"

  case "$command_name" in
  status)
    status
    ;;
  on)
    set_power on
    ;;
  off)
    set_power off
    ;;
  toggle)
    toggle
    ;;
  list)
    list_networks
    ;;
  connect)
    [[ $# -ge 2 && $# -le 3 ]] || {
      usage >&2
      return 2
    }
    connect_network "$2" "${3:-}"
    ;;
  disconnect)
    [[ $# -le 2 ]] || {
      usage >&2
      return 2
    }
    disconnect_network "${2:-}"
    ;;
  forget)
    [[ $# -eq 2 ]] || {
      usage >&2
      return 2
    }
    forget_network "$2"
    ;;
  rescan)
    rescan
    ;;
  info)
    [[ $# -ge 2 && $# -le 4 ]] || {
      usage >&2
      return 2
    }
    info "$2" "${3:-}" "${4:-}"
    ;;
  help | -h | --help)
    usage
    ;;
  *)
    usage >&2
    return 2
    ;;
  esac
}

main "$@"
