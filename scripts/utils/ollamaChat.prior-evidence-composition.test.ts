import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "Evidence Composition receives validated support references for the prior conclusion",
  async () => {
    const originalFetch = globalThis.fetch;
    let requestBody: Record<string, unknown> | null = null;

    globalThis.fetch = (async (_url, init) => {
      requestBody = JSON.parse(String(init?.body ?? "{}"));

      return {
        ok: true,
        status: 200,
        statusText: "OK",
        json: async () => ({
          response: JSON.stringify({
            reply:
              "The supplied workflow excerpt shows that the workflow invokes ollamaChat through the established semantic seam.",
            explanationStatus: "recommended",
            supportSourceReferences: [
              {
                type: "project_context_excerpt",
                relativePath:
                  "server/matilda-chat-workflow.ts",
                lineNumber: 179,
              },
            ],
            durableInterpretation:
              "The user requested evidence supporting the prior workflow recommendation.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat(
        "What evidence supports that recommendation?",
        {
          priorExplanationEvidenceStatus:
            "sufficient",
          priorExplanationSupportSourceReferences: [
            {
              type: "project_context_excerpt",
              relativePath:
                "server/matilda-chat-workflow.ts",
              lineNumber: 179,
            },
          ],
          projectContextExcerpts: [
            {
              relativePath:
                "server/matilda-chat-workflow.ts",
              lineNumber: 179,
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

      const prompt = String(requestBody?.prompt ?? "");

      assert.match(
        prompt,
        /Validated support references for the immediately preceding eligible conclusion/,
      );

      assert.match(
        prompt,
        /Validated prior support: project_context_excerpt:server\/matilda-chat-workflow\.ts:179/,
      );

      assert.match(
        prompt,
        /compose the evidence from these validated support references/,
      );

      assert.match(
        prompt,
        /Do not treat any other supplied context as evidence for that conclusion unless it appears in this validated list/,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
