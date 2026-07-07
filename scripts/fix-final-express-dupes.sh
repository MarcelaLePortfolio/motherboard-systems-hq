
#!/bin/bash

FILES=(

  "routes/cade.ts"

  "routes/tasks.ts"

)

echo "🧼 Cleaning final Express duplicates..."

for f in "${FILES[@]}"; do

  awk '

  BEGIN {

    seenExpress = 0;

    seenRouter = 0;

  }

  /import express from "express";/ {

    if (seenExpress == 0) {

      print;

      seenExpress = 1;

    }

    next;

  }

  /const router = express\.Router\(\);/ {

    if (seenRouter == 0) {

      print;

      seenRouter = 1;

    }

    next;

  }

  { print }

  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

done

echo "✅ Final duplicate cleanup complete"

