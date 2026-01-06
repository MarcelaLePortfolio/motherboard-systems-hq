#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

echo "────────────────────────────────────────────"
echo " Phase 14.4 — Verify dashboard banner text"
echo "────────────────────────────────────────────"
echo

HTML="$(curl -fsS http://127.0.0.1:8080/dashboard || true)"

echo "$HTML" | grep -q "Phase 11.3" && { echo "❌ still shows Phase 11.3"; exit 1; } || true
echo "$HTML" | grep -q "Phase 14 (ops reliability)" && echo "✅ banner shows Phase 14" || { echo "⚠️ banner string not found (may be rendered by JS bundle)"; exit 2; }

echo "Done."
