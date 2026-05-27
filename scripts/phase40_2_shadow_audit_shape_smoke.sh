#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

echo "=== phase40.2 smoke: audit shape normalization ==="

node - <<'NODE'
import { policyEvalShadow } from "./server/policy/policy_eval.mjs";
import { policyAuditWrite } from "./server/policy/policy_audit.mjs";

const env = {
  ...process.env,
  POLICY_SHADOW_MODE: "1",
  POLICY_ENFORCE_MODE: "0",
  WORKER_ID: "smoke.worker",
};

const audit = await policyEvalShadow({ task: { task_id: "smoke.task", action_tier: "A" }, run: { run_id: "smoke.run" } }, env);
await policyAuditWrite(audit, env);

// Minimal structural assertions
if (!audit?.version) throw new Error("missing version");
NODE

echo "OK: phase40.2 smoke complete"
