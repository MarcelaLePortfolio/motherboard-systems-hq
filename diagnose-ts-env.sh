import Database from "better-sqlite3";

#!/usr/bin/env bash

echo "=== TS ENV DIAGNOSTIC ==="

echo ""

echo "Node:"

node -v

echo ""

echo "TypeScript:"

npx tsc -v

echo ""

echo "Checking tsconfig flags..."

cat tsconfig.json | grep -E "target|module|lib|esModuleInterop|allowImportingTsExtensions" || echo "No relevant flags found"

echo ""

echo "Checking express types..."

npm ls express @types/express || true

echo ""

echo "Checking sqlite types..."

npm ls better-sqlite3 @types/better-sqlite3 || true

echo ""

echo "DONE"

