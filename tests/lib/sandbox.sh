#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_TEST_SANDBOX_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_TEST_SANDBOX_LOADED=1

ORIGINAL_HOME="$HOME"
ORIGINAL_PATH="$PATH"

ORIGINAL_TMPDIR="${TMPDIR-}"
ORIGINAL_XDG_CONFIG_HOME="${XDG_CONFIG_HOME-}"
ORIGINAL_XDG_CACHE_HOME="${XDG_CACHE_HOME-}"
ORIGINAL_XDG_DATA_HOME="${XDG_DATA_HOME-}"
ORIGINAL_XDG_STATE_HOME="${XDG_STATE_HOME-}"

ORIGINAL_TMPDIR_SET="${TMPDIR+x}"
ORIGINAL_XDG_CONFIG_HOME_SET="${XDG_CONFIG_HOME+x}"
ORIGINAL_XDG_CACHE_HOME_SET="${XDG_CACHE_HOME+x}"
ORIGINAL_XDG_DATA_HOME_SET="${XDG_DATA_HOME+x}"
ORIGINAL_XDG_STATE_HOME_SET="${XDG_STATE_HOME+x}"

create_test_sandbox() {
    TEST_ROOT="$(
        mktemp -d \
            "${TMPDIR:-/tmp}/hyprdots-test.XXXXXX"
    )"

    TEST_HOME="$TEST_ROOT/home"
    TEST_BIN="$TEST_ROOT/bin"
    TEST_STATE="$TEST_ROOT/state"
    TEST_TMP="$TEST_ROOT/tmp"

    mkdir -p \
        "$TEST_HOME" \
        "$TEST_BIN" \
        "$TEST_STATE" \
        "$TEST_TMP"

    ORIGINAL_HOME="$HOME"
    ORIGINAL_PATH="$PATH"

    export TEST_ROOT
    export TEST_HOME
    export TEST_BIN
    export TEST_STATE
    export TEST_TMP

    export ORIGINAL_HOME
    export ORIGINAL_PATH

    export HOME="$TEST_HOME"
    export PATH="$TEST_BIN:/usr/bin:/bin"
    export TMPDIR="$TEST_TMP"

    export XDG_CONFIG_HOME="$TEST_HOME/.config"
    export XDG_CACHE_HOME="$TEST_HOME/.cache"
    export XDG_DATA_HOME="$TEST_HOME/.local/share"
    export XDG_STATE_HOME="$TEST_HOME/.local/state"

    mkdir -p \
        "$XDG_CONFIG_HOME" \
        "$XDG_CACHE_HOME" \
        "$XDG_DATA_HOME" \
        "$XDG_STATE_HOME"
}

destroy_test_sandbox() {
    if [[ -n "${TEST_ROOT:-}" && -d "$TEST_ROOT" ]]; then
        rm -rf -- "$TEST_ROOT"
    fi

    export HOME="$ORIGINAL_HOME"
    export PATH="$ORIGINAL_PATH"

    if [[ -n "${ORIGINAL_TMPDIR_SET:-}" ]]; then
        export TMPDIR="$ORIGINAL_TMPDIR"
    else
        unset TMPDIR
    fi

    if [[ -n "${ORIGINAL_XDG_CONFIG_HOME_SET:-}" ]]; then
        export XDG_CONFIG_HOME="$ORIGINAL_XDG_CONFIG_HOME"
    else
        unset XDG_CONFIG_HOME
    fi

    if [[ -n "${ORIGINAL_XDG_CACHE_HOME_SET:-}" ]]; then
        export XDG_CACHE_HOME="$ORIGINAL_XDG_CACHE_HOME"
    else
        unset XDG_CACHE_HOME
    fi

    if [[ -n "${ORIGINAL_XDG_DATA_HOME_SET:-}" ]]; then
        export XDG_DATA_HOME="$ORIGINAL_XDG_DATA_HOME"
    else
        unset XDG_DATA_HOME
    fi

    if [[ -n "${ORIGINAL_XDG_STATE_HOME_SET:-}" ]]; then
        export XDG_STATE_HOME="$ORIGINAL_XDG_STATE_HOME"
    else
        unset XDG_STATE_HOME
    fi

    unset TEST_ROOT
    unset TEST_HOME
    unset TEST_BIN
    unset TEST_STATE
    unset TEST_TMP
}
