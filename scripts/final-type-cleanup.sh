
#!/usr/bin/env bash

echo "Running FINAL targeted cleanup pass..."

# -----------------------------

# 1. Fix Express Router consistency ONLY

# -----------------------------

find routes -type f -name "*.ts" | while read file; do

  # ensure express is consistent

  if grep -q "Router()" "$file"; then

    sed -i '' 's/import express from "express"/import express from "express"/g' "$file"

  fi

done

# -----------------------------

# 2. Normalize DB imports only (safe path fix)

# -----------------------------

find . -type f -name "*.ts" | while read file; do



  sed -i '' 's#"\.\./db/audit"#"../db/audit"#g' "$file"

  sed -i '' 's#"\.\./\.\./db/audit"#"../db/audit"#g' "$file"

done

echo "FINAL cleanup complete."

