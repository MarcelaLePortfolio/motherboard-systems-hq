# Executive Decision Classification

Status: Reconciled working draft — implementation not yet authorized.

## Purpose

This document classifies which executive decisions are currently authoritative, which are implemented but transient, and which are absent.

The classification governs what the first Approval Request read model may safely expose.

---

# 1. Approve Canonical Package

Decision identifier:

approve_canonical_package

Classification:

- authoritative
- mounted in the active server
- persisted
- project-scoped
- completion is authoritative

Command:

POST /api/matilda/canonical-package

Authoritative source:

- Living Draft Package
- Reconciled Intent Summary

Completion object:

- Canonical Package

Completion condition:

Canonical Package exists for the Living Draft Package.

Executive question:

Should this Living Draft Package become the authoritative Canonical Package?

Status:

Available for the first Approval Request read model.

---

# 2. Confirm Preview

Decision identifier:

confirm_preview

Classification:

- runtime exists
- route exists
- route not mounted
- preview not authoritative
- confirmation not persisted

Executive question:

Does this Preview accurately represent the intended execution?

Status:

Deferred.

Must not appear as an executable Approval Request until Preview becomes authoritative.

---

# 3. Authorize Execution

Decision identifier:

authorize_execution

Classification:

- runtime exists
- route exists
- not mounted
- intentionally unreachable
- execution remains disabled

Executive question:

May the system execute this approved Preview?

Status:

Deferred.

Must not appear until execution authority becomes active.

---

# 4. Request Changes

Decision identifier:

request_changes

Repository evidence:

No authoritative runtime found.

No route found.

No persistence found.

Status:

Architectural only.

Requires its own reconciliation corridor.

---

# 5. Reject

Repository evidence:

No executive rejection runtime found.

Status:

Not currently implemented.

---

# 6. Defer

Repository evidence:

No executive defer runtime found.

Status:

Not currently implemented.

---

# 7. Cancel

Repository evidence:

Task cancellation exists.

Executive Approval cancellation does not.

Status:

Not currently implemented.

---

# 8. Escalate

Repository evidence:

Safety validation prevents execution escalation.

No executive escalation decision exists.

Status:

Not currently implemented.

---

# First Approval Request Decision Catalog

The initial Approval Request repository should expose exactly one authoritative executive decision:

approve_canonical_package

No other executive decision is yet authoritative.

---

# First Approval Request Scope

The first read model should derive pending approval requests from:

- Living Draft Package
- Reconciled Intent Summary
- project ownership
- absence of a Canonical Package

Deterministic request identity:

canonical_package_approval:<draft_package_id>

Status:

pending

Executive question:

Should this Living Draft Package become the authoritative Canonical Package?

Available decision:

approve_canonical_package

---

# Architectural Boundary

Approval Requests expose decisions.

They do not own decisions.

Decision authority remains inside the corresponding runtime.

Approval Requests remain projections over authoritative runtime state.

---

# Next Canonical Corridor

Implement a read-only Approval Request Repository.

Scope:

- repository
- repository tests
- read model
- assembler
- API
- API tests
- typed client
- provider
- hook
- Approvals workspace

Explicitly deferred:

- Request Changes
- Preview approval
- Execution authorization
- Notifications
- Mutation authority
- Decision execution wiring
