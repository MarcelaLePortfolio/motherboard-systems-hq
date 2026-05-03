#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase465_0_governance_execution_bridge_probe.txt"

mkdir -p docs

echo "PHASE 465.0 — GOVERNANCE → EXECUTION BRIDGE PROBE" > "$OUT"
echo "=================================================" >> "$OUT"
echo >> "$OUT"

echo "OBJECTIVE:" >> "$OUT"
echo "- Prove existence (or absence) of structural bridge between:" >> "$OUT"
echo "  governance evaluation → execution preparation" >> "$OUT"
echo "- NO mutation. Evidence only." >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Locate governance decision surfaces" >> "$OUT"
rg -n "governance|evaluate|policy|decision" src server 2>/dev/null >> "$OUT" || echo "no governance references found" >> "$OUT"
echo >> "$OUT"

echo "STEP 2 — Locate execution entrypoints" >> "$OUT"
rg -n "execute|run|dispatch|task|job" src server 2>/dev/null >> "$OUT" || echo "no execution references found" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Detect co-location (bridge candidates)" >> "$OUT"
rg -n "governance.*execute|execute.*governance|policy.*run|run.*policy" src server 2>/dev/null >> "$OUT" || echo "no direct bridge patterns found" >> "$OUT"
echo >> "$OUT"

echo "STEP 4 — Identify structured intake flow" >> "$OUT"
rg -n "intake|request|input|normalize|validate" src server 2>/dev/null >> "$OUT" || echo "no intake patterns found" >> "$OUT"
echo >> "$OUT"

echo "STEP 5 — Identify execution preparation signals" >> "$OUT"
rg -n "prepare|ready|authorization|eligible" src server 2>/dev/null >> "$OUT" || echo "no preparation signals found" >> "$OUT"
echo >> "$OUT"

echo "STEP 6 — Top-level architecture hints" >> "$OUT"
rg -n "pipeline|flow|stage|phase" src server 2>/dev/null >> "$OUT" || echo "no pipeline hints found" >> "$OUT"
echo >> "$OUT"

echo "DECISION TARGET:" >> "$OUT"
echo "- If NO bridge exists → structural gap confirmed" >> "$OUT"
echo "- If partial signals exist → bridge is fragmented" >> "$OUT"
echo "- If clear path exists → ready for formalization" >> "$OUT"
echo >> "$OUT"

echo "Wrote $OUT"

