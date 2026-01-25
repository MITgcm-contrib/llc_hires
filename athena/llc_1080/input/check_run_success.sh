#!/usr/bin/env bash
PATTERN="PROGRAM MAIN: Execution ended Normally"

latest_log=$(ls -1t STDOUT* *.out *.log 2>/dev/null | head -n 1)

[[ -z "$latest_log" ]] && exit 1

tail -n 20 "$latest_log" | grep -q "$PATTERN"
