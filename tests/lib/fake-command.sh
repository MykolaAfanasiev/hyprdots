#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_TEST_FAKE_COMMAND_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_TEST_FAKE_COMMAND_LOADED=1

create_fake_command() {
  local command_name="$1"
  local exit_code="${2:-0}"

  local command_path="$TEST_BIN/$command_name"

  cat >"$command_path" <<EOF
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/$command_name.log"

exit $exit_code
EOF

  chmod +x -- "$command_path"
}
