#!/usr/bin/env bash
set -euo pipefail

DB="${1:-db/main.db}"

printf '\n========== VERIFY MATILDA SEMANTIC RUNTIME ==========\n'

if [ -e matilda-chat-stub.js ]; then
    printf '\nFAIL: stale matilda-chat-stub.js exists.\n'
    exit 1
fi

if grep -q "createInterpretationEvidenceLedgerEntry" matilda-chat-stub.ts; then
    printf '\nFAIL: stub owns IEL persistence.\n'
    exit 1
fi

if ! grep -q "createInterpretationEvidenceLedgerEntry" server/matilda-chat-workflow.ts; then
    printf '\nFAIL: workflow does not own IEL persistence.\n'
    exit 1
fi

BEFORE_IEL="$(sqlite3 "$DB" 'SELECT COUNT(*) FROM matilda_interpretation_evidence_ledger;')"
BEFORE_TURNS="$(sqlite3 "$DB" 'SELECT COUNT(*) FROM matilda_conversation_turns;')"

printf '\nCurrent IEL rows:  %s\n' "$BEFORE_IEL"
printf 'Current turn rows: %s\n' "$BEFORE_TURNS"

printf '\nOpen Matilda and send ONE new message.\n'
printf 'Wait for the reply, then return here and press Enter.\n'
read -r

AFTER_IEL="$(sqlite3 "$DB" 'SELECT COUNT(*) FROM matilda_interpretation_evidence_ledger;')"
AFTER_TURNS="$(sqlite3 "$DB" 'SELECT COUNT(*) FROM matilda_conversation_turns;')"

if [ "$AFTER_IEL" -ne $((BEFORE_IEL + 1)) ]; then
    printf '\nFAIL: expected one new IEL row.\n'
    exit 1
fi

if [ "$AFTER_TURNS" -ne $((BEFORE_TURNS + 1)) ]; then
    printf '\nFAIL: expected one new conversation turn.\n'
    exit 1
fi

NEW_ENTRY="$(
sqlite3 "$DB" \
'SELECT entry_id
 FROM matilda_interpretation_evidence_ledger
 ORDER BY created_at DESC
 LIMIT 1;'
)"

sqlite3 "$DB" <<SQL
.headers on
.mode column

SELECT
    i.entry_id,
    i.project_id,
    i.conversation_id,
    t.turn_id,
    CASE
        WHEN i.matilda_observation = t.assistant_reply
        THEN 'same artifact'
        ELSE 'separate artifacts'
    END AS artifact_boundary
FROM matilda_interpretation_evidence_ledger i
JOIN matilda_conversation_turns t
ON t.interpretation_entry_id=i.entry_id
WHERE i.entry_id='$NEW_ENTRY';
SQL

printf '\nPASS: semantic runtime verified.\n'
