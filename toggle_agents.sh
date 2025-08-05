#!/bin/bash
# 🔀 Toggle between stub agents and full agents for Motherboard Systems HQ
# Usage: ./toggle_agents.sh [full|stub]

set -e

TARGET="$1"
AGENTS_DIR="scripts/agents"
STUB_DIR="scripts/agents_stub"
FULL_DIR="scripts/agents_full"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 [full|stub]"
  exit 1
fi

if [ ! -d "$STUB_DIR" ]; then
  echo "📦 Creating stub backup directory..."
  mkdir -p "$STUB_DIR"
  cp $AGENTS_DIR/*.ts "$STUB_DIR"/
fi

if [ "$TARGET" == "full" ]; then
  echo "⚡ Switching to FULL AGENTS..."
  cp "$FULL_DIR"/*.ts "$AGENTS_DIR"/
elif [ "$TARGET" == "stub" ]; then
  echo "💤 Switching to STUB AGENTS..."
  cp "$STUB_DIR"/*.ts "$AGENTS_DIR"/
else
  echo "❌ Invalid target. Use: full | stub"
  exit 1
fi

echo "🔄 Restarting PM2 agents..."
pm2 delete all || true
pm2 flush
rm -rf ~/.tsx

NODE_BIN=$(which node)
pm2 start "$NODE_BIN" --name cade --interpreter none -- --import tsx ./scripts/_local/agent-runtime/launch-cade.ts
pm2 start "$NODE_BIN" --name effie --interpreter none -- --import tsx ./scripts/_local/agent-runtime/launch-effie.ts
pm2 start "$NODE_BIN" --name matilda --interpreter none -- --import tsx ./scripts/_local/agent-runtime/launch-matilda.ts
pm2 start "$NODE_BIN" --name cade-processor --interpreter none -- --import tsx ./scripts/_local/agent-runtime/cade-processor.ts

pm2 save

echo "✅ Switched to $TARGET agents and restarted all services."
