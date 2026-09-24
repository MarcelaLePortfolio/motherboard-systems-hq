#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="e8d1904bd"
DB="db/main.db"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$DB"

printf '\n====================================================\n'
printf ' LIVE ENVELOPE CANDIDATE — PREREQUISITE DIAGNOSTIC\n'
printf '====================================================\n\n'

python3 << 'PY'
import sqlite3
from pathlib import Path

db_path = Path("db/main.db")
conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
conn.row_factory = sqlite3.Row

try:
    delegations = conn.execute(
        """
        SELECT
          delegation_id,
          package_id,
          package_version,
          authorization_state,
          created_at
        FROM governance_delegations
        ORDER BY created_at DESC
        """
    ).fetchall()

    validations = conn.execute(
        """
        SELECT
          validation_result_id,
          package_id,
          package_version,
          delegation_id,
          validation_status,
          operational_requirements,
          capability_requirements,
          created_at
        FROM governance_validation_results
        ORDER BY created_at DESC
        """
    ).fetchall()

    gates = conn.execute(
        """
        SELECT
          envelope_gate_id,
          package_id,
          package_version,
          delegation_id,
          validation_result_id,
          gate_status,
          created_at
        FROM governance_envelope_gates
        ORDER BY created_at DESC
        """
    ).fetchall()

    envelopes = conn.execute(
        """
        SELECT
          envelope_id,
          package_id,
          package_version,
          delegation_id,
          validation_result_id,
          envelope_gate_id,
          lifecycle_state,
          created_at
        FROM governance_envelopes
        ORDER BY created_at DESC
        """
    ).fetchall()

    print(f"DELEGATION_COUNT={len(delegations)}")
    print(f"VALIDATION_RESULT_COUNT={len(validations)}")
    print(f"ENVELOPE_GATE_COUNT={len(gates)}")
    print(f"ENVELOPE_COUNT={len(envelopes)}")

    print("\n=== AUTHORIZED DELEGATIONS ===")
    authorized = [
        row for row in delegations
        if row["authorization_state"] == "AUTHORIZED"
    ]
    print(f"AUTHORIZED_DELEGATION_COUNT={len(authorized)}")

    for d in authorized:
        print(
            "AUTHORIZED_DELEGATION="
            f"{d['delegation_id']}|"
            f"{d['package_id']}|"
            f"{d['package_version']}"
        )

        matching_validations = [
            v for v in validations
            if v["delegation_id"] == d["delegation_id"]
            and v["package_id"] == d["package_id"]
            and v["package_version"] == d["package_version"]
        ]

        print(
            "MATCHING_VALIDATION_COUNT="
            f"{len(matching_validations)}"
        )

        for v in matching_validations:
            operational_ok = bool(
                (v["operational_requirements"] or "").strip()
            )
            capability_ok = bool(
                (v["capability_requirements"] or "").strip()
            )

            print(
                "VALIDATION="
                f"{v['validation_result_id']}|"
                f"{v['validation_status']}|"
                f"OPERATIONAL_SEMANTICS={'YES' if operational_ok else 'NO'}|"
                f"CAPABILITY_SEMANTICS={'YES' if capability_ok else 'NO'}"
            )

            matching_gates = [
                g for g in gates
                if g["validation_result_id"] == v["validation_result_id"]
                and g["delegation_id"] == d["delegation_id"]
                and g["package_id"] == d["package_id"]
                and g["package_version"] == d["package_version"]
            ]

            print(
                "MATCHING_GATE_COUNT="
                f"{len(matching_gates)}"
            )

            for g in matching_gates:
                print(
                    "GATE="
                    f"{g['envelope_gate_id']}|"
                    f"{g['gate_status']}"
                )

                exact_envelopes = [
                    e for e in envelopes
                    if e["package_id"] == d["package_id"]
                    and e["package_version"] == d["package_version"]
                    and e["delegation_id"] == d["delegation_id"]
                    and e["validation_result_id"] == v["validation_result_id"]
                    and e["envelope_gate_id"] == g["envelope_gate_id"]
                ]

                print(
                    "EXISTING_EXACT_ENVELOPE_COUNT="
                    f"{len(exact_envelopes)}"
                )

    print("\n=== ELIGIBILITY BREAKDOWN ===")

    authorized_count = len(authorized)

    passed = [
        v for v in validations
        if v["validation_status"] == "VALIDATION_PASSED"
        and any(
            d["delegation_id"] == v["delegation_id"]
            and d["package_id"] == v["package_id"]
            and d["package_version"] == v["package_version"]
            and d["authorization_state"] == "AUTHORIZED"
            for d in delegations
        )
    ]

    semantic_ready = [
        v for v in passed
        if (v["operational_requirements"] or "").strip()
        and (v["capability_requirements"] or "").strip()
    ]

    open_gate_ready = []
    for v in semantic_ready:
        for g in gates:
            if (
                g["validation_result_id"] == v["validation_result_id"]
                and g["delegation_id"] == v["delegation_id"]
                and g["package_id"] == v["package_id"]
                and g["package_version"] == v["package_version"]
                and g["gate_status"] == "OPEN"
            ):
                open_gate_ready.append((v, g))

    unconsumed = []
    for v, g in open_gate_ready:
        exists = any(
            e["package_id"] == v["package_id"]
            and e["package_version"] == v["package_version"]
            and e["delegation_id"] == v["delegation_id"]
            and e["validation_result_id"] == v["validation_result_id"]
            and e["envelope_gate_id"] == g["envelope_gate_id"]
            for e in envelopes
        )
        if not exists:
            unconsumed.append((v, g))

    print(f"AUTHORIZED_DELEGATION_READY_COUNT={authorized_count}")
    print(f"PASSED_VALIDATION_READY_COUNT={len(passed)}")
    print(f"SEMANTIC_READY_VALIDATION_COUNT={len(semantic_ready)}")
    print(f"OPEN_GATE_READY_COUNT={len(open_gate_ready)}")
    print(f"UNCONSUMED_EXACT_ENVELOPE_CANDIDATE_COUNT={len(unconsumed)}")

    if authorized_count == 0:
        blocker = "NO_AUTHORIZED_DELEGATION"
    elif len(passed) == 0:
        blocker = "NO_PASSED_VALIDATION_FOR_AUTHORIZED_DELEGATION"
    elif len(semantic_ready) == 0:
        blocker = "PASSED_VALIDATION_MISSING_AUTHORITATIVE_SEMANTICS"
    elif len(open_gate_ready) == 0:
        blocker = "NO_OPEN_GATE_FOR_SEMANTIC_READY_PASSED_VALIDATION"
    elif len(unconsumed) == 0:
        blocker = "ALL_ELIGIBLE_EXACT_LINEAGES_ALREADY_HAVE_ENVELOPES"
    else:
        blocker = "NONE"

    print(f"PRIMARY_BLOCKER={blocker}")
    print("READ_ONLY_DIAGNOSTIC=YES")
    print("LIVE_GOVERNANCE_MUTATION=NO")
    print("LIVE_ENVELOPE_CREATION_ATTEMPT_CONSUMED=NO")
finally:
    conn.close()
PY

printf '\n=== AUTHORITY BOUNDARY ===\n'
echo "ONE_LIVE_ENVELOPE_CREATION_ATTEMPT_AUTHORIZED=YES"
echo "ONE_LIVE_ENVELOPE_CREATION_ATTEMPT_EXECUTED=NO"
echo "AUTOMATIC_REPAIR=NO"
echo "AUTOMATIC_VALIDATION=NO"
echo "AUTOMATIC_GATE_CREATION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\nLIVE_ENVELOPE_CANDIDATE_PREREQUISITE_DIAGNOSTIC=COMPLETE\n'
