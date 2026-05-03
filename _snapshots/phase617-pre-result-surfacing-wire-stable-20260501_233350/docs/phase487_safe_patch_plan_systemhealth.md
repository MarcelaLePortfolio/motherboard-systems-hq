# Phase 487 — SAFE Patch Plan (systemHealth)

## Classification
SAFE — Patch planning only (no mutation)

## What we now KNOW (from audit)

### Payload builder returns:
{
  situationSummary: string
}

### Meaning:
- `situationSummaryPayload` is ALWAYS an object
- It is NOT an array
- The deduplication logic is invalid and unnecessary

### Root Cause of Failure
Inside `systemHealth.ts`, this block is illegal:

if (Array.isArray(payload)) { ... }

AND it is incorrectly placed inside `res.json({ ... })`

So:
- Syntax is broken
- Logic is unnecessary
- Payload is already correct shape

## Correct Minimal Fix (Design Only)

We should:
1. REMOVE the array normalization block entirely
2. KEEP payload spread as-is

Target structure:

res.json({
  status: "OK",
  uptime: process.uptime(),
  memory: process.memoryUsage(),
  timestamp: new Date().toISOString(),
  ...situationSummaryPayload
})

## Why this is SAFE (conceptually)

- Matches actual payload contract
- Removes invalid logic
- Restores valid syntax
- Does NOT change data shape
- Does NOT affect downstream consumers

## Next Step

We will:
- generate a minimal patch
- no extra logic
- no restructuring
- no assumptions

## Status
READY — Awaiting approval to generate patch command
