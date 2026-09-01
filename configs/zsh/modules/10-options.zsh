# Allow comments in the interactive shell
setopt INTERACTIVE_COMMENTS

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# More powerful filename patterns
setopt EXTENDED_GLOB

# Show more information about background jobs
setopt LONG_LIST_JOBS

# Disable terminal bell and Ctrl+S/Ctrl+Q flow control
unsetopt BEEP
unsetopt FLOW_CONTROL
