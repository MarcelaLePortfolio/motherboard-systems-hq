#!/bin/bash
set -u

echo "🔍 Diagnosing why /api/chat did not return..."
echo

echo "1) Checking listeners on ports 3000, 3001, 8080"
lsof -nP -iTCP:3000 -sTCP:LISTEN || true
echo "---"
lsof -nP -iTCP:3001 -sTCP:LISTEN || true
echo "---"
lsof -nP -iTCP:8080 -sTCP:LISTEN || true
echo

echo "2) Testing dashboard server root on :3001"
curl -I --max-time 5 http://127.0.0.1:3001/ || true
echo

echo "3) Testing direct /matilda endpoint on :3001"
curl -sS --max-time 5 -X POST http://127.0.0.1:3001/matilda \
  -H "Content-Type: application/json" \
  -d '{"message":"status"}' || true
echo
echo

echo "4) Testing proxied /api/chat on :3001"
curl -sS --max-time 5 -X POST http://127.0.0.1:3001/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"status","agent":"matilda"}' || true
echo
echo

echo "5) Testing /api/chat on :3000"
curl -sS --max-time 5 -X POST http://127.0.0.1:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"status","agent":"matilda"}' || true
echo
echo

echo "6) Quick route file confirmation"
sed -n '1,160p' routes/api-chat.ts
echo
echo "✅ Diagnosis complete."
