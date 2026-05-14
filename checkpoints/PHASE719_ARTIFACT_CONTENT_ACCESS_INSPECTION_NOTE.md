
PHASE 719 ARTIFACT CONTENT ACCESS INSPECTION NOTE

Purpose:

- Determine whether the frontend can already read artifact file contents.

- Preserve current frontend-only rendered preview goal unless inspection proves a read-only content route is required.

Decision rule:

- If artifact content is not reachable by the browser, do not guess.

- Prefer the smallest read-only content route or static mount only after confirming no existing route serves /app/data/artifacts.

- Do not mutate retry, execution, worker, DB schema, or task lifecycle contracts.

