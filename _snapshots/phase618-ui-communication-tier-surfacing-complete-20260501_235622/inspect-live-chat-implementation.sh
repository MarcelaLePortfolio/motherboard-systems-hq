#!/bin/bash
set -euo pipefail

echo "🔍 Inspecting live /api/chat implementation sources..."
echo

echo "=== server.mjs :: /api/chat region ==="
grep -n 'app.post("/api/chat"\|app.post('\''/api/chat'\''\|deterministic-local-response\|Matilda received your request\|matilda-stub' server.mjs || true
echo
sed -n '340,460p' server.mjs || true
echo

echo "=== matilda-chat-stub.ts ==="
sed -n '1,220p' matilda-chat-stub.ts || true
echo

echo "=== docker container image + command ==="
docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Ports}}\t{{.Names}}' | grep 'motherboard_systems_hq-dashboard-1\|8080->' || true
echo

echo "=== conclusion anchor ==="
echo "Live 8080 runtime is the Docker container, and /api/chat behavior is coming from server.mjs."
