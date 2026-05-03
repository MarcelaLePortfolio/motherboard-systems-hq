#!/usr/bin/env bash
set -euo pipefail

echo "[1] Fetch tasks API"
curl -sS 'http://localhost:8080/api/tasks?limit=5' | jq

echo
echo "[2] Confirm claimed_by present in payload"
curl -sS 'http://localhost:8080/api/tasks?limit=5' | grep -E "claimed_by|worker"

echo
echo "[3] Reminder: hard refresh dashboard (Cmd+Shift+R)"
echo "[4] Expected UI:"
echo "agent: worker-1"
