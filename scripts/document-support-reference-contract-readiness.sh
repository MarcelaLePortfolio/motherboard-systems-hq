#!/usr/bin/env bash
set -euo pipefail

echo "=== SUPPORT REFERENCE CONTRACT — READINESS ==="

cat <<'FINDINGS'
CORRIDOR STATUS

This investigation is COMPLETE.

Verified conclusions
====================

✓ Candidate A remains the selected architecture.

✓ Existing workflow already owns stable conversation identifiers
  (sourceTurnId).

✓ Existing project context already owns stable excerpt identity
  (relativePath + lineNumber).

✓ Prompt-only enforcement was experimentally falsified.

✓ Existing structured runtime signals are insufficient.

✓ No additional semantic author is required.

✓ No second Ollama invocation is required.

✓ No Explanation Invitation classifier is required.

✓ The remaining work is CONTRACT DESIGN.

Current implementation boundary
===============================

The repository no longer has an architectural uncertainty.

The remaining task is to design the response contract itself.

The next corridor is therefore:

Response Contract Extension

It is no longer:

- Evidence Sufficiency investigation
- Grounding investigation
- Signal-origin investigation
- Signal-shape investigation

Those investigations are now complete.

READY TO DESIGN

supportSourceReferences

as the minimum structured contract extension.

FINDINGS

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
