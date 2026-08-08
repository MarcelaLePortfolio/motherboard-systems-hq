#!/usr/bin/env bash
set -euo pipefail

echo "=== EVIDENCE SUFFICIENCY PREDICATE INVESTIGATION ==="

echo
cat <<'QUESTION'
Candidate A has been selected.

The remaining architectural question is NOT where the gate belongs.
The remaining question is what deterministic predicate the gate evaluates.

Determine whether evidence sufficiency can be decided entirely from
existing structured repository signals.

Candidate structured signals:

- selectedHistory
- projectContextExcerpts
- projectContextWarning
- history length
- excerpt count
- authorityEvaluation
- contaminationEvaluation

For each signal determine:

1. Does it directly indicate that supporting justification exists?
2. Does it merely indicate that context exists?
3. Would using it require semantic interpretation?
4. Is the signal deterministic?

Then determine:

Can evidence sufficiency be computed from existing structured data alone?

Possible outcomes:

IMPLEMENTATION READY
NEEDS ONE NEW DETERMINISTIC SIGNAL
NOT DETERMINISTIC

Do not design the implementation.
Only determine the deterministic predicate.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
