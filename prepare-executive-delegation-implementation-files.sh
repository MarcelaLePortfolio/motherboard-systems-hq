#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="542171061"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

cat > /tmp/executive-delegation-server-files.txt << 'LIST'
server/index.ts
server/routes/governance-delegation-route.ts
server/routes/canonical-package-route.ts
server/routes/canonical-packages-route.ts
server/canonical-package-read-model.ts
server/canonical-package-read-repository.ts
db/governance-delegation-persistence.ts
db/governance-delegation-repository.ts
LIST

echo "=== EXISTING VERIFIED CANDIDATES ==="
while IFS= read -r file; do
  if [ -f "$file" ]; then
    echo
    echo "----- $file -----"
    sed -n '1,320p' "$file"
  fi
done < /tmp/executive-delegation-server-files.txt

echo
echo "=== FALLBACK MATCHES ==="
find server db -type f \
  \( -iname '*canonical*package*' -o -iname '*delegation*' \) \
  -not -path '*/node_modules/*' \
  -not -path '*/dist/*' \
  -print | sort
