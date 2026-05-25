
# Phase 743 External Backup Thinning Recommendation

## Status

Recommendation only.

No files are deleted by this document.

## Current Finding

The external snapshots drive contains more full disaster recovery backups than are operationally necessary.

The latest successful external disaster recovery backup is:

`/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260525-122214`

Current free space:

`64Gi`

## Recommendation

Use a thinning strategy instead of preserving every full snapshot indefinitely.

## Preserve

Always preserve:

- latest successful full backup

- latest Phase 743 backup chain

- latest Phase 742D preservation chain

- latest canonical handoff chain

- milestone recovery checkpoints

- checkpoint manifests committed in Git

## Candidate Removal Class

Prefer removing:

- older superseded May 22 full disaster recovery snapshots

- redundant same-day full snapshots created minutes apart

- older pre-stabilization backups already superseded by newer verified May 25 snapshots

## Do Not Remove Yet

Do not remove:

- `full-disaster-recovery-20260525-122214`

- `full-disaster-recovery-20260525-120426`

- `full-disaster-recovery-20260525-114458`

- `full-disaster-recovery-20260525-113253`

- Phase 743 verification manifests

- Phase 742D preservation manifests

## Suggested Next Action

Generate a read-only candidate deletion list, then approve one targeted deletion batch.

## Locked Conclusion

The snapshots drive is over-retained.

Controlled thinning is appropriate, but only after producing a read-only candidate list and preserving the thinning recommendation in Git.

