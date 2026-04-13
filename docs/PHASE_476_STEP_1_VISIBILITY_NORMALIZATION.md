PHASE 476 — STEP 1
VISIBILITY NORMALIZATION SURFACE

OBJECTIVE

Convert the current visibility output into a structured, deterministic summary
that can act as a stable contract for future operator interfaces.

This does NOT change execution behavior.
This does NOT introduce UI.
This is a read-only normalization layer.

────────────────────────────────

OUTPUT TARGET

docs/visibility_normalized_latest.json

────────────────────────────────

STRUCTURE

{
  "intake": {
    "intakeId": "",
    "status": "SUCCESS | FAILURE"
  },
  "governance": {
    "decision": "APPROVED | REJECTED",
    "decisionId": ""
  },
  "approval": {
    "status": "APPROVED | REJECTED | SKIPPED",
    "approvalId": ""
  },
  "execution": {
    "status": "SUCCEEDED | BLOCKED",
    "output": ""
  },
  "failure": {
    "stage": "entry_validation | governance | approval | none",
    "error": ""
  }
}

────────────────────────────────

INVARIANTS

• derived only from existing artifacts
• no mutation of pipeline
• deterministic output for same artifact set
• reflects latest run state only
• safe for replay

────────────────────────────────

SUCCESS CRITERIA

• normalized file is generated
• structure is consistent across runs
• values correctly reflect latest artifacts
• no execution artifacts are modified

