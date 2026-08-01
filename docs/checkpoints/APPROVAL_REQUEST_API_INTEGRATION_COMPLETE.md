# Approval Request API Integration Completion

- Branch: `feature/new-ui-shell`
- Protected commit: `4753574c`
- Status: Committed and pushed

## Verified Outcomes

- Approval Request repository test passed.
- Approval Request assembler tests passed.
- Approval Request API tests passed.
- Missing `project_id` returns HTTP 400.
- Project-scoped pending Approval Requests return successfully.
- Approval Request route is mounted at `/api/approval-requests`.
- Semantic drift guard passed.
- Integration commit was pushed to `origin/feature/new-ui-shell`.

## TypeScript Validation Note

The temporary scoped TypeScript configuration failed with:

`TS2688: Cannot find type definition file for 'node'`

The temporary configuration was located outside the repository and did not resolve the repository's Node type definitions correctly.

The generated validation command did not use `set -e`, so execution continued after that failure.

The following corridor validations passed:

- repository runtime test
- assembler runtime tests
- API runtime tests
- route registration check
- semantic drift guard

The unrelated full-repository TypeScript error previously observed in `routes/atlas/why.ts` remains outside the Approval Request corridor.

No claim is made that a repository-wide TypeScript check passed.

## Stable Backend Pipeline

Living Draft Package

↓

Approval Request Repository

↓

Approval Request Read Model

↓

Approval Request Assembler

↓

Approval Request API

↓

Mounted Active Route

## Authority Boundary

This corridor remains read-only.

It introduces:

- no new persistence
- no approval execution
- no Canonical Package mutation
- no Preview confirmation
- no Execution Authorization
- no Request Changes
- no notification routing
- no mutation, shell, or autonomous execution authority

## Next Canonical Corridor

Implement the typed Approval Request client.

The next slice should use the repository's existing client TypeScript and production-build commands rather than another temporary root TypeScript configuration.
