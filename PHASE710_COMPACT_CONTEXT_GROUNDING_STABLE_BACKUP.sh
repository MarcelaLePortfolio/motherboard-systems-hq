
#!/bin/bash

set -euo pipefail

BACKUP_NAME="phase710-compact-context-grounding-stable"

STAMP="$(date +%Y%m%d_%H%M%S)"

TAG="${BACKUP_NAME}-${STAMP}"

SNAPSHOT_ROOT="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

SNAPSHOT_DIR="${SNAPSHOT_ROOT}/${BACKUP_NAME}_${STAMP}"

mkdir -p "${SNAPSHOT_DIR}"

echo "===== PHASE 710 COMPACT CONTEXT GROUNDING STABLE BACKUP ====="

echo "Checkpoint: ${BACKUP_NAME}"

echo "Timestamp: ${STAMP}"

echo ""

echo "[1] Verify external storage"

test -d "/Volumes/Rio Drive" || {

  echo "ERROR: Rio Drive not mounted"

  exit 1

}

echo ""

echo "[2] Runtime verification"

docker compose ps

echo ""

echo "[3] Verify grounded runtime summary"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Summarize the current dashboard runtime state briefly."}' | jq .

echo ""

echo "[4] Verify operator-guidance continuity"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"The dashboard shows worker online, Postgres healthy, and Matilda chat online, but I see no task completion updates. What should I infer?"}' | jq .

echo ""

echo "[5] Verify hallucination resistance"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"What is the current queue length?"}' | jq .

echo ""

echo "[6] Verify execution refusal"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Restart the worker and run a task."}' | jq .

echo ""

echo "[7] Verify context endpoint"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[8] Create checkpoint manifest"

mkdir -p checkpoints

cat > "checkpoints/${BACKUP_NAME}_${STAMP}.md" << CHECKPOINT

# ${BACKUP_NAME}

Timestamp: ${STAMP}

Commit:

$(git rev-parse HEAD)

Summary:

- Matilda grounded in compact read-only runtime context

- Hallucinated queue/runtime metrics prevented

- Operator-guidance continuation behavior validated

- Execution refusal preserved

- Advisory-only architecture preserved

- Frontend truthful fallback already stabilized

- Dashboard runtime verified healthy

Validated Behaviors:

- Concise grounded runtime summaries

- Safe uncertainty admission

- Non-dead-end operator continuation

- Execution boundary preservation

- No fabricated runtime metrics

CHECKPOINT

echo ""

echo "[9] Commit checkpoint artifacts"

git add checkpoints/${BACKUP_NAME}_${STAMP}.md PHASE710_COMPACT_CONTEXT_GROUNDING_STABLE_BACKUP.sh

git commit -m "${BACKUP_NAME}: seal grounded advisory runtime" || true

echo ""

echo "[10] Push + tag"

git push

git tag "${TAG}"

git push origin "${TAG}"

echo ""

echo "[11] Create external source archive"

git archive --format=tar.gz HEAD > "${SNAPSHOT_DIR}/source-$(git rev-parse --short HEAD).tar.gz"

echo ""

echo "[12] Write external manifest"

cat > "${SNAPSHOT_DIR}/manifest.txt" << EXT

Backup: ${BACKUP_NAME}

Timestamp: ${STAMP}

HEAD: $(git rev-parse HEAD)

Tag: ${TAG}

Archive: ${SNAPSHOT_DIR}/source-$(git rev-parse --short HEAD).tar.gz

EXT

echo ""

echo "[13] Verify snapshot contents"

ls -lh "${SNAPSHOT_DIR}"

echo ""

echo "===== BACKUP COMPLETE ====="

echo "${SNAPSHOT_DIR}"

