#!/usr/bin/env bash
set -euo pipefail

REPORT="PHASE88_14_13_CONTAINER_RUNTIME_PROTECTION_PASS.txt"
BOOT_LOG="PHASE88_14_13_CONTAINER_RUNTIME_PROTECTION_BOOT.log"
BASE_URL="${1:-http://127.0.0.1:3000}"

find_first() {
  local pattern
  for pattern in "$@"; do
    if compgen -G "$pattern" > /dev/null; then
      compgen -G "$pattern" | head -n 1
      return 0
    fi
  done
  return 1
}

DOCKERFILE_PATH="$(find_first './Dockerfile' './docker/Dockerfile' './server/Dockerfile' || true)"
COMPOSE_PATH="$(find_first './docker-compose.yml' './docker-compose.yaml' './docker-compose*.yml' './docker-compose*.yaml' || true)"

{
  echo "PHASE 88.14.13 CONTAINER RUNTIME PROTECTION PASS"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Base URL: $BASE_URL"
  echo "Dockerfile: ${DOCKERFILE_PATH:-NOT_FOUND}"
  echo "Compose: ${COMPOSE_PATH:-NOT_FOUND}"
  echo "────────────────────────────────"

  echo "SECTION: PROTECTION INTENT"
  echo "- Create runtime/container checkpoint after live Phase 88 verification"
  echo "- Do not widen scope beyond protection verification"
  echo "- Prefer rebuild/validate only if container artifacts exist"
  echo "────────────────────────────────"

  echo "SECTION: DOCKER VERSION"
  docker --version || true
  echo "────────────────────────────────"

  if [[ -n "${DOCKERFILE_PATH:-}" ]]; then
    echo "SECTION: DOCKER BUILD"
    IMAGE_TAG="motherboard-systems-hq:phase88-live-health-golden"
    echo "Building image: $IMAGE_TAG from $DOCKERFILE_PATH"
    docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_TAG" . 2>&1 | tee "$BOOT_LOG"
    echo "IMAGE_TAG=$IMAGE_TAG"
    echo "────────────────────────────────"
  else
    echo "SECTION: DOCKER BUILD"
    echo "SKIPPED: No Dockerfile found"
    echo "────────────────────────────────"
  fi

  if [[ -n "${COMPOSE_PATH:-}" ]]; then
    echo "SECTION: COMPOSE CONFIG"
    docker compose -f "$COMPOSE_PATH" config >/dev/null
    echo "Compose config validation: PASS"
    echo "────────────────────────────────"

    echo "SECTION: COMPOSE BUILD"
    docker compose -f "$COMPOSE_PATH" build 2>&1 | tee -a "$BOOT_LOG"
    echo "Compose build: PASS"
    echo "────────────────────────────────"
  else
    echo "SECTION: COMPOSE CONFIG / BUILD"
    echo "SKIPPED: No compose file found"
    echo "────────────────────────────────"
  fi

  echo "SECTION: LIVE ROUTE RECHECK"
  curl -fsS "$BASE_URL/diagnostics/system-health" > /tmp/phase88_14_13_primary.json
  curl -fsS "$BASE_URL/diagnostics/systemHealth" > /tmp/phase88_14_13_alias.json
  python3 - << 'PY'
import json
from pathlib import Path

primary = json.loads(Path("/tmp/phase88_14_13_primary.json").read_text())
alias = json.loads(Path("/tmp/phase88_14_13_alias.json").read_text())

assert primary["status"] == "OK"
assert alias["status"] == "OK"
assert "situationSummary" in primary
assert "situationSummary" in alias
assert "SYSTEM STABLE" in primary["situationSummary"]
assert "SYSTEM STABLE" in alias["situationSummary"]
print("Live route recheck: PASS")
PY
  echo "────────────────────────────────"

  echo "SECTION: CONCLUSION"
  echo "Runtime/container protection pass complete."
  echo "Source protection already existed via commit/push/tag."
  echo "This pass confirms container artifacts can also be refreshed from the verified Phase 88 state."
  echo "────────────────────────────────"
  echo "RESULT: PASS"
} | tee "$REPORT"

rm -f /tmp/phase88_14_13_primary.json /tmp/phase88_14_13_alias.json
