
#!/bin/bash

set -euo pipefail

echo "== PHASE 731 EXECUTE REPAIRED DR SNAPSHOT REFRESH =="

echo

echo "Repository:"

pwd

echo

echo "Branch:"

git branch --show-current

echo

echo "HEAD:"

git rev-parse --short HEAD

echo

echo "Verifying clean synchronization..."

git fetch origin

LOCAL=$(git rev-parse @)

REMOTE=$(git rev-parse @{u})

if [[ "$LOCAL" != "$REMOTE" ]]; then

  echo "SYNC FAILURE: local and remote diverged"

  exit 1

fi

echo "SYNC VERIFIED"

echo

echo "Running syntax validation..."

bash -n PHASE719_FULL_DISASTER_RECOVERY_BACKUP.sh

echo "SYNTAX VALIDATION PASSED"

echo

echo "Executing disaster recovery backup..."

./PHASE719_FULL_DISASTER_RECOVERY_BACKUP.sh

echo

echo "Capturing refresh state..."

mkdir -p runtime/semantic-preview-planning

cat > runtime/semantic-preview-planning/PHASE731_DISASTER_RECOVERY_REFRESH_STATE.md << STATEEOF

# Phase 731 Disaster Recovery Refresh State

## Status

External disaster recovery snapshot refresh completed successfully.

## Branch

$(git branch --show-current)

## Commit

$(git rev-parse HEAD)

## Short Commit

$(git rev-parse --short HEAD)

## Timestamp

$(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Corridor Integrity

The refresh preserved the observability-only corridor and introduced no execution, orchestration, renderer, Preview, routing, or persistence mutations.

STATEEOF

echo

echo "PHASE 731 DISASTER RECOVERY REFRESH COMPLETE"

