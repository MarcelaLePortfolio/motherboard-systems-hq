#!/bin/bash
set -e

FILE="server/routes/task-events-sse.mjs"

# Replace fallback password only
sed -i '' 's/password: process.env.POSTGRES_PASSWORD || "password"/password: process.env.POSTGRES_PASSWORD || "postgres"/' "$FILE"

node --check "$FILE"
git diff -- "$FILE"

git add "$FILE"
git commit -m "Fix SSE DB fallback password to match docker postgres config"
git push
