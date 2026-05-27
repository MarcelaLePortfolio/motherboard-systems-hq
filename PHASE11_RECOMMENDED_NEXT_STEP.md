
# Phase 11 – Recommended Next Step

## Recommendation

Proceed with **Phase 11 dashboard bundling and reliability work** before touching any new Phase (including 11.5 DB Task Storage or Phase 12).

Rationale:

* The **core Phase 11 goal** has always been:

  * Dashboard visuals,
  * JS/CSS bundling,
  * Layout and reload reliability.
* DB-backed task storage is now:

  * Isolated,
  * Documented in `PHASE11_DB_ENDPOINTS_STATUS.md`,
  * Explicitly deferred in `PHASE11_NEXT_STEPS_RECOMMENDATION.md`.
* Continuing Phase 11 on the **front-end/dashboard track**:

  * Moves you closer to a demo-ready system,
  * Keeps scope clean,
  * Avoids another multi-layer backend debugging loop,
  * Respects your energy and phase-discipline rules.

In other words:

> The next best move is to finish what Phase 11 originally promised:
> a visually coherent, bundled, and reliable dashboard
> running on stable stubbed endpoints.

## What “Continue Phase 11 Bundling Work” Means

When you resume Phase 11 dashboard work, the focus should be:

### 1. JS/CSS Bundling

Goal: Move from scattered script tags to a coherent bundle, without breaking behavior.

High-level steps (for a future session, not now):

* Identify all JS entrypoints currently used by the dashboard:

  * Matilda chat console
  * Task delegation panel
  * Agent status tiles
  * Reflections/OPS SSE hooks
  * Any dashboard-only helpers
* Decide on a bundling strategy:

  * Single main dashboard bundle (preferred),
  * Or a very small number of clearly separated bundles (e.g. core + optional extras).
* Update the HTML template that powers the dashboard (the one used in the container) to:

  * Replace multiple `<script>` tags with a single bundled asset reference.
* Verify that:

  * Matilda chat still sends and receives messages,
  * Delegation UI still works against stubbed endpoints,
  * Agent statuses still update,
  * Reflections/OPS streams still appear in their panels.

### 2. Dashboard Reload & Stability

Goal: A hard reload of `http://127.0.0.1:8080` feels solid and predictable.

When you reload:

* Matilda chat console should reconnect cleanly.
* SSE streams (Reflections + OPS) should auto-reconnect without manual intervention.
* Agent tiles should accurately reflect online/offline.
* No duplicated event listeners or duplicate messages in the console.

### 3. Layout & Visual Integrity

Goal: The dashboard is visually clean and aligned with your expectations for demos.

Checks to perform:

* Left column:

  * Matilda chat console card
  * Key metrics (if present)
  * Task delegation panel
  * Atlas / status tiles
* Right column:

  * Project Visual Output viewport
  * Any alignment rules previously documented
* Structural checks:

  * No duplicates,
  * No overlapping cards,
  * Grid is clean and legible at your typical screen size.

### 4. Phase 11 Tag & Handoff

Once bundling + reload stability + layout are verified:

* Create a tag for this stable dashboard baseline, for example:

  * `v11.1-dashboard-bundled-stable`
* Update your Phase 11 handoff / overview docs to record:

  * That dashboard bundling is complete,
  * That DB-backed endpoints remain deferred by design and documented as such.

## When To Revisit DB Work

Only return to DB-backed task storage when:

* You explicitly start a new mini-phase:

  * e.g., `Phase 11.5 – DB Task Storage`, and
* You’re ready to:

  * Align `DATABASE_URL` / pool configuration,
  * Decide which database owns the schema (`dashboard_db` vs `motherboarddb`),
  * Create migrations / DDL for:

    * `agent_status`,
    * Any `tasks` / `delegations` tables the code expects.

Until then, keep DB-backed endpoints mentally and technically parked.

## Simple Resume Prompt for Next Session

When you’re ready to pick this up in a new thread, you can say:

> “Continue Phase 11 dashboard bundling and reliability work from PHASE11_RECOMMENDED_NEXT_STEP.md.”

and proceed directly into the bundling/reliability tasks without re-opening DB complexity.
