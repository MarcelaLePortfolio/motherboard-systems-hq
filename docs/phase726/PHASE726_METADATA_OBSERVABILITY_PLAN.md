
# Phase 726 Metadata Observability Plan

## Purpose

Define the next safe corridor after successful worker-side semantic metadata propagation.

This corridor is read-only observability only.

## Current Stable Baseline

Current HEAD:

`61c6dd92`

Confirmed stable:

- worker-side semantic metadata propagation

- artifact-scoped semantic metadata

- top-level task payload containment

- artifact preview compatibility

- Docker runtime health

- semantic helper suite passing

- failed validator-script corridor reverted

- manual validation protocol documented

## Observability Goal

Expose semantic metadata in a way that helps operators and developers inspect artifact intelligence without allowing semantic metadata to control rendering yet.

## Strict Boundaries

Do not mutate:

- artifact preview renderer

- artifact markdown content

- artifact preview route behavior

- database schema

- task event schema

- SSE event shape

- retry architecture

- task polling behavior

## Allowed Work

Allowed:

- documentation

- read-only inspection commands

- local terminal probes

- developer-only debug docs

- non-authoritative observability notes

- metadata interpretation utilities that are not wired into runtime

## Deferred Work

Deferred:

- semantic-driven rendering

- Preview UI mutation

- artifact card redesign

- schema-authoritative frontend behavior

- semantic payload expansion beyond artifact object

- database persistence expansion

## Recommended Next Step

Create a read-only artifact metadata inspection guide that uses existing `/api/tasks` output to inspect:

- artifact semantic schema

- artifact semantic intent

- artifact kind

- visual artifact flag

- validation status

- top-level leakage absence

