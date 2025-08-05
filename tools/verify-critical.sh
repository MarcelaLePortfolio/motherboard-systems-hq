#!/bin/bash
set -e

PROJECT="$HOME/Desktop/Motherboard_Systems_HQ"
MISSING=0

CRITICAL_ITEMS=(
  # 1️⃣ Agents
  "scripts/agents/cade.ts"
  "scripts/agents/effie.ts"
  "scripts/agents/matilda.mts"
  "scripts/agents/matilda.mts"

  # 2️⃣ UI / Dashboard
  "ui/dashboard/index.html"
  "ui/dashboard/dash.js"
  "ui/dashboard/agent-status.json"
  "ui/dashboard/favicon.ico"
  "ui/dashboard/test.json"
  "ui/dashboard/public/dash.css"
  "ui/dashboard/public/dash.js"
  "ui/dashboard/public/index.html"
  "ui/dashboard/public/dash-status-debug.js"
  "ui/dashboard/public/dash-status-injection.js"
  "ui/dashboard/public/dash.js.minimal"
  "ui/dashboard/public/dash.js.broken"
  "ui/dashboard/public/index.html.bak"
  "ui/dashboard/public_broken_2143/index.html"

  # 3️⃣ Memory
  "memory/agent_memory.db"
  "memory/agent_chain_state.json"
  "memory/memory_trace.json"
  "memory/sentiment_trace.json"

  # 4️⃣ Privacy / Audit
  "privacy/audit_access_log.json"
  "privacy/erase_trigger_log.json"
  "privacy/user_privacy_flags.json"
  "privacy/selective_deletion_log.json"

  # 5️⃣ Scripts & Tools
  "scripts/_local/agent-runtime/launch-cade.ts"
  "scripts/_local/agent-runtime/launch-effie.ts"
  "scripts/_local/agent-runtime/launch-matilda.ts"
  "scripts/_local/dev-server.ts"
  "tools/backup-now.sh"
  "tools/restore-motherboard.sh"
  "tools/restore-ui.sh"
  "tools/inspect-backup.sh"

  # 6️⃣ Project Root
  ".env.local"
  "pnpm-lock.yaml"
  "tsconfig.json"
  ".git/HEAD"
)

echo "🔹 Verifying project: $PROJECT"

for ITEM in "${CRITICAL_ITEMS[@]}"; do
    if [ ! -e "$PROJECT/$ITEM" ]; then
        echo "❌ Missing: $ITEM"
        ((MISSING++))
    else
        echo "✅ Found: $ITEM"
    fi
done

echo
if [ $MISSING -eq 0 ]; then
    echo "🎉 All critical files are present. Safe to back up!"
else
    echo "⚠️ $MISSING critical files/folders are missing! Investigate before backing up."
fi
