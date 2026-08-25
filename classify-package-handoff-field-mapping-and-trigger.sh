#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY PACKAGE HANDOFF FIELD MAPPING AND TRIGGER ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PACKAGE_HANDOFF_CONTRACT"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== GOVERNANCE PACKAGE SCHEMA EXACTNESS ==="
sqlite3 -header -column db/main.db '
PRAGMA table_info(governance_packages);
'

echo
echo "=== MISSION READ ACTUAL FIELD CONSUMPTION ==="
sed -n '1,220p' db/mission-read-repository.ts

echo
echo "=== PRODUCTION PACKAGE FIELD REQUIREMENTS ==="
rg -n -C 20 \
  'requested_outcome|scope|containment|constraints|success_criteria|context|style_presentation_intent|exclusions|required' \
  db/governance-runtime.ts \
  server/package/production-package-entry-point.ts \
  server/package/production-package-consumer.ts \
  server/routes/governance-package-route.ts

echo
echo "=== CANONICAL APPROVAL RETURN SURFACE ==="
sed -n '195,390p' db/matilda-canonical-package-runtime.ts

echo
echo "=== APPROVAL ROUTE / CREATION TRIGGER SURFACE ==="
rg -n -C 30 \
  'createCanonicalPackageFromApprovedSummary|approve_canonical_package|approval_actor|canonical_package_created|canonical_approved' \
  routes server db \
  --glob '*.ts' \
  --glob '!*.test.ts' \
  2>/dev/null | head -n 2400 || true

echo
echo "=== FIELD NECESSITY CLASSIFICATION ==="
python3 <<'PY'
from pathlib import Path

mission = Path("db/mission-read-repository.ts").read_text()
fields = [
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
        + ("YES" if field in mission else "NO")
    )
PY

echo
echo "=== TRIGGER CLASSIFICATION QUESTIONS ==="
echo "QUESTION_1=DOES_CANONICAL_APPROVAL_ROUTE_ALREADY_RETURN_EXACT_PROJECT_PACKAGE_VERSION_IDENTITY"
echo "QUESTION_2=DOES_APPROVAL_COMPLETION_CURRENTLY_CALL_ANY_DOWNSTREAM_PACKAGE_PROJECTION"
echo "QUESTION_3=WOULD_AUTOMATIC_PROJECTION_ON_SUCCESSFUL_CANONICAL_APPROVAL_ADD_ANY_NEW_AUTHORITY"
echo "QUESTION_4=IS_AN_OPERATOR_TRIGGER_REQUIRED_BY_EXISTING_DOCTRINE_OR_ONLY_BY_UNRESOLVED_PRODUCT_BEHAVIOR"
echo "QUESTION_5=CAN_PROJECTION_BE_IDEMPOTENT_FOR_THE_EXACT_CANONICAL_IDENTITY"

echo
echo "=== EVIDENCE-BOUND DESIGN RULES ==="
echo "RULE_1=ONLY_FIELDS_REQUIRED_BY_EXISTING_governance_packages_SCHEMA_MAY_REQUIRE_MATERIALIZATION_VALUES"
echo "RULE_2=MISSION_READ_ONLY_NEEDS_FIELDS_IT_ACTUALLY_SELECTS"
echo "RULE_3=UNUSED_LEGACY_FIELDS_MUST_NOT_GAIN_INVENTED_CANONICAL_MEANING"
echo "RULE_4=IF_REQUIRED_NON_NULL_LEGACY_FIELDS_HAVE_NO_CANONICAL_EQUIVALENT_SCHEMA_OR_TARGET_ADAPTER_CHANGE_MUST_BE_CLASSIFIED_BEFORE_IMPLEMENTATION"
echo "RULE_5=TRIGGER_MUST_NOT_IMPLY_DELEGATION_VALIDATION_ROUTING_ASSIGNMENT_OR_EXECUTION"
echo "RULE_6=PROJECTION_MUST_BE_IDEMPOTENT_FOR_EXACT_project_id+package_id+package_version"

echo
echo "=== CURRENT CLASSIFICATION ==="
echo "MINIMUM_PROJECTION_BOUNDARY=DEFINED_AT_097ce6ad"
echo "FIELD_MAPPING_STATUS=UNDER_EVIDENCE_CLASSIFICATION"
echo "TRIGGER_STATUS=UNDER_EVIDENCE_CLASSIFICATION"
echo "AUTOMATIC_POST_APPROVAL_TRIGGER=NOT_YET_AUTHORIZED"
echo "EXPLICIT_OPERATOR_TRIGGER=NOT_YET_REQUIRED"
echo "PROJECT_BOUND_HANDOFF_STARTED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=DETERMINE_MINIMUM_REQUIRED_TARGET_FIELDS_AND_TRIGGER_FROM_SCHEMA_AND_APPROVAL_CALL_GRAPH"
