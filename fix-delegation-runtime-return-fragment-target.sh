#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path

path = Path("implement-project-scoped-delegation-reference.sh")
text = path.read_text()

old = '''(
"""    delegation_id,

    package_id,

    package_version,

    authorization_state,""",
"""    delegation_id,

    project_id,

    package_id,

    package_version,

    authorization_state,"""
),'''

new = '''(
"""  return {

    delegation_id,

    package_id,

    package_version,

    authorization_state,""",
"""  return {

    delegation_id,

    project_id,

    package_id,

    package_version,

    authorization_state,"""
),'''

if old not in text:
    raise SystemExit("Expected ambiguous delegation return replacement block not found.")

path.write_text(text.replace(old, new, 1))
PY

git diff --check
git add implement-project-scoped-delegation-reference.sh
git commit -m "Disambiguate Delegation return patch target"
git push
./implement-project-scoped-delegation-reference.sh
