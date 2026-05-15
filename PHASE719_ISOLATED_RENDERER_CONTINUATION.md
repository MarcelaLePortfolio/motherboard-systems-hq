
# PHASE 719 — ISOLATED EMBEDDED RENDERING CONTINUATION

## CURRENT AUTHORITATIVE BASELINE

The system is currently paused at a stable embedded iframe/srcdoc rendering boundary.

Authoritative stable checkpoint:

`79252310`

Current branch:

`phase719-artifact-visibility`

Runtime status:

- Dashboard healthy

- Worker healthy

- Postgres healthy

- API routes operational

- SSE pipeline active

- Shared artifact volume verified

- Read-only artifact preview route verified

- Preview modal operational

- iframe/srcdoc rendering operational

- Retry/requeue architecture preserved

- Worker artifact contract preserved

- No DB schema changes introduced

## CONTINUATION RULE

Proceed only through the isolated frontend rendering corridor.

Do not resume worker-side HTML artifact mutation.

Do not mutate artifact persistence contracts.

Do not introduce artifact metadata schema changes in this step.

Do not modify retry/requeue behavior.

Do not modify execution routing.

## SAFE OBJECTIVE

Refine the embedded artifact preview renderer without altering execution infrastructure.

The current artifact pipeline remains:

markdown artifact

→ preview route returns persisted content

→ frontend visual renderer transforms markdown into card-style HTML

→ iframe/srcdoc isolates rendered preview

→ modal displays embedded artifact representation

## IMPORTANT BOUNDARY

The displayed preview is frontend-generated HTML derived from markdown.

It is not native worker-authored HTML.

It is not a true persisted HTML artifact contract.

That distinction must remain explicit in future handoffs and implementation notes.

## NEXT SAFE IMPLEMENTATION TARGET

Improve only the client-side embedded preview surface.

Permitted refinement areas:

- iframe height behavior

- modal scroll containment

- preview card spacing

- rendered heading hierarchy

- safer srcdoc template construction

- empty/error preview state clarity

- visual polish inside iframe only

- renderer adapter cleanup if currently duplicated or brittle

Forbidden areas:

- worker artifact generation mutation

- direct task execution changes

- retry/requeue contract changes

- database schema changes

- artifact persistence format changes

- speculative helper-script patching

- broad CSS mutation outside the preview/modal corridor

## FAILURE DISCIPLINE

If a renderer refinement fails:

1. Revert the specific frontend change.

2. Do not layer speculative fixes.

3. Preserve stable runtime before trying again.

4. Stop after three failed attempts for the same hypothesis.

5. Return to checkpoint discipline before changing approach.

## VALIDATION CHECKLIST

After any frontend-only renderer refinement:

```bash

docker compose ps

curl -s http://localhost:3000/ | head

curl -s http://localhost:3000/api/tasks | head

git status --short
