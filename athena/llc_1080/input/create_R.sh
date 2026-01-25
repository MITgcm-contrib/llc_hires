#!/bin/bash
for f in *.0000038880.data; do
    cp "$f" "R_$f"
done

