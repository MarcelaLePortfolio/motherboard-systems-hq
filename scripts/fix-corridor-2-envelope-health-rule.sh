#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 - << 'PY'
from pathlib import Path

path = Path("db/mission-read-model-assembler.ts")
text = path.read_text()

old = '''  if (
    input.lifecycle_state !== null &&
    input.lifecycle_state !== "ASSIGNED" &&
    input.gate_status !== "OPEN"
  ) {
    warnings.push(
      "Envelope lifecycle state exists without an open envelope gate.",
    );
  }
'''

new = '''  if (
    input.lifecycle_state !== null &&
    input.lifecycle_state !== "ASSIGNED" &&
    input.gate_status !== "OPEN" &&
    input.gate_status !== "PASSED"
  ) {
    warnings.push(
      "Envelope lifecycle state exists without authoritative envelope-gate lineage.",
    );
  }
'''

if old not in text:
    raise SystemExit("Expected envelope integrity rule not found; refusing speculative edit.")

path.write_text(text.replace(old, new))
PY

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'ACTIVE_CORRIDOR=MISSION_STATE_PROJECTION' \
  'FIX=ENVELOPE_HEALTH_GATE_LINEAGE' \
  'CREATION_TIME_GATE_STATE=OPEN' \
  'LIVE_POST_CREATION_GATE_STATE=PASSED' \
  'VALID_ENVELOPE_GATE_LINEAGE=OPEN_OR_PASSED' \
  'NEW_SEMANTIC_AUTHORITY=NO' \
  'NEW_PERSISTENCE=NO'

printf '\n=== TARGETED DIFF ===\n'
git diff -- db/mission-read-model-assembler.ts

printf '\n=== BACKEND VALIDATION ===\n'
npx tsx db/mission-read-model-assembler.test.ts
npx tsx db/mission-read-repository.test.ts
npx tsx db/mission-read-model.integration.test.ts

printf '\n=== CLIENT BUILD ===\n'
npm run build --prefix client

printf '\n=== LIVE CORRIDOR 2 VALIDATION ===\n'
npx tsx scripts/validate-mission-state-projection-live.ts

printf '\n=== WORKTREE ===\n'
git status --short
