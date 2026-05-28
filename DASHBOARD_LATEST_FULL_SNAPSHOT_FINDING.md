
# Dashboard Latest Full Snapshot Finding

Rio Drive disaster-proof backups were successfully inspected.

The strongest recovered candidates are:

- Phase 744 full DR snapshot: 45658-byte `public/index.html`

- Phase 743 full DR snapshot: 45658-byte `public/index.html`

- Phase 631/630 runtime proof snapshots: 46141-byte `public/index.html`

The latest external backup snapshot from `20260527_141840` is older/intermediate and should not be restored as the remembered latest UI.

Next action: visually inspect the Phase 744 / Phase 743 / Phase 631 candidates before restoring anything.

Preview root:

http://localhost:8099/_dashboard_candidate_previews/rio-drive-latest-full-snapshot/

Most likely candidates:

- candidate-03-full-disaster-recovery-20260526-phase744-architecture-494f61b3

- candidate-04-full-disaster-recovery-20260526-phase743-sealed-13f8eb4a

- candidate-07-phase631-live-runtime-proof-containerized

Do not restore until one candidate is visually confirmed.

