#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SCOPE=(server.mjs server/routes)

echo "=== Phase 44: mutation route inventory (scoped: server.mjs + server/routes/) ==="
echo

echo "=== 1) Direct registrations: app.METHOD('/path') or router.METHOD('/path') ==="
rg -n --pcre2 --no-heading \
  '(?:^|\s)(?:app|router)\.(post|put|patch|delete)\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\2' \
  "${SCOPE[@]}" \
| sed -E 's/^([^:]+):([0-9]+):.*\.(post|put|patch|delete)\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\4.*/\1:\2\t\3\t\5/I' \
| awk -F'\t' '{print toupper($2) "\t" $3 "\t(" $1 ")"}' \
| sort -u || true

echo
echo "=== 2) Chained registrations: app.route('/path').METHOD(...) / router.route('/path').METHOD(...) ==="
rg -n --pcre2 --no-heading \
  '(?:^|\s)(?:app|router)\.route\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\1\s*\)\.(post|put|patch|delete)\b' \
  "${SCOPE[@]}" \
| sed -E 's/^([^:]+):([0-9]+):.*\.route\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\3\s*\)\.(post|put|patch|delete)\b.*/\1:\2\t\5\t\4/I' \
| awk -F'\t' '{print toupper($2) "\t" $3 "\t(" $1 ")"}' \
| sort -u || true

echo
echo "=== 3) Router mounts: app.use('/prefix', router) ==="
rg -n --pcre2 --no-heading \
  '(?:^|\s)app\.use\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\1\s*,\s*[A-Za-z0-9_.$]+' \
  server.mjs \
| sed -E 's/^([^:]+):([0-9]+):.*app\.use\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\3\s*,.*/\1:\2\tMOUNT\t\4/I' \
| awk -F'\t' '{print $2 "\t" $3 "\t(" $1 ")"}' \
| sort -u || true

echo
echo "=== 4) Current allowlist ==="
sed -n '1,220p' server/enforcement/phase44_mutation_allowlist.mjs
