
#!/usr/bin/env bash

echo "Fixing Express type consistency..."

find routes -type f -name "*.ts" | while read file; do

  # ensure express import exists

  if grep -q "express.Router" "$file" || grep -q "Router(" "$file"; then

    sed -i '' 's/import express from "express"/import express, { Request, Response } from "express"/g' "$file"

  fi

done

echo "Done"

