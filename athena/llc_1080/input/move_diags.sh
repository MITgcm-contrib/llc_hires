#!/bin/bash

dest="diags_run20260125_141254"

# Variable prefixes taken from your R_ files
vars=(
Eta
Salt
Theta
U
V
SIarea
SIheff
SIhsalt
SIhsnow
SIuice
SIvice
)

for v in "${vars[@]}"; do
    for f in ${v}*.data; do
        [ -e "$f" ] || continue
        mv "$f" "$dest/"
    done
done

