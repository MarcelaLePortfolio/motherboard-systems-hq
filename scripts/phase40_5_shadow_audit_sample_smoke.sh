#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

echo "=== phase40.5 smoke: audit sampling (file only) ==="

DIR="$(mktemp -d -t policy_audit_sample.XXXXXX)"
trap 'rm -rf "$DIR"' EXIT

export POLICY_SHADOW_MODE="1"
export POLICY_ENFORCE_MODE="0"
export WORKER_ID="smoke.worker"
export POLICY_AUDIT_PATH="$DIR/audit.jsonl"
export POLICY_AUDIT_MAX_BYTES="0"
export POLICY_AUDIT_MAX_FILES="0"
export POLICY_AUDIT_SAMPLE_SEED="seed1"

echo "--- SAMPLE_PCT=0 (no file writes) ---"
export POLICY_AUDIT_SAMPLE_PCT="0"
node - <<'NODE'
import { policyEvalShadow } from "./server/policy/policy_eval.mjs";
import { policyAuditWrite } from "./server/policy/policy_audit.mjs";
const env = { ...process.env };
const audit = await policyEvalShadow({ task:{task_id:"t0",action_tier:"A"}, run:{run_id:"r0"} }, env);
await policyAuditWrite(audit, env);
NODE
test ! -s "$POLICY_AUDIT_PATH"

echo "--- SAMPLE_PCT=100 (file writes) ---"
export POLICY_AUDIT_SAMPLE_PCT="100"
node - <<'NODE'
import { policyEvalShadow } from "./server/policy/policy_eval.mjs";
import { policyAuditWrite } from "./server/policy/policy_audit.mjs";
const env = { ...process.env };
const audit = await policyEvalShadow({ task:{task_id:"t1",action_tier:"A"}, run:{run_id:"r1"} }, env);
await policyAuditWrite(audit, env);
NODE
test -s "$POLICY_AUDIT_PATH"
grep -q '"channel":"policy_audit"' "$POLICY_AUDIT_PATH"

echo "OK: phase40.5 smoke complete"
