#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT PROJECT-SCOPED DELEGATION PERSISTENCE BINDING DEFECT ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== CURRENT DELEGATION CREATE RUNTIME ==="
sed -n '690,835p' db/governance-runtime.ts

echo
echo "=== PROJECT ID SQL / BINDING EVIDENCE ==="
rg -n -C 14 \
  '@project_id|project_id,|\.run\(\{' \
  db/governance-runtime.ts

echo
echo "=== STATIC FAIL-CLOSED CHECK ==="
python3 <<'PY'
from pathlib import Path

text = Path("db/governance-runtime.ts").read_text()

start = text.find("export function createGovernanceDelegation(")
if start == -1:
    raise SystemExit("createGovernanceDelegation not found")

end = text.find("\nexport function createGovernanceValidationResult(", start)
if end == -1:
    raise SystemExit("createGovernanceDelegation boundary not found")

block = text[start:end]
sql_requires_project = "@project_id" in block

run_start = block.find("`).run({")
if run_start == -1:
    raise SystemExit("Delegation .run binding object not found")

run_end = block.find("\n  });", run_start)
if run_end == -1:
    raise SystemExit("Delegation .run binding object end not found")

run_block = block[run_start:run_end]
binding_present = "\n    project_id," in run_block or "project_id:" in run_block

print("SQL_REQUIRES_PROJECT_ID=" + ("YES" if sql_requires_project else "NO"))
print("RUN_BINDING_INCLUDES_PROJECT_ID=" + ("YES" if binding_present else "NO"))

if sql_requires_project and not binding_present:
    print("PERSISTENCE_BINDING_DEFECT=CONFIRMED")
else:
    print("PERSISTENCE_BINDING_DEFECT=NOT_CONFIRMED")
PY

echo
echo "=== CURRENT TEST COVERAGE SEARCH ==="
rg -n -C 10 \
  'createGovernanceDelegation\(|project_id|GovernanceDelegationPersistenceFunction' \
  server/delegation db \
  --glob '*test.ts' \
  --glob '*spec.ts' \
  2>/dev/null | head -n 1800 || true

echo
echo "=== CLASSIFICATION ==="
echo "CONTRADICTORY_REPOSITORY_EVIDENCE=YES"
echo "DEFECT_CANDIDATE=MISSING_PROJECT_ID_IN_CREATE_GOVERNANCE_DELEGATION_SQL_BINDING_OBJECT"
echo "TYPECHECK_COULD_DETECT_THIS_RUNTIME_BINDING_DEFECT=NO"
echo "MOCKED_DELEGATION_ENTRY_POINT_TESTS_COULD_PASS_WITH_THIS_DEFECT=YES"
echo "PACKAGE_HANDOFF_CONTRACT_INVESTIGATION_PAUSED=YES"
echo "PROJECT_SCOPED_DELEGATION_CORRIDOR_CLOSURE_RECONCILIATION_REQUIRED=YES"
echo "LIVE_SCHEMA_MIGRATION_INVALIDATED=NO"
echo "HISTORICAL_LINEAGE_INVALIDATED=NO"
echo "KNOWN_DOWNSTREAM_LEGACY_ROOT_DEFECT_REOPENED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=IF_BINDING_DEFECT_CONFIRMED_DEFINE_MINIMUM_RUNTIME_FIX_AND_DIRECT_PERSISTENCE_VALIDATION_BEFORE_RESUMING_PACKAGE_HANDOFF_CONTRACT"
