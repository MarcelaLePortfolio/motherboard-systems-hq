#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

CURRENT="scripts/utils/ollamaChat.ts"
PRE_FIX_COMMIT="1b143dec"
FIX_COMMIT="76be6132"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=22a1789b' \
  'ACTION=CLASSIFY_REQUEST_SIZE_AND_PROMPT_LOAD_WITHOUT_OLLAMA' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PRODUCTION_CHANGE=NO'

TMP_PRE="$(mktemp)"
TMP_POST="$(mktemp)"
trap 'rm -f "$TMP_PRE" "$TMP_POST"' EXIT

git show "${PRE_FIX_COMMIT}:${CURRENT}" > "$TMP_PRE"
git show "${FIX_COMMIT}:${CURRENT}" > "$TMP_POST"

printf '\n=== FILE SIZE COMPARISON ===\n'
PRE_BYTES="$(wc -c < "$TMP_PRE" | tr -d ' ')"
POST_BYTES="$(wc -c < "$TMP_POST" | tr -d ' ')"
PRE_LINES="$(wc -l < "$TMP_PRE" | tr -d ' ')"
POST_LINES="$(wc -l < "$TMP_POST" | tr -d ' ')"
printf '%s\n' \
  "PRE_FIX_FILE_BYTES=$PRE_BYTES" \
  "POST_FIX_FILE_BYTES=$POST_BYTES" \
  "FILE_BYTE_DELTA=$((POST_BYTES - PRE_BYTES))" \
  "PRE_FIX_FILE_LINES=$PRE_LINES" \
  "POST_FIX_FILE_LINES=$POST_LINES" \
  "FILE_LINE_DELTA=$((POST_LINES - PRE_LINES))"

printf '\n=== EXACT PROMPT FIX DIFF ===\n'
git diff "$PRE_FIX_COMMIT" "$FIX_COMMIT" -- "$CURRENT"

printf '\n=== PROMPT PRESENTATION TEXT DELTA ===\n'
python3 - "$TMP_PRE" "$TMP_POST" << 'PY'
from pathlib import Path
import sys

pre = Path(sys.argv[1]).read_text()
post = Path(sys.argv[2]).read_text()

added_fragments = [
    '"Source:",',
    '`relativePath = ${item.relativePath}`',
    '`lineNumber = ${item.lineNumber}`',
    '`Display identity = ${item.relativePath}:${item.lineNumber}`',
    '"Parent support source:",',
    '"For project_context_excerpt support, copy relativePath from the explicit relativePath field only and copy lineNumber from the explicit lineNumber field only.",',
    '"The relativePath field must contain only the raw repository path and must never include a colon-line suffix such as :12.",',
    '"A Display identity such as path/to/file.ts:12 is human-readable only and must never be copied wholesale into relativePath.",',
]

removed_fragments = [
    '`Source: ${item.relativePath}:${item.lineNumber}`',
    '`Parent support source = ${item.relativePath}:${item.lineNumber}`',
]

def chars(items):
    return sum(len(x) for x in items)

print(f"CLASSIFIED_ADDED_LITERAL_FRAGMENT_CHARS={chars(added_fragments)}")
print(f"CLASSIFIED_REMOVED_LITERAL_FRAGMENT_CHARS={chars(removed_fragments)}")
print(
    "CLASSIFIED_LITERAL_FRAGMENT_CHAR_DELTA="
    f"{chars(added_fragments) - chars(removed_fragments)}"
)

for fragment in added_fragments:
    print(
        "POST_FIX_FRAGMENT_PRESENT="
        + ("YES|" if fragment in post else "NO|")
        + fragment
    )

for fragment in removed_fragments:
    print(
        "PRE_FIX_FRAGMENT_PRESENT="
        + ("YES|" if fragment in pre else "NO|")
        + fragment
    )
PY

printf '\n=== DASHBOARD SNAPSHOT CONTEXT COUNTS ===\n'
printf '%s\n' \
  'HISTORY_COUNT=1' \
  'PROJECT_CONTEXT_EXCERPT_COUNT=6' \
  'PROJECT_CONTEXT_SEGMENT_COUNT=9' \
  'MODEL_CONTEXT_WINDOW=131072'

printf '\n=== CAUSAL CLASSIFICATION ===\n'
python3 - "$PRE_BYTES" "$POST_BYTES" << 'PY'
import sys

pre = int(sys.argv[1])
post = int(sys.argv[2])
delta = post - pre
ratio = (delta / pre) if pre else 0

print(f"OLLAMA_CHAT_SOURCE_FILE_BYTE_DELTA={delta}")
print(f"OLLAMA_CHAT_SOURCE_FILE_RELATIVE_DELTA={ratio:.6f}")
print(
    "PROMPT_FIX_CREATED_LARGE_STATIC_SOURCE_EXPANSION="
    + ("YES" if ratio >= 0.10 else "NO")
)
print("EXACT_REQUEST_TOKEN_COUNT_ESTABLISHED=NO")
print("PROMPT_SIZE_AS_TIMEOUT_CAUSE_ESTABLISHED=NO")
print("SUPPORT_REFERENCE_FIX_VALIDATED=NO")
print("SUPPORT_REFERENCE_FIX_DISPROVEN=NO")
print("THIRD_IDENTICAL_VALIDATION_JUSTIFIED=NO")
PY

printf '\n=== NEXT BOUNDED CLASS ===\n'
printf '%s\n' \
  'NEXT_ACTION=CLASSIFY_GENERATION_DURATION_AND_RESPONSE_SIZE_HISTORY_FROM_EXISTING_EVIDENCE_ONLY' \
  'PURPOSE=DETERMINE_WHETHER_TIMEOUTS_CORRELATE_WITH_RESPONSE_GENERATION_LENGTH_OR_EXISTING_RUNTIME_VARIANCE' \
  'THIRD_OLLAMA_INVOCATION_AUTHORIZED=NO' \
  'TIMEOUT_CHANGE_AUTHORIZED=NO' \
  'MODEL_CHANGE_AUTHORIZED=NO' \
  'PROMPT_CHANGE_AUTHORIZED=NO'

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'OLLAMA_GENERATION_STARTED=NO' \
  'TIMEOUT_CHANGED=NO' \
  'MODEL_CHANGED=NO' \
  'VALIDATOR_CHANGED=NO' \
  'PROMPT_CHANGED=NO' \
  'GENERATION_POLICY_CHANGED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
