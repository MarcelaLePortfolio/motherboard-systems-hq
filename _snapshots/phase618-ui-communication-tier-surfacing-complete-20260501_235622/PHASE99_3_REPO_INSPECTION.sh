#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE99_3_REPO_INSPECTION_OUTPUT.txt"

{
  echo "# Phase 99.3 Repo Inspection Output"
  echo
  echo "## Query 1 — summary search"
  rg -n "situation summary|SituationSummary|situationSummary|summary" src || true
  echo
  echo "────────────────────────────────"
  echo
  echo "## Query 2 — summary type contracts"
  rg -n "interface .*Summary|type .*Summary" src || true
  echo
  echo "────────────────────────────────"
  echo
  echo "## Query 3 — summary builders/selectors/composers"
  rg -n "select.*Summary|build.*Summary|compose.*Summary" src || true
  echo
  echo "────────────────────────────────"
  echo
  echo "## Query 4 — governance references"
  rg -n "governance" src || true
} | tee "$OUTPUT_FILE"
