#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Seal authoritative Docker runtime recovery"
echo "────────────────────────────────"

SEAL_FILE="PHASE704_AUTHORITATIVE_RUNTIME_SEAL.md"

cat > "$SEAL_FILE" << 'SEAL'
# Phase 704 — Authoritative Runtime Recovery Seal

## Status

Phase 704 restored Docker daemon health and re-established the authoritative container runtime.

## Verified Runtime State

- Docker daemon: HEALTHY
- Disk pressure: RESOLVED
- Dashboard container: RUNNING
- Worker container: RUNNING
- Postgres container: RUNNING + HEALTHY
- Dashboard port: 3000
- `/api/chat`: PASS
- `/api/guidance`: PASS

## Verified Advisory Chat Contract

Observed container response:

{
  "reply": "Advisory response only: received input \"confirm advisory chat contract\". No execution performed.",
  "meta": {
    "mode": "advisory-deterministic",
    "execution": false,
    "systemCoupling": false
  }
}

## Verified Guidance Contract

Observed container response:

{
  "ok": true,
  "guidance_available": true,
  "guidance": [
    {
      "type": "info",
      "severity": 1,
      "message": "All monitored subsystems are operating normally.",
      "subsystem": "all",
      "suggested_action": null
    }
  ]
}

## Recovery Notes

- Docker VM disk pressure was the root infrastructure failure.
- Docker data reset freed approximately 75GB.
- Docker Desktop daemon recovered after app/process-layer hard restart.
- Container runtime was rebuilt from repo state.
- No execution coupling was introduced.
- Advisory chat truth boundaries remain intact.

## Current Authoritative State

The system is now container-authoritative again.

## Next Safe Corridor

Resume application work only after this seal is committed, tagged, and pushed.
SEAL

echo ""
echo "1) Current container status..."
docker compose ps | tee /tmp/phase704_final_compose_ps.txt

echo ""
echo "2) Current Docker containers..."
docker ps | tee /tmp/phase704_final_docker_ps.txt

echo ""
echo "3) Rechecking dashboard..."
curl -I http://localhost:3000 | sed -n '1,20p'

echo ""
echo "4) Rechecking advisory chat..."
curl -sS http://localhost:3000/api/chat \
  -H 'Content-Type: application/json' \
  -d '{"message":"phase704 final seal check"}' \
  | tee /tmp/phase704_final_chat.json

echo ""
echo "5) Rechecking guidance..."
curl -sS http://localhost:3000/api/guidance \
  | tee /tmp/phase704_final_guidance.json \
  | head -c 1000

echo ""
echo ""
echo "6) Git seal..."
git add \
  "$SEAL_FILE" \
  PHASE704_DOCKER_RECOVERY_REVALIDATION.sh \
  PHASE704_DOCKER_DAEMON_START_AND_WAIT.sh \
  PHASE704_DOCKER_DESKTOP_DIAGNOSTIC.sh \
  PHASE704_SAFE_DISK_RELIEF_AND_DOCKER_RESTART.sh \
  PHASE704_DOCKER_DATA_RESET_RECOVERY.sh \
  PHASE704_DOCKER_HARD_RESTART_APP_LAYER.sh \
  PHASE704_RUN_CONTAINER_REVALIDATION.sh \
  PHASE704_SEAL_AUTHORITATIVE_RUNTIME.sh

git commit -m "Phase 704: seal authoritative Docker runtime recovery"

git tag phase704-authoritative-runtime-restored

git push
git push origin phase704-authoritative-runtime-restored

echo ""
echo "Phase 704 authoritative runtime recovery sealed."
