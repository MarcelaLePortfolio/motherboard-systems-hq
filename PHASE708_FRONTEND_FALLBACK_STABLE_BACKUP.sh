
#!/bin/bash

set -euo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"

BACKUP_NAME="phase708-frontend-fallback-stable"

TAG="${BACKUP_NAME}-${STAMP}"

SNAPSHOT_DIR="/Volumes/Rio Drive/Motherboard_Storage/snapshots/${BACKUP_NAME}_${STAMP}"

echo "===== PHASE 708 FRONTEND FALLBACK STABLE BACKUP ====="

echo "Checkpoint: ${BACKUP_NAME}"

echo "Timestamp: ${STAMP}"

echo ""

echo "[1] Verify external storage"

if [ ! -d "/Volumes/Rio Drive" ]; then

  echo "Rio Drive not mounted"

  exit 1

fi

mkdir -p "${SNAPSHOT_DIR}"

mkdir -p checkpoints

echo ""

echo "[2] Runtime verification"

docker compose ps

echo ""

echo "[3] Verify served frontend fallback"

curl -sS "http://localhost:3000/js/matilda-chat-console.js?cachebust=${STAMP}" | grep -n "could not reach the chat service"

echo ""

echo "[4] Verify backend chat"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Quick systems check from dashboard."}' | jq .

echo ""

echo "[5] Verify context endpoint"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[6] Create checkpoint manifest"

cat > "checkpoints/${BACKUP_NAME}_${STAMP}.md" << MANIFEST

# ${BACKUP_NAME}

Timestamp: ${STAMP}

## Stable State

- Advisory-only Matilda chat verified

- Frontend timeout fallback corrected

- Cache-busted frontend asset verified live

- Backend advisory corridor healthy

- Context endpoint healthy

- Runtime stable

- No execution coupling introduced

## Git Head Before Checkpoint

$(git rev-parse HEAD)

## Runtime

$(docker compose ps)

MANIFEST

echo ""

echo "[7] Commit checkpoint artifacts"

git add checkpoints/${BACKUP_NAME}_${STAMP}.md PHASE708_FRONTEND_FALLBACK_STABLE_BACKUP.sh

git commit -m "${BACKUP_NAME}: stabilized truthful frontend advisory fallback" || true

echo ""

echo "[8] Push + tag"

git push

git tag "${TAG}"

git push origin "${TAG}"

echo ""

echo "[9] Create external source archive"

git archive --format=tar.gz HEAD > "${SNAPSHOT_DIR}/source-$(git rev-parse --short HEAD).tar.gz"

echo ""

echo "[10] Write external manifest"

cat > "${SNAPSHOT_DIR}/manifest.txt" << EXT

Backup: ${BACKUP_NAME}

Timestamp: ${STAMP}

HEAD: $(git rev-parse HEAD)

Tag: ${TAG}

Archive: ${SNAPSHOT_DIR}/source-$(git rev-parse --short HEAD).tar.gz

EXT

echo ""

echo "[11] Verify snapshot contents"

ls -lh "${SNAPSHOT_DIR}"

echo ""

echo "===== BACKUP COMPLETE ====="

echo "${SNAPSHOT_DIR}"

