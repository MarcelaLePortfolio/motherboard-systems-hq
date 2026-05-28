
#!/bin/bash

set -euo pipefail

OUTPUT="GOVERNED_ROUTE_REGISTRATION_DISCOVERY.txt"

: > "$OUTPUT"

echo "===== GOVERNED ROUTE REGISTRATION DISCOVERY =====" >> "$OUTPUT"

echo "$(date)" >> "$OUTPUT"

echo >> "$OUTPUT"

echo "===== EXPRESS SERVER SURFACES =====" >> "$OUTPUT"

find . \( \

  -name "server.js" -o \

  -name "app.js" -o \

  -name "index.js" -o \

  -name "*.mjs" -o \

  -name "*.ts" \

\) \

-type f \

| grep -v node_modules \

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

  "governed-planning-route\|governed_planning\|governed-planning" \

  server scripts . \

  --exclude-dir=node_modules \

  >> "$OUTPUT" 2>/dev/null || true

echo >> "$OUTPUT"

echo "===== SERVER ENTRYPOINT CANDIDATES =====" >> "$OUTPUT"

find . \

  \( -name "server.js" -o -name "index.js" -o -name "app.js" \) \

  -type f \

  | grep -v node_modules \

  >> "$OUTPUT"

echo >> "$OUTPUT"

echo "===== DISCOVERY COMPLETE =====" >> "$OUTPUT"

cat "$OUTPUT"

