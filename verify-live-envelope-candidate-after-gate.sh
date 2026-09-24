#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="5cc65b43f"
DB="db/main.db"

VALIDATION_RESULT_ID="ef2ee15c-7f5b-4d7c-9a1f-b1180a614a3a"
ENVELOPE_GATE_ID="gate-live-envelope-validation-20260924T060547Z"
DELEGATION_ID="8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c"
PACKAGE_ID="pkg-68dfc4bc-791d-4156-b32a-e51e458b3160"
PACKAGE_VERSION="1"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$DB"

printf '\n====================================================\n'
printf ' LIVE ENVELOPE CREATION — EXACT ELIGIBILITY VERIFICATION\n'
printf '====================================================\n\n'

python3 << 'PY'
import sqlite3
import sys

db = sqlite3.connect("file:db/main.db?mode=ro", uri=True)
db.row_factory = sqlite3.Row

validation_result_id = "ef2ee15c-7f5b-4d7c-9a1f-b1180a614a3a"
envelope_gate_id = "gate-live-envelope-validation-20260924T060547Z"
delegation_id = "8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c"
package_id = "pkg-68dfc4bc-791d-4156-b32a-e51e458b3160"
package_version = 1

try:
    rows = db.execute(
        """
        SELECT
          d.authorization_state,
          v.validation_result_id,
          v.validation_status,
          v.operational_requirements,
          v.capability_requirements,
          g.envelope_gate_id,
          g.gate_status
        FROM governance_delegations d
        JOIN governance_validation_results v
          ON v.delegation_id = d.delegation_id
         AND v.package_id = d.package_id
         AND v.package_version = d.package_version
        JOIN governance_envelope_gates g
          ON g.validation_result_id = v.validation_result_id
         AND g.delegation_id = d.delegation_id
         AND g.package_id = d.package_id
         AND g.package_version = d.package_version
        WHERE d.delegation_id = ?
          AND d.package_id = ?
          AND d.package_version = ?
          AND v.validation_result_id = ?
          AND g.envelope_gate_id = ?
        """,
        (
            delegation_id,
            package_id,
            package_version,
            validation_result_id,
            envelope_gate_id,
        ),
    ).fetchall()

    if len(rows) != 1:
        print(f"EXACT_LINEAGE_MATCH_COUNT={len(rows)}")
        print("LIVE_ENVELOPE_ELIGIBILITY=FAILED_CLOSED")
        print("LIVE_ENVELOPE_ATTEMPT_CONSUMED=NO")
        sys.exit(21)

    row = rows[0]

    existing = db.execute(
        """
        SELECT COUNT(*) AS count
        FROM governance_envelopes
        WHERE package_id = ?
          AND package_version = ?
          AND delegation_id = ?
          AND validation_result_id = ?
          AND envelope_gate_id = ?
        """,
        (
            package_id,
            package_version,
            delegation_id,
            validation_result_id,
            envelope_gate_id,
        ),
    ).fetchone()["count"]

    operational = (row["operational_requirements"] or "").strip()
    capabilities = (row["capability_requirements"] or "").strip()

    checks = {
        "DELEGATION_AUTHORIZED": row["authorization_state"] == "AUTHORIZED",
        "VALIDATION_PASSED": row["validation_status"] == "VALIDATION_PASSED",
        "GATE_OPEN": row["gate_status"] == "OPEN",
        "OPERATIONAL_SEMANTICS_PRESENT": bool(operational),
        "CAPABILITY_SEMANTICS_PRESENT": bool(capabilities),
        "EXISTING_EXACT_ENVELOPE_ABSENT": existing == 0,
    }

    for key, value in checks.items():
        print(f"{key}={'YES' if value else 'NO'}")

    print(f"VALIDATION_RESULT_ID={row['validation_result_id']}")
    print(f"ENVELOPE_GATE_ID={row['envelope_gate_id']}")
    print(f"EXISTING_EXACT_ENVELOPE_COUNT={existing}")

    if not all(checks.values()):
        print("LIVE_ENVELOPE_ELIGIBILITY=FAILED_CLOSED")
        print("LIVE_ENVELOPE_ATTEMPT_CONSUMED=NO")
        sys.exit(22)

    print("LIVE_ENVELOPE_ELIGIBILITY=PASS")
    print("LIVE_ENVELOPE_ATTEMPT_AUTHORIZED=YES")
    print("LIVE_ENVELOPE_ATTEMPT_CONSUMED=NO")
    print("NEXT_ACTION=EXECUTE_ONE_AUTHORIZED_LIVE_ENVELOPE_CREATION")
finally:
    db.close()
PY

printf '\n=== AUTHORITY BOUNDARY ===\n'
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "ROUTING_AUTHORITY=NO"
echo "ASSIGNMENT_AUTHORITY=NO"
echo "SCHEDULING_AUTHORITY=NO"
echo "WORKER_CLAIM_AUTHORITY=NO"
echo "ORCHESTRATION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"
echo "AUTOMATIC_ADVANCE=NO"

printf '\nLIVE_ENVELOPE_CREATION_ELIGIBILITY_VERIFICATION=COMPLETE\n'
