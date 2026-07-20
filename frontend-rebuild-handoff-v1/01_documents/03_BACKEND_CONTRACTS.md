# 03 — Backend Contracts

## Purpose

This document defines how the rebuilt frontend should reason about backend information.

It is not a complete API reference.

It identifies which classes of backend information are authoritative, which contracts are confirmed within this packet, which areas remain unresolved, and how the frontend must behave when backend information is incomplete or unavailable.

---

## Backend Truth Model

The backend is authoritative for:

- Authority.
- Permissions.
- Governance state.
- Delegation state.
- Approval state.
- Execution state.
- Lifecycle transitions.
- Agent ownership.
- Recovery state.
- Reconciliation state.
- Outcome-review state.
- Project and lineage relationships.
- Operational health.
- Observability data.

The frontend must not independently synthesize, infer, or promote any of these states into authoritative truth.

---

## Confirmed Contract Included in This Packet

The rebuild packet currently includes:

- `02_reference/backend/contracts/execution-envelope.v1.mjs`

This contract should be treated as authoritative for the fields and relationships it explicitly defines.

It provides confirmed evidence of a governed execution lifecycle involving concepts including:

- Origin and target actors.
- User intent.
- Interpretation.
- Delegation authorization.
- Mutation scope.
- Execution planning.
- Patch specification.
- Validation authority.
- Approval state.
- Sandbox boundaries.
- Rollback.
- Recovery.
- Reconciliation.
- Governance authority.

The existence of a field in this contract confirms that the concept participates in the backend model.

It does not, by itself, prove that the concept requires a dedicated page, route, component, or interaction pattern in the frontend.

---

## Contract Interpretation Rules

Frontend architecture must distinguish among:

- Contract fields that are explicitly defined.
- UI behavior explicitly required by documentation.
- Reasonable architectural proposals.
- Unresolved implementation details.

A backend field must not automatically be translated into a UI screen.

A reusable frontend module must not automatically be treated as evidence of the system's total product scope.

A missing contract must not be interpreted as evidence that the associated backend capability does not exist.

---

## Governed Transitions

The frontend may request authoritative transitions only when supported by explicit backend contracts.

Examples may include:

- Delegation.
- Approval.
- Rejection.
- Cancellation.
- Execution.
- Recovery.
- Reconciliation.
- Outcome acceptance or revision.

For every governed transition:

1. The frontend presents the action from backend-reported state.
2. The frontend submits the request and any required authorization evidence.
3. The backend independently validates authority, lifecycle state, scope, and request validity.
4. The backend accepts or rejects the transition.
5. The frontend reflects the backend response as authoritative.

The frontend must not treat a click, local reducer update, optimistic mutation, or cached permission as proof that an authoritative transition occurred.

---

## Known Unknowns

This packet does not currently define:

- Complete API endpoints.
- Request and response schemas for every domain.
- Authentication mechanisms.
- Authorization evidence format.
- Session or identity model.
- Persistence architecture.
- Streaming transport.
- Polling strategy.
- Retry contracts.
- Idempotency requirements.
- Conflict-resolution behavior.
- Complete error taxonomy.
- Freshness or staleness thresholds.
- Full project-registry contracts.
- Full agent-state contracts.
- Full recovery and reconciliation contracts.
- Full outcome-review contracts.

These items must remain unresolved until explicit documentation or contracts are supplied.

They must not be invented during preliminary architecture work.

---

## Events and Streaming

Some included reference modules use names or shapes that may suggest streamed or event-driven data.

This does not confirm a specific transport.

The frontend must not assume:

- Server-Sent Events.
- WebSockets.
- Long polling.
- Fixed polling intervals.
- Event names.
- Reconnection behavior.
- Replay behavior.
- Ordering guarantees.

The integration boundary should remain transport-independent until the backend contract confirms the mechanism.

---

## Failure and Rejection

Backend rejection is authoritative operational information.

The frontend must:

- Surface the rejection accurately.
- Preserve the distinction between denial, invalid state, transport failure, timeout, and unknown outcome.
- Avoid converting denial into a generic transient error.
- Avoid automatic retries of authoritative transitions unless an explicit retry and idempotency contract permits them.
- Avoid displaying success before backend confirmation.
- Avoid concealing stale or disconnected state.

---

## Data Freshness

The frontend must not infer that cached or previously confirmed state remains current indefinitely.

Where freshness metadata exists, the interface should represent it truthfully.

Where no freshness contract exists, the frontend should preserve the distinction between:

- Confirmed current state.
- Previously confirmed state.
- Stale state.
- Disconnected state.
- Unavailable state.
- Unknown state.

The exact thresholds and behavior remain unresolved until supported by explicit backend contracts.

---

## Prohibited Assumptions

The frontend must not assume that:

- Omitted contracts do not exist.
- Included contracts define the entire backend.
- Included reusable modules define the entire application.
- A contract field necessarily requires its own visual surface.
- Client-side state is authoritative.
- An available button implies backend permission.
- A submitted request implies acceptance.
- A failed response is safe to retry.
- Missing information can be reconstructed from legacy UI behavior.
- Historical frontend implementation is evidence of current backend truth.

---

## Requesting Additional Context

When implementation requires backend information not present in this packet, the collaborator should:

- Identify the exact missing contract.
- Explain which architectural or implementation decision depends on it.
- Request only the specific file, schema, route, event definition, or response example required.
- Avoid requesting the entire repository by default.
- Keep the affected decision explicitly unresolved until evidence is supplied.

---

## Governing Principle

The UI governs affordances and accurately communicates authority.

The backend governs permission and validates every authoritative transition.
