
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 LIVE CHAT FAILURE TRACE ====="

echo ""

echo "[1] Tail dashboard logs live (open another terminal for browser test)"

echo "Send these messages in order:"

echo "  hi"

echo "  project ideas. what could the system build for me?"

echo ""

echo "Press CTRL+C after reproducing the failure."

echo ""

docker compose logs -f dashboard | grep -Ei "chat|ollama|11434|abort|timeout|error|fetch|api/chat"

