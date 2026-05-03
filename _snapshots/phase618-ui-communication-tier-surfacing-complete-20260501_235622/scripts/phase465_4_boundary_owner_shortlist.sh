#!/usr/bin/env bash
set -euo pipefail

INPUT="docs/phase465_3_boundary_owner_extraction.txt"
OUT="docs/phase465_4_boundary_owner_shortlist.txt"

mkdir -p docs

{
  echo "PHASE 465.4 — BOUNDARY OWNER SHORTLIST"
  echo "======================================"
  echo
  echo "INPUT: $INPUT"
  echo

  if [ ! -f "$INPUT" ]; then
    echo "ERROR: missing input artifact: $INPUT"
    exit 1
  fi

  echo "STEP 1 — Intake shortlist"
  awk '
    /STEP 1 — Intake owner candidates/ {flag=1; next}
    /STEP 2 — Governance owner candidates/ {flag=0}
    flag
  ' "$INPUT" \
    | rg -o 'server/[A-Za-z0-9_./-]+|src/[A-Za-z0-9_./-]+' \
    | sort | uniq -c | sort -nr | head -n 20
  echo

  echo "STEP 2 — Governance shortlist"
  awk '
    /STEP 2 — Governance owner candidates/ {flag=1; next}
    /STEP 3 — Execution\/preparation owner candidates/ {flag=0}
    flag
  ' "$INPUT" \
    | rg -o 'server/[A-Za-z0-9_./-]+|src/[A-Za-z0-9_./-]+' \
    | sort | uniq -c | sort -nr | head -n 20
  echo

  echo "STEP 3 — Execution/preparation shortlist"
  awk '
    /STEP 3 — Execution\/preparation owner candidates/ {flag=1; next}
    /STEP 4 — Distinct file shortlist by boundary/ {flag=0}
    flag
  ' "$INPUT" \
    | rg -o 'server/[A-Za-z0-9_./-]+|src/[A-Za-z0-9_./-]+' \
    | sort | uniq -c | sort -nr | head -n 20
  echo

  echo "STEP 4 — Distinct files declared by boundary"
  awk '
    /--- INTAKE FILES ---/ {section="intake"; next}
    /--- GOVERNANCE FILES ---/ {section="governance"; next}
    /--- EXECUTION\/PREP FILES ---/ {section="execution"; next}
    /^STEP 5 — Candidate overlap/ {section=""}
    section != "" && NF { print "[" section "] " $0 }
  ' "$INPUT" | head -n 120
  echo

  echo "STEP 5 — Candidate overlap frequencies"
  awk '
    /STEP 5 — Candidate overlap/ {flag=1; next}
    /DECISION TARGET:/ {flag=0}
    flag && NF
  ' "$INPUT" \
    | rg -o 'server/[A-Za-z0-9_./-]+|src/[A-Za-z0-9_./-]+' \
    | sort | uniq -c | sort -nr | head -n 40
  echo

  echo "DECISION TARGET"
  echo "- Choose ONE likely owner for intake"
  echo "- Choose ONE likely owner for governance"
  echo "- Choose ONE likely owner for execution/preparation"
  echo "- Next phase should extract exact snippets from only those files"
} > "$OUT"

echo "Wrote $OUT"
