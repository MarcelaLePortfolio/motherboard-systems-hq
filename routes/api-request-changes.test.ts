import assert from "node:assert/strict";
import test from "node:test";

import {
  createRequestChangesHandler,
} from "./api-request-changes";

function createResponse() {
  let statusCode = 200;
  let body: unknown = null;

  return {
    response: {
      status(code: number) {
        statusCode = code;
        return this;
      },
      json(value: unknown) {
        body = value;
        return this;
      },
    } as any,
    read() {
      return {
        statusCode,
        body,
      };
    },
  };
}

function createRepository(
  source: any | null,
) {
  let closed = false;

  return {
    listPendingCanonicalPackageApprovalsByProject() {
      return source ? [source] : [];
    },
    getPendingCanonicalPackageApprovalById() {
      return source;
    },
    getPendingCanonicalPackageApprovalByDraftPackageId() {
      return source;
    },
    close() {
      closed = true;
    },
    isClosed() {
      return closed;
    },
  };
}

const source = {
  draft_package_id:
    "matilda-draft-originating-conversation",
  lineage_id:
    "matilda-lineage-originating-conversation",
  project_id: "hq",
  conversation_id: "originating-conversation",
  current_interpretation: "Current interpretation",
  proposed_work: null,
  proposed_artifacts: null,
  in_scope: null,
  out_of_scope: null,
  constraints: null,
  expected_outcome: "Validated expected outcome",
  unresolved_questions: null,
  evidence_entry_ids: "[]",
  source_draft_status: "draft_non_authoritative",
  created_at: "2026-08-30T00:00:00.000Z",
  updated_at: "2026-08-30T00:00:00.000Z",
};

test(
  "Request Changes rejects empty feedback before workflow invocation",
  async () => {
    let workflowCalls = 0;
    const repository = createRepository(source);

    const handler = createRequestChangesHandler({
      createRepository: () => repository as any,
      runWorkflow: async () => {
        workflowCalls += 1;
        throw new Error("workflow must not run");
      },
    });

    const result = createResponse();

    await handler(
      {
        body: {
          approval_request_id:
            "canonical_package_approval:matilda-draft-originating-conversation",
          feedback: "   ",
        },
      } as any,
      result.response,
    );

    assert.equal(result.read().statusCode, 400);
    assert.equal(workflowCalls, 0);
    assert.equal(repository.isClosed(), false);
  },
);

test(
  "Request Changes rejects unknown pending approval before workflow invocation",
  async () => {
    let workflowCalls = 0;
    const repository = createRepository(null);

    const handler = createRequestChangesHandler({
      createRepository: () => repository as any,
      runWorkflow: async () => {
        workflowCalls += 1;
        throw new Error("workflow must not run");
      },
    });

    const result = createResponse();

    await handler(
      {
        body: {
          approval_request_id:
            "canonical_package_approval:unknown-draft",
          feedback: "Please revise this.",
        },
      } as any,
      result.response,
    );

    assert.equal(result.read().statusCode, 404);
    assert.equal(workflowCalls, 0);
    assert.equal(repository.isClosed(), true);
  },
);

test(
  "Request Changes rejects a pending approval without an originating conversation",
  async () => {
    let workflowCalls = 0;
    const repository = createRepository({
      ...source,
      conversation_id: null,
    });

    const handler = createRequestChangesHandler({
      createRepository: () => repository as any,
      runWorkflow: async () => {
        workflowCalls += 1;
        throw new Error("workflow must not run");
      },
    });

    const result = createResponse();

    await handler(
      {
        body: {
          approval_request_id:
            "canonical_package_approval:matilda-draft-originating-conversation",
          feedback: "Please revise this.",
        },
      } as any,
      result.response,
    );

    assert.equal(result.read().statusCode, 409);
    assert.equal(workflowCalls, 0);
    assert.equal(repository.isClosed(), true);
  },
);

