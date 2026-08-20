#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE="scripts/run-dashboard-generation-control-comparison.ts"

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/run-dashboard-generation-control-comparison.ts")
text = path.read_text()

old = """  parsedSupportReferenceCount: number | null;
  fingerprint: string | null;
"""
new = """  parsedSupportReferenceCount: number | null;
  parsedSupportReferences:
    | readonly MatildaSupportSourceReference[]
    | null;
  fingerprint: string | null;
"""
if old not in text:
    raise SystemExit("RUN_RECORD_SHAPE_ANCHOR_NOT_FOUND")
text = text.replace(old, new, 1)

old = """      parsedSupportReferenceCount:
        parsedSupport?.length ?? null,
      fingerprint: fingerprint(output),
"""
new = """      parsedSupportReferenceCount:
        parsedSupport?.length ?? null,
      parsedSupportReferences:
        parsedSupport ? [...parsedSupport] : null,
      fingerprint: fingerprint(output),
"""
if old not in text:
    raise SystemExit("ACCEPTED_RECORD_ANCHOR_NOT_FOUND")
text = text.replace(old, new, 1)

old = """      parsedSupportReferenceCount:
        parsedSupport?.length ?? null,
      fingerprint: null,
"""
new = """      parsedSupportReferenceCount:
        parsedSupport?.length ?? null,
      parsedSupportReferences:
        parsedSupport ? [...parsedSupport] : null,
      fingerprint: null,
"""
if old not in text:
    raise SystemExit("REJECTED_RECORD_ANCHOR_NOT_FOUND")
text = text.replace(old, new, 1)

path.write_text(text)
PY

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=bc61b4d2' \
  'ISSUE_RESOLVED=NO' \
  'IMPLEMENTATION=VALIDATION_RUNNER_SUPPORT_REFERENCE_OBSERVABILITY' \
  'IMPLEMENTATION_AUTHORIZED=YES' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PRODUCTION_RUNTIME_CHANGE=NO' \
  'VALIDATOR_CHANGE=NO' \
  'PROMPT_CHANGE=NO'

printf '\n=== DIFF ===\n'
git diff -- "$FILE"

printf '\n=== STATIC VERIFICATION ===\n'
grep -n -A5 -B3 'parsedSupportReferences' "$FILE"

printf '\n=== TYPECHECK ===\n'
npx tsc --noEmit

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'OBSERVABILITY_IMPLEMENTED=YES' \
  'OLLAMA_RUN_STARTED=NO' \
  'DATABASE_WRITE=NO' \
  'NEXT_ACTION=REVIEW_IMPLEMENTATION_RESULT_BEFORE_SEPARATELY_AUTHORIZING_ANY_NEW_VALIDATION_RUN'
