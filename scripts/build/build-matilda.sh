#!/usr/bin/env bash

set -e

echo "[BUILD] Matilda compile step starting..."

# ensure clean dist
rm -rf dist
mkdir -p dist

# compile TypeScript
npx tsc --project tsconfig.json

echo "[BUILD] compile complete"

echo "[RUN] start command example:"
echo "pm2 start dist/scripts/_local/agent-runtime/launch-matilda.js --name matilda"

echo "[OK] Matilda build pipeline ready"
