
#!/usr/bin/env bash

echo "Running system stabilization pass..."

# -----------------------------

# 1. Normalize DB imports

# -----------------------------

find routes -type f -name "*.ts" | while read file; do



  sed -i '' 's#"\.\./db/audit"#"../db/audit"#g' "$file"

  sed -i '' 's#"\.\./\.\./db/audit"#"../db/audit"#g' "$file"

done

# -----------------------------

# 2. Normalize Express imports

# -----------------------------

find routes -type f -name "*.ts" | while read file; do

  if grep -q "express.Router" "$file"; then

    sed -i '' 's/import express from "express"/import express, { Request, Response, Router } from "express"/g' "$file"

  fi

done

# -----------------------------

# 3. Remove duplicate bad Request/Response patterns

# -----------------------------

find routes -type f -name "*.ts" | while read file; do

  sed -i '' 's/: Request, Response//g' "$file"

  sed -i '' 's/Request, Response//g' "$file"

done

echo "Stabilization pass complete."

