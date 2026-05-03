# Phase 11 – Immediate Runtime Command

From current state (stubs in place, code pushed):

## ▶️ Do This Next

1) Rebuild and restart container so server.mjs stubs are live:

docker-compose build --no-cache
docker-compose down
docker-compose up -d

2) Then run:

scripts/phase11_delegate_task_curl.sh

Use the output + logs to decide next steps, as documented in:
- PHASE11_READY_FOR_CONTAINER_REBUILD.md
- PHASE11_NEXT_RUNTIME_AFTER_STUBS.md
