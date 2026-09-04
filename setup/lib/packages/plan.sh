#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_PACKAGE_PLAN_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_PACKAGE_PLAN_LOADED=1

deduplicate_packages() {
  local destination_name="$1"
  shift

  # destination_ref is a nameref to an array supplied by the caller.
  # shellcheck disable=SC2178
  local -n destination_ref="$destination_name"

  local -A seen=()
  local package

  destination_ref=()

  for package in "$@"; do
    if [[ -n "${seen[$package]+x}" ]]; then
      continue
    fi

    seen["$package"]=1
    destination_ref+=("$package")
  done
}

build_package_plan() {
  local arch_destination_name="$1"
  local aur_destination_name="$2"

  deduplicate_packages \
    "$arch_destination_name" \
    "${SELECTED_ARCH_REQUIRED[@]}" \
    "${SELECTED_ARCH_RECOMMENDED[@]}" \
    "${SELECTED_ARCH_DEFAULT_APPS[@]}"

  deduplicate_packages \
    "$aur_destination_name" \
    "${SELECTED_AUR_REQUIRED[@]}"
}
