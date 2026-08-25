#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FIX CORRIDOR-SMOKE RUNTIME STATUS INSPECTION ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== FAILURE CLASSIFICATION ==="
echo "FAILED_HYPOTHESIS=NO"
echo "REPOSITORY_DEFECT_ESTABLISHED=NO"
echo "INSPECTION_SCRIPT_DEFECT=YES"
echo "DEFECT=TOP_LEVEL_AWAIT_UNSUPPORTED_BY_TSX_EVAL_CJS_OUTPUT"
echo "PRIOR_EVIDENCE_INVALIDATED=NO"
echo "NEXT_STEP=REPAIR_INSPECTION_HARNESS_ONLY"
echo "PRODUCTION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"

python3 <<'PY'
from pathlib import Path

path = Path("classify-corridor-smoke-downstream-runtime-status.sh")
text = path.read_text()

old = '''npx tsx -e '
import Database from "better-sqlite3";
import { createMissionReadRepository } from "./db/mission-read-repository.ts";
import { assembleMissionReadModel } from "./db/mission-read-model-assembler.ts";

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
'
'''

new = '''npx tsx -e '
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
'''

if old not in text:
    raise SystemExit(
        "Expected failing TSX inspection block was not found; refusing speculative edit."
    )

path.write_text(text.replace(old, new, 1))
PY

echo
echo "=== VERIFY EDIT IS INSPECTION-ONLY ==="
git diff -- classify-corridor-smoke-downstream-runtime-status.sh

echo
echo "=== RUN REPAIRED CLASSIFICATION ==="
./classify-corridor-smoke-downstream-runtime-status.sh

echo
echo "=== POST-RUN WORKTREE ==="
git status --short
