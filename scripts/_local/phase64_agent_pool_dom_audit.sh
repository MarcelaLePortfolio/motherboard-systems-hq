#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8080}"

echo "== Phase 64 agent pool DOM audit =="
echo "BASE_URL=$BASE_URL"

tmp_html="$(mktemp)"
trap 'rm -f "$tmp_html"' EXIT

curl -fsS "$BASE_URL/dashboard" > "$tmp_html"

echo
echo "-- agent pool anchors"
grep -nE 'Agent Pool|Matilda|Atlas|Cade|Effie|agent-status-container|agent-state|data-agent=' "$tmp_html" || true

echo
echo "-- nearby dashboard region around agent-status-container"
anchor_line="$(grep -n 'id="agent-status-container"' "$tmp_html" | head -n1 | cut -d: -f1 || true)"
if [[ -n "${anchor_line:-}" ]]; then
  start=$(( anchor_line > 80 ? anchor_line - 80 : 1 ))
  end=$(( anchor_line + 220 ))
  sed -n "${start},${end}p" "$tmp_html"
else
  echo "ERROR: id=\"agent-status-container\" not found"
  exit 1
fi

echo
echo "-- script tags"
grep -n '<script ' "$tmp_html" || true

echo
echo "PASS: agent pool DOM audit complete"
