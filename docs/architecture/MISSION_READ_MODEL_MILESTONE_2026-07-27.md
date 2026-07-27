Mission Read Model Pipeline Milestone
------------------------------------
Commit: aefd4bde

Verified:
  ✓ Mission Read Repository validated against the live governance schema.
  ✓ Repository correctly joins lifecycle events through envelope_id.
  ✓ project_id remains null until authoritative persistence exists.
  ✓ Mission Read Model assembler successfully consumes repository output.
  ✓ End-to-end Mission Read Model integration test passes.

Current architecture:
  SQLite
      ↓
  Mission Read Repository
      ↓
  Mission Read Model Assembler
      ↓
  Mission Read Model

Next corridor (recommended):
  Implement a read-only Mission Read API that exposes the assembled Mission Read Model without introducing any UI changes.
