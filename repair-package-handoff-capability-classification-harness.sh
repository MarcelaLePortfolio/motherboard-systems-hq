#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path

path = Path("classify-package-handoff-capability-existence.sh")
text = path.read_text()

old = """CANONICAL_TO_GOVERNANCE_BRIDGE_MATCHES="$(
  rg -n \\
    'matilda_canonical_packages.*governance_packages|governance_packages.*matilda_canonical_packages|INSERT INTO governance_packages.*matilda_canonical_packages|createGovernancePackage\\(.*canonical|canonical.*createGovernancePackage' \\
    db server \\
    2>/dev/null | wc -l | tr -d ' '
)"
echo "DIRECT_CANONICAL_TO_GOVERNANCE_PACKAGE_BRIDGE_MATCHES=${CANONICAL_TO_GOVERNANCE_BRIDGE_MATCHES}"

HANDOFF_ARTIFACT_MATCHES="$(
  rg -n \\
    'handoff[_ -]?(artifact|package|contract|record)|package[_ -]?handoff|handoff[_ -]?eligib' \\
    db server client \\
    2>/dev/null | wc -l | tr -d ' '
)"
echo "EXPLICIT_HANDOFF_ARTIFACT_MATCHES=${HANDOFF_ARTIFACT_MATCHES}"
"""

new = """set +e
CANONICAL_TO_GOVERNANCE_RESULTS="$(
  rg -n \\
    'matilda_canonical_packages.*governance_packages|governance_packages.*matilda_canonical_packages|INSERT INTO governance_packages.*matilda_canonical_packages|createGovernancePackage\\(.*canonical|canonical.*createGovernancePackage' \\
    db server \\
    2>/dev/null
)"
CANONICAL_TO_GOVERNANCE_RG_STATUS=$?

HANDOFF_ARTIFACT_RESULTS="$(
  rg -n \\
    'handoff[_ -]?(artifact|package|contract|record)|package[_ -]?handoff|handoff[_ -]?eligib' \\
    db server client \\
    2>/dev/null
)"
HANDOFF_ARTIFACT_RG_STATUS=$?
set -e

if [ "$CANONICAL_TO_GOVERNANCE_RG_STATUS" -gt 1 ]; then
  echo "Canonical-to-governance repository search failed."
  exit "$CANONICAL_TO_GOVERNANCE_RG_STATUS"
fi

if [ "$HANDOFF_ARTIFACT_RG_STATUS" -gt 1 ]; then
  echo "Handoff-artifact repository search failed."
  exit "$HANDOFF_ARTIFACT_RG_STATUS"
fi

if [ -n "$CANONICAL_TO_GOVERNANCE_RESULTS" ]; then
  CANONICAL_TO_GOVERNANCE_BRIDGE_MATCHES="$(printf '%s\\n' "$CANONICAL_TO_GOVERNANCE_RESULTS" | wc -l | tr -d ' ')"
else
  CANONICAL_TO_GOVERNANCE_BRIDGE_MATCHES=0
fi

if [ -n "$HANDOFF_ARTIFACT_RESULTS" ]; then
  HANDOFF_ARTIFACT_MATCHES="$(printf '%s\\n' "$HANDOFF_ARTIFACT_RESULTS" | wc -l | tr -d ' ')"
else
  HANDOFF_ARTIFACT_MATCHES=0
fi

echo "DIRECT_CANONICAL_TO_GOVERNANCE_PACKAGE_BRIDGE_MATCHES=${CANONICAL_TO_GOVERNANCE_BRIDGE_MATCHES}"
echo "EXPLICIT_HANDOFF_ARTIFACT_MATCHES=${HANDOFF_ARTIFACT_MATCHES}"
"""

if old not in text:
    raise SystemExit("Expected handoff capability search fragment not found")

path.write_text(text.replace(old, new, 1))
PY

git add classify-package-handoff-capability-existence.sh
git commit -m "Fix Package handoff capability search harness"
git push
./classify-package-handoff-capability-existence.sh
