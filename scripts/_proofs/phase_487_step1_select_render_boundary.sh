#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
IN="$ROOT/docs/PHASE_487_STEP1_PRIORITY_RENDER_CANDIDATE_INSPECTION.txt"
OUT="$ROOT/docs/PHASE_487_STEP1_RENDER_BOUNDARY_DECISION.txt"

awk '
BEGIN {
  file=""
}
$0 ~ /^FILE: / {
  file=$0
  sub(/^FILE: /, "", file)
  files[++n]=file
  exportCount[file]=0
  hookCount[file]=0
  labelCount[file]=0
  first220[file]=0
  next
}
file != "" && $0 ~ /---- EXPORT \/ COMPONENT LINES ----/ { section="export"; next }
file != "" && $0 ~ /---- HOOK \/ LOGIC LINES ----/ { section="hook"; next }
file != "" && $0 ~ /---- LABEL \/ UI TEXT LINES ----/ { section="label"; next }
file != "" && $0 ~ /---- FIRST 220 LINES ----/ { section="first220"; next }
file != "" && $0 ~ /^════════/ { section=""; next }

file != "" && section=="export" && $0 ~ /^[0-9]+:/ { exportCount[file]++ }
file != "" && section=="hook" && $0 ~ /^[0-9]+:/ { hookCount[file]++ }
file != "" && section=="label" && $0 ~ /^[0-9]+:/ { labelCount[file]++ }
file != "" && section=="first220" && length($0) > 0 { first220[file]++ }

END {
  print "PHASE 487 — STEP 1 RENDER BOUNDARY DECISION"
  print ""
  cmd="date -u +%Y-%m-%dT%H:%M:%SZ"
  cmd | getline now
  close(cmd)
  print "Generated: " now
  print ""
  print "────────────────────────────────"
  print "CANDIDATE SCORING"
  print "────────────────────────────────"
  for (i=1; i<=n; i++) {
    f=files[i]
    score=(labelCount[f]*10)+(exportCount[f]*3)-(hookCount[f]*2)
    scores[f]=score
    printf "%4d | labels=%-3d exports=%-3d hooks=%-3d | %s\n", score, labelCount[f], exportCount[f], hookCount[f], f
  }
  print ""
  print "────────────────────────────────"
  print "RECOMMENDED SELECTION CRITERIA"
  print "────────────────────────────────"
  print "Choose the file with:"
  print "1. highest label density,"
  print "2. visible dashboard/operator text present,"
  print "3. lowest hook/logic density,"
  print "4. enough existing layout content to regroup by wrappers only."
  print ""
  print "────────────────────────────────"
  print "TOP CANDIDATES"
  print "────────────────────────────────"
  for (rank=1; rank<=5; rank++) {
    bestFile=""
    bestScore=-999999
    for (i=1; i<=n; i++) {
      f=files[i]
      if (!(f in used) && scores[f] > bestScore) {
        bestScore=scores[f]
        bestFile=f
      }
    }
    if (bestFile != "") {
      used[bestFile]=1
      printf "%d. %s\n", rank, bestFile
      printf "   score=%d labels=%d exports=%d hooks=%d\n", scores[bestFile], labelCount[bestFile], exportCount[bestFile], hookCount[bestFile]
    }
  }
  print ""
  print "────────────────────────────────"
  print "NEXT ACTION"
  print "────────────────────────────────"
  print "Open the #1 candidate first."
  print "If it contains the visible dashboard sections and can be regrouped by wrappers only, use it as the Phase 487 Step 1 mutation boundary."
  print "If not, fall through to the next candidate."
}
' "$IN" > "$OUT"

echo "Wrote $OUT"
