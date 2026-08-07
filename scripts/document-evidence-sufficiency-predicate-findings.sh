#!/usr/bin/env bash
set -euo pipefail

echo "=== EVIDENCE SUFFICIENCY PREDICATE — FINDINGS ==="

cat <<'FINDINGS'

Repository-supported classifications
====================================

selectedHistory
  CONTEXT_PRESENCE_SIGNAL

projectContextExcerpts
  CONTEXT_PRESENCE_SIGNAL

projectContextWarning
  AVAILABILITY_SIGNAL

history.length
  CONTEXT_PRESENCE_SIGNAL

excerpt count
  CONTEXT_PRESENCE_SIGNAL

authorityEvaluation
  ELIGIBILITY_SIGNAL

contaminationEvaluation
  ELIGIBILITY_SIGNAL


Canonical determination
=======================

The current structured fields cannot distinguish:

CASE A
-------
History contains explicit supporting engineering justification.

CASE B
-------
History contains only a recommendation.

Both cases can have identical:

- selectedHistory
- authorityEvaluation
- contaminationEvaluation
- history length
- excerpt count
- project context availability

Therefore:

Evidence sufficiency CANNOT be computed deterministically from the
existing structured fields alone.

FINAL CLASSIFICATION

NEEDS ONE NEW DETERMINISTIC SIGNAL

Reason

The repository currently knows:

- what context is available
- what context is eligible
- what context was selected

The repository does NOT know:

whether explicit engineering justification exists inside that context.

That missing fact is the deterministic predicate Candidate A requires.

Candidate A therefore remains the correct architectural direction,
but implementation is blocked until that single structured signal is
defined.

