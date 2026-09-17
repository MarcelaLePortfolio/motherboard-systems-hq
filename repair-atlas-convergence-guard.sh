#!/bin/bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="a34714b65"
TARGET="implement-atlas-historical-persistence-attempt-1.sh"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
git fetch origin "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

test ! -e db/atlas-historical-observation-persistence.ts
test ! -e db/atlas-historical-observation-persistence.test.ts

python3 - <<'PY'
from pathlib import Path

path = Path("implement-atlas-historical-persistence-attempt-1.sh")
data = path.read_bytes()

old = b"""test "$(git rev-list --left-right --count "HEAD...origin/$EXPECTED_BRANCH")" = $'0\\\\\\\\t0'"""
new = b"""test "$(git rev-list --left-right --count "HEAD...origin/$EXPECTED_BRANCH")" = $'0\\t0'"""

count = data.count(old)
if count != 1:
    raise SystemExit(
        f"FAIL CLOSED: expected exactly one defective byte sequence; found {count}"
    )

path.write_bytes(data.replace(old, new, 1))
PY

printf '\n=== VERIFY EXACT ONE-LINE REPAIR ===\n'
git diff -- "$TARGET"
git diff --numstat -- "$TARGET"
grep -n 'rev-list --left-right --count' "$TARGET" | cat -vet
bash -n "$TARGET"

python3 - <<'PY'
from pathlib import Path

data = Path(
    "implement-atlas-historical-persistence-attempt-1.sh"
).read_bytes()

bad = b"""$'0\\\\\\\\t0'"""
good = b"""$'0\\t0'"""

if bad in data:
    raise SystemExit("FAIL CLOSED: defective double-backslash guard remains")

if data.count(good) != 1:
    raise SystemExit(
        f"FAIL CLOSED: expected repaired guard exactly once; found {data.count(good)}"
    )

print("REPAIRED_GUARD_BYTES=PASS")
PY

printf '\n=== VERIFY NO IMPLEMENTATION EXECUTION ===\n'
test ! -e db/atlas-historical-observation-persistence.ts
test ! -e db/atlas-historical-observation-persistence.test.ts
echo "IMPLEMENTATION=NOT_EXECUTED"

printf '\n=== VERIFY ONLY TARGET TRACKED CHANGE ===\n'
unexpected="$(
  git diff --name-only |
  while IFS= read -r path; do
    case "$path" in
      ".DS_Store"|\
      "scripts/diagnose-live-selected-context-identities.ts"|\
      "scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts"|\
      "scripts/utils/ollamaChat.structured-evidence-object.test.ts"|\
      "scripts/utils/ollamaChat.ts"|\
      "$TARGET")
        ;;
      *)
        printf '%s\n' "$path"
        ;;
    esac
  done
)"

if [ -n "$unexpected" ]; then
    echo "FAIL CLOSED: unexpected tracked mutation:"
    printf '%s\n' "$unexpected"
    exit 1
fi

printf '\n=== REPAIR VALIDATED ===\n'
