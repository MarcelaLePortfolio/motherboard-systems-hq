# 05 — Repository Boundaries

## Purpose

This rebuild kit is intentionally curated.

It is not a complete repository snapshot.

Its purpose is to provide sufficient architectural context for frontend redesign while avoiding dependence on historical implementation details.

The absence of a file from this packet should never be interpreted as evidence that the corresponding capability does not exist within the broader system.

---

## Included

This rebuild kit intentionally includes:

- Architectural overview.
- Frontend objectives.
- Backend architectural guidance.
- Architectural invariants.
- Repository boundary guidance.
- Representative backend contract(s).
- Representative reusable frontend modules.

These materials are intended to establish architectural understanding rather than reproduce the production repository.

---

## Intentionally Excluded

This rebuild kit intentionally excludes:

- Legacy dashboard implementations.
- Historical frontend layouts.
- Archived experiments.
- Compatibility layers.
- Snapshots.
- Backup artifacts.
- Previous UI iterations.
- Obsolete implementations.
- Repository history not required for frontend redesign.

These exclusions are intentional.

They should not be reconstructed unless explicitly requested.

---

## Interpretation Rules

Collaborators should distinguish between:

- Included reference material.
- Confirmed architectural requirements.
- Confirmed backend contracts.
- Unresolved implementation details.
- Intentionally omitted repository content.

The rebuild kit is designed to minimize historical implementation bias.

Its purpose is to encourage architecture-driven design rather than legacy-driven reconstruction.

---

## Prohibited Inferences

Do not assume that:

- The included reusable modules define the complete application.
- The included backend contract defines the complete backend.
- Omitted files represent deleted capabilities.
- Missing documentation implies missing functionality.
- Historical UI behavior defines future architecture.
- Legacy implementation should be reproduced.

---

## Requesting Additional Repository Context

If implementation requires additional information:

1. Identify the specific missing artifact.
2. Explain why it is required.
3. Request only the smallest amount of additional repository context necessary.
4. Keep architectural conclusions explicitly provisional until supporting evidence is supplied.

Avoid requesting the complete repository unless no narrower request can satisfy the need.

---

## Preferred Engineering Behavior

Collaborators should:

- Read the architecture documents before implementation.
- Distinguish confirmed, inferred, proposed, and unresolved information.
- Preserve backend authority boundaries.
- Preserve architectural invariants.
- Request evidence before making assumptions.
- Prefer reusable reference modules over unnecessary rewrites.
- Explain uncertainty rather than concealing it.

---

## Governing Principle

This rebuild kit is intended to communicate architecture, not repository history.

Successful collaboration should be driven by confirmed architectural intent rather than reverse-engineering omitted implementation details.
