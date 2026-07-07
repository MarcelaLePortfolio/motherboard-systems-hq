
#!/usr/bin/env bash

echo "Fixing governance-runtime boolean/number drift..."

FILE="db/governance-runtime.ts"

# backup first

cp "$FILE" "$FILE.bak"

# normalize comparisons: raw boolean-safe coercion wrapper

sed -i '' 's/=== 1/== 1/g' "$FILE"

sed -i '' 's/=== 0/== 0/g' "$FILE"

echo "Done."

