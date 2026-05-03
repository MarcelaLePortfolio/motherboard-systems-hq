#!/usr/bin/env bash
set -euo pipefail

OUTDIR="docs/health_snapshots"
STAMP="$(date -u +"%Y%m%d_%H%M%S")"
OUTFILE="$OUTDIR/HEALTH_SNAPSHOT_$STAMP.md"

mkdir -p "$OUTDIR"

PASS_COUNT=0
FAIL_COUNT=0

record_pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
}

record_fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

{
  echo "PHASE 70A HEALTH SNAPSHOT"
  echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "--------------------------------------------------"

  echo ""
  echo "## GIT"
  GIT_STATUS="$(git status --porcelain || true)"
  CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  CURRENT_TAG="$(git describe --tags --always || true)"

  if [ -z "$GIT_STATUS" ]; then
    echo "Working tree: CLEAN"
    record_pass
  else
    echo "Working tree: DIRTY"
    echo "$GIT_STATUS"
    record_fail
  fi

  echo ""
  echo "Branch:"
  echo "$CURRENT_BRANCH"

  echo ""
  echo "Tag:"
  echo "$CURRENT_TAG"

  echo ""
  echo "## LAYOUT CONTRACT"
  if bash scripts/_local/phase65_pre_commit_protection_gate.sh >/dev/null 2>&1; then
    echo "PASS"
    record_pass
  else
    echo "FAIL"
    record_fail
  fi

  echo ""
  echo "## DOCKER"
  if docker compose ps >/tmp/phase70a_docker_ps.txt 2>/tmp/phase70a_docker_ps.err; then
    cat /tmp/phase70a_docker_ps.txt
    record_pass
  else
    cat /tmp/phase70a_docker_ps.err
    record_fail
  fi

  echo ""
  echo "Dashboard container:"
  if DASHBOARD_STATUS="$(docker inspect -f '{{.State.Status}}' dashboard 2>/dev/null)"; then
    echo "$DASHBOARD_STATUS"
    if [ "$DASHBOARD_STATUS" = "running" ]; then
      record_pass
    else
      record_fail
    fi
  else
    echo "dashboard container not found"
    record_fail
  fi

  echo ""
  echo "## TELEMETRY DRIFT"
  if [ -f scripts/_local/phase68_drift_detection.sh ]; then
    if bash scripts/_local/phase68_drift_detection.sh >/tmp/phase70a_drift.txt 2>&1; then
      cat /tmp/phase70a_drift.txt
      record_pass
    else
      cat /tmp/phase70a_drift.txt
      record_fail
    fi
  else
    echo "drift script not present"
    record_fail
  fi

  echo ""
  echo "## REPLAY VALIDATION"
  if [ -f scripts/_local/phase69_replay_validation.sh ]; then
    if bash scripts/_local/phase69_replay_validation.sh >/tmp/phase70a_replay.txt 2>&1; then
      cat /tmp/phase70a_replay.txt
      record_pass
    else
      cat /tmp/phase70a_replay.txt
      record_fail
    fi
  else
    echo "replay script not present"
    record_fail
  fi

  echo ""
  echo "## DASHBOARD LOG TAIL"
  if docker logs dashboard --tail 30 >/tmp/phase70a_logs.txt 2>&1; then
    cat /tmp/phase70a_logs.txt
    record_pass
  else
    cat /tmp/phase70a_logs.txt
    record_fail
  fi

  echo ""
  echo "## SUMMARY"
  echo "PASS_COUNT=$PASS_COUNT"
  echo "FAIL_COUNT=$FAIL_COUNT"

  if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "OVERALL=PASS"
  else
    echo "OVERALL=FAIL"
  fi

  echo ""
  echo "SNAPSHOT COMPLETE"
} > "$OUTFILE"

rm -f \
  /tmp/phase70a_docker_ps.txt \
  /tmp/phase70a_docker_ps.err \
  /tmp/phase70a_drift.txt \
  /tmp/phase70a_replay.txt \
  /tmp/phase70a_logs.txt

echo "Health snapshot written to:"
echo "$OUTFILE"

if [ "$FAIL_COUNT" -eq 0 ]; then
  exit 0
fi

exit 1
