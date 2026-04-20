#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 RUNTIME VERIFICATION (SAFE MODE) ==="

echo
echo "Step 1: Installing dependencies (no mutation if already installed)"
pnpm install || npm install || true

echo
echo "Step 2: Typecheck (no emit)"
pnpm tsc --noEmit || npx tsc --noEmit || true

echo
echo "Step 3: Checking server entrypoint existence"
if [ -f server/index.js ]; then
  echo "OK   server/index.js exists"
else
  echo "MISS server/index.js"
fi

echo
echo "Step 4: Checking agent launcher files"
for path in \
  scripts/_local/agent-runtime/launch-cade.ts \
  scripts/_local/agent-runtime/launch-matilda.ts \
  scripts/_local/agent-runtime/launch-effie.ts
do
  if [ -f "$path" ]; then
    echo "OK   $path"
  else
    echo "MISS $path"
  fi
done

echo
echo "Step 5: Dry-run require check (no execution)"
node -e "
try {
  require('./package.json');
  console.log('OK   package.json loadable');
} catch (e) {
  console.log('FAIL package.json load error');
}
"

echo
echo "=== NOTE ==="
echo "This script does NOT start the server or agents."
echo "It only verifies readiness to avoid unintended runtime side effects."
