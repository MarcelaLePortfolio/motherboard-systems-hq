#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE="scripts/utils/ollamaChat.ts"

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

old = """            ...context.projectContextExcerpts.flatMap((item) => [
              "",
              `Source: ${item.relativePath}:${item.lineNumber}`,
              `Provenance: ${item.provenance}`,
              `Authority status: ${item.authorityStatus}`,
              item.excerpt,
            ]),
"""
new = """            ...context.projectContextExcerpts.flatMap((item) => [
              "",
              "Source:",
              `relativePath = ${item.relativePath}`,
              `lineNumber = ${item.lineNumber}`,
              `Display identity = ${item.relativePath}:${item.lineNumber}`,
              `Provenance: ${item.provenance}`,
              `Authority status: ${item.authorityStatus}`,
              item.excerpt,
            ]),
"""
if old not in text:
    raise SystemExit("PROJECT_CONTEXT_EVIDENCE_ANCHOR_NOT_FOUND")
text = text.replace(old, new, 1)

old = """            ...(context.projectContextExcerpts || []).flatMap((item) => [
              `Parent support source = ${item.relativePath}:${item.lineNumber}`,
            ]),
"""
new = """            ...(context.projectContextExcerpts || []).flatMap((item) => [
              "Parent support source:",
              `relativePath = ${item.relativePath}`,
              `lineNumber = ${item.lineNumber}`,
              `Display identity = ${item.relativePath}:${item.lineNumber}`,
            ]),
"""
if old not in text:
    raise SystemExit("VALIDATION_PARENT_PRESENTATION_ANCHOR_NOT_FOUND")
text = text.replace(old, new, 1)

old = """"For project-context support, use type project_context_excerpt with the exact relativePath and lineNumber supplied in bounded project context evidence.",
            "For project_context_excerpt support, use only a Source identity explicitly shown under Bounded project context evidence.",
"""
new = """"For project-context support, use type project_context_excerpt with the exact relativePath and lineNumber supplied in bounded project context evidence.",
            "For project_context_excerpt support, copy relativePath from the explicit relativePath field only and copy lineNumber from the explicit lineNumber field only.",
            "The relativePath field must contain only the raw repository path and must never include a colon-line suffix such as :12.",
            "A Display identity such as path/to/file.ts:12 is human-readable only and must never be copied wholesale into relativePath.",
            "For project_context_excerpt support, use only a Source identity explicitly shown under Bounded project context evidence.",
"""
if old not in text:
    raise SystemExit("SUPPORT_REFERENCE_INSTRUCTION_ANCHOR_NOT_FOUND")
text = text.replace(old, new, 1)

path.write_text(text)
PY

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=1b143dec' \
  'ISSUE_RESOLVED=NO' \
  'IMPLEMENTATION=SUPPORT_REFERENCE_PROMPT_PRESENTATION_FIX' \
  'IMPLEMENTATION_AUTHORIZED=YES' \
  'PRODUCTION_PROMPT_CHANGE=YES' \
  'VALIDATOR_CHANGE=NO' \
  'VALIDATOR_WEAKENING=NO' \
  'OUTPUT_SCHEMA_CHANGE=NO' \
  'MODEL_CHANGE=NO' \
  'RETRY_CHANGE=NO' \
  'DATABASE_WRITE=NO' \
  'NEW_OLLAMA_INVOCATION=NO'

printf '\n=== DIFF ===\n'
git diff -- "$FILE"

printf '\n=== STATIC VERIFICATION ===\n'
grep -n -A12 -B4 'Display identity' "$FILE" || true
grep -n -A8 -B3 'relativePath field must contain only the raw repository path' "$FILE" || true

printf '\n=== TYPECHECK ===\n'
set +e
npx tsc --noEmit
TYPECHECK_STATUS=$?
set -e
echo "TYPECHECK_STATUS=$TYPECHECK_STATUS"

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'PROMPT_PRESENTATION_FIX_IMPLEMENTED=YES' \
  'VALIDATION_RUN_STARTED=NO' \
  'PRODUCTION_VALIDATION_PENDING=YES' \
  'NEXT_ACTION=REVIEW_IMPLEMENTATION_RESULT_AND_OPEN_SEPARATE_VALIDATION_AUTHORIZATION_GATE'

git status --short
