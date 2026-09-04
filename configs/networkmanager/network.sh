#!/usr/bin/env bash

set -euo pipefail

NETWORK_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

ROFI_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/config.rasi"
NETWORK_THEME="$NETWORK_DIR/theme.rasi"

declare -a ROFI_COMMON=()

if [[ -f "$ROFI_CONFIG" ]]; then
  ROFI_COMMON+=(
    -config "$ROFI_CONFIG"
  )
fi

ROFI_COMMON+=(
  -theme "$NETWORK_THEME"
  -kb-row-up "Up,Alt+k"
  -kb-row-down "Down,Alt+j"
)
notify() {
  local message="$1"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send \
      --app-name="Hyprdots Network" \
      "Network" \
      "$message" \
      >/dev/null 2>&1 ||
      true
  else
    printf 'Network: %s\n' "$message" >&2
  fi
}

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command is not installed: %s\n' "$command_name" >&2
    exit 127
  fi
}

wifi_enabled() {
  [[ "$(LC_ALL=C nmcli radio wifi)" == "enabled" ]]
}

signal_icon() {
  local signal="${1:-0}"

  if ((signal >= 80)); then
    printf '󰤨'
  elif ((signal >= 60)); then
    printf '󰤥'
  elif ((signal >= 40)); then
    printf '󰤢'
  elif ((signal >= 20)); then
    printf '󰤟'
  else
    printf '󰤯'
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
        2>/dev/null ||
        true
    )"

    [[ "$connection_type" == "802-11-wireless" ]] || continue

    saved_ssid="$(
      LC_ALL=C nmcli \
        --escape no \
        -g 802-11-wireless.ssid \
        connection show uuid "$uuid" \
        2>/dev/null ||
        true
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

password_prompt() {
  local ssid="$1"
  local password

  password="$(
    printf '' |
      rofi \
        -dmenu \
        -password \
        -p " Password" \
        -mesg "$ssid" \
        "${ROFI_COMMON[@]}" \
        -theme-str '
          window {
            width: 320px;
            x-offset: 330px;
          }

          listview {
            enabled: false;
          }
        ' ||
      true
  )"

  printf '%s' "$password"
}

connect_network() {
  local ssid="$1"
  local security="$2"

  # Saved connection or open network may work without asking
  # for a password.
  if nmcli \
    --wait 15 \
    device wifi connect "$ssid" \
    >/dev/null 2>&1; then
    notify "Connected to $ssid"
    return 0
  fi

  if [[ -z "$security" || "$security" == "--" ]]; then
    notify "Could not connect to $ssid"
    return 1
  fi

  local password
  password="$(password_prompt "$ssid")"

  [[ -n "$password" ]] || return 0

  if nmcli \
    --wait 15 \
    device wifi connect "$ssid" \
    password "$password" \
    >/dev/null 2>&1; then
    notify "Connected to $ssid"
  else
    notify "Could not connect to $ssid"
    return 1
  fi

  unset password
}

disconnect_network() {
  local ssid="$1"
  local device

  device="$(active_wifi_device)"

  if [[ -z "$device" ]]; then
    notify "No active Wi-Fi device"
    return 1
  fi

  if nmcli \
    --wait 10 \
    device disconnect "$device" \
    >/dev/null 2>&1; then
    notify "Disconnected from $ssid"
  else
    notify "Could not disconnect from $ssid"
    return 1
  fi
}

