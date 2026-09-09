#!/usr/bin/env bash

set -euo pipefail

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  STATE_DIR="$XDG_RUNTIME_DIR/hyprdots/hyprlock"
else
  STATE_DIR="/run/user/$(id -u)/hyprdots/hyprlock"
fi

HYPRLOCK_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SESSION_CONFIG="$HYPRLOCK_DIR/session.conf"

BLUETOOTH_LOCK_POLICY="disconnect-audio"

if [[ -r "$SESSION_CONFIG" ]]; then
  # shellcheck source=/dev/null
  source "$SESSION_CONFIG"
fi

MPRIS_FILE="$STATE_DIR/mpris-playing"
MPD_FILE="$STATE_DIR/mpd-playing"
AUDIO_FILE="$STATE_DIR/audio-sinks"
ACTIVE_FILE="$STATE_DIR/active"

MPD_SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/mpd/socket"

BLUETOOTH_FILE="$STATE_DIR/bluetooth-audio"
BLUETOOTH_POWER_FILE="$STATE_DIR/bluetooth-powered"

warn() {
  printf 'hyprlock-session: %s\n' "$*" >&2
}

mute_all_sinks() {
  command -v pactl >/dev/null 2>&1 || return 0

  local sink

  while IFS= read -r sink; do
    [[ -n "$sink" ]] || continue

    pactl \
      set-sink-mute \
      "$sink" \
      1 >/dev/null 2>&1 ||
      true
  done < <(
    pactl list short sinks 2>/dev/null |
      awk '{ print $2 }'
  )
}

lock_mpris() {
  command -v playerctl >/dev/null 2>&1 || return 0

  : >"$MPRIS_FILE"

  local player
  local status

  while IFS= read -r player; do
    [[ -n "$player" ]] || continue

    status="$(
      playerctl \
        --player="$player" \
        status 2>/dev/null ||
        true
    )"

    [[ "$status" == "Playing" ]] || continue

    printf '%s\n' "$player" >>"$MPRIS_FILE"

    playerctl \
      --player="$player" \
      pause >/dev/null 2>&1 ||
      warn "Could not pause MPRIS player: $player"
  done < <(playerctl -l 2>/dev/null || true)
}

unlock_mpris() {
  command -v playerctl >/dev/null 2>&1 || return 0
  [[ -s "$MPRIS_FILE" ]] || return 0

  local player

  while IFS= read -r player; do
    [[ -n "$player" ]] || continue

    if playerctl --player="$player" status >/dev/null 2>&1; then
      playerctl \
        --player="$player" \
        play >/dev/null 2>&1 ||
        warn "Could not resume MPRIS player: $player"
    fi
  done <"$MPRIS_FILE"
}

lock_mpd() {
  command -v mpc >/dev/null 2>&1 || return 0
  [[ -S "$MPD_SOCKET" ]] || return 0

  rm -f -- "$MPD_FILE"

  if mpc --host="$MPD_SOCKET" status 2>/dev/null |
    grep -q '^\[playing\]'; then

    touch "$MPD_FILE"

    mpc \
      --host="$MPD_SOCKET" \
      pause >/dev/null 2>&1 ||
      warn "Could not pause MPD"
  fi
}

unlock_mpd() {
  command -v mpc >/dev/null 2>&1 || return 0
  [[ -f "$MPD_FILE" ]] || return 0
  [[ -S "$MPD_SOCKET" ]] || return 0

  mpc \
    --host="$MPD_SOCKET" \
    play >/dev/null 2>&1 ||
    warn "Could not resume MPD"
}

sink_exists() {
  local wanted_sink="$1"

  pactl list short sinks 2>/dev/null |
    awk '{ print $2 }' |
    grep -Fxq -- "$wanted_sink"
}

lock_audio() {
  command -v pactl >/dev/null 2>&1 || return 0

  : >"$AUDIO_FILE"

  local sink
  local mute_status
  local was_muted

  while IFS= read -r sink; do
    [[ -n "$sink" ]] || continue

    mute_status="$(
      pactl get-sink-mute "$sink" 2>/dev/null ||
        true
    )"

    case "$mute_status" in
    *"yes"*)
      was_muted=1
      ;;
    *"no"*)
      was_muted=0
      ;;
    *)
      continue
      ;;
    esac

    printf '%s\t%s\n' \
      "$sink" \
      "$was_muted" >>"$AUDIO_FILE"

    pactl \
      set-sink-mute \
      "$sink" \
      1 >/dev/null 2>&1 ||
      warn "Could not mute sink: $sink"
  done < <(
    pactl list short sinks 2>/dev/null |
      awk '{ print $2 }'
  )
}

unlock_audio() {
  command -v pactl >/dev/null 2>&1 || return 0
  [[ -r "$AUDIO_FILE" ]] || return 0

  local sink
  local was_muted

  while IFS=$'\t' read -r sink was_muted; do
    [[ -n "$sink" ]] || continue

    # Bluetooth and other outputs may have disappeared while locked.
    sink_exists "$sink" || continue

    case "$was_muted" in
    0 | 1)
      pactl \
        set-sink-mute \
        "$sink" \
        "$was_muted" >/dev/null 2>&1 ||
        warn "Could not restore sink: $sink"
      ;;
    esac
  done <"$AUDIO_FILE"
}
bluetooth_mac_from_sink() {
  local sink="$1"
  local device

  device="${sink#bluez_output.}"
  device="${device%%.*}"
  device="${device//_/:}"

  printf '%s\n' "$device"
}

