
# Cross-Repository Capability Governance Roadmap

Status: ROADMAP BASELINE

Purpose:

Preserve the implementation sequence and architectural findings discovered after Atlas cross-repository knowledge consumption reconciliation.

---

## Core Finding

Motherboard is evolving from an agent-centric system into a repository-centric governance platform.

Repositories are first-class governance contexts.

Agents operate within repository contexts.

---

## Backend Completion Principle

The backend is complete when it contains its own governed extensibility mechanism.

This means the system can:

- Work inside a selected repository.

- Identify missing or reusable capabilities.

- Route approved capability work through governance.

- Execute cross-repository changes through approved authority.

- Preserve lineage so Atlas can understand what changed and why.

---

## Corridor Sequence

### Corridor 1 — Repository Registry and Active Context

Goal:

Make repositories visible, selectable, and governable as first-class objects.

Tracks:

- Repository identity

- Local path

- Remote URL

- Repository role

- Conversation context

- Development context

- Execution context

---

### Corridor 2 — Capability Recommendation Artifact

Goal:

Allow Cade to identify and document a technical gap or reuse opportunity without creating a Package.

Cade may produce recommendation artifacts.

Cade may not assume Matilda package authority.

---

### Corridor 3 — Matilda Recommendation Review

Goal:

Allow Matilda to transform a Capability Recommendation into the normal user-facing package review workflow.

Matilda owns collaborative review, meaning confirmation, and approval flow.

---

### Corridor 4 — Effie Cross-Repository Execution

Goal:

Allow an approved Package to direct Effie to operate across repository boundaries.

Effie executes approved desktop/repository operations.

Effie does not decide what should be built.

---

### Corridor 5 — Cross-Repository Lineage and Atlas Reconciliation

Goal:

Ensure every cross-repository action emits enough lineage for Atlas to reconstruct the architectural story.

Atlas consumes authoritative metadata and preserves lineage.

Atlas does not govern, execute, validate, or interpret.

---

## Successor Architecture Concepts

Future implementation should account for:

- Repository Registry

- Active Context Registry

- Capability Registry

- Capability Recommendation Registry

- Cross-Repository Directive Registry

- Cross-Repository Lineage Registry

- Promotion Records

- Adoption Records

- Capability Version Records

- Capability Channel Records

- Architectural Knowledge Registry

---

## Promotion and Adoption Distinction

Promotion and adoption are separate decisions.

Promotion asks:

May this capability become available outside its origin repository?

Adoption asks:

Should this repository use this capability?

Both require appropriate user approval.

---

## Capability Channels

Potential capability lifecycle channels:

- Draft

- Internal

- Experimental

- Beta

- Stable

- LTS

- Deprecated

- Retired

Repos may have channel preferences.

A capability may only cross into a repo when capability eligibility, repo preference, and user approval align.

---

## Atlas Consumption Rule

Atlas consumes authoritative state transitions and preserves their lineage.

Atlas consumes metadata by default.

Atlas requests payload access only by exception.

Atlas preserves append-only organizational knowledge history.

---

## Key Authority Boundaries

Cade:

Identifies technical gaps and proposes recommendations.

Matilda:

Owns review, meaning, package presentation, and approval workflow.

Effie:

Executes approved desktop and repository operations.

Atlas:

Preserves lineage, relationship cartography, and organizational knowledge history.

User:

Approves intent, packages, promotion, adoption, and cross-repository execution.

---

## Architectural Principle

Nothing important should have to be rediscovered twice.

Motherboard preserves, governs, and reuses what the organization learns.

