
# Governance Runtime Package Function Contract

Status: PLANNING ONLY

Baseline: 175b66a0

## Proposed function

createGovernancePackage(input)

## Location

Recommended location:

- db/governance-runtime.ts

Reason:

The first runtime surface is DB-only and should not enter routes, UI, execution, or agent runtime yet.

## Required input

- package_id

- package_version

- requested_outcome

- scope

- containment

- constraints

- success_criteria

## Optional input

- context

- style_presentation_intent

- exclusions

## Behavior

The function should:

- validate required inputs

- insert one row into governance_packages

- preserve package_id + package_version identity

- let the database reject duplicate package identity

- return package_id, package_version, and created_at

## Non-behavior

The function must not:

- create Delegation records

- run Governance Validation

- open Envelope Gates

- create Envelopes

- route work

- assign work

- execute work

- trigger agents

- call launch-matilda.mjs

## Implementation status

Not authorized.

