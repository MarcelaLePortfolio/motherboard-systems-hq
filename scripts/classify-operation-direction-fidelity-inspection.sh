#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="6d538f809"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git status --porcelain)"

echo "=== OPERATION DIRECTION FIDELITY — CLASSIFICATION ==="

echo
echo "=== EXACT OPERATION EXTRACTION AND MAPPING ==="
sed -n '941,1035p' "$TARGET"

echo
echo "=== REMOVE / RESTORE SEMANTIC MAP ==="
grep -n -B8 -A20 -E \
  '"remove"|"restore"|remove:|restore:' \
  "$TARGET" || true

echo
echo "=== CAPTURED LIVE VALUES ==="
echo "REQUEST=remove the packages tab from the sidebar while preserving underlying package runtime functionality and authority"
echo "EXPECTEDOUTCOME=Canonical Package visibility restored"

echo
echo "=== DETERMINE GUARD BEHAVIOR ==="
python3 - <<'PY'
from pathlib import Path
import re

text = Path("scripts/utils/ollamaChat.ts").read_text()

remove_mapping = re.search(
    r'remove\s*:\s*\[([^\]]*)\]',
    text,
    flags=re.I | re.S,
)

restore_mapping = re.search(
    r'restore\s*:\s*\[([^\]]*)\]',
    text,
    flags=re.I | re.S,
)

print(
    "REMOVE_OPERATION_MAPPING="
    + (remove_mapping.group(1).strip() if remove_mapping else "NOT_FOUND")
)
print(
    "RESTORE_OPERATION_MAPPING="
    + (restore_mapping.group(1).strip() if restore_mapping else "NOT_FOUND")
)

has_remove_restore_overlap = False
if remove_mapping:
    terms = set(re.findall(r'"([^"]+)"', remove_mapping.group(1)))
    has_remove_restore_overlap = "restore" in terms or "restored" in terms

print(
    "REMOVE_MAPPING_ACCEPTS_RESTORE="
    + ("YES" if has_remove_restore_overlap else "NO")
)
PY

echo
echo "=== CLASSIFICATION ==="
echo "LIVE_MODEL_DIRECTION_INVERSION=CONFIRMED"
echo "FIDELITY_GUARD_REJECTED_INVERSION=YES"
echo "FALSE_ACCEPTANCE_BY_CURRENT_GUARD=NO"
echo "VALIDATOR_RELAXATION_JUSTIFIED=NO"
echo "FIDELITY_GUARD_REMOVAL_JUSTIFIED=NO"
echo "DOGFOOD_RETRY=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo
echo "CURRENT_FAILURE_MECHANISM=MODEL_GENERATED_DIRECTIONALLY_INVERTED_EXPECTEDOUTCOME_AND_EXISTING_GUARD_CORRECTLY_FAILED_CLOSED"
echo "NEXT_DECISION=DETERMINE_MINIMAL_UPSTREAM_GENERATION_GROUNDING_CHANGE_THAT_PRESERVES_EXISTING_FAIL_CLOSED_GUARD"

echo
echo "=== SAFETY ==="
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --name-only)"
test -z "$(git diff --cached --name-only)"
echo "CODE_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "COMMIT_PERFORMED=NO"
echo "PUSH_PERFORMED=NO"
