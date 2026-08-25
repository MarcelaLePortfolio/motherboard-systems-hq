#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY MINIMUM HANDOFF TARGET AND TRIGGER ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PACKAGE_HANDOFF_CONTRACT"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== LIVE GOVERNANCE PACKAGE COLUMN CONTRACT ==="
sqlite3 -header -column db/main.db '
PRAGMA table_info(governance_packages);
'

echo
echo "=== REQUIRED NON-NULL GOVERNANCE PACKAGE FIELDS ==="
sqlite3 -header -column db/main.db '
SELECT
  name,
  type,
  "notnull",
  dflt_value,
  pk
FROM pragma_table_info("governance_packages")
WHERE "notnull" = 1
ORDER BY cid;
'

echo
echo "=== MISSION READ REQUIRED PACKAGE FIELDS ==="
python3 <<'PY'
from pathlib import Path

text = Path("db/mission-read-repository.ts").read_text()

fields = [
    "package_id",
    "package_version",
    "project_id",
    "conversation_id",
    "requested_outcome",
    "scope",
    "containment",
    "constraints",
    "success_criteria",
    "context",
    "style_presentation_intent",
    "exclusions",
]

for field in fields:
    print(
        f"MISSION_READ_CONSUMES_{field}="
        + ("YES" if field in text else "NO")
    )
PY

echo
echo "=== CANONICAL SOURCE FIELD AVAILABILITY ==="
sqlite3 -header -column db/main.db '
PRAGMA table_info(matilda_canonical_packages);
'

echo
echo "=== EXACT APPROVAL ROUTE SUCCESS PATH ==="
sed -n '1,110p' server/routes/matilda-canonical-package-route.ts

echo
echo "=== EXACT CANONICAL CREATION RETURN CONTRACT ==="
sed -n '340,375p' db/matilda-canonical-package-runtime.ts

echo
echo "=== EXISTING POST-APPROVAL PROJECTION CALL SEARCH ==="
rg -n -C 12 \
  'createCanonicalPackageFromApprovedSummary|createGovernancePackage|consumeProductionPackageEntryPoint|invokeProductionPackageEntryPoint|governance_packages' \
  server/routes/matilda-canonical-package-route.ts \
  db/matilda-canonical-package-runtime.ts \
  server/package \
  2>/dev/null || true

echo
echo "=== IDEMPOTENCY SURFACE ==="
sqlite3 -header -column db/main.db '
SELECT
  sql
FROM sqlite_master
WHERE type IN ("table", "index")
  AND (
    name = "governance_packages"
    OR tbl_name = "governance_packages"
  )
ORDER BY type, name;
'

echo
echo "=== FIELD MAPPING CLASSIFICATION ==="
echo "MISSION_READ_MINIMUM_REQUIRED_IDENTITY=package_id+package_version+project_id+conversation_id"
echo "MISSION_READ_MINIMUM_REQUIRED_SEMANTIC_FIELD=requested_outcome"
echo "MISSION_READ_DOES_NOT_CONSUME_scope=YES"
echo "MISSION_READ_DOES_NOT_CONSUME_containment=YES"
echo "MISSION_READ_DOES_NOT_CONSUME_constraints=YES"
echo "MISSION_READ_DOES_NOT_CONSUME_success_criteria=YES"
echo "MISSION_READ_DOES_NOT_CONSUME_context=YES"
echo "MISSION_READ_DOES_NOT_CONSUME_style_presentation_intent=YES"
echo "MISSION_READ_DOES_NOT_CONSUME_exclusions=YES"
echo "UNUSED_LEGACY_FIELDS_MUST_NOT_RECEIVE_INVENTED_CANONICAL_MEANING=YES"
echo "TARGET_SCHEMA_MAY_REQUIRE_RECONCILIATION_IF_UNUSED_FIELDS_ARE_NON_NULL=YES"

echo
echo "=== TRIGGER CLASSIFICATION ==="
echo "CANONICAL_APPROVAL_ROUTE_RETURNS_EXACT_PACKAGE_IDENTITY=YES"
echo "CANONICAL_APPROVAL_CREATION_CONFERS_DELEGATION_AUTHORITY=NO"
echo "CANONICAL_APPROVAL_CREATION_CONFERS_VALIDATION_AUTHORITY=NO"
echo "CANONICAL_APPROVAL_CREATION_CONFERS_ENVELOPE_AUTHORITY=NO"
echo "CANONICAL_APPROVAL_CREATION_CONFERS_EXECUTION_AUTHORITY=NO"
echo "CURRENT_POST_APPROVAL_GOVERNANCE_PACKAGE_PROJECTION=NOT_ESTABLISHED"
echo "OPERATOR_TRIGGER_REQUIRED_BY_CURRENT_EVIDENCE=NO"
echo "AUTOMATIC_POST_APPROVAL_TRIGGER_AUTHORIZED=NO"
echo "PROJECTION_TRIGGER_REMAINS_DESIGN_DECISION_PENDING_TARGET_SCHEMA_COMPATIBILITY"

echo
echo "=== NEXT DECISION ==="
echo "QUESTION=CAN_EXISTING_governance_packages_SCHEMA_SUPPORT_A_MINIMUM_DERIVED_MISSION_READ_PROJECTION_WITHOUT_INVENTING_VALUES_FOR_UNUSED_REQUIRED_LEGACY_FIELDS"
echo "IF_YES=CLASSIFY_IDEMPOTENT_POST_APPROVAL_PROJECTION_TRIGGER"
echo "IF_NO=CLASSIFY_BOUNDED_TARGET_SCHEMA_RECONCILIATION_BEFORE_TRIGGER_SELECTION"
echo "PROJECT_BOUND_HANDOFF_STARTED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
