#!/bin/bash
set -euo pipefail

FILE="server/routes/task-events-sse.mjs"

sed -i '' 's/database: process.env.POSTGRES_DB || "dashboard_db"/database: process.env.POSTGRES_DB || "postgres"/' "$FILE"

node --check "$FILE"
git diff -- "$FILE"

git add "$FILE"
git commit -m "Fix SSE DB fallback name to match docker postgres config"
git push

docker compose up -d --build dashboard

sleep 3

curl -sS -o /dev/null -w "%{http_code} %{content_type}\n" http://localhost:3000/events/task-events
curl -N --max-time 10 http://localhost:3000/events/task-events
