import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

const suppliedExcerpt =
  "const ollamaResult = await ollamaChat(message, {";

const projectContext = {
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
  "runtime constructs exact Source-Excerpt evidence from validated project-context support",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          investigationLifecycle: null,
          reply:
            "The workflow invokes ollamaChat.",
          explanationStatus: "optional",
          selectedContextSegments: [],
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
            "Repository evidence establishes the workflow invocation seam.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat(
        "What repository evidence shows that this workflow invokes ollamaChat?",
        projectContext,
      );

      assert.deepEqual(result.evidence, {
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
      });
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "model-owned evidence selection is not required for Source-Excerpt construction",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          investigationLifecycle: null,
          reply:
            "The workflow invokes ollamaChat.",
          explanationStatus: "optional",
          selectedContextSegments: [],
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
            "Repository support is available.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat(
        "Question.",
        projectContext,
      );

      assert.equal(
        result.evidence?.sources.length,
        1,
      );
      assert.equal(
        result.evidence?.sources[0].excerpt,
        suppliedExcerpt,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "conversation support does not create Source-Excerpt evidence",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          investigationLifecycle: null,
          reply:
            "The prior conversation supports this.",
          explanationStatus: "optional",
          selectedContextSegments: [],
          supportSourceReferences: [
            {
              type: "conversation_turn",
              sourceTurnId:
                "turn-support-driven-evidence-1",
            },
          ],
          evidence: null,
          durableInterpretation:
            "Prior conversation support exists.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      const result = await ollamaChat(
        "Question.",
        {
          history: [
            {
              sourceTurnId:
                "turn-support-driven-evidence-1",
              userMessage:
                "Prior question.",
              assistantReply:
                "Prior answer.",
            },
          ],
        },
      );

      assert.equal(result.evidence, null);
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
  "duplicate project-context support references produce one Source-Excerpt source",
  async () => {
    const originalFetch = globalThis.fetch;

    const reference = {
      type:
        "project_context_excerpt",
      relativePath:
        "server/matilda-chat-workflow.ts",
      lineNumber: 155,
    };

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          investigationLifecycle: null,
          reply:
            "The workflow invokes ollamaChat.",
          explanationStatus: "optional",
          selectedContextSegments: [],
          supportSourceReferences: [
            reference,
            reference,
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
        projectContext,
      );

      assert.equal(
        result.supportSourceReferences.length,
        1,
      );
      assert.equal(
        result.evidence?.sources.length,
        1,
      );
      assert.equal(
        result.evidence?.sources[0].excerpt,
        suppliedExcerpt,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);

test(
  "empty validated support produces null evidence",
  async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () => ({
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        response: JSON.stringify({
          investigationLifecycle: null,
          reply: "No supported conclusion.",
          explanationStatus: "optional",
          selectedContextSegments: [],
          supportSourceReferences: [],
          evidence: null,
          durableInterpretation:
            "No supporting source was selected.",
        }),
      }),
    })) as typeof globalThis.fetch;

    try {
      const result =
        await ollamaChat("Question.");

      assert.equal(result.evidence, null);
      assert.equal(
        result.evidenceSufficient,
        false,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
