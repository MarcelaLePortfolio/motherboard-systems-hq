#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="610aad624"
FILE="client/src/approvals/ApprovalsWorkspace.tsx"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

python3 << 'PY'
from pathlib import Path

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

selection_anchor = """  const selectedApprovedPackage =
    canonicalPackages.find(
      (pkg) =>
        pkg.package_id === selectedApprovedPackageId,
    ) ?? null;
"""

selection_replacement = """  const executiveInboxApprovedPackages =
    canonicalPackages.filter(
      (pkg) => pkg.delegation.state !== "delegated",
    );

  const selectedApprovedPackage =
    executiveInboxApprovedPackages.find(
      (pkg) =>
        pkg.package_id === selectedApprovedPackageId,
    ) ?? null;
"""

if selection_anchor not in text:
    raise SystemExit(
        "Approved-package selection anchor not found; refusing speculative mutation."
    )

text = text.replace(selection_anchor, selection_replacement, 1)

render_replacements = (
    ("canonicalPackages.map(", "executiveInboxApprovedPackages.map("),
    ("canonicalPackages.length", "executiveInboxApprovedPackages.length"),
)

render_change = False

for old, new in render_replacements:
    if old in text:
        text = text.replace(old, new)
        render_change = True

if not render_change:
    raise SystemExit(
        "Approved-list render anchor not found; refusing speculative mutation."
    )

path.write_text(text)
PY

git diff --check -- "$FILE"

echo "=== EXECUTIVE INBOX FILTER ==="
grep -n -B 8 -A 18 \
  -E 'executiveInboxApprovedPackages|selectedApprovedPackage' \
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
