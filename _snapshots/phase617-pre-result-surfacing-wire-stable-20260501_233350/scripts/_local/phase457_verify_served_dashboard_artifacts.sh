#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/32_served_dashboard_artifact_verification.txt"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

fetch_url_artifacts() {
  local name="$1"
  local port="$2"

  local html="$TMP_DIR/${name}.html"
  local bundle="$TMP_DIR/${name}.bundle.js"
  local core="$TMP_DIR/${name}.bundle-core.js"

  curl -L --max-time 15 "http://localhost:${port}" -o "$html" 2>/dev/null || true
  curl -L --max-time 15 "http://localhost:${port}/bundle.js" -o "$bundle" 2>/dev/null || true
  curl -L --max-time 15 "http://localhost:${port}/bundle-core.js" -o "$core" 2>/dev/null || true

  echo "===== LIVE ${name} : http://localhost:${port} ====="
  echo "[status]"
  curl -I --max-time 10 "http://localhost:${port}" 2>&1 || true
  echo
  echo "[title]"
  grep -o '<title>[^<]*</title>' "$html" | head -n 1 || true
  echo
  echo "[live artifact hashes]"
  [ -f "$html" ] && shasum -a 256 "$html" || true
  [ -f "$bundle" ] && shasum -a 256 "$bundle" || true
  [ -f "$core" ] && shasum -a 256 "$core" || true
  echo
  echo "[live body markers]"
  grep -Eo 'Operator Console|Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity Over Time|Agent Pool|Guidance|Atlas Subsystem Status|Probe lifecycle|System Reflections|Critical Ops Alerts' "$html" | sort -u || true
  echo
}

inspect_worktree_artifacts() {
  local name="$1"
  local wt="$2"

  echo "===== WORKTREE ${name} : ${wt} ====="
  echo "[branch]"
  git -C "$wt" branch --show-current || true
  echo
  echo "[tracked artifact hashes]"
  [ -f "$wt/public/dashboard.html" ] && shasum -a 256 "$wt/public/dashboard.html" || true
  [ -f "$wt/public/index.html" ] && shasum -a 256 "$wt/public/index.html" || true
  [ -f "$wt/public/bundle.js" ] && shasum -a 256 "$wt/public/bundle.js" || true
  [ -f "$wt/public/bundle-core.js" ] && shasum -a 256 "$wt/public/bundle-core.js" || true
  echo
  echo "[html markers from tracked files]"
  grep -Eo 'Operator Console|Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity Over Time|Agent Pool|Guidance|Atlas Subsystem Status|Probe lifecycle|System Reflections|Critical Ops Alerts' "$wt/public/dashboard.html" 2>/dev/null | sort -u || true
  grep -Eo 'Operator Console|Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity Over Time|Agent Pool|Guidance|Atlas Subsystem Status|Probe lifecycle|System Reflections|Critical Ops Alerts' "$wt/public/index.html" 2>/dev/null | sort -u || true
  echo
  echo "[package scripts]"
  python3 - <<'PY' "$wt/package.json"
import json, sys, pathlib
p = pathlib.Path(sys.argv[1])
if p.exists():
    data = json.loads(p.read_text())
    print(data.get("scripts", {}))
else:
    print("missing package.json")
PY
  echo
}

compare_pair() {
  local left="$1"
  local right="$2"
  local left_port="$3"
  local right_port="$4"

  echo "===== DIFF ${left} vs ${right} ====="
  echo "[live html diff summary]"
  diff -u "$TMP_DIR/${left}.html" "$TMP_DIR/${right}.html" | sed -n '1,200p' || true
  echo
  echo "[live bundle.js diff summary]"
  diff -u "$TMP_DIR/${left}.bundle.js" "$TMP_DIR/${right}.bundle.js" | sed -n '1,200p' || true
  echo
  echo "[live bundle-core.js diff summary]"
  diff -u "$TMP_DIR/${left}.bundle-core.js" "$TMP_DIR/${right}.bundle-core.js" | sed -n '1,200p' || true
  echo
}

{
  echo "PHASE 457 - SERVED DASHBOARD ARTIFACT VERIFICATION"
  echo "=================================================="
  echo
  echo "PURPOSE"
  echo "Prove whether the live candidates are actually serving different dashboard artifacts,"
  echo "or whether the same HTML/bundle is still being served despite different worktree sources."
  echo
  inspect_worktree_artifacts "phase65_layout" "../mbhq_recovery_visual_compare/phase65_layout"
  inspect_worktree_artifacts "phase65_wiring" "../mbhq_recovery_visual_compare/phase65_wiring"
  inspect_worktree_artifacts "operator_guidance" "../mbhq_recovery_visual_compare/operator_guidance"

  fetch_url_artifacts "phase65_layout" "8091"
  fetch_url_artifacts "phase65_wiring" "8092"
  fetch_url_artifacts "operator_guidance" "8093"

  compare_pair "phase65_layout" "phase65_wiring" "8091" "8092"
  compare_pair "phase65_layout" "operator_guidance" "8091" "8093"
  compare_pair "phase65_wiring" "operator_guidance" "8092" "8093"

  echo "DETERMINISTIC INTERPRETATION"
  echo "- If live artifact hashes differ, the candidates are serving different builds and the remembered layout is likely from another checkpoint."
  echo "- If live artifact hashes match, the remaining issue is artifact/build parity, not branch recovery."
  echo "- Use the first matching-or-diverging proof here as the only next mutation target."
} > "$OUT"

sed -n '1,320p' "$OUT"
