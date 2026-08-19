#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE='server/matilda-chat-workflow.ts'

python3 - << 'PY'
from pathlib import Path

path = Path("server/matilda-chat-workflow.ts")
text = path.read_text()

old = '''  } catch (workflowError) {
    console.error(
      "[Matilda conversation workflow] Conversational response failed:",
      workflowError,
    );

    throw new MatildaConversationWorkflowUnavailableError();
  }
}
'''

new = '''  } catch (workflowError) {
    console.error(
      "[Matilda conversation workflow] Conversational response failed:",
      workflowError,
    );

    console.error(
      "[Matilda conversation workflow] Diagnostic failure details:",
      workflowError instanceof Error
        ? {
            name: workflowError.name,
            message: workflowError.message,
            stack: workflowError.stack,
          }
        : {
            value: String(workflowError),
          },
    );

    throw new MatildaConversationWorkflowUnavailableError();
  }
}
'''

if old not in text:
    raise SystemExit("EXPECTED_CATCH_BOUNDARY_NOT_FOUND")

path.write_text(text.replace(old, new, 1))
PY

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=ba0595d3' \
  'CHANGE_CLASS=BOUNDED_DIAGNOSTIC_LOGGING_ONLY' \
  'HTTP_RESPONSE_CHANGE=NO' \
  'VALIDATION_CHANGE=NO' \
  'GENERATION_POLICY_CHANGE=NO' \
  'PERSISTENCE_CHANGE=NO' \
  'AUTHORITY_CHANGE=NO'

printf '\n=== DIFF ===\n'
git diff -- "$FILE"

printf '\n=== TYPECHECK ===\n'
npm run check

printf '\n=== WORKTREE ===\n'
git status --short

git add "$FILE"
git commit -m "Add bounded Matilda 503 diagnostic logging"
git push
