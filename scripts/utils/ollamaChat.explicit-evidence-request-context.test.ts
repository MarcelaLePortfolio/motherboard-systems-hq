import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

const suppliedExcerpt =
  "const ollamaResult = await ollamaChat(message, {";

const projectContext = {
  explicitEvidenceRequest: true,
  projectContextExcerpts: [
    {
      relativePath:
        "server/matilda-chat-workflow.ts",
      lineNumber: 155,
      excerpt: suppliedExcerpt,
      provenance:
        "git_tracked_project_file" as const,
      authorityStatus:
        "candidate_evidence_not_authority" as const,
    },
  ],
};

test(
  "explicit evidence request deterministically surfaces supplied project-context evidence",
  async () => {
    const originalFetch = globalThis.fetch;
    let invocationCount = 0;

    globalThis.fetch = (async () => {
      invocationCount += 1;

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply:
              "Repository evidence is available.",
            explanationStatus: "optional",
            supportSourceReferences: [
              {
                type: "conversation_turn",
                sourceTurnId:
                  "turn-evidence-context",
              },
            ],
            evidence: null,
            durableInterpretation:
              "The user explicitly requested repository evidence.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat(
        "Show me the repository evidence.",
        {
          ...projectContext,
          history: [
            {
              sourceTurnId:
                "turn-evidence-context",
              userMessage:
                "Prior question.",
              assistantReply:
                "Prior answer.",
            },
          ],
        },
      );

      assert.equal(invocationCount, 1);

      assert.deepEqual(
        result.evidence,
        {
          sources: [
            {
              reference: {
                type:
                  "project_context_excerpt",
                relativePath:
                  "server/matilda-chat-workflow.ts",
                lineNumber: 155,
              },
              excerpt: suppliedExcerpt,
            },
          ],
        },
      );

      assert.deepEqual(
        result.supportSourceReferences,
        [
          {
            type: "conversation_turn",
            sourceTurnId:
              "turn-evidence-context",
          },
        ],
      );

      assert.equal(
        result.evidenceSufficient,
        true,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "explicit evidence request with no retrieved project context returns null evidence",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          reply:
            "No repository evidence was retrieved.",
          explanationStatus: "optional",
          supportSourceReferences: [],
          evidence: null,
          durableInterpretation:
            "The user requested repository evidence but none was retrieved.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat(
        "Show me the repository evidence.",
        {
          explicitEvidenceRequest: true,
        },
      );

      assert.equal(
        result.evidence,
        null,
      );

      assert.equal(
        result.evidenceSufficient,
        false,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "non-evidence requests retain support-driven Source-Excerpt behavior",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          reply:
            "The workflow invokes ollamaChat.",
          explanationStatus: "optional",
          supportSourceReferences: [
            {
              type:
                "project_context_excerpt",
              relativePath:
                "server/matilda-chat-workflow.ts",
              lineNumber: 155,
            },
          ],
          evidence: null,
          durableInterpretation:
            "Repository support exists.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat(
        "Question.",
        {
          explicitEvidenceRequest: false,
          projectContextExcerpts:
            projectContext.projectContextExcerpts,
        },
      );

      assert.deepEqual(
        result.evidence,
        {
          sources: [
            {
              reference: {
                type:
                  "project_context_excerpt",
                relativePath:
                  "server/matilda-chat-workflow.ts",
                lineNumber: 155,
              },
              excerpt: suppliedExcerpt,
            },
          ],
        },
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
