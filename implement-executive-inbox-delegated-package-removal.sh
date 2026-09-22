#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="6041099d9"
FILE="client/src/approvals/ApprovalsWorkspace.tsx"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

python3 << 'PY'
from pathlib import Path

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

anchor = """  const approvedPackages = useMemo(
    () => canonicalCollection?.packages ?? [],
    [canonicalCollection],
  );
"""

replacement = """  const approvedPackages = useMemo(
    () =>
      (canonicalCollection?.packages ?? []).filter(
        (pkg) => pkg.delegation.state !== "delegated",
      ),
    [canonicalCollection],
  );
"""

if anchor not in text:
    raise SystemExit(
        "Approved-package collection anchor not found; refusing speculative mutation."
    )

text = text.replace(anchor, replacement, 1)
path.write_text(text)
PY

git diff --check -- "$FILE"

echo "=== EXECUTIVE INBOX FILTER ==="
grep -n -B 6 -A 12 \
  -E 'const approvedPackages|delegation\.state !== "delegated"' \
  "$FILE"

echo
echo "=== SERVER BUILD ==="
npm run build

echo
echo "=== CLIENT BUILD ==="
(
  cd client
  npm run build
)

git add -- "$FILE"
git commit -m "Remove delegated packages from Executive Inbox"
git push origin "$BRANCH"
