# Phase 487 Docker Controlled Prune Plan

Generated: Tue Apr 21 2026

## Purpose
This file defines the allowed prune tiers for Motherboard Systems HQ.

This is a planning artifact only.
It does not execute any prune action.

## Protected Asset
Do not touch:
- `motherboard_systems_hq_pgdata`

Reason:
- persistent Postgres state
- restore proof not yet validated

## Current Classified Assets

### Lowest-risk
- build cache

### Medium-risk
- exited containers
- unused images

### Not allowed in current corridor
- volumes
- any command using `--volumes`
- blind `docker system prune -a --volumes`

## Tiered Commands

### Tier 1 — Build cache only

    docker builder prune

More aggressive build-cache-only variant:

    docker builder prune -a

### Tier 2 — Exited containers only

    docker container prune

### Tier 3 — Unused images only

    docker image prune -a

### Tier 4 — Combined non-volume prune

    docker system prune -a

## Required Execution Order
1. Tier 1 only
2. Re-check system state
3. Tier 2 only if still needed
4. Re-check system state
5. Tier 3 only if still needed
6. Tier 4 only if explicitly chosen

## Mandatory Safety Rules
- Never use `--volumes`
- Never delete `motherboard_systems_hq_pgdata`
- Re-check Docker health after each tier
- Stop immediately if Docker returns EOF, timeout, or daemon errors again

## Recommended Next Safe Step
Generate a read-only helper that prints the tier commands for operator selection,
without executing them automatically.
