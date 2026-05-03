# Worker lane (Phase 31.8)

This repo supports running task workers as a separate docker-compose project ("worker lane") that connects to the main stack's external network.

## Prereqs
Main stack must be up (creates the external network):
- docker compose -p motherboard_systems_hq up -d

## Commands
Bring up N workers (default N=2):
- WORKER_N=2 scripts/worker_up.sh

Tail worker logs:
- scripts/worker_logs.sh

Bring workers down:
- scripts/worker_down.sh

## Defaults
- WORKER_PROJECT defaults to: motherboard_workers
- WORKER_N defaults to: 2

## Guardrails (expected failures)
- If main network is missing: you’ll be told to bring up the main stack first.
- If WORKER_PROJECT=motherboard_systems_hq: script refuses (prevents touching main stack).
- If transcript artifacts (lines starting with "heredoc>") are present in the script file: script refuses.

## Optional: crash/reclaim test
1) Start workers, create tasks, then hard-kill one worker container.
2) Run scripts/phase31_7_verify_container_reclaim.sh to confirm invariants.
