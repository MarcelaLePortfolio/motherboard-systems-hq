# Phase 487 Docker Storage Classification

Generated: Tue Apr 21 2026

## Current Read-Only Findings

### Docker health gate
- Docker storage inspection completed successfully after force recovery.
- Prior EOF failure is no longer present.
- Storage can now be classified safely.
- No prune has been executed.

### Current storage snapshot
- Images: 2 total, 2 inactive from a runtime perspective, 1.109GB reclaimable shown by Docker
- Containers: 2 total, 0 active, 24.58kB reclaimable
- Local volumes: 1 total, 1 active, 40.67MB, 0B reclaimable
- Build cache: 13 entries, 0 active, 545.6MB total, 160MB reclaimable

### Volumes
Protected:
- `motherboard_systems_hq_pgdata`

Reason:
- This is the Postgres persistent data volume.
- It must be treated as stateful and non-disposable unless backup + restore proof is complete.

### Containers
Disposable after classification:
- `motherboard_systems_hq-dashboard-1`
- `motherboard_systems_hq-postgres-1`

Current state:
- both are exited
- both returned exit 255
- neither is currently running

Interpretation:
- containers are runtime shells, not the durable database itself
- removing exited containers is lower risk than touching volumes
- however, do not remove them until controlled prune rules are scripted and checkpointed

### Images
Potentially disposable after confirmation:
- `motherboard_systems_hq-dashboard:latest`
- `postgres:16-alpine`

Interpretation:
- images are reconstructable artifacts
- they are not the persistent database state
- they should still not be pruned blindly while recovery behavior is being stabilized

### Build cache
Lowest-risk prune class:
- 13 inactive cache entries
- 160MB explicitly reclaimable

Interpretation:
- build cache is reconstructable
- this is the safest prune candidate class

## Storage Class Policy

### Protected
- named Docker volume backing Postgres data
- anything required for restore validation
- anything not yet classified

### Reconstructable
- images
- exited containers
- build cache

### Lowest-risk prune order
1. Build cache only
2. Exited containers
3. Unused images
4. Volumes only with explicit backup + restore proof

## Recommended Next Safe Corridor

Phase 487 should now move to:

**Controlled prune script generation only**
- no execution yet
- explicit exclusion of protected volume
- explicit ordering by risk class
- checkpoint before any prune action

## Decision

Safe next step:
- generate a non-executed controlled prune script
- classify commands by risk tier
- require operator-run selection per tier

Not yet safe:
- volume deletion
- blind `docker system prune -a --volumes`
- anything that touches `motherboard_systems_hq_pgdata`
