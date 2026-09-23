#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="f3c4926e4"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

echo "===== AUTHORIZED MUTATION STATUS ====="
git status --short -- \
  db/matilda-canonical-package-runtime.ts \
  db/canonical-package-read-repository.ts \
  db/canonical-package-mission-projection.ts \
  db/matilda-canonical-package-runtime.test.ts \
  db/canonical-package-mission-projection.test.ts \
  db/canonical-package-read-repository.delegation.test.ts \
  scripts/implement-canonical-success-criteria-lineage.sh

echo
echo "===== CANONICAL RUNTIME SQL ====="
grep -n -B 35 -A 90 \
  -E 'CREATE TABLE IF NOT EXISTS matilda_canonical_packages|approved_success_criteria|INSERT INTO matilda_canonical_packages|VALUES' \
  db/matilda-canonical-package-runtime.ts

echo
echo "===== GOVERNANCE PROJECTION SQL ====="
grep -n -B 35 -A 100 \
  -E 'approved_success_criteria|SELECT|INSERT INTO governance_packages|success_criteria|VALUES' \
  db/canonical-package-mission-projection.ts

echo
echo "===== CANONICAL RUNTIME TEST FIXTURE SQL ====="
grep -n -B 30 -A 100 \
  -E 'CREATE TABLE.*matilda_canonical_packages|CREATE TABLE.*matilda_living_draft_packages|CREATE TABLE.*matilda_draft_revisions|approved_success_criteria|success_criteria|INSERT INTO' \
  db/matilda-canonical-package-runtime.test.ts

echo
echo "===== PROJECTION TEST FIXTURE SQL ====="
grep -n -B 30 -A 100 \
  -E 'CREATE TABLE.*matilda_canonical_packages|approved_success_criteria|INSERT INTO matilda_canonical_packages|VALUES|success_criteria' \
  db/canonical-package-mission-projection.test.ts

echo
echo "===== READ REPOSITORY TEST FIXTURE SQL ====="
grep -n -B 30 -A 100 \
  -E 'CREATE TABLE.*matilda_canonical_packages|approved_success_criteria|INSERT INTO matilda_canonical_packages|VALUES' \
  db/canonical-package-read-repository.delegation.test.ts

echo
echo "===== EXACT PLACEHOLDER COUNTS ====="
python3 - <<'PY'
from pathlib import Path
import re

for name in [
    "db/matilda-canonical-package-runtime.ts",
    "db/matilda-canonical-package-runtime.test.ts",
    "db/canonical-package-mission-projection.test.ts",
    "db/canonical-package-read-repository.delegation.test.ts",
]:
    text = Path(name).read_text()
    print(f"\n--- {name} ---")
    for match in re.finditer(
        r"INSERT\s+INTO\s+matilda_canonical_packages\s*\((.*?)\)\s*VALUES\s*\((.*?)\)",
        text,
        re.S | re.I,
    ):
        columns = [
            item.strip()
            for item in match.group(1).split(",")
            if item.strip()
        ]
        values = [
            item.strip()
            for item in match.group(2).split(",")
            if item.strip()
        ]
        print(
            f"columns={len(columns)} values={len(values)} "
            f"question_marks={match.group(2).count('?')}"
        )
        print("columns:", columns)
        print("values:", values)
PY

echo
echo "===== TYPECHECK ====="
npx tsc --noEmit

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
