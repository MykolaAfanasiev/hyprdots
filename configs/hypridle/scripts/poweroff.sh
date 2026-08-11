#!/usr/bin/env bash

exec hyprshutdown \
    --top-label "Shutting down..." \
    --post-cmd 'shutdown -P 0'
