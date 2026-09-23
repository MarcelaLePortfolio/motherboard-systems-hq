#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"

test "$(git branch --show-current)" = "$BRANCH"

echo "===== CURRENT HEAD / REMOTE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== FAILED CONFLICT FIXTURE ====="
sed -n '170,365p' db/matilda-canonical-package-runtime.test.ts

echo
echo "===== CANONICAL SCHEMA / MIGRATION ====="
grep -n -B 30 -A 100 \
  -E 'CREATE TABLE matilda_canonical_packages|approved_success_criteria|migrateLegacyCanonicalPackageTableIfRequired' \
  db/matilda-canonical-package-runtime.ts || true

echo
echo "===== PROJECTION CONFLICT PATH ====="
grep -n -B 40 -A 100 \
  -E 'conflicting identity|success_criteria|approved_success_criteria|governance_packages' \
  db/canonical-package-mission-projection.ts || true

echo
echo "===== CONFLICT FIXTURE CARDINALITY ====="
python3 - <<'PY'
from pathlib import Path
import re

source = Path("db/matilda-canonical-package-runtime.test.ts").read_text()

marker = "if (conflictingGovernanceTarget)"
start = source.index(marker)
end = source.index("sqlite.close();", start)
block = source[start:end]

for table in ("matilda_canonical_packages", "governance_packages"):
    match = re.search(
        rf"INSERT INTO {table}\s*\((.*?)\)\s*VALUES\s*\((.*?)\)",
        block,
        re.S,
    )
    if not match:
        print(f"{table}: INSERT not found")
        continue

    columns = [x.strip() for x in match.group(1).split(",")]
    values = [x.strip() for x in match.group(2).split(",")]

    print(
        f"{table}: columns={len(columns)} "
        f"values={len(values)} "
        f"question_marks={match.group(2).count('?')}"
    )
    print("columns:", columns)
    print("values:", values)

echo = None
PY

echo
echo "===== ISOLATED FAILURE WITH SQLITE TRACE ====="
NODE_DEBUG=sqlite node --import tsx --test \
  --test-name-pattern="projection conflict rolls back Canonical Package persistence" \
  db/matilda-canonical-package-runtime.test.ts || true

echo
echo "===== CURRENT AUTHORIZED DIFF ====="
git diff -- \
  db/matilda-canonical-package-runtime.ts \
  db/canonical-package-read-repository.ts \
  db/canonical-package-mission-projection.ts \
  db/matilda-canonical-package-runtime.test.ts \
  db/canonical-package-mission-projection.test.ts \
  db/canonical-package-read-repository.delegation.test.ts \
  scripts/implement-canonical-success-criteria-lineage.sh \
  scripts/repair-canonical-success-criteria-fixtures.sh

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
