#!/bin/bash

set -e

echo "Installing missing runtime dependencies..."

npm install better-sqlite3 cors uuid chokidar node-fetch proper-lockfile drizzle-orm ollama

echo "Installing type dependencies..."

npm install -D @types/node @types/cors @types/uuid @types/node-fetch

echo "Verifying core agent entrypoints..."

ls mirror/agent.ts
ls agents/matilda.*

echo "Dependency restore complete."