bluetooth_connected_audio_devices() {
  command -v pactl >/dev/null 2>&1 || return 0

  local sink
  local mac

  while IFS= read -r sink; do
    [[ "$sink" == bluez_output.* ]] || continue

    mac="$(bluetooth_mac_from_sink "$sink")"

    [[ -n "$mac" ]] || continue

    printf '%s\n' "$mac"
  done < <(
    pactl list short sinks 2>/dev/null |
      awk '{ print $2 }'
  )
}

bluetooth_is_powered() {
  command -v bluetoothctl >/dev/null 2>&1 || return 1

  bluetoothctl show 2>/dev/null |
    grep -q 'Powered: yes'
}

lock_bluetooth_audio() {
  command -v bluetoothctl >/dev/null 2>&1 || return 0

  : >"$BLUETOOTH_FILE"

  local mac

  while IFS= read -r mac; do
    [[ -n "$mac" ]] || continue

    printf '%s\n' "$mac" >>"$BLUETOOTH_FILE"

    bluetoothctl \
      disconnect "$mac" >/dev/null 2>&1 ||
      warn "Could not disconnect Bluetooth audio device: $mac"
  done < <(bluetooth_connected_audio_devices)
}

lock_bluetooth_power() {
  command -v bluetoothctl >/dev/null 2>&1 || return 0

  rm -f -- "$BLUETOOTH_POWER_FILE"

  if bluetooth_is_powered; then
    printf '1\n' >"$BLUETOOTH_POWER_FILE"

    bluetoothctl power off >/dev/null 2>&1 ||
      warn "Could not power off Bluetooth"
  else
    printf '0\n' >"$BLUETOOTH_POWER_FILE"
  fi
}

unlock_bluetooth_power() {
  command -v bluetoothctl >/dev/null 2>&1 || return 0
  [[ -r "$BLUETOOTH_POWER_FILE" ]] || return 0

  local was_powered
  was_powered="$(<"$BLUETOOTH_POWER_FILE")"

  if [[ "$was_powered" == "1" ]]; then
    bluetoothctl power on >/dev/null 2>&1 ||
      warn "Could not restore Bluetooth power"
  fi
}

lock_bluetooth() {
  case "$BLUETOOTH_LOCK_POLICY" in
  keep)
    ;;

  disconnect-audio)
    lock_bluetooth_audio
    ;;

  power-off)
    lock_bluetooth_power
    ;;

  *)
    warn "Unknown Bluetooth policy: $BLUETOOTH_LOCK_POLICY"
    ;;
  esac
}

unlock_bluetooth() {
  case "$BLUETOOTH_LOCK_POLICY" in
  keep | disconnect-audio)
    # Audio devices intentionally stay disconnected.
    ;;

  power-off)
    unlock_bluetooth_power
    ;;
  esac
}

reconnect_bluetooth_audio() {
  command -v bluetoothctl >/dev/null 2>&1 || return 1
  [[ -s "$BLUETOOTH_FILE" ]] || return 1

  local mac
  local connected=false

  while IFS= read -r mac; do
    [[ -n "$mac" ]] || continue

    if bluetoothctl connect "$mac" >/dev/null 2>&1; then
      connected=true
    else
      warn "Could not reconnect Bluetooth audio device: $mac"
    fi
  done <"$BLUETOOTH_FILE"

  [[ "$connected" == true ]]
}

wait_for_bluetooth_audio() {
  command -v pactl >/dev/null 2>&1 || return 1

  local timeout=5
  local elapsed=0

  while ((elapsed < timeout * 10)); do
    if pactl list short sinks 2>/dev/null |
      awk '{ print $2 }' |
      grep -q '^bluez_output\.'; then

      return 0
    fi

    sleep 0.1
    ((elapsed += 1))
  done

  return 1
}

lock_session() {
  mkdir -p -- "$STATE_DIR"

  rm -f -- \
    "$MPRIS_FILE" \
    "$MPD_FILE" \
    "$AUDIO_FILE" \
    "$BLUETOOTH_FILE" \
    "$BLUETOOTH_POWER_FILE" \
    "$ACTIVE_FILE"

  lock_mpris
  lock_mpd

  # Save the original state of every output and mute them.
  lock_audio

  # Bluetooth audio can now be safely disconnected.
  lock_bluetooth

  # The default output may have changed after Bluetooth disconnect.
  mute_all_sinks

  touch "$ACTIVE_FILE"
}

bluetooth_audio_was_disconnected() {
  [[ -s "$BLUETOOTH_FILE" ]]
}

unlock_session() {
  [[ -f "$ACTIVE_FILE" ]] || return 0

  local bluetooth_restored=false

  if bluetooth_audio_was_disconnected; then
    if reconnect_bluetooth_audio &&
      wait_for_bluetooth_audio; then

      bluetooth_restored=true
    fi
  fi

  unlock_bluetooth
  unlock_audio

  if bluetooth_audio_was_disconnected; then
    if [[ "$bluetooth_restored" == true ]]; then
      unlock_mpd
      unlock_mpris
    fi
  else
    unlock_mpd
    unlock_mpris
  fi

  rm -rf -- "$STATE_DIR"
}

case "${1:-}" in
lock)
  lock_session
  ;;

unlock)
  unlock_session
  ;;

*)
  printf 'Usage: %s {lock|unlock}\n' "$0" >&2
  exit 1
  ;;
esac
