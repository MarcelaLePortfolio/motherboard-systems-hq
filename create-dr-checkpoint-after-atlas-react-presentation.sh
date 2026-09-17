#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="01550c296"
STAMP="$(date +%Y%m%d_%H%M%S)"
DR_DIR="backups/DR_${STAMP}"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

mkdir -p "$DR_DIR"

git rev-parse HEAD > "$DR_DIR/HEAD.txt"
git rev-parse --abbrev-ref HEAD > "$DR_DIR/BRANCH.txt"
git status --short --branch > "$DR_DIR/STATUS.txt"
git log --oneline --decorate -20 > "$DR_DIR/RECENT_COMMITS.txt"

cat > "$DR_DIR/CHECKPOINT.md" << DOC
# DR Checkpoint

Created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

Repository: motherboard-systems-hq-clean
Branch: $BRANCH
Head: $(git rev-parse HEAD)

## Verified State

ATLAS_REACT_PRESENTATION_CORRIDOR=CLOSED
ATLAS_MINIMUM_REACT_PRESENTATION=LANDED_AND_PUSHED
NEXT_ATLAS_CORRIDOR=UNCLASSIFIED
NEXT_ATLAS_CORRIDOR_AUTHORIZED=NO

## Atlas lineage

- f64cb63e9 — Add Atlas read-only pre-execution presentation
- 2af069463 — Record Atlas React presentation implementation
- 73d92f2c5 — Verify Atlas React presentation landed
- c1bfc8e8e — Close Atlas React presentation corridor
- 896fc5215 — Record Atlas React presentation corridor closure
- 01550c296 — Verify Atlas React presentation corridor closure

## Preserved External Boundary

The full client TypeScript build remains blocked by the unrelated pre-existing ApprovalsWorkspace.tsx unused feedbackReady error.

No runtime repair for that unrelated issue is included in this checkpoint.
DOC

printf '\n===== DR CHECKPOINT =====\n'
printf 'DR_PATH=%s\n' "$DR_DIR"
printf 'HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'UPSTREAM=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"

git add "$DR_DIR"
git commit -m "Create DR checkpoint after Atlas React presentation closure"
git push origin "$BRANCH"
