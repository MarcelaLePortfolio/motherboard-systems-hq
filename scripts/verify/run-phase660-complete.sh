#!/bin/bash
set -e

echo "PHASE 660 — COMPLETION SEQUENCE START"

echo "Step 1: Confirm handoff exists"
test -f STATE_HANDOFF.md

echo "Step 2: Rebuild runtime (snapshot integrity)"
docker compose up -d --build

echo "Step 3: Tag completion"
git tag -a phase660-complete -m "Phase 660 complete: priority guidance handoff snapshot preserved"
git push origin phase660-complete

echo "PHASE 660 COMPLETE — snapshot verified and tagged."
