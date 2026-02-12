#!/usr/bin/env bash
set -euo pipefail

# Phase 37.6 — run_view single-owner guard
# Canonical/only owner allowed to query run_view:
ALLOWED="server/routes/phase36_run_view.mjs"

# We only care about *server runtime code* that could execute SQL.
# Docs, scripts, dashboards, and build artifacts may reference run_view freely.
SCAN_PATHS=(
  "server"
)

# Exclusions:
# - Allowed owner file itself
# - Tests (may reference run_view in fixtures)
# - TypeScript sources if you’re not running them in prod
EXCLUDE_GLOBS=(
  "--glob=!${ALLOWED}"
  "--glob=!server/**/__tests__/**"
  "--glob=!server/**/*.test.*"
  "--glob=!server/**/*.spec.*"
  "--glob=!server/**/*.ts"
)

# Grep for run_view usage in server runtime code only.
# (String match is intentional + strict.)
mapfile -t hits < <(rg -n "run_view" "${SCAN_PATHS[@]}" "${EXCLUDE_GLOBS[@]}" || true)

if (( ${#hits[@]} > 0 )); then
  echo "ERROR: run_view referenced in server runtime code outside allowed owner: ${ALLOWED}" >&2
  echo "" >&2
  echo "Offending references:" >&2
  printf '%s\n' "${hits[@]}" >&2
  echo "" >&2
  echo "Fix: move the runtime reference into ${ALLOWED}, or update this guard's exclusions intentionally." >&2
  exit 2
fi

echo "OK: run_view has a single runtime owner (${ALLOWED})."
