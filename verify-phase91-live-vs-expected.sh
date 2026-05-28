
#!/usr/bin/env bash

set -euo pipefail

REPORT="PHASE91_LIVE_VISUAL_VERIFICATION.txt"

TMP_EXPECTED="/tmp/phase91-expected-dashboard.html"

TMP_LIVE="/tmp/live-dashboard-phase91.html"

git show v91.0-guidance-intelligence-refinement-golden:public/dashboard.html > "$TMP_EXPECTED"

curl -s http://localhost:8080/ > "$TMP_LIVE"

{

  echo "===== PHASE 91 LIVE VISUAL VERIFICATION ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -5

  echo

  echo "===== LIVE ROOT TITLE ====="

  grep -n "<title" "$TMP_LIVE" || true

  echo

  echo "===== LIVE PHASE MARKERS ====="

  grep -n "phase61-workspace-grid" "$TMP_LIVE" || true

  grep -n "phase61-telemetry-column" "$TMP_LIVE" || true

  grep -n "phase62-top-row" "$TMP_LIVE" || true

  grep -n "Operator Guidance" "$TMP_LIVE" || true

  grep -n "Matilda" "$TMP_LIVE" | head -20 || true

  echo

  echo "===== LIVE CSS ASSET CHECK ====="

  grep -o 'css/[^"]*' "$TMP_LIVE" | sort -u || true

  echo

  echo "===== LIVE JS ASSET CHECK ====="

  grep -o 'js/[^"]*' "$TMP_LIVE" | sort -u || true

  echo

  echo "===== FILE SIZE CHECK ====="

  wc -c public/index.html public/dashboard.html public/bundle.js "$TMP_LIVE" "$TMP_EXPECTED"

  echo

  echo "===== VERIFY INDEX SOURCE MATCH ====="

  if diff -q public/index.html "$TMP_EXPECTED"; then

    echo "INDEX EXACTLY MATCHES PHASE91 DASHBOARD SOURCE"

  else

    echo "INDEX DIFFERS FROM PHASE91 SOURCE"

  fi

  echo

  echo "===== VERIFY DASHBOARD SOURCE MATCH ====="

  if diff -q public/dashboard.html "$TMP_EXPECTED"; then

    echo "DASHBOARD EXACTLY MATCHES PHASE91 DASHBOARD SOURCE"

  else

    echo "DASHBOARD DIFFERS FROM PHASE91 SOURCE"

  fi

  echo

  echo "===== VERIFY LIVE ROOT MATCH ====="

  if diff -q "$TMP_LIVE" "$TMP_EXPECTED"; then

    echo "LIVE ROOT EXACTLY MATCHES PHASE91 DASHBOARD SOURCE"

  else

    echo "LIVE ROOT DIFFERS FROM PHASE91 SOURCE"

  fi

  echo

  echo "===== CONCLUSION ====="

  echo "Phase 91 dashboard source and live root verification complete."

  echo "If visual drift remains, next step is comparing against another candidate lineage, not patching blindly."

} | tee "$REPORT"

git add verify-phase91-live-vs-expected.sh "$REPORT"

git commit -m "Verify live phase 91 dashboard against expected source"

git push

