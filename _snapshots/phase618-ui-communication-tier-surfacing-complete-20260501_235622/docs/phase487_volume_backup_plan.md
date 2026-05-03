# Phase 487 Protected Volume Backup Plan

Generated: Tue Apr 21 2026

## Purpose
This adds a non-destructive backup script for the protected Postgres volume.

## Protected asset
- `motherboard_systems_hq_pgdata`

## Safety posture
- Read-only mount from protected volume
- Backup output written outside repo
- No restore executed
- No volume mutation
- No volume deletion

## Backup destination
- `~/Desktop/Motherboard_Systems_HQ_Backups/postgres_volume/<timestamp>/`

## Produced artifacts
- `motherboard_systems_hq_pgdata.tar.gz`
- `backup_manifest.txt`

## Next safe step
Run the backup script once, verify the archive exists, then generate a restore script without executing restore yet.
