# Phase 487 — better-sqlite3 Build Script Audit

## Classification
SAFE — Read-only, bounded environment/build audit

## Purpose
The native rebuild did not produce the required binding file.

Before any further mutation, inspect only:

1. whether the binding file exists anywhere after rebuild
2. whether pnpm is suppressing native build scripts
3. whether build tools needed for native compilation are present
4. whether the package's install/build scripts look normal

## Status
READY
