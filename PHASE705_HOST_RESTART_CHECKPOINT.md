# Phase 705 Host Restart Checkpoint

## Current state
- Docker Desktop app launches, but Docker daemon/server does not become available.
- Docker client is present.
- Docker server socket remains unavailable.
- Dashboard rebuild must remain paused.
- Internal disk recovered from critical exhaustion to approximately 13GB free.
- External SSD is mounted at `/Volumes/Rio Drive` with approximately 788GB free.
- Do not attempt another Docker rebuild until after host restart.

## Confirmed safe progress
- Loose snapshot tarballs were removed from the repo.
- Immediate no-space-left condition was relieved.
- Phase 705 Matilda advisory chat patch was applied.
- A prior broad server overwrite was corrected by restoring from the previous baseline and patching only the chat route.
- Docker process reset script was committed at `31921f99`.

## Next action after Mac restart
1. Reopen terminal.
2. `cd /Users/marcela-dev/Projects/Motherboard_Systems_HQ`
3. Confirm disk:
   `df -h`
4. Confirm Docker daemon:
   `docker info | grep -E "Server Version|Docker Root Dir|Storage Driver"`
5. Only if Docker daemon is healthy, run:
   `docker compose ps`
6. Do not rebuild until daemon health is confirmed.

## Storage strategy
- Do not buy new hardware yet.
- Use `/Volumes/Rio Drive` as external archive/offload tier.
- Keep active runtime on internal SSD until Docker is stable.
- Move snapshots, tarballs, archives, old repos, and large logs to external SSD.
- Avoid Docker root migration until daemon integrity is restored.
