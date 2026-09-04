#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_VERIFY_REPORT_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_VERIFY_REPORT_LOADED=1

declare -gi VERIFY_PASS_COUNT=0
declare -gi VERIFY_WARN_COUNT=0
declare -gi VERIFY_FAIL_COUNT=0

reset_verification_report() {
    VERIFY_PASS_COUNT=0
    VERIFY_WARN_COUNT=0
    VERIFY_FAIL_COUNT=0
}

verify_pass() {
    ((VERIFY_PASS_COUNT += 1))
    success "$*"
}

verify_warn() {
    ((VERIFY_WARN_COUNT += 1))
    warn "$*"
}

verify_fail() {
    ((VERIFY_FAIL_COUNT += 1))
    error "$*"
}

print_verification_summary() {
    section "Verification summary"

    success "PASS: $VERIFY_PASS_COUNT"

    if ((VERIFY_WARN_COUNT > 0)); then
        warn "WARN: $VERIFY_WARN_COUNT"
    else
        printf '[WARN] WARN: 0\n'
    fi

    if ((VERIFY_FAIL_COUNT > 0)); then
        error "FAIL: $VERIFY_FAIL_COUNT"
    else
        printf '[FAIL] FAIL: 0\n'
    fi
}