forget_network() {
  local ssid="$1"
  local choice

  choice="$(
    printf '%s\n' \
      "󰆴  Forget network" \
      "󰜺  Cancel" |
      rofi \
        -dmenu \
        -p "$ssid" \
        "${ROFI_COMMON[@]}" \
        -theme-str '
          window {
            width: 300px;
            x-offset: 330px;
          }

          listview {
            lines: 2;
          }
        ' ||
      true
  )"

  [[ "$choice" == "󰆴  Forget network" ]] || return 0

  local -a uuids=()

  mapfile -t uuids < <(
    saved_profile_uuids_for_ssid "$ssid"
  )

  if ((${#uuids[@]} == 0)); then
    notify "No saved profile for $ssid"
    return 0
  fi

  local uuid

  for uuid in "${uuids[@]}"; do
    if ! nmcli \
      connection delete uuid "$uuid" \
      >/dev/null 2>&1; then
      notify "Could not remove saved profile for $ssid"
      return 1
    fi
  done

  notify "Forgot $ssid"
}

copy_ssid() {
  local ssid="$1"

  if ! command -v wl-copy >/dev/null 2>&1; then
    notify "wl-copy is not installed"
    return 1
  fi

  printf '%s' "$ssid" | wl-copy
  notify "SSID copied: $ssid"
}

show_info() {
  local ssid="$1"
  local signal="$2"
  local security="$3"
  local active="$4"

  local saved="No"
  local device=""
  local ip=""
  local gateway=""
  local dns=""

  local -a uuids=()

  mapfile -t uuids < <(
    saved_profile_uuids_for_ssid "$ssid"
  )

  if ((${#uuids[@]} > 0)); then
    saved="Yes"
  fi

  if [[ "$active" == "true" ]]; then
    device="$(active_wifi_device)"

    if [[ -n "$device" ]]; then
      ip="$(
        LC_ALL=C nmcli \
          --escape no \
          -g IP4.ADDRESS \
          device show "$device" |
          head -n 1
      )"

      gateway="$(
        LC_ALL=C nmcli \
          --escape no \
          -g IP4.GATEWAY \
          device show "$device" |
          head -n 1
      )"

      dns="$(
        LC_ALL=C nmcli \
          --escape no \
          -g IP4.DNS \
          device show "$device" |
          paste -sd ',' -
      )"
    fi
  fi

  {
    printf 'SSID       %s\n' "$ssid"
    printf 'Signal     %s%%\n' "$signal"
    printf 'Security   %s\n' "${security:---}"
    printf 'Saved      %s\n' "$saved"

    if [[ "$active" == "true" ]]; then
      printf 'Status     Connected\n'
      printf 'Interface  %s\n' "${device:---}"
      printf 'IP         %s\n' "${ip:---}"
      printf 'Gateway    %s\n' "${gateway:---}"
      printf 'DNS        %s\n' "${dns:---}"
    else
      printf 'Status     Disconnected\n'
    fi
  } |
    rofi \
      -dmenu \
      -no-custom \
      -p "󰋼 Network info" \
      "${ROFI_COMMON[@]}" \
      -theme-str '
        window {
          width: 440px;
          x-offset: 390px;
        }

        listview {
          lines: 9;
        }
      ' \
      >/dev/null ||
    true
}

network_actions() {
  local ssid="$1"
  local signal="$2"
  local security="$3"
  local active="$4"

  local -a actions=()

  if [[ "$active" == "true" ]]; then
    actions+=("󰌊  Disconnect")
  else
    actions+=("󰖩  Connect")
  fi

  actions+=(
    "󰋼  Info"
    "󰆏  Copy SSID"
    "󰆴  Forget"
  )

  local action

  action="$(
    printf '%s\n' "${actions[@]}" |
      rofi \
        -dmenu \
        -p "$ssid" \
        "${ROFI_COMMON[@]}" \
        -theme-str '
          window {
            width: 300px;
            x-offset: 330px;
          }

          listview {
            lines: 5;
          }
        ' ||
      true
  )"

  case "$action" in
  "󰖩  Connect")
    connect_network "$ssid" "$security" || true
    ;;

  "󰌊  Disconnect")
    disconnect_network "$ssid" || true
    ;;

  "󰋼  Info")
    show_info \
      "$ssid" \
      "$signal" \
      "$security" \
      "$active"
    ;;

  "󰆏  Copy SSID")
    copy_ssid "$ssid" || true
    ;;

  "󰆴  Forget")
    forget_network "$ssid" || true
    ;;

  "")
    ;;

  *)
    notify "Unknown action"
    ;;
  esac
}

