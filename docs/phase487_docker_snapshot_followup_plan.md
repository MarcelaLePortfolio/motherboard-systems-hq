# Phase 487 — Docker Snapshot Follow-Up Plan

## Classification
SAFE — Read-only Docker audit

## Current truth
Git checkpointing succeeded:
- commit created
- branch pushed
- tag pushed

Docker snapshot did NOT succeed.

## Goal
Determine why Docker build failed before making any container-related mutation.

## Audit targets
1. Dockerfile presence
2. docker-compose presence
3. build context files
4. likely reasons the build stopped immediately

## Commands
echo "=== docker-related files ==="
find . \
  \( -path './.git' -o -path './node_modules' -o -path './.next' \) -prune -o \
  -type f \
  \( -iname 'Dockerfile' -o -iname 'dockerfile' -o -iname 'docker-compose.yml' -o -iname 'docker-compose.yaml' -o -iname '.dockerignore' \) \
  | sort

echo
echo "=== Dockerfile candidates (first 120 lines each) ==="
for f in $(find . \
  \( -path './.git' -o -path './node_modules' -o -path './.next' \) -prune -o \
  -type f \
  \( -iname 'Dockerfile' -o -iname 'dockerfile' \)); do
  echo "--- $f ---"
  sed -n '1,120p' "$f"
  echo
done

echo
echo "=== .dockerignore (first 120 lines, if present) ==="
for f in $(find . \
  \( -path './.git' -o -path './node_modules' -o -path './.next' \) -prune -o \
  -type f \
  -iname '.dockerignore'); do
  echo "--- $f ---"
  sed -n '1,120p' "$f"
  echo
done

## Status
READY — Safe and bounded
