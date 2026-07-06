
/*

Matilda Delegation Runtime

Corridor:

Canonical Package

→ Explicit Delegation

→ Pending Governance Validation

Responsibilities:

1. Persist explicit delegations.

2. Reference an existing Canonical Package.

3. Preserve immutable lineage.

4. Record delegation metadata.

5. Transition only to Pending Governance Validation.

Delegation fields:

- delegation_id

- package_id

- lineage_id

- delegated_by

- delegation_target

- authorization_state

- authorization_timestamp

- status

- created_at

Required invariants:

Creating a Delegation MUST NOT:

- complete Governance Validation

- create an Envelope

- authorize routing

- authorize assignment

- authorize Cade execution

Authority Boundary:

Only explicit operator delegation may create a Delegation.

Delegation authorizes governance processing only.

Execution authority remains in later corridors.

*/

