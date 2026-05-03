#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 626 — VISUAL VERIFICATION"
echo
echo "1. Start local stack if not running:"
echo "   docker compose up -d"
echo
echo "2. Open dashboard in browser:"
echo "   http://localhost:8080"
echo
echo "3. Create or trigger a task that reaches task.completed with guidance payload"
echo
echo "4. Confirm in UI:"
echo "   - Task row still renders normally"
echo "   - Guidance line appears under task title"
echo "   - Classification label + outcome visible"
echo "   - Explanation expandable (if present)"
echo
echo "5. Validate no regressions:"
echo "   - Tasks still load"
echo "   - Complete button works"
echo "   - No console errors"
echo "   - SSE stream remains stable"
echo
echo "6. If guidance not visible:"
echo "   - Inspect network → /api/tasks response"
echo "   - Confirm guidance field exists on task payload"
echo
echo "DONE"
