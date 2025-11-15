#!/usr/bin/env bash

infile="$1"
outfile="blank"

awk '
  # Look for: Empty tile: # <spaces> <number>
  match($0, /Empty tile: #[[:space:]]*([0-9]+)/, m) {
    print m[1]      # m[1] is the captured number = [N4]
  }
' "$infile" > "$outfile"
