
# Phase 724 Create Route Inspection

## Objective

Inspect `/api/tasks/create` before patching input normalization.

## Target File

`server/routes/api-tasks-postgres.mjs`

## Target Lines

Create route around lines 219–290.

## Goal

Confirm the safest place to normalize incoming task text before insert.

## Scope

Inspection only.

