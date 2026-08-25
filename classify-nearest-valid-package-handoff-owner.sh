#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY NEAREST VALID PACKAGE HANDOFF OWNER ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PACKAGE_HANDOFF_CONTRACT"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CANONICAL APPROVAL WRITE SURFACE ==="
for file in \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  routes/api-approval-request.ts \
  server/index.ts
do
  echo "--- ${file} ---"
  if [[ -f "$file" ]]; then
    sed -n '1,1000p' "$file"
  else
    echo "MISSING"
  fi
done

echo
echo "=== EXACT CANONICAL WRITE / APPROVAL CALL GRAPH ==="
rg -n -C 16 \
  'matilda_canonical_packages|canonical_approved|approval_actor|approval_timestamp|createCanonical|create.*Canonical|approve.*Package|persist.*Canonical|INSERT INTO matilda_canonical_packages' \
  db server routes \
  2>/dev/null | head -n 2400 || true

echo
echo "=== SUCCESSOR / CALLBACK / PROJECTION SEARCH ==="
rg -n -C 14 \
  'canonical_package_created|after.*approval|post.*approval|on.*approval|handoff|successor|projection|materializ|governance_packages|createGovernancePackage' \
  db server routes \
  2>/dev/null | head -n 2200 || true

echo
echo "=== OWNERSHIP TEST ==="
python3 <<'PY'
from pathlib import Path

candidates = [
    Path("db/matilda-canonical-package-runtime.ts"),
    Path("server/routes/matilda-canonical-package-route.ts"),
    Path("routes/api-approval-request.ts"),
]

for path in candidates:
    if not path.exists():
        print(f"{path}=MISSING")
        continue

    text = path.read_text()
    print(f"{path}_HAS_CANONICAL_TABLE={'YES' if 'matilda_canonical_packages' in text else 'NO'}")
    print(f"{path}_HAS_CANONICAL_APPROVAL={'YES' if 'canonical_approved' in text else 'NO'}")
    print(f"{path}_HAS_PROJECT_ID={'YES' if 'project_id' in text else 'NO'}")
    print(f"{path}_HAS_PACKAGE_ID={'YES' if 'package_id' in text else 'NO'}")
    print(f"{path}_HAS_PACKAGE_VERSION={'YES' if 'package_version' in text else 'NO'}")
    print(f"{path}_WRITES_GOVERNANCE_PACKAGES={'YES' if 'governance_packages' in text else 'NO'}")
PY

echo
echo "=== ARCHITECTURAL CLASSIFICATION RULES ==="
echo "RULE_1=HANDOFF_OWNER_MUST_BE_UPSTREAM_OF_MISSION_READ"
echo "RULE_2=HANDOFF_OWNER_MUST_ALREADY_POSSESS_EXACT_PROJECT_PACKAGE_VERSION_IDENTITY"
echo "RULE_3=HANDOFF_OWNER_MUST_NOT_CONFERR_DELEGATION_VALIDATION_ROUTING_ASSIGNMENT_OR_EXECUTION_AUTHORITY"
echo "RULE_4=HANDOFF_OWNER_MUST_NOT_CREATE_A_SECOND_PACKAGE_AUTHORITY_ROOT"
echo "RULE_5=MISSION_CONTROL_AND_MISSION_READ_REMAIN_CONSUMERS_NOT_AUTHORITY_SOURCES"

echo
echo "=== CLASSIFICATION ==="
echo "CANONICAL_APPROVAL_PERSISTENCE_BOUNDARY=PRIMARY_OWNER_CANDIDATE"
echo "CANONICAL_PACKAGE_ROUTE=TRANSPORT_BOUNDARY_CANDIDATE"
echo "GOVERNANCE_PACKAGE_ROUTE=NOT_ESTABLISHED_AS_HANDOFF_OWNER"
echo "DELEGATION=NOT_HANDOFF_OWNER"
echo "MISSION_READ=NOT_HANDOFF_OWNER"
echo "MISSION_CONTROL=NOT_HANDOFF_OWNER"
echo "HANDOFF_MATERIALIZATION_FORM=STILL_UNRESOLVED"
echo "READ_ONLY_PROJECTION_VS_DURABLE_HANDOFF_RECORD=REQUIRES_NEXT_CLASSIFICATION"
echo "PROJECT_BOUND_HANDOFF_STARTED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_CANONICAL_APPROVAL_PERSISTENCE_BOUNDARY_AND_PROJECTION_FORM_FROM_EXACT_CALL_GRAPH"
