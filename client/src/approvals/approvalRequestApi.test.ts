import assert from "node:assert/strict";
import test from "node:test";

import {
  requestChanges,
  type ApprovalRequestCollection,
} from "./approvalRequestApi";

test("ApprovalRequestCollection typing", () => {
  const collection: ApprovalRequestCollection = {
    project_id: "hq",
    requests: [],
  };

  assert.equal(collection.project_id, "hq");
  assert.deepEqual(collection.requests, []);
});

test(
  "requestChanges sends only approval_request_id and feedback",
  async () => {
    const originalFetch = globalThis.fetch;
    const calls: Array<{
      input: string;
      init: RequestInit | undefined;
    }> = [];

    globalThis.fetch = (async (
      input: string | URL | Request,
      init?: RequestInit,
    ) => {
      calls.push({
        input: String(input),
        init,
      });

      return new Response(
        JSON.stringify({
          ok: true,
          route: "request_changes_route",
          result: {
            canonical_package_created: false,
            delegation_authorized: false,
            validation_authorized: false,
            envelope_authorized: false,
            execution_authorized: false,
          },
          canonical_package_created: false,
          delegation_authorized: false,
          validation_authorized: false,
          envelope_authorized: false,
          execution_authorized: false,
        }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }) as typeof fetch;

    try {
      await requestChanges(
        " canonical_package_approval:draft-1 ",
        " Please revise the expected outcome. ",
      );
    } finally {
      globalThis.fetch = originalFetch;
    }

    assert.equal(calls.length, 1);
    assert.equal(
      calls[0]?.input,
      "/api/request-changes",
    );
    assert.equal(calls[0]?.init?.method, "POST");

    const body = JSON.parse(
      String(calls[0]?.init?.body),
    );

    assert.deepEqual(body, {
      approval_request_id: "canonical_package_approval:draft-1",
      feedback: "Please revise the expected outcome.",
    });
    assert.deepEqual(
      Object.keys(body).sort(),
      ["approval_request_id", "feedback"],
    );
  },
);


test(
  "requestChanges sends explicit typed user package semantics when supplied",
  async () => {
    const originalFetch = globalThis.fetch;
    const calls: Array<{
      input: string;
      init: RequestInit | undefined;
    }> = [];

    globalThis.fetch = (async (
      input: string | URL | Request,
      init?: RequestInit,
    ) => {
      calls.push({
        input: String(input),
        init,
      });

      return new Response(
        JSON.stringify({
          ok: true,
          route: "request_changes_route",
          result: {
            canonical_package_created: false,
            delegation_authorized: false,
            validation_authorized: false,
            envelope_authorized: false,
            execution_authorized: false,
          },
          canonical_package_created: false,
          delegation_authorized: false,
          validation_authorized: false,
          envelope_authorized: false,
          execution_authorized: false,
        }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }) as typeof fetch;

    try {
      await requestChanges(
        " canonical_package_approval:draft-1 ",
        " Please revise the expected outcome. ",
        {
          expectedOutcome:
            "Preserve this exact expected outcome.",
          proposedWork:
            "Preserve this exact proposed work.",
          proposedArtifacts:
            "Preserve these exact deliverables.",
          inScope:
            "Preserve this exact in-scope value.",
          outOfScope:
            "Preserve this exact out-of-scope value.",
          constraints:
            "Preserve these exact constraints.",
          unresolvedQuestions:
            "Preserve these exact open questions.",
        },
      );
    } finally {
      globalThis.fetch = originalFetch;
    }

    assert.equal(calls.length, 1);
    assert.equal(
      calls[0]?.input,
      "/api/request-changes",
    );
    assert.equal(calls[0]?.init?.method, "POST");

    const body = JSON.parse(
      String(calls[0]?.init?.body),
    );

    assert.deepEqual(body, {
      approval_request_id: "canonical_package_approval:draft-1",
      feedback: "Please revise the expected outcome.",
      user_package_semantics: {
        expectedOutcome:
          "Preserve this exact expected outcome.",
        proposedWork:
          "Preserve this exact proposed work.",
        proposedArtifacts:
          "Preserve these exact deliverables.",
        inScope:
          "Preserve this exact in-scope value.",
        outOfScope:
          "Preserve this exact out-of-scope value.",
        constraints:
          "Preserve these exact constraints.",
        unresolvedQuestions:
          "Preserve these exact open questions.",
      },
    });

    assert.deepEqual(
      Object.keys(body).sort(),
      [
        "approval_request_id",
        "feedback",
        "user_package_semantics",
      ],
    );
  },
);
