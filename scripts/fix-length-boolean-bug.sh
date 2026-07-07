
#!/usr/bin/env bash

echo "Fixing length === boolean comparisons..."

FILE="db/governance-runtime.ts"

cp "$FILE" "$FILE.bak"

# fix the actual TS2367 root cause

sed -i '' 's/length === false/length === 0/g' "$FILE"

sed -i '' 's/length === true/length > 0/g' "$FILE"

echo "Length comparison bug fixed."

