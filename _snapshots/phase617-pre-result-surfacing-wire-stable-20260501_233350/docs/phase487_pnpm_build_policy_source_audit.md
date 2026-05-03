# Phase 487 — pnpm Build Policy Source Audit

## Classification
SAFE — Read-only, bounded configuration audit

## Purpose
The latest audit showed that `better-sqlite3` is present in pnpm's ignored built dependencies signal.

Before changing pnpm behavior, identify exactly where that policy is coming from.

## Audit questions
1. Is `better-sqlite3` listed in a local `.npmrc` or workspace config?
2. Is there a project-level pnpm config causing native builds to be skipped?
3. Is the next move a config correction rather than another rebuild attempt?

## Status
READY
