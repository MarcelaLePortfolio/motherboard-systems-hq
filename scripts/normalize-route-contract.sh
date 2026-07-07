
#!/bin/bash

echo "🧩 Normalizing Express route contract..."

find routes -type f -name "*.ts" | while read f; do

  awk '

    BEGIN {

      hasExpress = 0;

      hasRouter = 0;

    }

    /import express from "express";/ {

      if (hasExpress == 0) {

        print;

        hasExpress = 1;

      }

      next;

    }

    /const router = express\.Router\(\);/ {

      if (hasRouter == 0) {

        print;

        hasRouter = 1;

      }

      next;

    }

    /export default router;/ {

      print;

      next;

    }

    { print }

  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

done

echo "✅ Route contract normalized"

