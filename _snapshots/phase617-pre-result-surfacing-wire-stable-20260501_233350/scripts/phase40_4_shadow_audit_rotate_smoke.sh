#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

echo "=== phase40.4 smoke: audit rotation (size-based) ==="

DIR="$(mktemp -d -t policy_audit_rotate.XXXXXX)"
trap 'rm -rf "$DIR"' EXIT

export POLICY_SHADOW_MODE="1"
export POLICY_ENFORCE_MODE="0"
export WORKER_ID="smoke.worker"
export POLICY_AUDIT_PATH="$DIR/audit.jsonl"
export POLICY_AUDIT_MAX_BYTES="300"
export POLICY_AUDIT_MAX_FILES="3"

node - <<'NODE'
import { policyEvalShadow } from "./server/policy/policy_eval.mjs";
import { policyAuditWrite } from "./server/policy/policy_audit.mjs";

const env = { ...process.env };

for (let i = 0; i < 50; i += 1) {
  const audit = await policyEvalShadow(
    { task: { task_id: `smoke.task.${i}`, action_tier: "A" }, run: { run_id: `smoke.run.${i}` } },
    env
  );
  await policyAuditWrite(audit, env);
}
NODE

test -f "$POLICY_AUDIT_PATH"
test -s "$POLICY_AUDIT_PATH"
if ls "$POLICY_AUDIT_PATH".* >/dev/null 2>&1; then
  echo "OK: found rotated files:"
  ls -1 "$POLICY_AUDIT_PATH".* | head -n 20
else
  echo "ERROR: expected rotated files but none found" >&2
  exit 2
fi
COUNT="$(ls -1 "$POLICY_AUDIT_PATH".* 2>/dev/null | wc -l | tr -d ' ')"
if [[ "$COUNT" -gt 3 ]]; then
  echo "ERROR: rotation exceeded max files: COUNT=$COUNT" >&2
  exit 3
fi

echo "OK: phase40.4 smoke complete"
