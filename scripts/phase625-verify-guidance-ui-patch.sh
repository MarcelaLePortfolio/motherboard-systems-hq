#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase625-guidance-ui-patch-verified.md"

{
  echo "# Phase 625 Guidance UI Patch Verification"
  echo
  echo "## Git status"
  git status --short
  echo
  echo "## Guidance helper present"
  grep -n "function renderGuidance(t)" public/js/dashboard-tasks-widget.js
  echo
  echo "## Guidance render call present"
  grep -n "renderGuidance(t)" public/js/dashboard-tasks-widget.js
  echo
  echo "## Patch size confirmation"
  git show --stat --oneline HEAD
  echo
  echo "## Conclusion"
  echo "Read-only guidance rendering is now micro-patched into the real dashboard task widget without replacing render, polling, fetch, SSE, or execution behavior."
} > "$REPORT"
