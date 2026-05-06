
# Phase 705 Storage Stabilization Policy

## Current validated runtime state

- Docker daemon: healthy

- Postgres container: healthy

- Dashboard container: running on port 3000

- Worker container: running

- Matilda advisory chat: validated

- Chat contract preserved:

  - mode: advisory-deterministic

  - execution: false

  - systemCoupling: false

## Current storage state

- Internal SSD recovered from critical exhaustion.

- External SSD mounted at `/Volumes/Rio Drive`.

- External SSD has substantial available capacity and is now the preferred archive/offload tier.

- Docker build cache was pruned to 0B.

- Active Docker images remain large and should not be deleted while active runtime is needed.

- Historical Git packfiles remain oversized and should not be manually deleted from `.git`.

## Storage policy

- Do not commit Docker image tarballs.

- Do not commit large snapshot tarballs.

- Do not store new heavy snapshots in the active repo root.

- Store future archives under:

  `/Volumes/Rio Drive/Motherboard_Storage/`

- Keep active runtime on internal SSD for now.

- Do not migrate Docker root dir while runtime is freshly recovered.

- Reassess Docker root migration only after several stable sessions.

## External SSD directory plan

- `/Volumes/Rio Drive/Motherboard_Storage/snapshots`

- `/Volumes/Rio Drive/Motherboard_Storage/archives`

- `/Volumes/Rio Drive/Motherboard_Storage/logs`

- `/Volumes/Rio Drive/Motherboard_Storage/exports`

- `/Volumes/Rio Drive/Motherboard_Storage/inactive_repos`

## Operating rule

One storage change at a time. Validate runtime after each meaningful change.

