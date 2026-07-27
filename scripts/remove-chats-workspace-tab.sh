#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

TARGET="client/src/shell/NavigationRegion.tsx"
BACKUP="$(mktemp)"

cp "$TARGET" "$BACKUP"

cleanup() {
    rm -f "$BACKUP"
}

rollback() {
    printf '\n=== ROLLBACK ===\n'
    cp "$BACKUP" "$TARGET"
    printf 'RESTORED: %s\n' "$TARGET"
}

trap 'status=$?; if [[ $status -ne 0 ]]; then rollback; fi; cleanup; exit $status' EXIT

python3 <<'PY'
from pathlib import Path

path = Path("client/src/shell/NavigationRegion.tsx")
text = path.read_text()

original = """
        <button
          type="button"
          aria-current={activeWorkspace === "chat" ? "page" : undefined}
          onClick={() => onSelectWorkspace("chat")}
        >
          Chats
        </button>
"""

if original not in text:
    raise SystemExit("STOP: Chats workspace button not found.")

text = text.replace(original, "")

path.write_text(text)
PY

printf '\n=== SCOPE CHECK ===\n'

EXPECTED="client/src/shell/NavigationRegion.tsx"
ACTUAL="$(git diff --name-only | tr -d '\n')"

if [[ "$ACTUAL" != "$EXPECTED" ]]; then
    printf 'STOP: unauthorized files changed.\n'
    printf 'Changed:\n%s\n' "$ACTUAL"
    exit 1
fi

printf 'PASS: only NavigationRegion.tsx changed.\n'

printf '\n=== CLIENT BUILD ===\n'
npm --prefix client run build

printf 'PASS: build succeeded.\n'

trap - EXIT
cleanup

printf '\n=== RESULT ===\n'
printf 'PASS: Chats workspace tab removed.\n'
printf 'PASS: Sidebar remains authoritative for conversation navigation.\n'
