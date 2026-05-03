#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

TARGET="src/cognition/operatorGuidanceMapping.ts"

python3 - <<'PY'
from pathlib import Path
path = Path("src/cognition/operatorGuidanceMapping.ts")
text = path.read_text()

bad_block = """(
(signal.summary
  ? 
  : 
)
)"""
good_block = """(signal.summary
          ? `Signal quality is limited; interpret with caution: ${signal.summary}`
          : `Signal quality currently unavailable; awaiting stronger signal.`)"""

if bad_block in text:
    text = text.replace(bad_block, good_block, 1)
else:
    old = "`Signal quality is limited; interpret with caution: ${signal.summary}`"
    new = "(signal.summary\n          ? `Signal quality is limited; interpret with caution: ${signal.summary}`\n          : `Signal quality currently unavailable; awaiting stronger signal.`)"
    if old in text:
        text = text.replace(old, new, 1)
    elif "Signal quality currently unavailable; awaiting stronger signal." not in text:
        raise SystemExit("Expected patch target not found; aborting for safety.")

path.write_text(text)
PY

cat > docs/phase487_patch_repair_verification.txt << 'EOF'
PHASE 487 — PATCH REPAIR VERIFICATION

OBJECTIVE:
Repair the malformed operator guidance patch introduced by shell interpolation and restore the intended guarded message rendering.

EXPECTED RESULT:
(signal.summary
  ? `Signal quality is limited; interpret with caution: ${signal.summary}`
  : `Signal quality currently unavailable; awaiting stronger signal.`)

SCOPE:
• UI-only
• No backend mutation
• No governance mutation
• No execution mutation
