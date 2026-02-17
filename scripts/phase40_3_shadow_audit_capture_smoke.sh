#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

echo "=== phase40.3 smoke: audit capture to file (optional path) ==="

TMP="$(mktemp -t policy_audit.XXXXXX.jsonl)"
trap 'rm -f "$TMP"' EXIT

node - <<NODE
import { policyEvalShadow } from "./server/policy/policy_eval.mjs";
import { policyAuditWrite } from "./server/policy/policy_audit.mjs";

const env = {
  ...process.env,
  POLICY_SHADOW_MODE: "1",
  POLICY_ENFORCE_MODE: "0",
  POLICY_AUDIT_PATH: ${TMP@Q},
  WORKER_ID: "smoke.worker",
};

const audit = await policyEvalShadow(
  { task: { task_id: "smoke.task", action_tier: "A" }, run: { run_id: "smoke.run" } },
  env
);

await policyAuditWrite(audit, env);
NODE

test -s "$TMP"
grep -q '"channel":"policy_audit"' "$TMP"
grep -q '"policy-shadow-v1"' "$TMP"

echo "OK: wrote audit jsonl to $TMP"
echo "OK: phase40.3 smoke complete"
