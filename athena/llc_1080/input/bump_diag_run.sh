#!/usr/bin/env bash
set -e

if (( $# == 0 )); then
    echo "Usage: $0 file1 [file2 file3 ...]"
    exit 1
fi

# Generate timestamp once for this run
ts=$(date +"%Y%m%d_%H%M%S")

for file in "$@"; do
    if [[ ! -f "$file" ]]; then
        echo "Skipping $file (not found)"
        continue
    fi

    # Extract old dest value if present
    old=$(sed -nE 's/.*(dest="diags_run[^"]*").*/\1/p' "$file")

    if [[ -z "$old" ]]; then
        echo "No dest=\"diags_run...\" found in $file ? skipping"
        continue
    fi

    # Replace with timestamped version
    sed -i -E "s/dest=\"diags_run[^\"]*\"/dest=\"diags_run${ts}\"/" "$file"

    echo "$file : $old ? dest=\"diags_run${ts}\""
done

