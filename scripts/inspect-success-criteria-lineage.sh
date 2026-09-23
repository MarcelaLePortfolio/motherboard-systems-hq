#!/usr/bin/env bash
set -euo pipefail

echo "===== BASELINE ====="
printf "BRANCH: "; git rev-parse --abbrev-ref HEAD
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'
git status --short --untracked-files=no

echo
echo "===== LIVING DRAFT SCHEMA + MIGRATION ====="
sed -n '1,230p' db/matilda-living-draft-runtime.ts

echo
echo "===== LIVING DRAFT TYPES / WRITE / READ ====="
sed -n '230,560p' db/matilda-living-draft-runtime.ts

echo
echo "===== LIVING DRAFT DRIZZLE SCHEMA ====="
cat db/matilda-living-draft.schema.ts

echo
echo "===== DRAFT REVISION FULL RUNTIME ====="
cat db/matilda-draft-revision-runtime.ts

echo
echo "===== RECONCILED INTENT FULL RUNTIME ====="
cat db/matilda-reconciled-intent-runtime.ts

echo
echo "===== SUCCESS-CRITERIA SOURCE CANDIDATES ====="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'success_criteria|expected_outcome|selectedPackageSemantics' \
  db server scripts |
head -700

echo
echo "===== LIVE TABLE COLUMN OWNERSHIP ====="
sqlite3 -header -column db/main.db "
PRAGMA table_info(matilda_living_draft_packages);
PRAGMA table_info(matilda_draft_revisions);
PRAGMA table_info(matilda_canonical_packages);
PRAGMA table_info(governance_packages);
"

echo
echo "===== EXACT TARGET REVISION ====="
sqlite3 -header -column db/main.db "
SELECT *
FROM matilda_draft_revisions
WHERE draft_revision_id='draft-revision-7d868f8c-1661-4547-8a8e-5eaf5c286736';
"

echo
echo "===== TARGET GOVERNANCE SUCCESS CRITERIA ====="
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  requested_outcome,
  scope,
  constraints,
  success_criteria
FROM governance_packages
WHERE package_id='pkg-68dfc4bc-791d-4156-b32a-e51e458b3160'
  AND package_version=1;
"

echo
echo "===== PRESERVED DRIFT ====="
git status --short --untracked-files=no
