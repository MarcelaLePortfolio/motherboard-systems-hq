
# Governed Response Normalization

## Purpose

Define a canonical deterministic response structure for governed planning routes.

## Required Guarantees

Every governed route response must preserve:

- deterministic shape

- explicit authority state

- explicit governance state

- explicit planning state

- explicit error state

- reconciliation-safe metadata

## Explicit Non-Authority

Response normalization does NOT authorize:

- mutation execution

- shell execution

- autonomous execution

- orchestration authority

## Stabilized Meaning

Governed execution responses now possess a canonical transport format independent of:

- route implementation details

- pipeline internals

- approval gate internals

- Cade planning internals

## Locked Boundary

Clients must not infer execution authority from:

- HTTP success

- governance success

- planning success

- approval gate success

Execution authority remains separately gated.

