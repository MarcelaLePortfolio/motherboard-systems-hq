#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT_OUT="docs/phase477_0_attribute_reintro_result.txt"
NEXT_OUT="docs/phase477_0_next_corridor_after_attribute_stability.txt"

mkdir -p docs

cat > "$RESULT_OUT" <<'EOT'
PHASE 477.0 — ATTRIBUTE REINTRO RESULT
======================================

RESULT:
ATTRIBUTES_REINTRO_STABLE

OPTIONAL_NOTE:
Original body attributes were restored onto the stable recomposed dashboard and the page remained stable.
EOT

cat > "$NEXT_OUT" <<'EOT'
PHASE 477.0 — NEXT CORRIDOR AFTER ATTRIBUTE STABILITY
=====================================================

CRITICAL UPDATE
- Minimal probe is stable
- Body probe is stable
- Q1 is stable
- Q2 is stable
- Q3 is stable
- Q4 is stable
- Recomposed full-body probe is stable
- Restored original body attributes are also stable

CURRENT HIGHEST-CONFIDENCE VERDICT
- The freeze is not caused by:
  • server delivery
  • public tree sync
  • isolated markup quarters
  • recomposed full-body structure
  • original body tag attributes alone

REMAINING LIKELY FAULT DOMAIN
- Additional original dashboard-only lines outside the recomposed stable shape
- Route-accurate wrapper composition differences
- Non-body structural leftovers in the original dashboard file
- A specific original dashboard delta that was excluded by the stable recomposition path

NEXT SAFE CORRIDOR
- Compare original backup against current stable dashboard
- Restore only one dashboard-only delta class at a time
- Start with non-script, non-CSS, non-body-tag structural lines closest to the body boundary
- Do NOT re-enable bundle.js yet
- Do NOT reintroduce local CSS yet
- Do NOT stack multiple reintroductions in one step

RECOMMENDED NEXT STEP
- Build a targeted delta restoration report:
  • lines present in original backup but absent in current stable dashboard
  • grouped by head/body/footer boundary
  • excluding script tags, stylesheet links, and body tag attributes already tested
EOT

echo "Wrote $RESULT_OUT"
sed -n '1,120p' "$RESULT_OUT"
echo
echo "Wrote $NEXT_OUT"
sed -n '1,220p' "$NEXT_OUT"
