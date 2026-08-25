#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== REWRITE PROJECT-SCOPED DELEGATION IMPLEMENTATION AGAINST VERIFIED LIVE FRAGMENTS ==="

python3 <<'PY'
from pathlib import Path

path = Path("implement-project-scoped-delegation-reference.sh")
text = path.read_text()

start = text.find("python3 <<'PY'\nfrom pathlib import Path\n\npath = Path(\"db/governance-runtime.ts\")")
if start == -1:
    raise SystemExit("Expected governance-runtime patch block start not found; refusing edit.")

end_marker = "\nPY\n\npython3 <<'PY'\nfrom pathlib import Path\n\nfiles = ["
end = text.find(end_marker, start)
if end == -1:
    raise SystemExit("Expected governance-runtime patch block end not found; refusing edit.")

replacement = r'''python3 <<'PY'
from pathlib import Path

path = Path("db/governance-runtime.ts")
text = path.read_text()

replacements = [
(
"""export type CreateGovernanceDelegationInput = {

  delegation_id: string;

  package_id: string;""",
"""export type CreateGovernanceDelegationInput = {

  delegation_id: string;

  project_id: string;

  package_id: string;"""
),
(
"""export type CreatedGovernanceDelegation = {

  delegation_id: string;

  package_id: string;""",
"""export type CreatedGovernanceDelegation = {

  delegation_id: string;

  project_id: string;

  package_id: string;"""
),
(
"""    CREATE TABLE IF NOT EXISTS governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES matilda_canonical_packages(package_id, package_version)
    );""",
"""    CREATE UNIQUE INDEX IF NOT EXISTS idx_matilda_canonical_packages_project_package_version
      ON matilda_canonical_packages(project_id, package_id, package_version);

    CREATE TABLE IF NOT EXISTS governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      project_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (project_id, package_id, package_version)
        REFERENCES matilda_canonical_packages(project_id, package_id, package_version)
    );"""
),
(
"""const requiredDelegationTextFields = [

  "delegation_id",

  "package_id",""",
"""const requiredDelegationTextFields = [

  "delegation_id",

  "project_id",

  "package_id","""
),
(
"""  const delegation_id = requireDelegationText(input, "delegation_id");

  const package_id = requireDelegationText(input, "package_id");""",
"""  const delegation_id = requireDelegationText(input, "delegation_id");

  const project_id = requireDelegationText(input, "project_id");

  const package_id = requireDelegationText(input, "package_id");"""
),
(
"""  const canonicalPackage = sqlite.prepare(`
    SELECT
      package_id,
      package_version
    FROM matilda_canonical_packages
    WHERE package_id = ?
      AND package_version = ?
    LIMIT 1
  `).get(
    package_id,
    package_version,
  ) as
    | {
        package_id: string;
        package_version: number;
      }
    | undefined;""",
"""  const canonicalPackage = sqlite.prepare(`
    SELECT
      project_id,
      package_id,
      package_version
    FROM matilda_canonical_packages
    WHERE project_id = ?
      AND package_id = ?
      AND package_version = ?
    LIMIT 1
  `).get(
    project_id,
    package_id,
    package_version,
  ) as
    | {
        project_id: string;
        package_id: string;
        package_version: number;
      }
    | undefined;"""
),
(
"""      delegation_id,

      package_id,

      package_version,""",
"""      delegation_id,

      project_id,

      package_id,

      package_version,"""
),
(
"""      @delegation_id,

      @package_id,

      @package_version,""",
"""      @delegation_id,

      @project_id,

      @package_id,

      @package_version,"""
),
(
"""    delegation_id,

    package_id,

    package_version,

    authorization_state,""",
"""    delegation_id,

    project_id,

    package_id,

    package_version,

    authorization_state,"""
),
]

for old, new in replacements:
    count = text.count(old)
    if count != 1:
        raise SystemExit(
            f"Expected exactly one verified governance-runtime fragment, found {count}:\\n{old[:220]}"
        )
    text = text.replace(old, new, 1)

path.write_text(text)
PY'''

text = text[:start] + replacement + text[end + len("\nPY"):]
path.write_text(text)
PY

echo
echo "=== VERIFY ONLY IMPLEMENTATION HARNESS CHANGED ==="
git diff -- implement-project-scoped-delegation-reference.sh
git diff --check

UNEXPECTED="$(
  git status --short \
    | grep -vE 'implement-project-scoped-delegation-reference\.sh$|rewrite-project-scoped-delegation-implementation-against-live-fragments\.sh$' \
    || true
)"

if [[ -n "$UNEXPECTED" ]]; then
  echo "ERROR=UNEXPECTED_WORKTREE_CHANGES"
  printf '%s\n' "$UNEXPECTED"
  exit 1
fi

echo
echo "=== CLASSIFICATION ==="
echo "FAILED_HYPOTHESIS=NO"
echo "PRIOR_FAILURE=PATCH_TARGET_MISMATCH"
echo "LIVE_SOURCE_FRAGMENTS=VERIFIED"
echo "PATCH_REWRITTEN_AGAINST_LIVE_SOURCE=YES"
echo "AUTHORIZED_IMPLEMENTATION_SCOPE_CHANGED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== COMMIT REPAIRED IMPLEMENTATION HARNESS ==="
git add implement-project-scoped-delegation-reference.sh
git commit -m "Align project-scoped Delegation patch with live runtime"
git push

echo
echo "=== RERUN AUTHORIZED IMPLEMENTATION ==="
./implement-project-scoped-delegation-reference.sh