test(
  "Request Changes resolves authoritative project and conversation identities without trusting client authority",
  async () => {
    const calls: any[] = [];
    const repository = createRepository(source);

    const handler = createRequestChangesHandler({
      createRepository: () => repository as any,
      runWorkflow: async (input) => {
        calls.push(input);

        return {
          ok: true,
          reply: "Revision processed.",
          turn: {} as any,
          draft_package_updated: true,
          canonical_package_created: false,
          delegation_authorized: false,
          validation_authorized: false,
          envelope_authorized: false,
          execution_authorized: false,
        } as any;
      },
    });

    const result = createResponse();

    await handler(
      {
        body: {
          approval_request_id:
            "canonical_package_approval:matilda-draft-originating-conversation",
          feedback: " Please revise this. ",
          project_id: "untrusted-project",
          conversation_id: "untrusted-conversation",
        },
      } as any,
      result.response,
    );

    assert.equal(result.read().statusCode, 200);
    assert.equal(calls.length, 1);
    assert.deepEqual(calls[0], {
      message: "Please revise this.",
      agent: "matilda",
      project_id: "hq",
      conversation_id: "originating-conversation",
      userPackageSemantics: null,
      requirePackageSemantics: true,
    });
    assert.equal(repository.isClosed(), true);

    const body = result.read().body as any;
    assert.equal(body.canonical_package_created, false);
    assert.equal(body.delegation_authorized, false);
    assert.equal(body.validation_authorized, false);
    assert.equal(body.envelope_authorized, false);
    assert.equal(body.execution_authorized, false);
  },
);


test(
  "Request Changes transports explicit typed user package semantics without expanding client authority",
  async () => {
    const calls: any[] = [];
    const repository = createRepository(source);

    const handler = createRequestChangesHandler({
      createRepository: () => repository as any,
      runWorkflow: async (input) => {
        calls.push(input);

        return {
          ok: true,
          reply: "Revision processed.",
          turn: {} as any,
          draft_package_updated: true,
          canonical_package_created: false,
          delegation_authorized: false,
          validation_authorized: false,
          envelope_authorized: false,
          execution_authorized: false,
        } as any;
      },
    });

    const result = createResponse();

    await handler(
      {
        body: {
          approval_request_id:
            "canonical_package_approval:matilda-draft-originating-conversation",
          feedback: "Please revise this.",
          project_id: "untrusted-project",
          conversation_id: "untrusted-conversation",
          user_package_semantics: {
            expectedOutcome:
              "  Preserve this exact expected outcome.  ",
            inScope:
              "  Preserve this exact in-scope value.  ",
          },
        },
      } as any,
      result.response,
    );

    assert.equal(result.read().statusCode, 200);
    assert.equal(calls.length, 1);
    assert.deepEqual(calls[0], {
      message: "Please revise this.",
      agent: "matilda",
      project_id: "hq",
      conversation_id: "originating-conversation",
      userPackageSemantics: {
        expectedOutcome:
          "Preserve this exact expected outcome.",
        inScope:
          "Preserve this exact in-scope value.",
      },
      requirePackageSemantics: true,
    });
    assert.equal(repository.isClosed(), true);
  },
);

test(
  "Request Changes rejects malformed typed user package semantics before repository or workflow access",
  async () => {
    let repositoryCalls = 0;
    let workflowCalls = 0;

    const handler = createRequestChangesHandler({
      createRepository: () => {
        repositoryCalls += 1;
        return createRepository(source) as any;
      },
      runWorkflow: async () => {
        workflowCalls += 1;
        throw new Error("workflow must not run");
      },
    });

    const result = createResponse();

    await handler(
      {
        body: {
          approval_request_id:
            "canonical_package_approval:matilda-draft-originating-conversation",
          feedback: "Please revise this.",
          user_package_semantics: {
            expectedOutcome: "   ",
          },
        },
      } as any,
      result.response,
    );

    assert.equal(result.read().statusCode, 400);
    assert.equal(repositoryCalls, 0);
    assert.equal(workflowCalls, 0);
  },
);
