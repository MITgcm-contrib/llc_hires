#!/bin/bash

dest="diags_run20260125_141254"
mkdir -p "$dest"
mv STD* "$dest/"
mv R_* "$dest/"

# Variable prefixes taken from your R_ files
vars=(
W
SHIfwFlx
KPPhbl
oceFWflx
oceQnet
oceQsw
oceSflux
oceTAUX
oceTAUY
PhiBot
SHIhtFlx
)

for v in "${vars[@]}"; do
    for f in ${v}*.data; do
        [ -e "$f" ] || continue
        mv "$f" "$dest/"
    done
done

