
#!/usr/bin/env bash

echo "Standardizing Express router imports..."

find routes -type f -name "*.ts" | while read file; do

  # ensure correct import exists

  if grep -q "Router()" "$file"; then

    sed -i '' 's/import express.*from "express"/import { Router, Request, Response } from "express"/g' "$file"

    # fallback insert if missing

    if ! grep -q "Router" "$file"; then

      awk 'NR==1{print "import { Router, Request, Response } from \"express\";"} {print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

    fi

  fi

done

echo "Done"