show_wifi_disabled() {
  local choice

  choice="$(
    printf '%s\n' \
      "󰖩  Enable Wi-Fi" \
      "󰜺  Cancel" |
      rofi \
        -dmenu \
        -p "󰖪 Wi-Fi disabled" \
        "${ROFI_COMMON[@]}" \
        -theme-str '
          window {
            width: 360px;
          }

          listview {
            lines: 2;
          }
        ' ||
      true
  )"

  if [[ "$choice" == "󰖩  Enable Wi-Fi" ]]; then
    nmcli radio wifi on

    sleep 1

    exec "$0"
  fi
}

show_networks() {
  # Let NetworkManager refresh only when it considers the scan stale.
  nmcli \
    device wifi list \
    --rescan auto \
    >/dev/null 2>&1 ||
    true

  local -a ssids=()
  local -a signals=()
  local -a securities=()
  local -a in_use=()

  mapfile -t ssids < <(
    LC_ALL=C nmcli \
      --escape no \
      -g SSID \
      device wifi list \
      --rescan no
  )

  mapfile -t signals < <(
    LC_ALL=C nmcli \
      --escape no \
      -g SIGNAL \
      device wifi list \
      --rescan no
  )

  mapfile -t securities < <(
    LC_ALL=C nmcli \
      --escape no \
      -g SECURITY \
      device wifi list \
      --rescan no
  )

  mapfile -t in_use < <(
    LC_ALL=C nmcli \
      --escape no \
      -g IN-USE \
      device wifi list \
      --rescan no
  )

  declare -A seen=()
  declare -A ssid_by_entry=()
  declare -A signal_by_entry=()
  declare -A security_by_entry=()
  declare -A active_by_entry=()

  local -a entries=()

  local index
  local ssid
  local label
  local signal
  local security
  local active
  local marker
  local lock
  local icon
  local entry

  for ((index = 0; index < ${#ssids[@]}; index++)); do
    ssid="${ssids[index]:-}"

    [[ -n "$ssid" ]] || continue

    # nmcli can return multiple access points for the same SSID.
    # Keep the first one, which normally represents the strongest AP.
    [[ -n "${seen[$ssid]:-}" ]] && continue
    seen["$ssid"]=1

    signal="${signals[index]:-0}"
    security="${securities[index]:---}"

    active="false"
    marker=" "

    if [[ "${in_use[index]:-}" == "*" ]]; then
      active="true"
      marker="󰄬"
    fi

    icon="$(signal_icon "$signal")"
    lock=""

    if [[ -n "$security" && "$security" != "--" ]]; then
      lock=""
    fi

    label="${ssid:0:28}"

    entry="$(
      printf '%s  %s  %-28s  %3s%%  %s' \
        "$marker" \
        "$icon" \
        "$label" \
        "$signal" \
        "$lock"
    )"

    entries+=("$entry")

    ssid_by_entry["$entry"]="$ssid"
    signal_by_entry["$entry"]="$signal"
    security_by_entry["$entry"]="$security"
    active_by_entry["$entry"]="$active"
  done

  entries+=(
    "󰑓  Rescan"
    "󰖪  Disable Wi-Fi"
  )

  local selection

  selection="$(
    printf '%s\n' "${entries[@]}" |
      rofi \
        -dmenu \
        -i \
        -p "󰖩 Network" \
        "${ROFI_COMMON[@]}" ||
      true
  )"

  case "$selection" in
  "")
    return 0
    ;;

  "󰑓  Rescan")
    if nmcli \
      device wifi rescan \
      >/dev/null 2>&1; then
      sleep 0.5
    else
      notify "Wi-Fi scan failed"
    fi

    exec "$0"
    ;;

  "󰖪  Disable Wi-Fi")
    nmcli radio wifi off
    notify "Wi-Fi disabled"
    ;;

  *)
    local selected_ssid="${ssid_by_entry[$selection]:-}"

    [[ -n "$selected_ssid" ]] || return 0

    network_actions \
      "$selected_ssid" \
      "${signal_by_entry[$selection]}" \
      "${security_by_entry[$selection]}" \
      "${active_by_entry[$selection]}"

    exec "$0"
    ;;
  esac
}

main() {
  require_command nmcli
  require_command rofi

  if ! wifi_enabled; then
    show_wifi_disabled
    return
  fi

  show_networks
}

main "$@"
