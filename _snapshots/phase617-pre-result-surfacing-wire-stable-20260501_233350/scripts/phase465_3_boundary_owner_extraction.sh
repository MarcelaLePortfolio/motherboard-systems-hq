#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase465_3_boundary_owner_extraction.txt"

mkdir -p docs

echo "PHASE 465.3 — BOUNDARY OWNER EXTRACTION" > "$OUT"
echo "=======================================" >> "$OUT"
echo >> "$OUT"

echo "OBJECTIVE:" >> "$OUT"
echo "- Since FULL_CHAIN_DISCONNECTED was confirmed, isolate likely owners for:" >> "$OUT"
echo "  1) intake boundary" >> "$OUT"
echo "  2) governance boundary" >> "$OUT"
echo "  3) execution/preparation boundary" >> "$OUT"
echo "- NO mutation. Evidence only." >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Intake owner candidates" >> "$OUT"
rg -n -C 2 "intake|request|normalize|validate|acceptRawInput|buildProject|plan\(" src server 2>/dev/null | head -n 200 >> "$OUT" || echo "no intake candidates found" >> "$OUT"
echo >> "$OUT"

echo "STEP 2 — Governance owner candidates" >> "$OUT"
rg -n -C 2 "governance|policy|decision|evaluate|authorization|eligible" src server 2>/dev/null | head -n 200 >> "$OUT" || echo "no governance candidates found" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Execution/preparation owner candidates" >> "$OUT"
rg -n -C 2 "prepare|ready|execute|run|dispatch|job|task" src server 2>/dev/null | head -n 200 >> "$OUT" || echo "no execution/prep candidates found" >> "$OUT"
echo >> "$OUT"

echo "STEP 4 — Distinct file shortlist by boundary" >> "$OUT"
echo "--- INTAKE FILES ---" >> "$OUT"
rg -l "intake|request|normalize|validate|acceptRawInput|buildProject|plan\(" src server 2>/dev/null | sort -u | head -n 40 >> "$OUT" || true
echo >> "$OUT"
echo "--- GOVERNANCE FILES ---" >> "$OUT"
rg -l "governance|policy|decision|evaluate|authorization|eligible" src server 2>/dev/null | sort -u | head -n 40 >> "$OUT" || true
echo >> "$OUT"
echo "--- EXECUTION/PREP FILES ---" >> "$OUT"
rg -l "prepare|ready|execute|run|dispatch|job|task" src server 2>/dev/null | sort -u | head -n 40 >> "$OUT" || true
echo >> "$OUT"

echo "STEP 5 — Candidate overlap" >> "$OUT"
rg -l "intake|request|normalize|validate|acceptRawInput|buildProject|plan\(|governance|policy|decision|evaluate|authorization|eligible|prepare|ready|execute|run|dispatch|job|task" src server 2>/dev/null | sort -u | head -n 80 >> "$OUT" || true
echo >> "$OUT"

echo "DECISION TARGET:" >> "$OUT"
echo "- Choose one likely owner file for each disconnected boundary." >> "$OUT"
echo "- Next phase should define an explicit bridge contract between those owners only." >> "$OUT"
echo >> "$OUT"

echo "Wrote $OUT"
