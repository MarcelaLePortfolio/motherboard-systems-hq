# Phase 423.2 — Step 1 Execution Discovery Commands

## Purpose

Provide deterministic search commands to locate the proof execution entrypoint without cognitive overhead.

Read-only inspection only.

No edits.
No mutation.
No execution changes.

---

## Search Block 1 — Direct Execution Terms

Run:

grep -R "execution" src || true
grep -R "execute" src || true
grep -R "proof" src || true
grep -R "runExecution" src || true
grep -R "executionAttempt" src || true

Goal:

Surface all execution-related files.

---

## Search Block 2 — Governance Gate Terms

Run:

grep -R "governance" src || true
grep -R "authorization" src || true
grep -R "eligibility" src || true
grep -R "activation" src || true
grep -R "approval" src || true

Goal:

Locate execution gating logic.

---

## Search Block 3 — Phase 423 Additions

Run:

git show 1d45520a --name-only
git show 5dc2be91 --name-only

Goal:

Identify files introduced during execution introduction.

These are the highest probability entrypoints.

---

## Search Block 4 — Handler Pattern Scan

Run:

grep -R "handler" src || true
grep -R "attempt" src || true
grep -R "gate" src || true

Goal:

Locate possible execution handler functions.

---

## Search Block 5 — Router Safety Check

Run:

grep -R "router" src || true
grep -R "orchestr" src || true
grep -R "taskGraph" src || true

Goal:

Verify execution has not connected to orchestration.

---

## Recording Rule

From results identify:

Execution entry file
Execution handler
Governance gate
Activation check
Approval check

Record only confirmed paths.

---

## Completion Condition

Discovery complete when entrypoint chain is known.

Do not proceed to Step 2 until entrypoint confirmed.

