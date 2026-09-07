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
            packageSemantics: null,
          investigationLifecycle: null,
            reply:
              "Preserving the current workflow preserves the established invariant.",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [0],
            supportSourceReferences: [
              {
                type: "conversation_turn",
                sourceTurnId: "turn-123",
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
          projectContextSegmentCandidates: [
            {
              relativePath: "server/matilda-chat-workflow.ts",
              parentRelativePath: "server/matilda-chat-workflow.ts",
              parentLineNumber: 155,
              sourceStartLine: 155,
              sourceEndLine: 155,
              text: "const ollamaResult = await ollamaChat(message, {",
            },
          ],
        },
      );

      assert.equal(invocationCount, 1);

      const prompt = String(requestBody?.prompt ?? "");

      assert.match(
        prompt,
        /Set supportSourceReferences to only supplied conversation turns that explicitly support/,
      );

      assert.match(
        prompt,
        /For conversation support, use type conversation_turn with the exact Conversation source identifier supplied in history/,
      );

      assert.match(
        prompt,
        /selectedContextCandidatePositions records semantic project-context admission\. Project-context child identity and parent support provenance are reconstructed deterministically by runtime from validated candidate positions/,
      );

      assert.match(
        prompt,
        /Do not return project_context_excerpt entries in supportSourceReferences/,
      );

      assert.match(
        prompt,
        /Return an empty supportSourceReferences array when no supplied conversation turn explicitly supports/,
      );

      assert.match(
        prompt,
        /Do not invent, reconstruct, approximate, or reference a conversation source identifier that was not supplied in this invocation/,
      );

      assert.match(
        prompt,
        /Allowed conversation support source = turn-123/,
      );

      assert.match(
        prompt,
        /relativePath = server\/matilda-chat-workflow\.ts/,
      );

      assert.match(
        prompt,
        /lineNumber = 155/,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat presents NONE when no prior conversation support identities exist",
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
            investigationLifecycle: null,
            packageSemantics: null,
            reply: "No prior conversation support is available.",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [],
            supportSourceReferences: [],
            evidence: null,
            durableInterpretation:
              "No durable user semantics were established in this turn.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat(
        "Answer using only support actually available in this invocation.",
      );

      assert.equal(invocationCount, 1);

      const prompt = String(requestBody?.prompt ?? "");

      assert.match(
        prompt,
        /Allowed conversation support source = NONE/,
      );

      assert.match(
        prompt,
        /No prior conversation support source identifiers were supplied\. Do not return any conversation_turn entry in supportSourceReferences\./,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "ollamaChat excludes the current user message from conversation-turn support identity",
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
            investigationLifecycle: null,
            packageSemantics: null,
            reply: "The prior turn supports the response.",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [],
            supportSourceReferences: [
              {
                type: "conversation_turn",
                sourceTurnId: "turn-prior-123",
              },
            ],
            evidence: null,
            durableInterpretation:
              "The prior conversation establishes support for the response.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat(
        "This is the current user message and is not prior conversation provenance.",
        {
          history: [
            {
              sourceTurnId: "turn-prior-123",
              userMessage: "Prior user message.",
              assistantReply: "Prior assistant reply.",
            },
          ],
        },
      );

      assert.equal(invocationCount, 1);

      const prompt = String(requestBody?.prompt ?? "");

      assert.match(
        prompt,
        /The current user message is not a prior conversation support source and must not be represented as conversation_turn provenance\./,
      );

      const allowedIdentityLines = prompt
        .split("\n")
        .filter((line) =>
          line.startsWith(
            "Allowed conversation support source = ",
          ),
        );

      assert.deepEqual(
        allowedIdentityLines,
        [
          "Allowed conversation support source = turn-prior-123",
        ],
      );

      assert.match(
        prompt,
        /Conversation source: turn-prior-123/,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
