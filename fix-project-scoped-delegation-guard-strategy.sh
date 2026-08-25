#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path

path = Path("implement-project-scoped-delegation-reference.sh")
text = path.read_text()

old = '''test "$(git rev-parse --short=8 HEAD)" = "7d206aef" || {
  echo "Unexpected HEAD; refusing implementation."
  exit 1
}'''

new = '''AUTHORIZED_ANCESTOR="fea53c11"
git merge-base --is-ancestor "$AUTHORIZED_ANCESTOR" HEAD || {
  echo "Authorized implementation checkpoint is not an ancestor of HEAD; refusing implementation."
  exit 1
}'''

if old not in text:
    raise SystemExit("Expected exact HEAD guard not found; refusing to edit.")

path.write_text(text.replace(old, new, 1))
PY

git add implement-project-scoped-delegation-reference.sh
git commit -m "Use ancestry guard for Delegation implementation"
git push

./implement-project-scoped-delegation-reference.sh
