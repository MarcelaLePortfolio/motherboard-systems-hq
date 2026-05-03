#!/usr/bin/env bash

set -e

echo "PHASE 456 — HEALTH DISPLAY LOCATION EVIDENCE PASS"
echo "Searching for dashboard health display locations..."
echo ""

echo "---- Searching for 'Health:' labels ----"
grep -Rni --exclude-dir=node_modules --exclude-dir=.git "Health:" . || true

echo ""
echo "---- Searching for health state variables ----"
grep -Rni --exclude-dir=node_modules --exclude-dir=.git "health" app server dashboard ui components 2>/dev/null || true

echo ""
echo "---- Searching for status classifications ----"
grep -Rni --exclude-dir=node_modules --exclude-dir=.git "critical\|high\|status" . || true

echo ""
echo "---- Searching for Operator Console component ----"
grep -Rni --exclude-dir=node_modules --exclude-dir=.git "Operator Console" . || true

echo ""
echo "Evidence pass complete."
