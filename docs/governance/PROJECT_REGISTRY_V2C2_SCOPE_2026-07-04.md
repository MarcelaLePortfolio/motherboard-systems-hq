
# Project Registry V2-C.2 Scope

Date: 2026-07-04

## Corridor

Project Registry V2-C.2 — Project Lifecycle Management

## Objective

Complete the core lifecycle operations for registered projects while preserving the backend-authoritative governance model established in V2-A through V2-C.1.

## In Scope

The corridor will be completed incrementally in the following order:

1. Archive / Unregister Project

2. Project Metadata Editor

3. New Project workflow

Each milestone will be independently validated before proceeding to the next.

## Current Milestone

Archive / Unregister Project

## Success Criteria

The operator can remove or archive a registered project through the dashboard.

The operation must:

- preserve backend authority

- preserve Active Context rules

- preserve registry integrity

- preserve duplicate detection

- preserve Project Registry validation

## Out of Scope

This corridor does not include:

- Cross-repository execution

- Organizational Event runtime

- Atlas runtime expansion

- Registry normalization

- Desktop packaging

- Desktop branding

- Commercial Motherboard implementation

## Rollback Anchor

HEAD: b7969171

Desktop foundation and native folder picker remain the stable implementation baseline.

