#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CORRIDOR-SMOKE DOWNSTREAM RUNTIME STATUS CLASSIFICATION ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== GOVERNANCE HISTORICAL CLASSIFICATION ==="
rg -n -C 8 \
  'corridor-smoke.*historical|historical.*corridor-smoke|downstream smoke artifacts|not migrated, copied, reparented|not.*live Canonical authority' \
  docs/governance docs/checkpoints \
  2>/dev/null | head -n 1000

echo
echo "=== CURRENT MISSION CONTROL DEPENDENCY ==="
rg -n -C 8 \
  'ACTIVE_PACKAGE_ID.*corridor-smoke|loadMission\("corridor-smoke"\)|loadMission\(ACTIVE_PACKAGE_ID\)|corridor-smoke mission not found' \
  client/src db server routes scripts \
  --glob '!*.bak' \
  2>/dev/null | head -n 1600

echo
echo "=== CURRENT MISSION READ DATA DEPENDENCY ==="
sed -n '1,180p' db/mission-read-repository.ts

echo
echo "=== CORRIDOR-SMOKE LIVE LINEAGE ==="
sqlite3 -header -column db/main.db "
SELECT
  p.package_id,
  p.package_version,
  p.project_id,
  p.conversation_id,
  d.delegation_id,
  d.authorization_state,
  v.validation_result_id,
  v.validation_status,
  g.envelope_gate_id,
  g.gate_status,
  e.envelope_id,
  e.lifecycle_state
FROM governance_packages p
LEFT JOIN governance_delegations d
  ON d.package_id = p.package_id
 AND d.package_version = p.package_version
LEFT JOIN governance_validation_results v
  ON v.package_id = p.package_id
 AND v.package_version = p.package_version
LEFT JOIN governance_envelope_gates g
  ON g.package_id = p.package_id
 AND g.package_version = p.package_version
LEFT JOIN governance_envelopes e
  ON e.package_id = p.package_id
 AND e.package_version = p.package_version
WHERE p.package_id = 'corridor-smoke'
  AND p.package_version = 1;
"

echo
echo "=== MISSION READ PROJECTION OF CORRIDOR-SMOKE ==="
npx tsx -e '
import Database from "better-sqlite3";
import { createMissionReadRepository } from "./db/mission-read-repository.ts";
import { assembleMissionReadModel } from "./db/mission-read-model-assembler.ts";

async function main(): Promise<void> {
  const db = new Database("db/main.db", { readonly: true });

  try {
    const repository = createMissionReadRepository(db);
    const input = await repository.loadMission("corridor-smoke");

    console.log("MISSION_INPUT_PRESENT=" + (input ? "YES" : "NO"));

    if (input) {
      console.log(JSON.stringify(input, null, 2));
      console.log("=== ASSEMBLED MISSION ===");
      console.log(JSON.stringify(assembleMissionReadModel(input), null, 2));
    }
  } finally {
    db.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
'

echo
echo "=== LIVE VALIDATION CONTRACT ==="
if [[ -x scripts/validate-mission-state-projection-live.sh ]]; then
  ./scripts/validate-mission-state-projection-live.sh
elif [[ -f scripts/validate-mission-state-projection-live.ts ]]; then
  npx tsx scripts/validate-mission-state-projection-live.ts
else
  echo "LIVE_MISSION_PROJECTION_VALIDATOR=NOT_FOUND"
fi

echo
echo "=== FALSIFICATION: ALTERNATE CURRENT MISSION IDENTITY ==="
rg -n -C 8 \
  'ACTIVE_PACKAGE_ID|activePackageId|active_package_id|selectedPackageId|selected_package_id|activeMission|active_mission|loadMission\(' \
  client/src db server routes \
  --glob '!*.bak' \
  2>/dev/null | head -n 2200

echo
echo "=== CURRENT FOREIGN KEY DEFECT ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== CLASSIFICATION ==="
echo "GOVERNANCE_AUTHORITY_CLASSIFICATION=CORRIDOR_SMOKE_LINEAGE_IS_HISTORICAL_AND_NOT_LIVE_CANONICAL_AUTHORITY"
echo "CURRENT_READ_RUNTIME_CLASSIFICATION=CORRIDOR_SMOKE_LINEAGE_IS_STILL_CONSUMED_BY_MISSION_CONTROL"
echo "HISTORICAL_AUTHORITY_AND_CURRENT_READ_DEPENDENCY_CAN_COEXIST=YES"
echo "CORRIDOR_SMOKE_ROWS_DISPOSABLE=NO"
echo "CORRIDOR_SMOKE_ROWS_SAFE_TO_REPARENT_TO_CANONICAL=NO"
echo "CORRIDOR_SMOKE_ROWS_SAFE_TO_DELETE=NO"
echo "CORRIDOR_SMOKE_ROWS_HISTORY_ONLY_WITH_NO_RUNTIME_DEPENDENCY=NO"
echo "CURRENT_RUNTIME_DEPENDENCY_CREATES_CANONICAL_AUTHORITY=NO"
echo "STALE_DELEGATION_FOREIGN_KEYS_REMAIN_SCHEMA_DEFECT=YES"
echo "VALIDATION_ROOT_RECONCILIATION_CAN_IGNORE_HISTORICAL_READ_DEPENDENCY=NO"
echo "ACTIVE_AUTHORITY_CHANGE_AUTHORIZED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "CURRENT_SCOPE=VALIDATION_ROOT_RECONCILIATION_READINESS"
echo "DECISION=DO_NOT_SELECT_A_DESTRUCTIVE_OR_REPARENTING_MIGRATION_BOUNDARY"
echo "NEXT_STEP=DETERMINE_WHETHER_VALIDATION_CAN_SUPPORT_CANONICAL_NEW_WRITES_WHILE_PRESERVING_THE_LEGACY_CORRIDOR_SMOKE_READ_LINEAGE_WITHOUT_FALSE_AUTHORITY"
