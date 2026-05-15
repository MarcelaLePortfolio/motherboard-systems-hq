
# Phase 720: Semantic Artifact Contract Design

## Inspection Findings

The active semantic artifact path is now confirmed:

1. Worker artifact writer:

   - `server/worker/phase26_task_worker.mjs`

   - `persistTaskArtifact({ task, completed, executionResult })`

   - writes markdown files into `MB_ARTIFACT_DIR`

   - returns artifact metadata into `task.completed` payload

2. Artifact preview route:

   - `server/routes/api-tasks-postgres.mjs`

   - `GET /api/tasks/:task_id/artifact-preview`

   - reads the persisted markdown artifact from the shared artifact volume

   - returns read-only preview content

3. Frontend semantic renderer:

   - `public/js/phase530_visible_panels_bridge.js`

   - fetches `/api/tasks/:task_id/artifact-preview`

   - parses markdown headings into semantic sections

   - renders visual semantic cards inline

## Current Contract

Current worker artifact contract is markdown-first.

The frontend expects markdown sections such as:

- Task

- Status

- Summary

- Deliverable

- Details

- Recommendations

- Next Steps

- Outcome

- Explanation

This contract must remain intact.

## Phase 720 Contract Direction

The next safe evolution is additive semantic metadata inside the existing markdown artifact.

Do not create a second artifact type yet.

Do not add DB columns.

Do not change task event structure.

Do not change SSE payload structure.

Do not change the artifact preview route response shape yet.

## Additive Semantic Envelope Proposal

Add a clearly delimited semantic metadata block to the top or bottom of the existing markdown artifact.

Recommended format:

~~~html

<!-- MB_SEMANTIC_ARTIFACT_V1

{

  "artifact_kind": "task_execution_summary",

  "semantic_version": "1.0",

  "task_summary": "",

  "execution_plan": [],

  "actionable_outputs": [],

  "evidence_notes": [],

  "operator_next_steps": [],

  "raw_markdown_fallback": true

}

-->

~~~

## Why HTML Comment Envelope

- Preserves markdown rendering.

- Does not disrupt current frontend section parsing.

- Does not require DB schema changes.

- Does not require route changes.

- Can be ignored safely by old renderers.

- Can later be parsed by frontend or route logic.

- Allows worker-authored semantic metadata without replacing markdown fallback.

## Initial Implementation Boundary

First implementation should only add the comment envelope to worker-generated markdown.

It should not attempt frontend parsing yet.

Success criteria:

- tasks still complete

- artifact file still writes

- preview route still returns content

- existing inline semantic preview still renders

- markdown sections still parse

- no Docker instability

- no task polling regression

## Rollback Boundary

If worker crashes or artifacts fail to generate:

- revert the worker change immediately

- do not patch frontend

- do not patch route

- return to `a3a77d4c`

## Next Safe Mutation

Patch only `server/worker/phase26_task_worker.mjs` to prepend or append a semantic comment envelope to generated markdown content.

