#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/docs/PHASE_487_STEP1_DASHBOARD_ENTRYPOINT.txt"

{
  echo "PHASE 487 — STEP 1 DASHBOARD ENTRYPOINT DETECTION"
  echo
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo Root: $ROOT"
  echo
  echo "────────────────────────────────"
  echo "NEXT.JS APP ROUTES (app/)"
  echo "────────────────────────────────"
  find "$ROOT/app" -type f \( -name "page.tsx" -o -name "page.jsx" \) 2>/dev/null | sort || true
  echo
  echo "────────────────────────────────"
  echo "PAGES ROUTES (pages/)"
  echo "────────────────────────────────"
  find "$ROOT/pages" -type f \( -name "*.tsx" -o -name "*.jsx" -o -name "*.ts" -o -name "*.js" \) 2>/dev/null | sort || true
  echo
  echo "────────────────────────────────"
  echo "FILES CONTAINING OPERATOR/DASHBOARD KEYWORDS"
  echo "────────────────────────────────"
  grep -RIlE 'Operator Console|Operator Workspace|Operator Guidance|Dashboard|Agent Pool|Chat Delegation' \
    "$ROOT" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build \
    | sort || true
  echo
  echo "────────────────────────────────"
  echo "LIKELY ENTRYPOINT CANDIDATES (TOP MATCHES)"
  echo "────────────────────────────────"
  grep -RIlE 'export default function|Page\(|return \(' \
    "$ROOT/app" "$ROOT/pages" 2>/dev/null \
    | grep -Ei '(dashboard|operator|matilda|index|home)' \
    | sort || true
} > "$OUT"

echo "Wrote $OUT"
