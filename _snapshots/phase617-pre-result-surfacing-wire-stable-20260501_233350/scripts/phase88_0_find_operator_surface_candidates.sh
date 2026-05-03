#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_0_OPERATOR_SURFACE_CANDIDATES.txt"

{
  echo "PHASE 88.0 OPERATOR SURFACE CANDIDATES"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Repo: $(pwd)"
  echo "────────────────────────────────"

  echo "SECTION: ROUTE / PAGE / SURFACE CANDIDATES"
  find . \
    \( -path "./node_modules" -o -path "./.git" -o -path "./.next" -o -path "./dist" -o -path "./build" \) -prune -o \
    \( -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.md" \) \) -print \
    | grep -E '/(app|src|pages|ui|components|dashboard|diagnostics|status|health|operator|ops)/' \
    | sort
  echo "────────────────────────────────"

  echo "SECTION: KEYWORD HITS — diagnostics|status|health|operator|summary"
  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden \
      --glob '!node_modules/**' \
      --glob '!.git/**' \
      --glob '!.next/**' \
      --glob '!dist/**' \
      --glob '!build/**' \
      '(diagnostic|diagnostics|status|health|operator|summary)' .
  else
    grep -RIn \
      --exclude-dir=node_modules \
      --exclude-dir=.git \
      --exclude-dir=.next \
      --exclude-dir=dist \
      --exclude-dir=build \
      -E '(diagnostic|diagnostics|status|health|operator|summary)' .
  fi
  echo "────────────────────────────────"

  echo "SECTION: PAGE / ROUTE EXPORT HITS"
  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden \
      --glob '!node_modules/**' \
      --glob '!.git/**' \
      --glob '!.next/**' \
      --glob '!dist/**' \
      --glob '!build/**' \
      'export default function|export async function GET|export async function POST|function Page|const .*Page' \
      app src pages
  else
    grep -RIn \
      --exclude-dir=node_modules \
      --exclude-dir=.git \
      --exclude-dir=.next \
      --exclude-dir=dist \
      --exclude-dir=build \
      -E 'export default function|export async function GET|export async function POST|function Page|const .*Page' \
      app src pages 2>/dev/null || true
  fi
  echo "────────────────────────────────"

  echo "SECTION: EXISTING SYSTEM SUMMARY USAGE"
  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden \
      --glob '!node_modules/**' \
      --glob '!.git/**' \
      --glob '!.next/**' \
      --glob '!dist/**' \
      --glob '!build/**' \
      'getSystemSituationSummary|getSituationSummarySnapshot|getSituationSummary|buildSituationSummary|renderSituationSummary' .
  else
    grep -RIn \
      --exclude-dir=node_modules \
      --exclude-dir=.git \
      --exclude-dir=.next \
      --exclude-dir=dist \
      --exclude-dir=build \
      -E 'getSystemSituationSummary|getSituationSummarySnapshot|getSituationSummary|buildSituationSummary|renderSituationSummary' .
  fi
  echo "────────────────────────────────"

  echo "SECTION: TOP CANDIDATES (MANUAL REVIEW NEXT)"
  echo "Review the files above and choose the narrowest existing operator-facing status or diagnostics surface."
  echo "Preference order:"
  echo "1. Existing diagnostics/status page"
  echo "2. Existing health/operator route"
  echo "3. Existing dashboard status component"
  echo "4. Existing CLI-only operator surface if no UI surface exists yet"
} | tee "$OUTPUT_FILE"
