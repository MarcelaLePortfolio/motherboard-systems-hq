import Database from "better-sqlite3";

# Native Database Validation Strategy Finding

## Finding

The repository does not currently have a separate validation strategy for runtime modules that depend on native database bindings.

Existing governance runtime smoke tests and lifecycle integration tests import `better-sqlite3` directly.

At the same time, repository dependency policy explicitly ignores the `better-sqlite3` build script.

## Evidence

`pnpm-workspace.yaml` contains:

```yaml

ignoredBuiltDependencies:

  - better-sqlite3

```

Runtime and smoke surfaces that depend on `better-sqlite3` include:

- `db/governance-runtime.ts`

- `db/governance-lifecycle-persistence.ts`

- `db/governance-lifecycle-integration.ts`

- `db/governance-lifecycle-integration.test.ts`

- `scripts/smoke-governance-package-runtime.mjs`

- `scripts/smoke-governance-delegation-runtime.mjs`

- `scripts/smoke-governance-validation-runtime.mjs`

- `scripts/smoke-governance-envelope-gate-runtime.mjs`

- `scripts/smoke-governance-envelope-runtime.mjs`

## Planning Conclusion

Production Lifecycle Entry Point implementation should not resume until the native database validation strategy is decided.

This is not a lifecycle architecture blocker.

It is a validation infrastructure blocker.

## Decision Required

A future corridor must decide one of the following:

1. Authorize a dependency-policy change allowing `better-sqlite3` native builds.

2. Introduce a test seam that allows lifecycle entry-point validation without importing native persistence at test-load time.

3. Designate a validated environment where native database runtime smokes are expected to execute.

## Scope Boundary

Do not change `pnpm-workspace.yaml` without explicit dependency-policy authorization.

Do not reattempt Production Lifecycle Entry Point implementation using the same validation hypothesis.

Do not treat the blocked validation as evidence against the lifecycle architecture.

## Current Status

Planning remains valid.

Implementation remains reverted.

The next canonical milestone is Native Database Validation Strategy, not Production Lifecycle Entry Point implementation.

