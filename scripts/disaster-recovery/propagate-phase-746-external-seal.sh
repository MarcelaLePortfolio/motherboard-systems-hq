
#!/usr/bin/env bash

set -euo pipefail

INTERNAL_SNAPSHOT="DISASTER_RECOVERY/phase-746-seal/2026-05-26T11-20-35"

EXTERNAL_ROOT="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

EXTERNAL_SNAPSHOT="$EXTERNAL_ROOT/full-disaster-recovery-20260526-phase746-sealed-927cb8ad"

echo "=== PHASE 746 EXTERNAL DR PROPAGATION ==="

if [ ! -d "/Volumes/Rio Drive" ]; then

  echo "ERROR: Rio Drive is not mounted."

  exit 1

fi

if [ ! -d "$INTERNAL_SNAPSHOT" ]; then

  echo "ERROR: Internal Phase 746 snapshot missing: $INTERNAL_SNAPSHOT"

  exit 1

fi

mkdir -p "$EXTERNAL_SNAPSHOT"

rsync -a --delete "$INTERNAL_SNAPSHOT/" "$EXTERNAL_SNAPSHOT/"

cat > "$EXTERNAL_SNAPSHOT/PHASE_746_EXTERNAL_DR_MANIFEST.txt" << MANIFEST

Phase 746 External Disaster Recovery Manifest

Repository:

- /Users/marcela-dev/Projects/Motherboard_Systems_HQ

Branch:

- phase730-semantic-section-extraction

Authoritative Phase 746 Final Seal Commit:

- 927cb8ad

Latest Propagation Script Commit Context:

- $(git rev-parse --short HEAD)

Internal Snapshot:

- $INTERNAL_SNAPSHOT

External Snapshot:

- $EXTERNAL_SNAPSHOT

Status:

- Phase 746 governance survivability consolidation sealed

- Drift-control gate established

- Seal index established

- Final seal established

- Internal DR snapshot propagated externally

- No execution runtime introduced

- No orchestration engine introduced

- No mutation authority introduced

- Preview remains read-only

- Renderer remains non-authoritative

- Sandbox remains isolated

- Governance remains observational/classificatory only

MANIFEST

echo "=== EXTERNAL SNAPSHOT CONTENTS ==="

find "$EXTERNAL_SNAPSHOT" -maxdepth 2 -type f | sort

echo ""

echo "=== CHECKSUM PARITY ==="

INTERNAL_HASH="$(awk '{print $1}' "$INTERNAL_SNAPSHOT/phase-746-seal.sha256")"

EXTERNAL_HASH="$(shasum -a 256 "$EXTERNAL_SNAPSHOT/phase-746-seal.tar.gz" | awk '{print $1}')"

echo "Internal: $INTERNAL_HASH"

echo "External: $EXTERNAL_HASH"

if [ "$INTERNAL_HASH" != "$EXTERNAL_HASH" ]; then

  echo "ERROR: checksum mismatch."

  exit 1

fi

ln -sfn "$EXTERNAL_SNAPSHOT" "$EXTERNAL_ROOT/latest-phase-746-seal"

echo ""

echo "PHASE 746 EXTERNAL DR PROPAGATION VERIFIED"

echo "$EXTERNAL_SNAPSHOT"

