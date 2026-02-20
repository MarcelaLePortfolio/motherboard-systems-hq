#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "=== Phase 44: mutation route inventory (best-effort, grep-based) ==="
echo

echo "=== 1) Direct registrations: app.METHOD('/path') or router.METHOD('/path') ==="
rg -n --no-heading --glob '!**/node_modules/**' --glob '!**/dist/**' --glob '!**/build/**' \
  '(?:^|\s)(?:app|router)\.(post|put|patch|delete)\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\2' \
  . \
| sed -E 's/^([^:]+):([0-9]+):.*\.(post|put|patch|delete)\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\4.*/\1:\2\t\3\t\5/I' \
| awk -F'\t' '{print toupper($2) "\t" $3 "\t(" $1 ")"}' \
| sort -u || true

echo
echo "=== 2) Chained registrations: app.route('/path').METHOD(...) / router.route('/path').METHOD(...) ==="
rg -n --no-heading --glob '!**/node_modules/**' --glob '!**/dist/**' --glob '!**/build/**' \
  '(?:^|\s)(?:app|router)\.route\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\1\s*\)\.(post|put|patch|delete)\b' \
  . \
| sed -E 's/^([^:]+):([0-9]+):.*\.route\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\3\s*\)\.(post|put|patch|delete)\b.*/\1:\2\t\5\t\4/I' \
| awk -F'\t' '{print toupper($2) "\t" $3 "\t(" $1 ")"}' \
| sort -u || true

echo
echo "=== 3) Router mounts: app.use('/prefix', router) ==="
rg -n --no-heading --glob '!**/node_modules/**' --glob '!**/dist/**' --glob '!**/build/**' \
  '(?:^|\s)app\.use\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\1\s*,\s*[A-Za-z0-9_.$]+' \
  server server.mjs . 2>/dev/null \
| sed -E 's/^([^:]+):([0-9]+):.*app\.use\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\3\s*,.*/\1:\2\tMOUNT\t\4/I' \
| awk -F'\t' '{print $2 "\t" $3 "\t(" $1 ")"}' \
| sort -u || true

echo
echo "=== 4) Where routes are registered (helpers) ==="
rg -n --no-heading --glob '!**/node_modules/**' --glob '!**/dist/**' --glob '!**/build/**' \
  'express\(\)|express\.Router\(\)|new Router|registerRoutes|register.*Routes|routes\/|server\/routes|app\.use\(' \
  server server.mjs . \
| sed -n '1,200p' || true

echo
echo "=== 5) Current allowlist ==="
sed -n '1,220p' server/enforcement/phase44_mutation_allowlist.mjs
