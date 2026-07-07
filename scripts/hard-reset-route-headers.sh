
#!/bin/bash

echo "🧼 Normalizing all route headers..."

find routes -type f -name "*.ts" | while read f; do

  awk '

    BEGIN {seenExpress=0; seenRouter=0}

    /import express from "express";/ {

      if (seenExpress == 0) {

        print

        seenExpress=1

      }

      next

    }

    /const router = express\.Router\(\);/ {

      if (seenRouter == 0) {

        print

        seenRouter=1

      }

      next

    }

    /export default router;/ {

      if (seenRouter == 1) {

        print

        seenRouter=2

      }

      next

    }

    {print}

  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

done

echo "✅ Route headers normalized"

