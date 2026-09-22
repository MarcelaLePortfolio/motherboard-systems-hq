#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="915e3d24a"
DOC="docs/checkpoints/EXECUTIVE_DELEGATION_SERVER_IMPLEMENTATION_SURFACE.md"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

mapfile -t FILES < <(
  {
    grep -RIl \
      --exclude-dir=node_modules \
      --exclude-dir=dist \
      -E "canonical-packages|matilda_canonical_packages|createGovernanceDelegationRouter|governance_delegations" \
      server db 2>/dev/null || true
  } | sort -u
)

{
  echo "# Executive Delegation — Server Implementation Surface"
  echo
  echo "Branch: $BRANCH"
  echo "Baseline: $EXPECTED_HEAD"
  echo
  echo "## Verified Existing Files"
  echo

  if [ "${#FILES[@]}" -eq 0 ]; then
    echo "NO_MATCHING_SERVER_FILES_FOUND=YES"
  else
    for file in "${FILES[@]}"; do
      echo "- \`$file\`"
    done
  fi

  echo
  echo "## File Contents"
  echo

  for file in "${FILES[@]}"; do
    echo "### $file"
    echo
    echo '```text'
    cat "$file"
    echo
    echo '```'
    echo
  done

  echo "## Classification"
  echo
  echo "IMPLEMENTATION_AUTHORIZED=YES"
  echo "PRODUCT_CODE_MUTATION_PERFORMED=NO"
  echo "SERVER_IMPLEMENTATION_SURFACE_CAPTURED=YES"
  echo "NEXT_ACTION=IMPLEMENT_BOUNDED_EXECUTIVE_DELEGATION_DECISION_ADAPTER"
} > "$DOC"
