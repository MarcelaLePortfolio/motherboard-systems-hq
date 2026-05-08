
PHASE 717 DIRECTION ESTABLISHED

Phase 716 remains sealed at:

- HEAD: 5ed96de9

- Tag: phase716-renderer-containment-verified

Architectural clarification reached after live runtime observation:

- Recent Tasks has effectively become the primary execution evidence surface.

- Execution Inspector responsibilities are already partially merged into Recent Tasks via renderer/evidence payload behavior.

- Retry/requeue actions should migrate directly into Recent Tasks task cards.

- Task History and dashboard Execution Inspector are now considered likely redundant surfaces.

- Static execution evidence should be preserved as a lightweight modal/button/read-only snapshot instead of a primary dashboard panel.

Phase 717 objective corridor:

1. Expand Recent Tasks into authoritative execution lifecycle surface.

2. Add retry/requeue controls directly to task cards.

3. Reassess/remove redundant Task History + Execution Inspector panels.

4. Preserve static execution evidence in secondary audit form.

5. Avoid broad CSS/layout experimentation.

6. Continue renderer-scoped modifications only.

Current system state remains:

- Runtime healthy

- Repository clean

- Docker healthy

- External backups verified

- Safe continuation corridor established

