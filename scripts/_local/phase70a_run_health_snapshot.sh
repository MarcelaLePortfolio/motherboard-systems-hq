#!/usr/bin/env bash
set -euo pipefail

OUTDIR="docs/health_snapshots"
STAMP=$(date -u +"%Y%m%d_%H%M%S")
OUTFILE="$OUTDIR/HEALTH_SNAPSHOT_$STAMP.md"

mkdir -p "$OUTDIR"

{
echo "PHASE 70A HEALTH SNAPSHOT"
echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "--------------------------------------------------"

echo ""
echo "## GIT"
git status --porcelain || true
echo ""
echo "Branch:"
git rev-parse --abbrev-ref HEAD
echo ""
echo "Tag:"
git describe --tags --always || true

echo ""
echo "## LAYOUT CONTRACT"
if bash scripts/_local/phase65_pre_commit_protection_gate.sh >/dev/null 2>&1; then
  echo "PASS"
else
  echo "FAIL"
fi

echo ""
echo "## DOCKER"
docker compose ps || true

echo ""
echo "Dashboard container:"
docker inspect -f '{{.State.Status}}' dashboard || true

echo ""
echo "## TELEMETRY DRIFT"
if [ -f scripts/_local/phase68_drift_detection.sh ]; then
  bash scripts/_local/phase68_drift_detection.sh || true
else
  echo "drift script not present"
fi

echo ""
echo "## REPLAY VALIDATION"
if [ -f scripts/_local/phase69_replay_validation.sh ]; then
  bash scripts/_local/phase69_replay_validation.sh || true
else
  echo "replay script not present"
fi

echo ""
echo "## DASHBOARD LOG TAIL"
docker logs dashboard --tail 30 || true

echo ""
echo "SNAPSHOT COMPLETE"

} > "$OUTFILE"

echo "Health snapshot written to:"
echo "$OUTFILE"

