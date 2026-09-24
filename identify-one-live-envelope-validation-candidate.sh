#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="a87f34110"
DB="db/main.db"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$DB"

printf '\n====================================================\n'
printf ' LIVE ENVELOPE CREATION VALIDATION — CANDIDATE INSPECTION\n'
printf '====================================================\n\n'

python3 << 'PY'
import sqlite3
import sys
from pathlib import Path

db_path = Path("db/main.db")
conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
conn.row_factory = sqlite3.Row

try:
    rows = conn.execute(
        """
        SELECT
          d.delegation_id,
          d.package_id,
          d.package_version,
          d.authorization_state,
          v.validation_result_id,
          v.validation_status,
          v.operational_requirements,
          v.capability_requirements,
          g.envelope_gate_id,
          g.gate_status,
          g.gate_decision_timestamp
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
        WHERE d.authorization_state = 'AUTHORIZED'
          AND v.validation_status = 'VALIDATION_PASSED'
          AND g.gate_status = 'OPEN'
          AND TRIM(COALESCE(v.operational_requirements, '')) <> ''
          AND TRIM(COALESCE(v.capability_requirements, '')) <> ''
        ORDER BY g.created_at ASC, v.created_at ASC, d.created_at ASC
        """
    ).fetchall()

    if len(rows) != 1:
        print(f"EXACT_ELIGIBLE_CANDIDATE_COUNT={len(rows)}")
        print("CANDIDATE_SELECTION=FAILED_CLOSED")
        print("LIVE_ENVELOPE_CREATION_ATTEMPT_CONSUMED=NO")
        sys.exit(21)

    row = rows[0]

    existing = conn.execute(
        """
        SELECT envelope_id
        FROM governance_envelopes
        WHERE package_id = ?
          AND package_version = ?
          AND delegation_id = ?
          AND validation_result_id = ?
          AND envelope_gate_id = ?
        LIMIT 2
        """,
        (
            row["package_id"],
            row["package_version"],
            row["delegation_id"],
            row["validation_result_id"],
            row["envelope_gate_id"],
        ),
    ).fetchall()

    if existing:
        print(f"EXISTING_EXACT_ENVELOPE_COUNT={len(existing)}")
        print("CANDIDATE_SELECTION=FAILED_CLOSED")
        print("REASON=EXACT_LINEAGE_ALREADY_HAS_ENVELOPE")
        print("LIVE_ENVELOPE_CREATION_ATTEMPT_CONSUMED=NO")
        sys.exit(22)

    print("EXACT_ELIGIBLE_CANDIDATE_COUNT=1")
    print("CANDIDATE_SELECTION=PASS")
    print(f"PACKAGE_ID={row['package_id']}")
    print(f"PACKAGE_VERSION={row['package_version']}")
    print(f"DELEGATION_ID={row['delegation_id']}")
    print(f"DELEGATION_AUTHORIZATION_STATE={row['authorization_state']}")
    print(f"VALIDATION_RESULT_ID={row['validation_result_id']}")
    print(f"VALIDATION_STATUS={row['validation_status']}")
    print(f"ENVELOPE_GATE_ID={row['envelope_gate_id']}")
    print(f"GATE_STATUS={row['gate_status']}")
    print(
        "CAPABILITY_REQUIREMENTS="
        + row["capability_requirements"].strip()
    )
    print(
        "OPERATIONAL_REQUIREMENTS="
        + row["operational_requirements"].strip()
    )
    print("EXACT_LINEAGE_ALREADY_HAS_ENVELOPE=NO")
    print("READ_ONLY_INSPECTION=YES")
    print("LIVE_GOVERNANCE_MUTATION=NO")
    print("LIVE_ENVELOPE_CREATION_ATTEMPT_CONSUMED=NO")
    print("NEXT_ACTION=EXECUTE_ONE_AUTHORIZED_LIVE_ENVELOPE_CREATION_ATTEMPT")
finally:
    conn.close()
PY

printf '\n=== AUTHORITY BOUNDARY ===\n'
echo "ONE_LIVE_ENVELOPE_CREATION_ATTEMPT_AUTHORIZED=YES"
echo "ONE_LIVE_ENVELOPE_CREATION_ATTEMPT_EXECUTED=NO"
echo "AUTOMATIC_ADVANCE=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "ROUTING_AUTHORITY=NO"
echo "ASSIGNMENT_AUTHORITY=NO"
echo "SCHEDULING_AUTHORITY=NO"
echo "WORKER_CLAIM_AUTHORITY=NO"
echo "ORCHESTRATION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\nLIVE_ENVELOPE_CREATION_VALIDATION_CANDIDATE_INSPECTION=COMPLETE\n'
