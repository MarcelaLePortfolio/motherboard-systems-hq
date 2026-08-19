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
