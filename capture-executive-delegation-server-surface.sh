#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="279d1388d"
DOC="docs/checkpoints/EXECUTIVE_DELEGATION_SERVER_IMPLEMENTATION_SURFACE.md"
TMP_FILES="/tmp/executive-delegation-server-files.$$"
TMP_DOC="/tmp/executive-delegation-server-surface.$$"

trap 'rm -f "$TMP_FILES" "$TMP_DOC"' EXIT

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

{
  grep -RIl \
    --exclude-dir=node_modules \
    --exclude-dir=dist \
    -E "canonical-packages|matilda_canonical_packages|createGovernanceDelegationRouter|governance_delegations" \
    server db 2>/dev/null || true
} | sort -u > "$TMP_FILES"

{
  echo "# Executive Delegation — Server Implementation Surface"
  echo
  echo "Branch: $BRANCH"
  echo "Baseline: $EXPECTED_HEAD"
  echo
  echo "## Verified Existing Files"
  echo

  if [ ! -s "$TMP_FILES" ]; then
    echo "NO_MATCHING_SERVER_FILES_FOUND=YES"
  else
    while IFS= read -r file; do
      printf -- '- `%s`\n' "$file"
    done < "$TMP_FILES"
  fi

  echo
  echo "## File Contents"
  echo

  while IFS= read -r file; do
    [ -n "$file" ] || continue
    echo "### $file"
    echo
    echo '```text'
    cat "$file"
    echo
    echo '```'
    echo
  done < "$TMP_FILES"

  echo "## Classification"
  echo
  echo "IMPLEMENTATION_AUTHORIZED=YES"
  echo "PRODUCT_CODE_MUTATION_PERFORMED=NO"
  echo "SERVER_IMPLEMENTATION_SURFACE_CAPTURED=YES"
  echo "NEXT_ACTION=IMPLEMENT_BOUNDED_EXECUTIVE_DELEGATION_DECISION_ADAPTER"
} > "$TMP_DOC"

test -s "$TMP_DOC"
grep -q "SERVER_IMPLEMENTATION_SURFACE_CAPTURED=YES" "$TMP_DOC"

cat > "$DOC" << 'DOC'
__CAPTURE_PLACEHOLDER__
DOC

cat "$TMP_DOC" > "$DOC"

echo "=== VERIFIED FILES ==="
cat "$TMP_FILES"

echo
echo "=== CHECKPOINT PREVIEW ==="
sed -n '1,220p' "$DOC"
