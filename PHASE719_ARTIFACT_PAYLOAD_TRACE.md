
# PHASE 719 — ARTIFACT PAYLOAD TRACE

## PURPOSE

Trace where the preview renderer receives its artifact payload and determine why only generic execution-summary content is available.

## CURRENT FINDING

Artifact preview renderer is functioning correctly.

The iframe receives valid HTML and renders successfully.

The rendered content is generic because the underlying artifact payload itself is generic.

## NEXT INVESTIGATION

Trace:

- `/api/artifacts/:task_id`

- task artifact persistence payload

- artifact JSON shape

- worker-produced artifact body

- preview renderer mapping logic

Goal:

Determine whether:

1. worker never generated richer artifact content

2. artifact persistence truncated content

3. renderer ignores richer fields already present

## SAFETY

Read-only inspection only.

No schema mutation.

No renderer mutation.

No worker mutation.

