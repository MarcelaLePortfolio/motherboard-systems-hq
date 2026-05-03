#!/bin/bash
set -e

echo "🔄 Restoring Motherboard Systems HQ to v1.0.0-golden..."

cd "$(dirname "$0")"

git fetch --all --tags
git reset --hard v1.0.0-golden

echo "<0001f9f9> Cleaning PM2..."
pm2 kill || true
rm -rf ~/.pm2

echo "📦 Reinstalling node modules..."
rm -rf node_modules .next dist
pnpm install

echo "🚀 Starting baseline agents..."
pm2 start scripts/_local/agent-runtime/launch-matilda.ts --name matilda --interpreter $(which tsx)
pm2 start scripts/servers/reflection-sse-server.ts --name reflections --interpreter $(which tsx)
pm2 start scripts/servers/ops-sse-server.ts --name ops --interpreter $(which tsx)
pm2 save --force

echo "✨ Restore complete. System is clean and working."
