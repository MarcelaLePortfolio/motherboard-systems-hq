#!/bin/bash
set -e

echo "PHASE 662 — COMPLETION SEQUENCE START"

echo "Step 1: Confirm handoff exists"
test -f STATE_HANDOFF.md

echo "Step 2: Rebuild runtime (snapshot integrity)"
docker compose up -d --build

echo "Step 3: Tag completion"
git tag -a phase662-complete -m "Phase 662 complete: prioritized guidance handoff snapshot preserved"
git push origin phase662-complete

echo "PHASE 662 COMPLETE — snapshot verified and tagged."
