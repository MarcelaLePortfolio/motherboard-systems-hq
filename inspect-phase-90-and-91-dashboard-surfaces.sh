
#!/bin/zsh

set -euo pipefail

REPORT="PHASE_90_91_DASHBOARD_SURFACE_INSPECTION.txt"

{

  echo "===== PHASE 90/91 DASHBOARD SURFACE INSPECTION ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -5

  echo

  echo "===== PHASE 90 GOLDEN TAG ====="

  git show --summary v90.0-operator-guidance-surface-golden || true

  echo

  echo "===== PHASE 91 GOLDEN TAG ====="

  git show --summary v91.0-guidance-intelligence-refinement-golden || true

  echo

  echo "===== FILE DIFFERENCES: CURRENT vs PHASE 91 ====="

  git diff --stat v91.0-guidance-intelligence-refinement-golden -- \

    public/dashboard.html \

    public/index.html \

    public/js \

    public/css \

    public/bundle.js || true

  echo

  echo "===== FILE DIFFERENCES: CURRENT vs PHASE 90 ====="

  git diff --stat v90.0-operator-guidance-surface-golden -- \

    public/dashboard.html \

    public/index.html \

    public/js \

    public/css \

    public/bundle.js || true

  echo

  echo "===== PHASE 91 DASHBOARD TITLE ====="

  git show v91.0-guidance-intelligence-refinement-golden:public/dashboard.html | grep -n "<title" || true

  echo

  echo "===== PHASE 91 MATILDA SURFACES ====="

  git show v91.0-guidance-intelligence-refinement-golden:public/dashboard.html | grep -ni "matilda" | head -40 || true

  echo

  echo "===== PHASE 91 OPERATOR GUIDANCE ====="

  git show v91.0-guidance-intelligence-refinement-golden:public/dashboard.html | grep -ni "operator guidance" | head -40 || true

  echo

  echo "===== PHASE 91 GUIDANCE INTELLIGENCE ====="

  git show v91.0-guidance-intelligence-refinement-golden:public/dashboard.html | grep -ni "guidance" | head -80 || true

  echo

  echo "===== CURRENT ROOT SIZE ====="

  wc -c public/index.html

  echo

  echo "===== PHASE 91 DASHBOARD SIZE ====="

  git show v91.0-guidance-intelligence-refinement-golden:public/dashboard.html | wc -c

  echo

  echo "===== POSSIBLE FINDING ====="

  echo "If Phase 91 assets differ substantially from current runtime,"

  echo "the current restore likely landed on an intermediate dashboard lineage."

  echo "The next safe action would be restoring directly from the v91 golden checkpoint."

} | tee "$REPORT"

git add inspect-phase-90-and-91-dashboard-surfaces.sh "$REPORT"

git commit -m "Inspect phase 90 and 91 dashboard surfaces"

git push
