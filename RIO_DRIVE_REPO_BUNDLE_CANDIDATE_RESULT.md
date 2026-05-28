
# Rio Drive Repo Bundle Candidate Result

Rio Drive disaster-proof backups were inspected through recursive repo-bundle discovery.

## Candidates Found

### `/Volumes/Rio Drive/backups/.staging_20260527_160657/repo.bundle`

- Head commit: `0139b201 finalize external-drive-only DR system with enforced mount validation`

- `public/index.html`: 10283 bytes

- `public/dashboard.html`: 31026 bytes

- Status: older/intermediate dashboard lineage

### `/Volumes/Rio Drive/Motherboard_Storage/snapshots/full-disaster-recovery-20260525-153721/git/motherboard-systems-hq.bundle`

- Head commit: `a7fc8054 Seal Phase 743 authoritative operational DR runtime state`

- `public/index.html`: 45658 bytes

- `public/dashboard.html`: 36216 bytes

- Status: stronger candidate than Phase 91, but still must be visually confirmed before restore

## Preview URLs

- `http://localhost:8099/_dashboard_candidate_previews/rio-drive-repo-bundles-v2/repo/index.html`

- `http://localhost:8099/_dashboard_candidate_previews/rio-drive-repo-bundles-v2/motherboard-systems-hq/index.html`

## Boundary

Do not restore either candidate unless one visually matches the remembered latest dashboard.

If neither candidate matches, continue searching Rio Drive disaster-proof backups by expanding beyond repo bundles and source archives into full snapshot directories and external backup project copies.

