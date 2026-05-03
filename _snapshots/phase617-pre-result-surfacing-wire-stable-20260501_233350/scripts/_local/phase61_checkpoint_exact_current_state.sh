#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

CHECKPOINT_NAME="phase61-exact-current-state-20260310"
SOURCE_TAG="v61.1-${CHECKPOINT_NAME}"
IMAGE_SOURCE="motherboard_systems_hq-dashboard:latest"
IMAGE_FROZEN="motherboard_systems_hq-dashboard:${CHECKPOINT_NAME}"
ARCHIVE_PATH=".artifacts/docker/motherboard_systems_hq-dashboard_${CHECKPOINT_NAME}.tar"
DOC_PATH="docs/checkpoints/PHASE61_EXACT_CURRENT_STATE_20260310.md"

mkdir -p .artifacts/docker docs/checkpoints

docker image inspect "$IMAGE_SOURCE" >/dev/null
docker image tag "$IMAGE_SOURCE" "$IMAGE_FROZEN"
docker save -o "$ARCHIVE_PATH" "$IMAGE_FROZEN"

cat > "$DOC_PATH" <<DOC
# Phase 61 Exact Current State Checkpoint — 2026-03-10

This checkpoint preserves the exact currently recovered and partially restored Phase 61 state.

## What is present

- left and right side workspace consolidations
- uniform button treatment
- task events wired

## What is intentionally still missing / reverted

- some redundant tab-title cleanup remains undone
- Atlas Subsystem Status is currently half-width on the right side

## Source checkpoint

- tag: \`${SOURCE_TAG}\`

## Runtime checkpoint

- frozen image: \`${IMAGE_FROZEN}\`
- archive: \`${ARCHIVE_PATH}\`

## Restore command

\`\`\`bash
scripts/_local/restore_phase61_exact_current_state.sh
\`\`\`
DOC

git add "$DOC_PATH"
git commit -m "Record Phase 61 exact current state checkpoint"
git push

git tag -a "$SOURCE_TAG" -m "Phase 61 exact current state checkpoint"
git push origin "$SOURCE_TAG"
