#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 490 STATE VERIFICATION ==="
echo

echo "=== GIT STATUS ==="
git status
echo

echo "=== CURRENT BRANCH ==="
git branch --show-current
echo

echo "=== LATEST COMMITS ==="
git log --oneline -n 5
echo

echo "=== TAG CHECK (v487 baseline) ==="
git tag | grep "v487.0-confidence-baseline-sealed" || echo "❌ baseline tag missing"
echo

echo "=== REMOTE SYNC CHECK ==="
git fetch
git status | grep "up to date" || echo "⚠️ branch may not be fully pushed"
echo

echo "=== PHASE FILES EXISTENCE ==="
ls docs/phase_487_* 2>/dev/null || true
ls docs/phase_488_* 2>/dev/null || true
ls docs/phase_489_* 2>/dev/null || true
ls docs/phase_490_* 2>/dev/null || true
echo

echo "=== DOCKER CONTAINER STATUS ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "Docker not running"
echo

echo "=== DASHBOARD CONTAINER CHECK (8080) ==="
docker ps | grep 8080 || echo "❌ no container serving 8080"
echo

echo "=== SERVED ARTIFACT CONFIDENCE CHECK ==="
curl -s http://localhost:8080 | grep -n "Confidence:" || echo "❌ cannot verify served dashboard"
echo

echo "=== FINAL VERDICT ==="
echo "✔ If:"
echo "  • branch is up to date"
echo "  • v487 tag exists"
echo "  • phase docs are present"
echo "  • container is running on 8080"
echo "  • served dashboard shows 'Confidence: limited'"
echo
echo "→ THEN: system is committed, tagged, pushed, and containerized correctly."
