
#!/usr/bin/env bash

echo "Normalizing Express usage (final pass)..."

find routes -type f -name "*.ts" | while read file; do

  # remove broken named imports

  sed -i '' 's/import { Router, Request, Response } from "express"/import express from "express"/g' "$file"

  sed -i '' 's/import { Router } from "express"/import express from "express"/g' "$file"

  # fix router creation

  sed -i '' 's/Router()/express.Router()/g' "$file"

done

echo "Done"

