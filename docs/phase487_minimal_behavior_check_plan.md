# Phase 487 — Minimal Behavior Check Plan

## Classification
SAFE — Read-only / observational runtime check

## Purpose
Move from structural verification to one tiny behavior confirmation without expanding scope.

## Behavior targets
1. `GET /tasks/recent`
2. `GET /logs/recent`
3. `GET /diagnostics/systemHealth`

## Why these three
They are directly tied to the current operator corridor and are safer to observe than broader runtime mutation.

## Constraint
- No file deletion
- No code mutation
- No git history rewrite
- No Docker work
- No broad type-cleanliness expansion

## Expected outcome
If these endpoints respond, the current corridor is operational enough to continue.
If they fail, we inspect only the failing surface.
