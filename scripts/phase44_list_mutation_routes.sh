#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "=== Phase 44: discovered server-side HTTP mutation route registrations (best-effort) ==="
echo "NOTE: this is a grep-based inventory; verify each hit is a real route."
echo

# Common patterns across express-style codebases:
# - app.post("/path", ...)
# - router.post("/path", ...)
# - app.use("/prefix", router)
# We inventory raw declarations; resolving mounted prefixes is manual.

rg -n --no-heading --glob '!**/node_modules/**' \
  '(?:^|\s)(?:app|router)\.(post|put|patch|delete)\(\s*([`'\''])(\/[^`'\'']*)\2' \
  server server.mjs 2>/dev/null \
| sed -E 's/^([^:]+):([0-9]+):.*\.(post|put|patch|delete)\(\s*([`'\''])(\/[^`'\'']*)\4.*/\1:\2  \3  \5/I' \
| awk '{print toupper($3) "\t" $4 "\t(" $1 ")"}' \
| sort -u || true

echo
echo "=== Phase 44: current allowlist ==="
sed -n '1,200p' server/enforcement/phase44_mutation_allowlist.mjs
