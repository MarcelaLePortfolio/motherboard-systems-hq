/* eslint-disable import/no-commonjs */
#!/bin/bash
# 🔄 Motherboard Systems HQ - Toggle Agents
# Usage: bash scripts/system/toggle_agents.sh [stub|full]

MODE="$1"

if [[ "$MODE" == "stub" ]]; then
  echo "🔹 Switching to stub agents..."
  cp scripts/agents_stub/*.ts scripts/agents/
elif [[ "$MODE" == "full" ]]; then
  echo "🔹 Switching to full agents..."
  cp scripts/agents_full/*.ts scripts/agents/
else
  echo "Usage: $0 [stub|full]"
  exit 1
fi

# Restart PM2
pm2 delete all
pm2 flush
rm -rf ~/.tsx

NODE_BIN=$(which node)
pm2 start "$NODE_BIN" --name cade --interpreter none -- --import tsx ./scripts/_local/agent-runtime/launch-cade.ts
pm2 start "$NODE_BIN" --name effie --interpreter none -- --import tsx ./scripts/_local/agent-runtime/launch-effie.ts
pm2 start "$NODE_BIN" --name matilda --interpreter none -- --import tsx ./scripts/_local/agent-runtime/launch-matilda.ts
pm2 start "$NODE_BIN" --name cade-processor --interpreter none -- --import tsx ./scripts/_local/agent-runtime/cade-processor.ts

# Start watchdog
pm2 start scripts/system/watchdog_agents.sh --name watchdog-agents

pm2 save
