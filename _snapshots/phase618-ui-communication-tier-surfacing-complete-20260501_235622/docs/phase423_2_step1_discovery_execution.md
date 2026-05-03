# Phase 423.2 — Step 1 Discovery Execution (Actual Verification Actions)

## Purpose

Define the exact terminal actions to execute Step 1 discovery.

This converts the discovery plan into deterministic operator actions.

No edits.
No mutation.
Read-only verification only.

---

## Step 1 Execution Procedure

Run these in order.

Do not skip.

---

## Command Group 1 — Phase 423 File Discovery

git show --stat 1d45520a

git show --stat 5dc2be91

Goal:

Identify files introduced by execution introduction.

Record any:

execution
proof
runtime
gate
activation
authorization

related files.

---

## Command Group 2 — Execution Keyword Scan

grep -R "execution" src || true
grep -R "execute" src || true
grep -R "proof" src || true

Goal:

Locate execution entry candidates.

---

## Command Group 3 — Gate Chain Scan

grep -R "eligib" src || true
grep -R "authoriz" src || true
grep -R "activat" src || true
grep -R "approv" src || true
grep -R "govern" src || true

Goal:

Locate gating chain.

---

## Command Group 4 — Direct Handler Discovery

grep -R "run" src || true
grep -R "attempt" src || true
grep -R "handler" src || true

Goal:

Locate handler functions.

---

## Command Group 5 — Alternate Entry Check

grep -R "executeProof" src || true
grep -R "runProof" src || true
grep -R "executionAttempt" src || true

Goal:

Ensure no alternate entrypoints exist.

---

## Required Recording After Search

After running commands, record:

Execution entry file
Execution handler
Governance gate
Activation check
Approval check

Do not interpret.

Only record what exists.

---

## Step 1 Completion Rule

Step completes when:

Entry file identified
Handler identified
Gate chain identified
Single entry confirmed

No guessing allowed.

---

## Next Corridor

Phase 423.2 Step 2 — Gate Ordering Verification

BLOCKED until Step 1 complete.

