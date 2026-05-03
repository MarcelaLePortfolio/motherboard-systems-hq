#!/usr/bin/env bash
set -euo pipefail

rm -f \
  fix_phase497.py \
  phase498_behavior_guard.py \
  phase499_response_structure.py \
  phase500_readiness_flags.py \
  phase501_chat_timeout_probe.sh \
  phase502_prompt_clarity.py \
  phase503_prompt_guard_unassigned.py \
  phase505_worker_timeout_probe.sh \
  phase511_fix_runid.py \
  phase512_claim_sql_type_anchor.py \
  phase514_allow_queued_claim.py \
  phase515_surface_claimed_by.py \
  phase516_recent_history_claimed_by.py \
  server.mjs.bak

git status --short

git add -A
git commit -m "Phase 518: remove temporary patch helpers from checkpoint"

git push

docker compose ps

sleep 8

curl -sS 'http://localhost:8080/api/health'
echo
curl -sS 'http://localhost:8080/api/tasks?limit=1' | jq

git tag phase-518-clean-worker-claim-lifecycle-validated
git push origin phase-518-clean-worker-claim-lifecycle-validated
