
#!/usr/bin/env bash

set -euo pipefail

REPORT="DASHBOARD_RECOVERY_CANDIDATES_DISCOVERY.txt"

{

  echo "===== DASHBOARD RECOVERY CANDIDATES DISCOVERY ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -5

  echo

  echo "===== ALL DASHBOARD-RELATED TAGS ====="

  git tag | grep -Ei 'phase|golden|dashboard|guidance|operator' | sort || true

  echo

  echo "===== POSSIBLE DASHBOARD BRANCHES ====="

  git branch -a | grep -Ei 'dashboard|phase-9|guidance|operator|workspace|telemetry' || true

  echo

  echo "===== RECENT STASHES ====="

  git stash list || true

  echo

  echo "===== POSSIBLE DASHBOARD HTML FILES ====="

  find . \

    -type f \

    \( -iname '*dashboard*.html' -o -iname '*operator*.html' -o -iname '*workspace*.html' \) \

    | sort

  echo

  echo "===== POSSIBLE DASHBOARD BACKUPS ====="

  find . \

    -type f \

    \( -iname '*backup*dashboard*' -o -iname '*restore*dashboard*' -o -iname '*golden*dashboard*' \) \

    | sort

  echo

  echo "===== POSSIBLE VISUAL SNAPSHOTS ====="

  find . \

    -type f \

    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) \

    | grep -Ei 'dashboard|workspace|operator|telemetry|matilda' \

    | sort || true

  echo

  echo "===== DASHBOARD COMMITS AFTER PHASE 91 ====="

  git log --oneline --all --since="2026-03-16" -- \

    public/index.html \

    public/dashboard.html \

    public/css \

    public/js \

    | head -120

  echo

  echo "===== EXTERNAL / BACKUP DIRECTORIES ====="

  find . \

    -maxdepth 3 \

    -type d \

    \( -iname '*backup*' -o -iname '*snapshot*' -o -iname '*recovery*' -o -iname '*archive*' \) \

    | sort

  echo

  echo "===== LIKELY NEXT ACTION ====="

  echo "Review candidate branches, tags, snapshots, and screenshots."

  echo "Identify the exact remembered dashboard lineage before any further restore."

} | tee "$REPORT"

git add discover-dashboard-recovery-candidates.sh "$REPORT"

git commit -m "Discover dashboard recovery candidates"

git push

