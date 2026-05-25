
# Phase 743 External Backup Retention Policy

## Status

Active operational guidance.

Planning-only governance document.

## Current Storage State

Latest verified external disaster recovery snapshot:

`/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260525-122214`

Current available space after cleanup:

`64Gi`

Approximate full snapshot size:

`6.7G`

## Operational Free-Space Targets

Healthy operational target:

- Maintain at least `50Gi` free space.

Warning threshold:

- Below `40Gi` free space.

Critical threshold:

- Below `25Gi` free space.

No new full backup generation should occur below the critical threshold until cleanup or alternate storage expansion occurs.

## Retention Principles

Never delete:

- latest successful full external backup

- latest stabilization-chain checkpoints

- latest canonical handoff preservation chain

- latest execution-corridor checkpoints

- latest recovery-validation checkpoints

Preferred cleanup targets:

- superseded older full snapshot directories

- older redundant same-day snapshots

- outdated pre-stabilization snapshots already superseded by newer verified chains

## Cleanup Governance

Before cleanup:

- verify newer successful backup exists

- verify repo is synchronized

- verify working tree is clean

- record cleanup plan checkpoint

After cleanup:

- verify recovered disk space

- rerun external disaster recovery backup

- record successful verification checkpoint

## Locked Conclusion

External disaster recovery continuity is now operationally sustainable if free-space thresholds are continuously enforced.

