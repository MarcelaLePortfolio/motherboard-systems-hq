#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

echo "=== phase40.1 smoke: module import + patch idempotency ==="

node -e "import('./server/policy/policy_eval.mjs').then(()=>console.log('OK: policy_eval import')).catch(e=>{console.error(e); process.exit(1);})"
node -e "import('./server/policy/policy_audit.mjs').then(()=>console.log('OK: policy_audit import')).catch(e=>{console.error(e); process.exit(1);})"
node -e "import('./server/policy/policy_flags.mjs').then(()=>console.log('OK: policy_flags import')).catch(e=>{console.error(e); process.exit(1);})"

echo
echo "=== apply patch (1st pass) ==="
node scripts/_ops/phase40_1_patch_execution_path.mjs

echo
echo "=== apply patch (2nd pass should no-op or refuse) ==="
if node scripts/_ops/phase40_1_patch_execution_path.mjs; then
  echo "ERROR: patch applied twice (expected refusal after first patch)" >&2
  exit 2
else
  echo "OK: second patch refused (already patched or no target)"
fi

echo
echo "OK: phase40.1 smoke complete"
