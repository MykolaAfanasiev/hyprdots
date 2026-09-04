#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_VERIFY_INSTALL_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_VERIFY_INSTALL_LOADED=1

run_post_install_verification() {
  section "[11/11] Post-install verification"

  reset_verification_report

  verify_selected_packages
  verify_configuration
  verify_runtime

  print_verification_summary

  if ((VERIFY_FAIL_COUNT > 0)); then
    die "Post-install verification failed."
  fi

  if ((VERIFY_WARN_COUNT > 0)); then
    warn "Installation completed with warnings."
    return 0
  fi

  success "Post-install verification passed"
}
