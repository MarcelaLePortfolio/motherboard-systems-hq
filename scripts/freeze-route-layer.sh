
#!/bin/bash

echo "🔒 Freezing route injection artifacts..."

# Remove duplicated injected router blocks safely

find routes -type f -name "*.ts" | while read f; do

  awk '

    BEGIN {skip=0}

    /import express from "express";/ {next}

    /const router = express\.Router\(\);/ {next}

    /export default router;/ {next}

    {print}

  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

done

echo "✅ Route layer stabilized (inject artifacts removed)"

