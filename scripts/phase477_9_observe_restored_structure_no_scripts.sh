#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase477_9_observe_restored_structure_no_scripts.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 477.9 — OBSERVE RESTORED STRUCTURE (NO SCRIPTS)
=====================================================

STATUS
- Original structural layout has been restored from backup
- All scripts remain disabled
- This is the highest-fidelity no-script checkpoint so far

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Let it sit for 30–60 seconds.

3. Check:
   - Does the structure now look correct?
   - Does it remain stable?
   - Is anything still obviously misplaced or missing?

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- STRUCTURE_RESTORED_CORRECT
- STRUCTURE_RESTORED_BUT_BROKEN
- WHITE_SCREEN_RETURNED

OPTIONAL_NOTE
- Briefly name what still looks wrong, if anything.
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
