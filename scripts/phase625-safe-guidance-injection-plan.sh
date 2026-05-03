#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase625-safe-guidance-injection-plan.md"

{
  echo "# Phase 625 SAFE GUIDANCE INJECTION PLAN"
  echo
  echo "## Current State"
  echo "- Dashboard widget restored (revert successful)"
  echo "- Execution integrity preserved"
  echo "- Guidance UI exists in React component only"
  echo
  echo "## Root Issue Identified"
  echo "Previous patch replaced large portions of dashboard-tasks-widget.js"
  echo "Violation: NOT append-only"
  echo
  echo "## Safe Strategy (MANDATORY)"
  echo "1. DO NOT replace render()"
  echo "2. DO NOT modify existing HTML structure"
  echo "3. ONLY append inside existing task map template"
  echo "4. ONLY add 1 helper: renderGuidance(t)"
  echo
  echo "## Exact Injection Point"
  echo "Inside state.tasks.map((t) => template)"
  echo "AFTER existing task row"
  echo
  echo "## Allowed Patch Shape"
  echo 'renderGuidance(t)'
  echo
  echo "## Constraints"
  echo "- No new state fields"
  echo "- No fetch changes"
  echo "- No polling changes"
  echo "- No lifecycle changes"
  echo
  echo "## Next Step"
  echo "Prepare MICRO PATCH (diff-style, under 10 lines)"
  echo "Zero overwrite risk"
} > "$REPORT"
