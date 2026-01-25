#!/usr/bin/env bash
set -e

file="data.cal"

# Extract YYYYMMDD from startDate_1
orig=$(sed -nE 's/.*startDate_1=([0-9]{8}).*/\1/p' "$file")

if [[ -z "$orig" ]]; then
    echo "Error: startDate_1 not found in $file"
    exit 1
fi

# Convert to date, add 27 days
newdate=$(date -u -d "${orig:0:4}-${orig:4:2}-${orig:6:2} +27 days" +"%Y%m%d")

echo "Original date: $orig"
echo "New date:      $newdate"

# Replace in file
sed -i -E "s/(startDate_1=)[0-9]{8}/\1$newdate/" "$file"

