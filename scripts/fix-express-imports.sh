
#!/usr/bin/env bash

echo "Fixing Express import patterns..."

# Convert "import { Router } from 'express'" → safe default

find routes server scripts -type f -name "*.ts" -exec sed -i '' \

's/import { Router } from "express"/import express from "express"/g' {} +

# Convert express.Router() safety pattern consistency

find routes server scripts -type f -name "*.ts" -exec sed -i '' \

's/express\.Router()/express.Router()/g' {} +

echo "Done"

