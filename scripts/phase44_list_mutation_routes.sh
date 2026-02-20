#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SCOPE=(server.mjs server/routes)

echo "=== Phase 44: mutation route inventory (scoped: server.mjs + server/routes/) ==="
echo

echo "=== 1) Direct registrations: <ident>.METHOD('/path') ==="
rg -n --pcre2 --no-heading \
  '(?:^|\s)([A-Za-z0-9_.$]+)\.(post|put|patch|delete)\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\3' \
  "${SCOPE[@]}" \
| sed -E 's/^([^:]+):([0-9]+):.*\b([A-Za-z0-9_.$]+)\.(post|put|patch|delete)\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\5.*/\1:\2\t\4\t\6\t\3/I' \
| awk -F'\t' '{print toupper($2) "\t" $3 "\t(" $1 ") [" $4 "]"}' \
| sort -u || true

echo
echo "=== 2) Chained registrations: <ident>.route('/path').METHOD(...) ==="
rg -n --pcre2 --no-heading \
  '(?:^|\s)([A-Za-z0-9_.$]+)\.route\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\2\s*\)\.(post|put|patch|delete)\b' \
  "${SCOPE[@]}" \
| sed -E 's/^([^:]+):([0-9]+):.*\b([A-Za-z0-9_.$]+)\.route\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\4\s*\)\.(post|put|patch|delete)\b.*/\1:\2\t\6\t\5\t\3/I' \
| awk -F'\t' '{print toupper($2) "\t" $3 "\t(" $1 ") [" $4 "]"}' \
| sort -u || true

echo
echo "=== 3) Router mounts: app.use('/prefix', <ident>) ==="
rg -n --pcre2 --no-heading \
  '(?:^|\s)app\.use\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\1\s*,\s*([A-Za-z0-9_.$]+)' \
  server.mjs \
| sed -E 's/^([^:]+):([0-9]+):.*app\.use\(\s*([`'"'"'"])(\/[^`'"'"'"]*)\3\s*,\s*([A-Za-z0-9_.$]+).*/\1:\2\tMOUNT\t\4\t\5/I' \
| awk -F'\t' '{print $2 "\t" $3 "\t(" $1 ") [" $4 "]"}' \
| sort -u || true

echo
echo "=== 4) Current allowlist ==="
sed -n '1,260p' server/enforcement/phase44_mutation_allowlist.mjs
