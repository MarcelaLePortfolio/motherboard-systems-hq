
#!/usr/bin/env bash

echo "Fixing Express type imports..."

find routes -type f -name "*.ts" | while read file; do

  # ensure correct imports exist

  if grep -q "express.Router" "$file"; then

    sed -i '' 's/express\.Router()/Router()/g' "$file"

  fi

  # ensure proper express imports (FIX REQUEST/RESPONSE TYPES)

  if grep -q "Router()" "$file" && ! grep -q "import.*express" "$file"; then

    awk 'NR==1{print "import express, { Router, Request, Response } from \"express\";"} {print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

  fi

done

echo "Done"

