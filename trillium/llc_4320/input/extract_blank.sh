#!/usr/bin/env bash

infile="$1"
outfile="blank"

awk '
  match($0, /Empty tile: #[[:space:]]*([0-9]+)/, m) {
    printf "%s,\n", m[1]    # [N4],
  }
' "$infile" > "$outfile"
