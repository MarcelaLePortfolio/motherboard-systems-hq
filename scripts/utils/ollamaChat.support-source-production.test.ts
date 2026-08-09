import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat instructs the semantic invocation to produce bounded support provenance",
  async () => {
    const originalFetch = globalThis.fetch;
    let invocationCount = 0;
    let requestBody: Record<string, any> | null = null;

    globalThis.fetch = (async (_url, init) => {
      invocationCount += 1;

      requestBody = JSON.parse(
        String(init?.body ?? "{}"),
      ) as Record<string, any>;

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply:
              "Preserving the current workflow preserves the established invariant.",
            explanationStatus: "optional",
            selectedContextSegments: [],
            supportSourceReferences: [
              {
                type: "conversation_turn",
                sourceTurnId: "turn-123",
              },
              {
                type: "project_context_excerpt",
                relativePath:
                  "server/matilda-chat-workflow.ts",
                lineNumber: 155,
              },
            ],
            evidence: null,
            durableInterpretation:
              "The user is evaluating which approach preserves the established workflow invariant.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat(
        "Which approach preserves the invariant?",
        {
          history: [
            {
              sourceTurnId: "turn-123",
              userMessage:
                "The workflow has one Ollama invocation.",
              assistantReply:
                "That is the established Conversation Engine invariant.",
            },
          ],
          projectContextExcerpts: [
            {
              relativePath:
                "server/matilda-chat-workflow.ts",
              lineNumber: 155,
              excerpt:
                "const ollamaResult = await ollamaChat(message, {",
              provenance:
                "git_tracked_project_file",
              authorityStatus:
                "candidate_evidence_not_authority",
            },
          ],
        },
      );

      assert.equal(invocationCount, 1);

      const prompt = String(requestBody?.prompt ?? "");

      assert.match(
        prompt,
        /Set supportSourceReferences to only the supplied conversation turns or parent project-context excerpts that explicitly support/,
      );

      assert.match(
        prompt,
        /For conversation support, use type conversation_turn with the exact Conversation source identifier supplied in history/,
      );

      assert.match(
        prompt,
        /For project-context support, use type project_context_excerpt with the exact relativePath and lineNumber supplied/,
      );

      assert.match(
        prompt,
        /Return an empty supportSourceReferences array when no supplied source explicitly supports/,
      );

      assert.match(
        prompt,
        /Do not invent, reconstruct, approximate, or reference a source identifier that was not supplied/,
      );

      assert.match(
        prompt,
        /Conversation source: turn-123/,
      );

      assert.match(
        prompt,
        /Source: server\/matilda-chat-workflow\.ts:155/,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
