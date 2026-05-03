#!/usr/bin/env bash
set -e

echo "=== VERIFYING PHASE 487 HUMANIZATION ==="

echo
echo "--- 1. Dashboard HTML includes humanizer ---"
curl -s http://127.0.0.1:3001/ | grep -n 'phase487_humanize_task_ids.js' || echo "❌ NOT FOUND"

echo
echo "--- 2. JS file loads without syntax error ---"
curl -s http://127.0.0.1:3001/js/phase487_humanize_task_ids.js | head -n 5

echo
echo "--- 3. Manual browser checks (run in DevTools) ---"
cat << 'CHECKS'

[...document.scripts].map(s => s.src).filter(Boolean)
typeof window.__PHASE487_TASK_TITLE_MAP !== "undefined"
window.__PHASE487_TASK_TITLE_MAP?.get("task.a3e77f01-bb39-4a4d-95c6-28b2a673aec0")

document.body.innerText.includes("Working on task.")
document.body.innerText.includes("Phase 487 delegation surface verification request")

CHECKS

echo
echo "=== EXPECTED RESULT ==="
echo "Cade should now show:"
echo "Working on Phase 487 delegation surface verification request"
