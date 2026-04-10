#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase468_9_retry_push_after_dns_failure.txt"

mkdir -p docs

{
  echo "PHASE 468.9 — RETRY PUSH AFTER DNS FAILURE"
  echo "=========================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "STEP 1 — Current branch and HEAD"
  git branch --show-current 2>&1 || true
  git rev-parse HEAD 2>&1 || true
  echo

  echo "STEP 2 — Remote configuration"
  git remote -v 2>&1 || true
  echo

  echo "STEP 3 — DNS/network probe"
  ping -c 1 github.com 2>&1 || true
  echo
  curl -I --max-time 10 https://github.com 2>&1 || true
  echo

  echo "STEP 4 — Retry push"
  git push 2>&1 || true
  echo

  echo "STEP 5 — Final status"
  git status --short 2>&1 || true
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
