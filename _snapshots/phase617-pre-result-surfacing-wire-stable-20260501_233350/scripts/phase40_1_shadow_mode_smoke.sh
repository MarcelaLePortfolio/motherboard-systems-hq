#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

echo "=== phase40.1 smoke: module import + wiring check (no patching) ==="

node -e "import('./server/policy/policy_eval.mjs').then(()=>console.log('OK: policy_eval import')).catch(e=>{console.error(e); process.exit(1);})"
node -e "import('./server/policy/policy_audit.mjs').then(()=>console.log('OK: policy_audit import')).catch(e=>{console.error(e); process.exit(1);})"
node -e "import('./server/policy/policy_flags.mjs').then(()=>console.log('OK: policy_flags import')).catch(e=>{console.error(e); process.exit(1);})"

echo
./scripts/phase40_1_shadow_mode_check.sh

echo
echo "OK: phase40.1 smoke complete"
