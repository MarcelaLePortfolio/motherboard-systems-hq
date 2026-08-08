import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "Evidence Composition grounds claims in supplied sources",
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
              "The supplied workflow excerpt shows that the workflow invokes ollamaChat through the existing semantic seam. The supplied evidence does not establish broader claims about performance or development speed.",
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
              "The user requested evidence supporting the workflow recommendation.",
          }),
        }),
      } as Response;
    }) as typeof globalThis.fetch;

    try {
      await ollamaChat(
        "What evidence supports preserving the workflow?",
        {
          priorExplanationEvidenceStatus: "sufficient",
          history: [
            {
              sourceTurnId: "turn-evidence-validation-1",
              userMessage:
                "Which implementation approach should we use?",
              assistantReply:
                "I recommend preserving the existing single-invocation workflow.",
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
        /compose the evidence portion of the reply only from conversation turns and project-context excerpts supplied in this invocation/,
      );

      assert.match(
        prompt,
        /identify which supplied source actually establishes that claim/,
      );

      assert.match(
        prompt,
        /the supplied evidence does not establish the claim/,
      );

      assert.match(
        prompt,
        /do not treat a prior assistant claim as independent proof of itself/,
      );

      assert.match(
        prompt,
        /Prefer project-context evidence over repeating a prior assistant conclusion/,
      );

      assert.match(
        prompt,
        /Do not invent design priorities, motivations, benefits, risks, performance claims, or architectural properties/,
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
