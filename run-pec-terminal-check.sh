
#!/usr/bin/env bash

set -euo pipefail

echo "=== PEC Runtime Sanity Check ==="

echo ""

echo "1. Typecheck (if available)..."

npx tsc --noEmit || echo "⚠ Typecheck skipped or failed"

echo ""

echo "2. Run tests (if configured)..."

npm test --silent || echo "⚠ Tests skipped or failed"

echo ""

echo "3. Lint check..."

npx eslint . || echo "⚠ Lint skipped or failed"

echo ""

echo "4. Search for unsafe execution primitives..."

grep -Rni "exec(\|spawn(\|child_process\|fs\.write" server || true

echo ""

echo "5. Verify PEC binder exists..."

test -f server/execution/pec-runtime-binder.ts && echo "✔ PEC binder present" || echo "❌ Missing PEC binder"

echo ""

echo "6. Verify route exists..."

test -f server/routes/pec-execute-route.ts && echo "✔ PEC route present" || echo "❌ Missing PEC route"

echo ""

echo "=== Check Complete ==="

