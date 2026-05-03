#!/usr/bin/env bash
set -euo pipefail

OUT="POST_PHASE95_CONTAINER_RECONCILIATION_AUDIT.txt"

{
  echo "POST-PHASE95 CONTAINER RECONCILIATION AUDIT"
  echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
  echo

  echo "== Current branch =="
  git branch --show-current || true
  echo

  echo "== Golden tag =="
  git tag --list 'v95.0-operator-cognition-interaction-golden' || true
  echo

  echo "== Container asset presence =="
  ls -1 Dockerfile docker-compose.yml .dockerignore 2>/dev/null || true
  echo

  echo "== Dockerfile =="
  sed -n '1,240p' Dockerfile 2>/dev/null || true
  echo

  echo "== docker-compose.yml =="
  sed -n '1,260p' docker-compose.yml 2>/dev/null || true
  echo

  echo "== .dockerignore =="
  sed -n '1,240p' .dockerignore 2>/dev/null || true
  echo

  echo "== Docker references across repo =="
  rg -n --hidden \
    --glob '!node_modules' \
    --glob '!.git' \
    --glob '!dist' \
    --glob '!build' \
    'docker|Dockerfile|docker-compose|compose' . || true
  echo

  echo "== Local container helper scripts =="
  find scripts/_local -type f 2>/dev/null | grep -Ei 'docker|container|compose' | sort || true
  echo

  echo "== Protection decision =="
  echo "Container assets already exist."
  echo "Next safe action is reconciliation, not blind containerization."
  echo "Do not alter runtime or compose topology until mismatch review is complete."
} > "$OUT"

cat "$OUT"
