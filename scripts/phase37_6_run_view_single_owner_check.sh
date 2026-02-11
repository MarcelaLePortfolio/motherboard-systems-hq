#!/usr/bin/env bash
set -euo pipefail

# Phase 37.6 — run_view single-owner guard
# Canonical/only owner allowed to query run_view:
ALLOWED="server/routes/phase36_run_view.mjs"

# Search for run_view usage that implies DB access (string match is intentional + strict).
# If you intentionally add a new owner, update ALLOWED and document why in PHASE37_6_NEXT.md.
matches="$(git grep -nE '\brun_view\b' -- ':!'"$ALLOWED" || true)"

if [[ -n "${matches}" ]]; then
  echo "ERROR: run_view referenced outside allowed owner: ${ALLOWED}" >&2
  echo "" >&2
  echo "Offending references:" >&2
  echo "${matches}" >&2
  echo "" >&2
  echo "Fix: remove/migrate the extra owner, or explicitly re-scope Phase 37.x to allow another owner." >&2
  exit 2
fi

echo "OK: run_view has a single owner (${ALLOWED})."
