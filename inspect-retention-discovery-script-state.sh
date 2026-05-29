
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-discovery-script-state-$(date +%Y%m%d_%H%M%S).md"

{

  echo "# Retention Discovery Script State Inspection"

  echo

  echo "## Script Exists"

  ls -l verify-retention-unit-discovery.sh 2>/dev/null || true

  echo

  echo "## Script Syntax"

  bash -n verify-retention-unit-discovery.sh 2>&1 || true

  echo

  echo "## Script Preview"

  sed -n '1,220p' verify-retention-unit-discovery.sh 2>/dev/null || true

  echo

  echo "## Recent Discovery Reports"

  ls -ltrh retention-unit-discovery-*.md 2>/dev/null | tail -10 || true

  echo

  echo "## Git Status"

  git status --short

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" inspect-retention-discovery-script-state.sh

git commit -m "Inspect retention discovery script state"

git push

