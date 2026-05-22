
# Preview Semantic Propagation Boundary

Status: VERIFIED

Corridor: READ-ONLY RUNTIME INSPECTION

## Confirmed Route Behavior

Authoritative file:

- server/routes/api-tasks-postgres.mjs

## `/api/tasks` behavior

The dashboard task list route selects:

- completed.payload->>'outcome_preview' AS outcome_preview

- completed.payload->>'explanation_preview' AS explanation_preview

- completed.payload->'artifact' AS artifact

- completed.payload->'artifacts' AS artifacts

- completed.payload AS guidance

This means the task list route can expose the full completed payload through `guidance`.

## `/api/tasks/:task_id/artifact-preview` behavior

The artifact Preview route selects only:

- completed.payload->'artifact' AS artifact

- completed.payload->'artifacts' AS artifacts

Then it resolves the artifact file path, reads the markdown file, and returns:

- ok

- task_id

- artifact metadata

- content

## Confirmed Boundary

The Preview route does NOT currently return the full completed payload.

It does NOT return:

- guidance

- outcome_preview

- explanation_preview

- semantic_artifact from completed payload

- artifact semantic metadata beyond file metadata

Instead, Preview receives raw artifact file content and the frontend renderer reconstructs sections from markdown.

## Architectural Meaning

Current runtime Preview lifecycle is markdown-file-driven.

Semantic continuity is not authoritatively propagated through the Preview route.

The frontend renderer bridge reconstructs display sections client-side from markdown content.

## Key Runtime Discovery

Semantic artifact structure exists adjacent to runtime lifecycle, but is not yet transported authoritatively through the `/artifact-preview` route.

## Constraint

No route mutation was performed.

No renderer mutation was performed.

No Preview runtime mutation was performed.

## Next Safe Direction

Before changing runtime behavior, inspect whether the full completed payload should be exposed through a separate read-only diagnostic route or whether `/artifact-preview` should remain minimal and a new semantic-preview inspection route should be introduced.

