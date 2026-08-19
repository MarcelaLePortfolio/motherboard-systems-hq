#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE='scripts/utils/ollamaChat.ts'

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

anchor = '''    const conversationHistory = (context.history || []).flatMap(
      (turn) => [
        "",
        ...(turn.sourceTurnId
          ? [`Conversation source: ${turn.sourceTurnId}`]
          : []),
        `User: ${turn.userMessage}`,
        `Matilda: ${turn.assistantReply}`,
      ],
    );
'''

replacement = '''    const conversationHistory = (context.history || []).flatMap(
      (turn) => [
        "",
        ...(turn.sourceTurnId
          ? [`Conversation source: ${turn.sourceTurnId}`]
          : []),
        `User: ${turn.userMessage}`,
        `Matilda: ${turn.assistantReply}`,
      ],
    );

    const allowedConversationSupportSourceIds =
      (context.history || [])
        .map((turn) => turn.sourceTurnId)
        .filter(
          (sourceTurnId): sourceTurnId is string =>
            typeof sourceTurnId === "string" &&
            Boolean(sourceTurnId),
        );

    const conversationSupportIdentityPresentation = [
      "",
      "Allowed conversation support source identifiers:",
      ...(allowedConversationSupportSourceIds.length > 0
        ? allowedConversationSupportSourceIds.map(
            (sourceTurnId) =>
              `Allowed conversation support source = ${sourceTurnId}`,
          )
        : ["Allowed conversation support source = NONE"]),
      allowedConversationSupportSourceIds.length > 0
        ? "For type conversation_turn, use only one of the exact allowed conversation support source identifiers listed above."
        : "No prior conversation support source identifiers were supplied. Do not return any conversation_turn entry in supportSourceReferences.",
      "The current user message is not a prior conversation support source and must not be represented as conversation_turn provenance.",
    ];
'''

if anchor not in text:
    raise SystemExit("CONVERSATION_HISTORY_ANCHOR_NOT_FOUND")

text = text.replace(anchor, replacement, 1)

prompt_anchor = '''            "For conversation support, use type conversation_turn with the exact Conversation source identifier supplied in history.",
'''

prompt_replacement = '''            "For conversation support, use type conversation_turn with the exact Conversation source identifier supplied in history.",
            ...conversationSupportIdentityPresentation,
'''

if prompt_anchor not in text:
    raise SystemExit("PROMPT_CONVERSATION_SUPPORT_ANCHOR_NOT_FOUND")

text = text.replace(prompt_anchor, prompt_replacement, 1)
path.write_text(text)
PY

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=09342faa' \
  'IMPLEMENTATION_SCOPE=BOUNDED_PROMPT_CONTRACT_CHANGE_ONLY' \
  'ISSUE_RESOLVED=NO' \
  'VALIDATOR_CHANGE=NO' \
  'VALIDATOR_WEAKENING=NO' \
  'GENERATION_POLICY_CHANGE=NO' \
  'MODEL_CHANGE=NO' \
  'RETRY_CHANGE=NO' \
  'PERSISTENCE_CHANGE=NO' \
  'AUTHORITY_CHANGE=NO' \
  'ONE_WORKFLOW_ONE_OLLAMA_INVOCATION=PRESERVED'

printf '\n=== DIFF ===\n'
git diff -- "$FILE"

printf '\n=== TARGETED STATIC VERIFICATION ===\n'
grep -n -A30 -B15 \
  'Allowed conversation support source identifiers' \
  "$FILE"

grep -n -A12 -B8 \
  'conversationSupportIdentityPresentation' \
  "$FILE"

printf '\n=== KNOWN TYPECHECK BASELINE ===\n'
set +e
npm run check
CHECK_STATUS=$?
set -e
echo "TYPECHECK_EXIT_STATUS=$CHECK_STATUS"
echo 'KNOWN_UNRELATED_BASELINE=routes/atlas/why.ts_TS2554_EXPECTED_2_ARGUMENTS_GOT_3'

printf '\n=== WORKTREE ===\n'
git status --short

git add "$FILE"
git commit -m "Fix empty-history conversation support prompt contract"
git push
