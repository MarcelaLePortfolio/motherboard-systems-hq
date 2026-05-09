
# Phase 717 Compact Recent Tasks Seal

Sealed checkpoint:

- HEAD: b536b7d0

- Commit: Phase 717: validate compact recent tasks renderer

Validated state:

- dashboard responds from localhost:3000

- dashboard references js/phase530_visible_panels_bridge.js

- compact Recent Tasks markers exist

- inline advanced JSON label removed from active Recent Tasks renderer

- Requeue control remains active

- Retry differently control remains active

- retry handler remains present

- Docker dashboard, worker, and Postgres remain healthy

Architecture preserved:

- Recent Tasks is now more lifecycle/action-oriented

- detailed evidence is pointed toward read-only audit/evidence surfaces

- /execution-evidence.html remains secondary read-only forensic review surface

- Recent Logs remains secondary telemetry/debug surface

- no broad CSS changes

- no execution coupling

- no chat coupling

- no retry contract changes

- no schema changes

Next safe corridor:

- visually confirm compact Recent Tasks cards in browser

- keep Recent Logs as the telemetry surface

- evaluate Task History and Execution Inspector only after Recent Tasks + Recent Logs roles are confirmed stable

- run external backup after this stable checkpoint

