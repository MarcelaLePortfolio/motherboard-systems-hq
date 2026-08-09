import assert from "node:assert/strict";
import test from "node:test";

import {
  ollamaChat,
  type MatildaSelectedContextSegment,
} from "./ollamaChat";

const originalFetch = globalThis.fetch;

function installResponse(
  structuredResponse: Record<string, unknown>,
): void {
  globalThis.fetch = async () =>
    new Response(
      JSON.stringify({
        response: JSON.stringify(structuredResponse),
      }),
      {
        status: 200,
        headers: {
          "content-type": "application/json",
        },
      },
    );
}

test.afterEach(() => {
  globalThis.fetch = originalFetch;
});

function baseResponse(
  selectedContextSegments: unknown[],
  supportSourceReferences: unknown[] = [],
) {
  return {
    reply: "The relevant implementation behavior is supported.",
    explanationStatus: "optional",
    selectedContextSegments,
    supportSourceReferences,
    evidence: null,
    durableInterpretation:
      "The relevant implementation behavior is supported.",
  };
}

const suppliedCandidate = {
  relativePath: "docs/adaptive-detail.md",
  parentRelativePath: "docs/adaptive-detail.md",
  parentLineNumber: 10,
  sourceStartLine: 10,
  sourceEndLine: 12,
  text: "Relevant implementation behavior.",
};

test(
  "normal production-style invocation remains valid without an observer",
  async () => {
    installResponse(
      baseResponse([
        {
          relativePath: suppliedCandidate.relativePath,
          sourceStartLine: suppliedCandidate.sourceStartLine,
          sourceEndLine: suppliedCandidate.sourceEndLine,
        },
      ]),
    );

    const result = await ollamaChat("Question.", {
      projectContextSegmentCandidates: [
        suppliedCandidate,
      ],
    });

    assert.equal(
      result.reply,
      "The relevant implementation behavior is supported.",
    );

    assert.equal(
      "selectedContextSegments" in result,
      false,
    );
  },
);

test(
  "observer receives only validated deterministically deduplicated selections",
  async () => {
    const identity = {
      relativePath: suppliedCandidate.relativePath,
      sourceStartLine: suppliedCandidate.sourceStartLine,
      sourceEndLine: suppliedCandidate.sourceEndLine,
    };

    installResponse(
      baseResponse([
        identity,
        identity,
      ]),
    );

    let observed:
      readonly MatildaSelectedContextSegment[] | undefined;

    await ollamaChat("Question.", {
      projectContextSegmentCandidates: [
        suppliedCandidate,
      ],
      observeValidatedSelectedContextSegments:
        (segments) => {
          observed = segments;
        },
    });

    assert.deepEqual(
      observed,
      [identity],
    );
  },
);

test(
  "invented selection fails before observer invocation",
  async () => {
    installResponse(
      baseResponse([
        {
          relativePath: "docs/invented.md",
          sourceStartLine: 99,
          sourceEndLine: 101,
        },
      ]),
    );

    let observerCalled = false;

    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          projectContextSegmentCandidates: [
            suppliedCandidate,
          ],
          observeValidatedSelectedContextSegments:
            () => {
              observerCalled = true;
            },
        }),
      /selected context segment that was not supplied/,
    );

    assert.equal(observerCalled, false);
  },
);

test(
  "parent support inconsistency fails before observer invocation",
  async () => {
    installResponse(
      baseResponse(
        [],
        [
          {
            type: "project_context_excerpt",
            relativePath: "docs/adaptive-detail.md",
            lineNumber: 10,
          },
        ],
      ),
    );

    let observerCalled = false;

    await assert.rejects(
      () =>
        ollamaChat("Question.", {
          projectContextExcerpts: [
            {
              relativePath: "docs/adaptive-detail.md",
              lineNumber: 10,
              excerpt:
                "Relevant implementation behavior.",
              provenance:
                "git_tracked_project_file",
              authorityStatus:
                "candidate_evidence_not_authority",
            },
          ],
          projectContextSegmentCandidates: [
            suppliedCandidate,
          ],
          observeValidatedSelectedContextSegments:
            () => {
              observerCalled = true;
            },
        }),
      /project-context support without selecting a supplied child segment/,
    );

    assert.equal(observerCalled, false);
  },
);
