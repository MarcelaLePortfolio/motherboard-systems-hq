
#!/bin/bash

set -euo pipefail

OUTPUT="GOVERNED_ROUTE_REGISTRATION_DISCOVERY.txt"

: > "$OUTPUT"

echo "===== GOVERNED ROUTE REGISTRATION DISCOVERY =====" >> "$OUTPUT"

date >> "$OUTPUT"

echo >> "$OUTPUT"

echo "===== EXPRESS SERVER SURFACES =====" >> "$OUTPUT"

find . \

  -path "./.git" -prune -o \

  -path "./node_modules" -prune -o \

  -path "./backups" -prune -o \

  -path "./dist" -prune -o \

  -type f \( \

    -name "server.js" -o \

    -name "app.js" -o \

    -name "index.js" -o \

    -name "*.mjs" -o \

    -name "*.ts" \

  \) -print \

| sort \

| while read -r file; do

  if grep -qE "express|Router|app.use|router.use" "$file" 2>/dev/null; then

    echo >> "$OUTPUT"

    echo "FILE: $file" >> "$OUTPUT"

    echo "--------------------------------------------------" >> "$OUTPUT"

    grep -nE \

      "express|Router|app.use|router.use|governed-planning-route|governed-planning" \

      "$file" \

      >> "$OUTPUT" 2>/dev/null || true

  fi

done

echo >> "$OUTPUT"

echo "===== ROUTE FILE REFERENCES =====" >> "$OUTPUT"

grep -Rni \

  --exclude-dir=.git \

  --exclude-dir=node_modules \

  --exclude-dir=backups \

  --exclude-dir=dist \

  "governed-planning-route\|governed_planning\|governed-planning" \

  server scripts . \

  >> "$OUTPUT" 2>/dev/null || true

echo >> "$OUTPUT"

echo "===== SERVER ENTRYPOINT CANDIDATES =====" >> "$OUTPUT"

find . \

  -path "./.git" -prune -o \

  -path "./node_modules" -prune -o \

  -path "./backups" -prune -o \

  -path "./dist" -prune -o \

  -type f \( \

    -name "server.js" -o \

    -name "index.js" -o \

    -name "app.js" \

  \) -print \

| sort >> "$OUTPUT"

echo >> "$OUTPUT"

echo "===== DISCOVERY COMPLETE =====" >> "$OUTPUT"

cat "$OUTPUT"

