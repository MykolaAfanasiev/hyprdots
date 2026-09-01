# Ghostty shell integration provides OSC 133 semantic prompt markers.
#
# GHOSTTY_RESOURCES_DIR can be missing after `exec zsh` or inside a
# previously created Zellij session. Arch Linux installs Ghostty
# resources into /usr/share/ghostty.

if [[ -z ${GHOSTTY_RESOURCES_DIR:-} &&
      -d /usr/share/ghostty ]]; then
    export GHOSTTY_RESOURCES_DIR=/usr/share/ghostty
fi

if [[ -r "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration" ]]; then
    builtin source \
        "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
else
    print -u2 -- "Warning: Ghostty Zsh integration was not found"
fi
