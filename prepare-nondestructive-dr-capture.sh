#!/usr/bin/env bash
set -euo pipefail

# PREPARATION ONLY — NO BACKUP EXECUTION.

REPO="/Users/marcela-dev/Projects/motherboard-systems-hq-clean"
BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="124c2e015c496b8c60c2c6bbbb42f89dd1ad35a2"
BACKUP_ROOT="/Volumes/Rio Drive/backups"

cat <<PLAN
NON-DESTRUCTIVE DR CAPTURE — PREPARATION PLAN

Repository: $REPO
Branch: $BRANCH
Expected HEAD: $EXPECTED_HEAD
Destination: $BACKUP_ROOT

PRECONDITIONS
- Verify repository, branch, HEAD, and remote alignment.
- Record all existing working-tree changes.
- Preserve the 356 previously observed working-tree entries.
- Verify Rio Drive identity, mount point, and available capacity.
- Verify SQLite integrity and database activity.
- Preserve the protected React dashboard recovery boundary.

PROPOSED CAPTURE
1. Create a unique checkpoint without overwriting existing backups.
2. Capture Git history using git bundle.
3. Preserve tracked, modified, and untracked repository files.
4. Create a transactionally consistent SQLite backup.
5. Record Git status, branch, HEAD, and timestamp.
6. Record the protected React dashboard recovery boundary.
7. Generate SHA-256 checksums and a recovery manifest.
8. Verify archive integrity and Git bundle.
9. Verify the captured SQLite database.
10. Confirm existing backups remain untouched.

CONFIDENTIALITY
- Treat .env and credentials as confidential.
- Do not publish or upload backup contents.
- Require a separate encryption decision before capture.
- Do not assume Git ignore rules protect secrets.

PROHIBITED
- No deletion or rotation of existing backups.
- No git reset, clean, stash, or checkout.
- No automatic rollback.
- No dashboard restoration.
- No production restart or deployment.
- No execution of historical DR scripts.

STATUS=PROCEDURE_PREPARED_FOR_REVIEW
BACKUP_EXECUTION=NOT_AUTHORIZED
PRODUCTION_ROLLBACK=NOT_AUTHORIZED
PLAN
