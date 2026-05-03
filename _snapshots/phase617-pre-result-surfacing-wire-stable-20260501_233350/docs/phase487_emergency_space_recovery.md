# Phase 487 — Emergency Space Recovery

## Trigger
Disk exhaustion blocked:
- file creation
- report generation
- git index lock creation
- commit/push continuation

## Immediate recovery action
Removed the highest-volume working-tree artifact archives under `.artifacts/docker/` to restore writable capacity.

## Files targeted
- `.artifacts/docker/motherboard_systems_hq-dashboard_phase61-layout-contract-locked-20260310.tar`
- `.artifacts/docker/motherboard_systems_hq-dashboard_phase61-exact-current-state-20260310.tar`
- `.artifacts/docker/motherboard_systems_hq-dashboard_v60.2-operator-console-polish-preview.tar`
- `.artifacts/docker/motherboard_systems_hq-dashboard_v60.1-recovered-stable-dashboard-checkpoint-20260309.tar`
- `.artifacts/docker/motherboard_systems_hq-dashboard_v60.1-dashboard-hierarchy-polish-preview.tar`
- `.artifacts/docker/motherboard_systems_hq-dashboard_v60.0-agent-pool-polish-preview.tar`

## Why these files
They were the largest working-tree files confirmed by the containment report and were not part of the protected backend/governance/approval/execution logic corridor.

## Important constraint
This restores operational headroom, but does **not** solve historical repository bloat inside `.git`.

## Required next corridor
1. Commit removal of oversized working-tree artifact archives.
2. Redirect future large artifacts outside the repo.
3. Add retention discipline for archive creation.
4. Plan a separate `.git` history reduction corridor only after stable recovery is restored.
