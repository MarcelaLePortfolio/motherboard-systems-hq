import Database from "better-sqlite3";

# Native Runtime Test Seam Decision

## Decision

The selected native runtime validation strategy is Option 2: Test Seam.

Architectural unit tests should not require native database loading.

Native persistence validation remains separate from architectural behavior validation.

## Rationale

This preserves the existing repository dependency policy while preventing architecture-level tests from being blocked by `better-sqlite3` native binding availability.

The Production Lifecycle Entry Point should be testable as a thin architectural caller without requiring the native persistence module to load at test startup.

## Boundary

This decision does not authorize implementation.

This decision does not authorize:

- dependency policy changes

- `pnpm-workspace.yaml` changes

- endpoint creation

- scheduler integration

- worker integration

- orchestration integration

- schema changes

- lifecycle expansion

- execution behavior

## Next Canonical Milestone

Native Runtime Test Seam Planning.

That corridor should determine the smallest seam that allows architectural lifecycle behavior to be validated without importing native persistence at test-load time.

