# Cade Mutation-Scope Guard Hardening — Closed

**Date:** 2026-10-29
**Status:** CLOSED — IMPLEMENTED, TESTED, COMMITTED, AND PUSHED
**Resolution commit:** `998c6ba0b`
**Branch:** `feature/support-source-references-runtime`

## Purpose

Preserve the verified resolution of the mutation-scope path-boundary defect so future "what's next?" investigations do not incorrectly classify this completed work as an outstanding MVP task.

## Original Finding

Read-only investigation identified three incorrect behaviors in `server/guards/mutation-scope-guard.mjs`:

1. A permitted filename also permitted a different filename sharing its prefix.
2. A permitted directory also permitted a sibling directory sharing its prefix.
3. A forbidden directory incorrectly blocked a permitted sibling directory sharing its prefix.

The original implementation used string-prefix matching rather than path-component-aware containment.

These were verified defects in the guard's path classification. The investigation did not establish an active production filesystem exploit.

## Authorized Resolution

An isolated guard-hardening corridor was explicitly authorized.

The implementation:

- Replaced string-prefix matching with path-component-aware containment using `path.relative`.
- Preserved forbidden-path precedence.
- Rejected empty paths, NUL-containing paths, and invalid scope-list types.
- Added dedicated automated tests for authorized files, sibling-prefix collisions, directory containment, traversal, forbidden paths, invalid inputs, and envelope-based scope enforcement.

Changed files:

- `server/guards/mutation-scope-guard.mjs`
- `server/guards/mutation-scope-guard.test.mjs`

No other files were included in the resolution commit.

## Verification Evidence

The isolated test command:

`node --test server/guards/mutation-scope-guard.test.mjs`

Result: **11 passed, 0 failed**.

Additional observed evidence:

- Semantic drift guard passed.
- Commit `998c6ba0b` created successfully.
- Commit pushed successfully to `origin/feature/support-source-references-runtime`.
- The two authorized files were clean after the push.
- The original baseline remained preserved.

## Scope and Authority Boundaries

This resolution did **not**:

- Enable live Cade filesystem mutation.
- Enable Cade shell execution or autonomous execution.
- Grant new governance authority.
- Activate a governed edit/test executor.
- Close Ellis Stage 3.

The guard now addresses the demonstrated lexical path-prefix defects. This result must **not** be represented as proof of filesystem-level containment against symbolic links, canonical project-root escapes, or other untested filesystem behaviors.

## Current Project Classification

- Mutation-scope guard prefix-collision repair: **RESOLVED — CLOSED**.
- Dedicated mutation-scope guard regression tests: **IMPLEMENTED — PASSING**.
- Governed Cade editing and testing: **NOT ACTIVATED**.
- Self-improvement Phase 3: **CLOSED**.
- Self-improvement Phase 4: **CLOSED**.
- Ellis Stage 3 hardware trust validation: **OPEN**.

## Instructions for Future "What's Next?" Investigations

Treat this specific guard-hardening corridor as completed work.

Do not reopen the three resolved prefix-collision defects merely because earlier investigation notes describe them as open.

If evaluating a future governed Cade mutation capability, independently assess the remaining filesystem containment, symlink, canonical-root, delegation, approval, rollback, and reconciliation requirements. Those concerns are not certified by this isolated repair.

Do not infer authorization to implement, activate, or expand governed mutation from this closure record.

**Final determination:** The demonstrated mutation-scope prefix-matching defect is resolved and must not be carried forward as an outstanding MVP task.
