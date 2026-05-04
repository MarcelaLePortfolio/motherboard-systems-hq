#!/bin/bash
set -e

echo "PHASE 649 — COMPLETION SEQUENCE START"

echo "Step 1: Confirm handoff exists"
test -f STATE_HANDOFF.md

echo "Step 2: Tag completion"
git tag -a phase649-complete -m "Phase 649 complete: stability handoff and snapshot preserved"
git push origin phase649-complete

echo "PHASE 649 COMPLETE — handoff snapshot verified and tagged."
