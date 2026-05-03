#!/usr/bin/env bash
set -euo pipefail

TAG="v401.7-trust-reliability-semantics-complete"

git tag -a "$TAG" -m "Phase 401.7 trust reliability semantics complete"
git push origin "$TAG"

docker compose up -d --build
docker compose ps
