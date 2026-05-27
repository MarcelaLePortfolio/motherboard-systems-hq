#!/bin/bash
set -e

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

echo "🔁 Phase 11 v11.10 resume — rebuild dashboard bundle and containers"

npm run build:dashboard-bundle

docker-compose down
docker-compose up --build -d

echo "✅ Phase 11 v11.10 resume complete."
echo "➡️ Open http://127.0.0.1:8080/dashboard
 to verify OPS pill, Matilda chat, and Project Visual Output screen."
