
# Phase 743 External Backup Disk-Space Cleanup Plan

## Status

Planning-only.

No backup files were deleted by this plan.

## Current Failure

The external backup failed because `/Volumes/Rio Drive` is full.

## Current Evidence

Latest committed state:

`aacc51f7` — Record Phase 743 external backup diskspace failure checkpoint

Current preserved Phase 743 commits:

- `efec345c` — Start Phase 743 execution corridor selection

- `b29f482d` — Record Phase 743 external backup verification checkpoint

- `d50888ae` — Define Phase 743 first bounded execution path artifact contract

- `aacc51f7` — Record Phase 743 external backup diskspace failure checkpoint

Latest successful external backup before disk-space failure:

`/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260525-120426`

External disk finding:

- `/Volumes/Rio Drive` reported 100% capacity.

- Available space reported 2.2Gi.

- Snapshot directory size reported 785G.

- Full disaster recovery snapshots are approximately 6.7G each.

- One older snapshot is 8.4G.

- One older Phase 719 tarball is 23G.

## Cleanup Principle

Do not delete the newest successful external backup:

`full-disaster-recovery-20260525-120426`

Do not delete Phase 742D or Phase 743 checkpoints until a newer successful backup exists.

Preferred cleanup candidates are older full disaster recovery directories from May 22 that are superseded by newer May 25 snapshots.

## Candidate Cleanup Set

The following older full snapshot directories are safe candidates for user-approved removal because newer May 25 full disaster recovery snapshots exist:

- `/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260522-091924`

- `/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260522-123946`

- `/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260522-124522`

- `/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260522-125123`

- `/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260522-125409`

- `/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260522-125721`

- `/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260522-130302`

- `/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260522-130811`

- `/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260522-131643`

- `/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260522-132403`

## Estimated Recovery

Removing only the listed candidate full snapshot directories may recover approximately 68G to 75G.

## Locked Conclusion

Cleanup should be explicit, targeted, and user-approved.

After cleanup, rerun the external disaster recovery backup and record a successful verification checkpoint.

