#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path

path = Path("server/routes/governance-delegation-route.ts")
text = path.read_text()

old = '''export type GovernanceDelegationRouteBody = {

  delegation_id?: unknown;

  package_id?: unknown;'''

new = '''export type GovernanceDelegationRouteBody = {

  delegation_id?: unknown;

  project_id?: unknown;

  package_id?: unknown;'''

if old not in text:
    raise SystemExit("Expected GovernanceDelegationRouteBody fragment not found.")

path.write_text(text.replace(old, new, 1))
PY

git diff --check
git add server/routes/governance-delegation-route.ts
git commit -m "Add project scope to Delegation route body"
git push

npx tsc --noEmit --pretty false
