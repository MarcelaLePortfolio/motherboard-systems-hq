#!/usr/bin/env bash
set -euo pipefail

echo "=== SUPPORTING JUSTIFICATION SIGNAL — ORIGIN INVESTIGATION ==="

cat <<'QUESTION'

The previous investigation established:

- Candidate A is the correct architecture.
- Existing structured signals are insufficient.
- One new deterministic signal is required.

The remaining question is NOT where to store the signal.

The remaining question is:

When does the system FIRST know that explicit supporting engineering
justification exists?

Evaluate the following ownership moments.

A.
Before Ollama is called.

B.
While Ollama is generating the original conclusion.

C.
Immediately after Ollama returns the original conclusion.

D.
During IEL persistence.

E.
Only later when the user requests an explanation.

For each moment determine:

1. Does the system actually possess the required knowledge?
2. Would establishing the signal require semantic inference?
3. Can the signal be persisted deterministically?
4. Would later stages merely consume the signal?
5. Does this preserve Interpretation Authority?

The signal must represent only one fact:

"Explicit supporting justification is available."

It must NOT represent:

- correctness
- confidence
- quality
- explanation text
- chain-of-thought

Required output:

Identify the earliest architectural point where this fact can exist.

Do not design storage.
Do not design implementation.
Do not revisit prompt engineering.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
