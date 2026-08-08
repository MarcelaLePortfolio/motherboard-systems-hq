#!/usr/bin/env bash
set -euo pipefail

echo "=== SUPPORT REFERENCE CONTRACT GAP — CONFIRMATION ==="

cat <<'FINDING'
CONFIRMED

Repository evidence demonstrates:

MatildaConversationTurn.turn_id
        ↓
MatildaConversationHistoryContextTurn.sourceTurnId
        ↓
MatildaSelectedHistoryTurn.sourceTurnId

Therefore stable conversation-source identifiers already exist.

However, ollamaChat() currently serializes only:

- userMessage
- assistantReply

The sourceTurnId is discarded before the semantic invocation.

Classification:

SMALL INPUT CONTRACT GAP

This is not a missing subsystem.
This is not a missing semantic capability.
This is not a missing workflow seam.

The existing workflow already owns the identifiers required for deterministic
validation.

The remaining architectural change is simply to expose bounded source identities
to the semantic invocation so that future structured support references can be
validated against the exact supplied context.

No additional semantic author is required.
No second Ollama invocation is required.
No Explanation Invitation classifier is required.
No Attention Management Runtime is required.

NEXT CANONICAL CORRIDOR

Design the minimal response-contract extension that allows the existing semantic
invocation to return bounded supportSourceReferences tied only to supplied
conversation turns and project-context excerpts.

Do not implement the contract yet.
FINDING

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
