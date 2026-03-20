#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 72 — OPERATOR GUIDANCE SNAPSHOT"
echo "-------------------------------------"

echo ""
echo "SYSTEM STATE"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep dashboard || true

echo ""
echo "RISK CLASSIFICATION"

if docker ps | grep -q dashboard; then
  echo "RISK: LOW — dashboard container healthy"
else
  echo "RISK: MEDIUM — dashboard container not detected"
fi

echo ""
echo "TELEMETRY HEALTH"

if curl -sf http://localhost:3000/api/health >/dev/null 2>&1; then
  echo "Telemetry API responding"
else
  echo "Telemetry API not responding"
fi

echo ""
echo "SAFE CONTINUATION VERDICT"

if docker ps | grep -q dashboard; then
  echo "SAFE TO CONTINUE: YES"
else
  echo "SAFE TO CONTINUE: INVESTIGATE"
fi

echo ""
echo "RECOMMENDED NEXT ACTION"

echo "1 Run protection gate:"
echo "bash scripts/_local/phase65_pre_commit_protection_gate.sh"

echo ""
echo "2 If clean, continue telemetry hydration work."

echo ""
echo "3 If drift detected, restore golden tag."

echo ""
echo "GUIDANCE COMPLETE"
