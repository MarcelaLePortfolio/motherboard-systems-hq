import assert from "node:assert/strict";
import test from "node:test";

import { ollamaChat } from "./ollamaChat";

test(
  "ollamaChat preserves the Evidence Composition contract",
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
              "The existing workflow remains the recommendation because the workflow implementation shows the request reaches the established single-invocation seam.",
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
              "The user requested evidence supporting the recommendation.",
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

      assert.match(prompt, /For evidence presentation:/);
      assert.match(prompt, /Present specific supporting evidence only when it materially helps/);
      assert.match(prompt, /Connect each presented evidence point to the claim it supports/);
      assert.match(prompt, /For conversation-turn support, describe only what the supplied prior statement or conclusion actually establishes/);
      assert.match(prompt, /For project-context support, identify the relevant repository artifact and state only the specific fact established by the supplied excerpt/);
      assert.match(prompt, /Present the minimum sufficient evidence needed for the current response/);
      assert.match(prompt, /Do not present provenance metadata/);
      assert.match(prompt, /Do not imply that a source proves more than the supplied evidence establishes/);
      assert.match(prompt, /Evidence presentation must remain part of the natural-language reply and must not become a separate semantic artifact/);
    } finally {
      globalThis.fetch = originalFetch;
    }
  },
);
