# Phase 487 — Matilda Route Missing Module Fix

## Classification
DESTRUCTIVE — Safe fallback shim

## Why this is needed
Live probe shows:

Error: Cannot find module './agents/matilda/matilda.mjs'

This blocks:

- POST /matilda
- operator interaction surface

## Strategy
Replace dynamic import with safe fallback handler:

- prevents crash
- preserves route availability
- maintains response contract

## Behavior
Returns:

{
  reply: "[Matilda unavailable — fallback active]"
}

## Impact surface
- server.ts only

## Status
READY
