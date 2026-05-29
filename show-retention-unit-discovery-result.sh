
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-unit-discovery-result-review-$(date +%Y%m%d_%H%M%S).md"

LATEST_DISCOVERY="$(ls -t retention-unit-discovery-*.md 2>/dev/null | head -1 || true)"

{

  echo "# Retention Unit Discovery Result Review"

  echo

  echo "Latest discovery report: ${LATEST_DISCOVERY:-NONE}"

  echo

  if [ -n "${LATEST_DISCOVERY:-}" ]; then

    echo "## Latest Discovery Contents"

    echo

    cat "$LATEST_DISCOVERY"

  else

    echo "No retention-unit-discovery report found."

  fi

  echo

  echo "## Current Manager Script Safety Markers"

  echo

  grep -nE "tar -czf|archive_name|gzip|zip|rm -f|KEEP_NEWEST|MIN_AGE|MANAGED|find" "$HOME/motherboard-backup-system/snapshot-manager-prod.sh" || true

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" show-retention-unit-discovery-result.sh

git commit -m "Review retention unit discovery result"

git push

