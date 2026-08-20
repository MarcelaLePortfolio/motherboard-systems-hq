# QA Recovery Agent — Post-MVP Architecture Candidate

Status: POST-MVP CANDIDATE
Implementation status: NOT STARTED
Production authority: NONE

## Purpose

Introduce a dedicated QA Recovery Agent that activates when Cade, Effie, or another system workflow encounters a bounded failure requiring investigation, validation, or recovery.

The agent is intended to reduce debugging burden without creating an unbounded autonomous repair loop.

## Core responsibility

The QA Recovery Agent owns evidence gathering, failure classification, bounded diagnosis, validation, and recovery coordination.

Default collaboration pattern:

1. Cade or another execution agent performs authorized work.
2. A qualifying failure event occurs.
3. QA Recovery Agent activates.
4. QA gathers evidence before proposing changes.
5. QA identifies the smallest supported failure hypothesis.
6. Cade remains the preferred implementation owner for production corrections.
7. QA validates the correction.
8. QA exits on verified success or escalates when its bounded authority is exhausted.

## Candidate trigger events

The QA Recovery Agent may be activated by events including:

- CI or build failure.
- Runtime 5xx response.
- Failed post-deployment smoke test.
- Fail-closed semantic validation rejection.
- Regression validation failure.
- Repeated generation timeout.
- Contract mismatch between model output and validator expectations.
- Unexpected integration failure.
- Deployment health regression.
- Repeated failure of an authorized implementation hypothesis.
- A successful implementation whose required validation subsequently fails.

Triggers are signals for investigation, not automatic authorization to mutate production.

## Bounded recovery lifecycle

The QA Recovery Agent must not simply "run until solved."

Its lifecycle should be:

TRIGGER
→ CAPTURE EVIDENCE
→ CLASSIFY FAILURE
→ ESTABLISH HYPOTHESIS
→ IDENTIFY MINIMUM SAFE INTERVENTION
→ REQUEST AUTHORIZATION WHEN REQUIRED
→ IMPLEMENT OR HAND OFF IMPLEMENTATION
→ VALIDATE
→ CLOSE OR ESCALATE

## Failure containment

The QA Recovery Agent must preserve the existing engineering discipline:

- Evidence first.
- Scope first.
- No speculative layering of fixes.
- One materially testable hypothesis at a time.
- Preserve the last known stable checkpoint.
- Use rollback rather than accumulating uncertain changes.
- Maximum three failed attempts under one hypothesis.
- After three failures, stop that hypothesis and return to the stable boundary.
- If a failure does not identify a defensible next step, stop and escalate instead of guessing.
- Do not weaken validators merely to make a failing result pass.
- Do not silently expand production authority.

## Exit conditions

The QA Recovery Agent exits when any of the following occurs:

### VERIFIED_SUCCESS

The original failure is no longer reproducible on the required validation surface and all required acceptance boundaries pass.

### ESCALATION_REQUIRED

The next intervention requires authority outside the QA Agent's approved scope.

### HYPOTHESIS_EXHAUSTED

Three bounded attempts under the same hypothesis have failed or the hypothesis has been disproven.

### EVIDENCE_INSUFFICIENT

Available evidence cannot support a safe next intervention.

### STABLE_REVERT

The system has been returned to the last known stable checkpoint and a new solution class must be selected.

## Production authority model

Recommended default:

- QA may inspect freely within authorized repository/runtime boundaries.
- QA may create diagnostic artifacts and classifications.
- QA may run explicitly permitted validation surfaces.
- QA may not independently weaken validators.
- QA may not independently change security or governance boundaries.
- QA may not independently change production generation policy.
- QA may not independently introduce retries or conceal failures.
- Production mutations remain separately authorized unless a future narrowly defined QA repair class is explicitly approved.

## Cade relationship

Preferred separation of responsibility:

Cade builds.
QA verifies.
QA diagnoses failure.
Cade implements approved production corrections.
QA re-validates.

A future bounded auto-repair mode may be considered for low-risk, reversible failure classes after sufficient production evidence exists.

## Effie relationship

Effie may participate in orchestration, planning, evidence synthesis, or agent-generation workflows while preserving the same QA authority boundary.

## Internal and market-facing versions

Internal Cade and Effie may use the full licensed/internal construct environment available to Marcela.

Any market-facing QA Agent, Cade, Effie, Chief of Staff, or generated derivative must be:

- Self-contained.
- Fully functional without proprietary internal constructs.
- Compliant with applicable redistribution and licensing restrictions.
- Designed so the public-facing agent cannot expose or grant access to protected construct logic.

The QA architecture itself may be reproduced as an independent behavioral design, but proprietary implementation logic must remain behind the internal compliance boundary.

## Post-MVP recommendation

This agent is recommended for explicit architectural consideration immediately after MVP stabilization because MVP completion increases the value of automated regression detection, bounded incident recovery, and validation ownership.

Implementation is not authorized by this document.
