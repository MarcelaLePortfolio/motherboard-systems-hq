#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase471_3_post_removal_observation_step.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 471.3 — POST-REMOVAL OBSERVATION STEP
===========================================

STATUS
- task-events restore script is removed for real
- operator guidance probe is already neutralized
- current corridor is pure browser observation

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Let it sit for 60–90 seconds.

3. Try these:
   - scroll once
   - click one tab or button
   - wait another 15–30 seconds

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- STABLE_AFTER_REAL_TASK_EVENTS_REMOVAL
- STILL_FREEZES
- WHITE_SCREEN_RETURNED

OPTIONAL
- add about how many seconds passed before failure
EOT

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
