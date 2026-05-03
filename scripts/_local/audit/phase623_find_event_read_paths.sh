#!/bin/bash

echo "🔍 PHASE 623 — LOCATE EVENT READ PATHS (SAFE DISCOVERY)"
echo ""

echo "Searching for event retrieval points..."
grep -R "task_events" server 2>/dev/null || true

echo ""
grep -R "events" server 2>/dev/null | grep -E "fetch|get|read" || true

echo ""
grep -R "run_view" server 2>/dev/null || true

echo ""
echo "📊 GOAL:"
echo "Identify EXACT location where events are already READ (not written)."
echo ""
echo "➡️ ONLY after identifying a clean read path should attachExecutionGuidance(events) be inserted."
echo "❗ DO NOT modify anything yet."
