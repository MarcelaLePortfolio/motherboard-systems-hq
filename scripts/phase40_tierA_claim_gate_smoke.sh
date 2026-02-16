#!/usr/bin/env bash
set -euo pipefail

# Phase 40 — Tier A claim gate smoke (pure SQL; no workers required)
# Assertions:
# 1) Insert queued Tier A + Tier B tasks
# 2) Canonical claim SQL claims at most 1 task and only Tier A
# 3) Tier B remains queued
# 4) Repeat deterministically

PGC="${PGC:-}"

if [[ -z "${PGC}" ]]; then
  PGC="$(docker ps --format '{{.Names}}' | awk '$0=="motherboard_systems_hq-postgres-1"{print; exit}')"
fi
if [[ -z "${PGC}" ]]; then
  PGC="$(docker ps --format '{{.Names}}' | awk 'tolower($0) ~ /postgres/ {print; exit}')"
fi
: "${PGC:?ERROR: postgres container not found (start your compose stack)}"

STAMP="$(date +%s%N 2>/dev/null || date +%s)"
SUF="${STAMP}.${RANDOM:-0}"
RID="smoke.phase40.run.${SUF}"
A_ID="smoke.phase40.tiergate.A.${SUF}"
B_ID="smoke.phase40.tiergate.B.${SUF}"

echo "PGC=$PGC"
echo "RID=$RID"
echo "A_ID=$A_ID"
echo "B_ID=$B_ID"
echo

echo "=== insert Tier A + Tier B queued tasks ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
\pset pager off
INSERT INTO tasks (task_id, title, status, attempts, max_attempts, action_tier)
VALUES
  ('$A_ID', 'Phase40 TierGate A', 'queued', 0, 3, 'A'),
  ('$B_ID', 'Phase40 TierGate B', 'queued', 0, 3, 'B');

SELECT id, task_id, status, action_tier, attempts, max_attempts
FROM tasks
WHERE task_id IN ('$A_ID','$B_ID')
ORDER BY task_id;
SQL

echo
echo "=== claim once via canonical SQL (must claim A only) ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 \
  -v claimed_by="phase40-smoke" -v run_id="$RID" \
  -f /dev/stdin < sql/phase40_claim_one_tierA.sql

echo
echo "=== acceptance checks (scoped listing + gates) ==="
docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 \
  -f /dev/stdin < PHASE40_ACCEPTANCE_CHECKS.sql

echo
echo "=== enforce acceptance gates (fail fast) ==="
RES1="$(docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -Atc \
  "SELECT CASE WHEN EXISTS (SELECT 1 FROM tasks WHERE task_id LIKE 'smoke.phase40.tiergate.%' AND COALESCE(action_tier,'A')<>'A' AND status='running') THEN 'FAIL' ELSE 'OK' END")"
[[ "$RES1" == "OK" ]] || { echo "FAIL: non-A task running"; exit 2; }

RES2="$(docker exec -i "$PGC" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -Atc \
  "SELECT count(*) FROM tasks WHERE task_id LIKE 'smoke.phase40.tiergate.%' AND COALESCE(action_tier,'A')='A' AND status='running'")"
[[ "$RES2" == "1" ]] || { echo "FAIL: expected exactly 1 A running, got $RES2"; exit 3; }

echo "OK: Phase 40 Tier A claim gate smoke passed"
