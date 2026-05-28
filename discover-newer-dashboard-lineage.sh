
#!/bin/zsh

set -euo pipefail

REPORT="NEWER_DASHBOARD_LINEAGE_DISCOVERY.txt"

{

  echo "===== NEWER DASHBOARD LINEAGE DISCOVERY ====="

  date

  echo

  echo "===== CURRENT BRANCH ====="

  git branch --show-current

  echo

  echo "===== COMMITS AFTER 4c55719f TOUCHING DASHBOARD SURFACES ====="

  git log --oneline --decorate 4c55719f..HEAD -- \

    public/dashboard.html \

    public/index.html \

    public/js \

    public/css \

    public/bundle.js || true

  echo

  echo "===== OTHER BRANCHES WITH DASHBOARD COMMITS ====="

  git branch -a

  echo

  echo "===== SEARCHING FOR DASHBOARD KEYWORDS IN RECENT COMMITS ====="

  git log --oneline --all --grep="dashboard" -i | head -120

  echo

  echo "===== SEARCHING FOR MATILDA WORKSPACE EVOLUTION ====="

  git log --oneline --all --grep="matilda" -i | head -120

  echo

  echo "===== SEARCHING FOR UX / UI EVOLUTION COMMITS ====="

  git log --oneline --all --grep="UX\|UI\|workspace\|telemetry\|operator guidance" -i | head -120

  echo

  echo "===== STASHES ====="

  git stash list || true

  echo

  echo "===== BACKUP DIRECTORIES ====="

  find . -maxdepth 3 \( \

    -iname '*backup*' -o \

    -iname '*snapshot*' -o \

    -iname '*restore*' -o \

    -iname '*archive*' \

  \) | sort

  echo

  echo "===== NEWEST DASHBOARD.HTML COMMITS ====="

  git log --oneline --all -- public/dashboard.html | head -80

  echo

  echo "===== NEWEST INDEX.HTML COMMITS ====="

  git log --oneline --all -- public/index.html | head -80

  echo

  echo "===== POSSIBLE TARGET COMMITS AFTER CURRENT RESTORE ====="

  git log --oneline --all --reverse -- public/dashboard.html | tail -40

  echo

  echo "===== CURRENT SERVED TITLE ====="

  grep -n "<title" public/index.html || true

  echo

  echo "===== CURRENT MATILDA SURFACES ====="

  grep -n "matilda" public/index.html | head -40 || true

  echo

  echo "===== CURRENT OPERATOR GUIDANCE SURFACES ====="

  grep -n "operator guidance" public/index.html | head -40 || true

} | tee "$REPORT"

echo

echo "REPORT WRITTEN: $REPORT"

