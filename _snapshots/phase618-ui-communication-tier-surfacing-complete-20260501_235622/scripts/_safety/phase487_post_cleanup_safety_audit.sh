#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
SUMMARY_PATH="$REPO_ROOT/docs/phase487_post_cleanup_safety_audit_summary.md"

cd "$REPO_ROOT"

{
  echo "# Phase 487 — Post-Cleanup Safety Audit Summary"
  echo
  echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
  echo
  echo "## Disk status"
  echo '```'
  df -h .
  echo '```'
  echo
  echo "## Git storage status"
  echo '```'
  du -sh .git
  git count-objects -vH
  echo '```'
  echo
  echo "## Required path existence"
  echo '```'
  for path in \
    scripts \
    src \
    public \
    server \
    routes \
    governance \
    cognition \
    tests \
    docs \
    scripts/_local \
    scripts/_safety \
    scripts/_local/agent-runtime \
    mirror \
    agents
  do
    if [ -e "$path" ]; then
      echo "OK   $path"
    else
      echo "MISS $path"
    fi
  done
  echo '```'
  echo
  echo "## Critical runtime file existence"
  echo '```'
  for path in \
    package.json \
    pnpm-lock.yaml \
    tsconfig.json \
    scripts/_local/agent-runtime/launch-cade.ts \
    scripts/_local/agent-runtime/launch-matilda.ts \
    scripts/_local/agent-runtime/launch-effie.ts \
    mirror/agent.ts \
    agents/cade.ts \
    agents/effie.ts
  do
    if [ -e "$path" ]; then
      echo "OK   $path"
    else
      echo "MISS $path"
    fi
  done
  echo '```'
  echo
  echo "## Bounded reference sample"
  echo '```'
  grep -RIn \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude-dir=.next \
    -E 'scripts_backup|scripts_backup_2|snapshots|memory/|logs/|server\.log|ticker-events\.log' \
    . 2>/dev/null | head -60 || true
  echo '```'
  echo
  echo "## Determination"
  echo "- Review any \`MISS\` lines before further cleanup."
  echo "- Review surviving references before runtime testing."
  echo "- agents/cade.ts and agents/effie.ts missing may be acceptable only if this repo intentionally uses a different agent source layout."
  echo "- This summary is intentionally bounded."
} > "$SUMMARY_PATH"

sed -n '1,220p' "$SUMMARY_PATH"
