#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase478_9_verify_css_files_exist_and_are_served.txt"
mkdir -p docs

{
echo "PHASE 478.9 — VERIFY CSS FILE EXISTENCE + SERVING"
echo "=================================================="
echo

echo "STEP 1 — Check filesystem presence"
echo "--- public/css directory ---"
ls -la public/css || echo "NO public/css directory found"
echo

echo "STEP 2 — Check specific files"
for f in dashboard.css dashboard-reflections.css; do
  if [ -f "public/css/$f" ]; then
    echo "FOUND: public/css/$f"
    wc -l "public/css/$f"
  else
    echo "MISSING: public/css/$f"
  fi
done
echo

echo "STEP 3 — Probe HTTP serving"
for f in dashboard.css dashboard-reflections.css; do
  echo "---- $f ----"
  curl -I --max-time 5 "http://localhost:8080/css/$f" 2>&1 || true
  echo
done

echo "STEP 4 — Fetch first 20 lines of each (content check)"
for f in dashboard.css dashboard-reflections.css; do
  echo "---- $f CONTENT PREVIEW ----"
  curl -s --max-time 5 "http://localhost:8080/css/$f" | head -n 20 || true
  echo
done

echo "STEP 5 — CLASSIFICATION RULE"
echo "- If files are missing → CSS_NOT_LOADING"
echo "- If 404 → CSS_NOT_LOADING"
echo "- If 200 but empty → CSS_LOADING_NOT_APPLYING"
echo "- If full content → CSS_APPLYING_BUT_LAYOUT_STILL_WRONG (likely JS-dependent layout)"
echo

} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
