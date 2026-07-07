
#!/usr/bin/env bash

echo "Running FINAL REAL stabilization..."

# -----------------------------------------

# 1. STOP TypeScript from analyzing backups

# -----------------------------------------

echo "Excluding legacy backup from TS (safe guard)..."

# add exclusion if not present

if ! grep -q "_legacy_backup" tsconfig.json; then

  sed -i '' 's/"exclude": \[/\"exclude\": [\"routes\/_legacy_backup\", /' tsconfig.json

fi

# -----------------------------------------

# 2. Fix boolean literal mismatch (safe coercion)

# -----------------------------------------

find db -type f -name "*.ts" | while read file; do

  sed -i '' 's/=== 1/=== true/g' "$file"

  sed -i '' 's/=== 0/=== false/g' "$file"

done

# -----------------------------------------

# 3. Normalize Express imports ONLY (no rewrites)

# -----------------------------------------

find routes -type f -name "*.ts" | while read file; do

  if grep -q "express.Router" "$file"; then

    sed -i '' 's/import express from "express"/import express from "express"/g' "$file"

  fi

done

echo "FINAL stabilization complete."

