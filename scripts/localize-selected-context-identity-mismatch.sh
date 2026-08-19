#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=99dc7c07' \
  'MODE=COLLABORATION_DIAGNOSTIC' \
  'ISSUE_RESOLVED=NO' \
  'CURRENT_FAILURE=SELECTED_CONTEXT_SEGMENT_NOT_SUPPLIED' \
  'FIX_AUTHORIZED=NO' \
  'TARGET=CAPTURE_EXACT_SUPPLIED_AND_MODEL_AUTHORED_SELECTED_CONTEXT_IDENTITIES'

printf '\n=== EXISTING OBSERVER CONTRACT ===\n'
grep -n -A18 -B12 \
  'observeParsedSelectedContextSegments' \
  scripts/utils/ollamaChat.ts

printf '\n=== LIVE PROJECT CONTEXT RETRIEVAL SURFACE ===\n'
sed -n '400,525p' server/matilda-project-context-retrieval.ts

printf '\n=== CONTEXT COMPOSITION SURFACE ===\n'
sed -n '35,115p' server/matilda-conversation-context-runtime.ts

printf '\n=== EXISTING SINGLE-SEGMENT DIAGNOSTIC PATTERN ===\n'
sed -n '1,180p' \
  scripts/run-phase-3-corridor-2-single-selected-context-diagnostic.ts \
  2>/dev/null || true

cat > scripts/diagnose-live-selected-context-identities.ts << 'TS'
import {
  retrieveMatildaProjectContext,
} from "../server/matilda-project-context-retrieval";
import {
  composeMatildaConversationContext,
} from "../server/matilda-conversation-context-runtime";
import {
  listMatildaConversationTurns,
} from "../db/matilda-conversation-runtime";
import {
  ollamaChat,
} from "./utils/ollamaChat";

async function main(): Promise<void> {
  const projectId = "hq";
  const conversationId =
    "matilda-conversation-hq-1787159584712-q6x7o3";
  const message =
    "Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing. Each workstream should show an owner, current status, next milestone, and blocker. Do not execute or delegate anything; help me define the request first.";

  const projectContextRetrieval =
    retrieveMatildaProjectContext({
      projectId,
      projectRootPath: process.cwd(),
      message,
    });

  const turns =
    listMatildaConversationTurns(
      projectId,
      20,
      conversationId,
    );

  const conversationContext =
    composeMatildaConversationContext({
      turns,
      projectContextRetrieval,
      interpretationLifecycleEntries: [],
    });

  const supplied =
    conversationContext.projectContextSegmentCandidates.map(
      (segment) => ({
        relativePath: segment.relativePath,
        sourceStartLine: segment.sourceStartLine,
        sourceEndLine: segment.sourceEndLine,
        identity:
          `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`,
      }),
    );

  let parsed: unknown[] = [];

  console.log(
    JSON.stringify(
      {
        SUPPLIED_SEGMENT_COUNT: supplied.length,
        SUPPLIED_SEGMENTS: supplied,
      },
      null,
      2,
    ),
  );

  try {
    await ollamaChat(message, {
      projectId,
      projectDisplayName: "Motherboard Systems HQ",
      history: conversationContext.selectedHistory,
      projectContextExcerpts:
        conversationContext.projectContextExcerpts,
      projectContextSegmentCandidates:
        conversationContext.projectContextSegmentCandidates,
      projectContextWarning:
        conversationContext.projectContextWarning,
      observeParsedSelectedContextSegments: (segments) => {
        parsed = [...segments];

        console.log(
          JSON.stringify(
            {
              MODEL_PARSED_SELECTED_CONTEXT_SEGMENTS:
                segments.map((segment) => ({
                  ...segment,
                  identity:
                    `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`,
                })),
            },
            null,
            2,
          ),
        );
      },
    });

    console.log("OLLAMA_CHAT_RESULT=PASS");
  } catch (error) {
    console.error(
      "OLLAMA_CHAT_RESULT=FAIL",
      error instanceof Error
        ? error.message
        : String(error),
    );

    const suppliedIdentities =
      new Set(supplied.map((item) => item.identity));

    const parsedWithIdentity =
      parsed.map((segment: any) => ({
        ...segment,
        identity:
          `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`,
      }));

    console.log(
      JSON.stringify(
        {
          UNSUPPLIED_MODEL_IDENTITIES:
            parsedWithIdentity.filter(
              (segment) =>
                !suppliedIdentities.has(segment.identity),
            ),
        },
        null,
        2,
      ),
    );

    process.exitCode = 1;
  }
}

void main();
TS

printf '\n=== RUN EXACT IDENTITY DIAGNOSTIC ===\n'
set +e
npx tsx scripts/diagnose-live-selected-context-identities.ts
DIAGNOSTIC_STATUS=$?
set -e
echo "DIAGNOSTIC_EXIT_STATUS=$DIAGNOSTIC_STATUS"

printf '\n=== CLASSIFICATION ===\n'
printf '%s\n' \
  'VALIDATOR_CHANGE=NO' \
  'VALIDATOR_WEAKENING=NO' \
  'GENERATION_POLICY_CHANGE=NO' \
  'SECOND_FIX_AUTHORIZED=NO' \
  'NEXT_ACTION=COMPARE_UNSUPPLIED_MODEL_IDENTITIES_TO_SUPPLIED_SEGMENT_IDENTITIES_FROM_OUTPUT'

printf '\n=== WORKTREE ===\n'
git status --short
