#!/usr/bin/env bash

set -euo pipefail

printf 'Enter the full path to the approved Mission Control mockup image: '
IFS= read -r MOCKUP_PATH

MOCKUP_PATH="${MOCKUP_PATH#\'}"
MOCKUP_PATH="${MOCKUP_PATH%\'}"
MOCKUP_PATH="${MOCKUP_PATH#\"}"
MOCKUP_PATH="${MOCKUP_PATH%\"}"

if [ ! -f "$MOCKUP_PATH" ]; then
  printf '\nSTOP: mockup image not found.\n'
  printf 'Received path:\n%s\n\n' "$MOCKUP_PATH"
  exit 1
fi

REQUIRED_FILES=(
  docs/MISSION_CONTROL_PRESENTATION_SPECIFICATION_V1.md
  docs/MISSION_CONTROL_IMPLEMENTATION_PLAN_V1.md
  docs/claude-handoffs/MISSION_CONTROL_PRESENTATION_V1_CLAUDE_TASK.md
  client/src/shell/MissionDashboardWorkspace.tsx
  client/src/shell/mission-dashboard.css
  client/src/shell/mission-dashboard-presentation.css
  client/src/mission-control/missionReadApi.ts
  client/src/mission-control/missionPresentationMapper.ts
)

for FILE in "${REQUIRED_FILES[@]}"; do
  [ -f "$FILE" ] || { echo "Missing required file: $FILE"; exit 1; }
done

BUNDLE_ROOT="$(mktemp -d)"
trap 'rm -rf "$BUNDLE_ROOT"' EXIT

BUNDLE_DIR="$BUNDLE_ROOT/mission-control-presentation-v1"

mkdir -p \
  "$BUNDLE_DIR/docs" \
  "$BUNDLE_DIR/reference"

for FILE in \
  client/src/shell/MissionDashboardWorkspace.tsx \
  client/src/shell/mission-dashboard.css \
  client/src/shell/mission-dashboard-presentation.css \
  client/src/mission-control/missionReadApi.ts \
  client/src/mission-control/missionPresentationMapper.ts
do
  mkdir -p "$BUNDLE_DIR/$(dirname "$FILE")"
done

cp docs/MISSION_CONTROL_PRESENTATION_SPECIFICATION_V1.md \
   "$BUNDLE_DIR/docs/"

cp docs/MISSION_CONTROL_IMPLEMENTATION_PLAN_V1.md \
   "$BUNDLE_DIR/docs/"

cp docs/claude-handoffs/MISSION_CONTROL_PRESENTATION_V1_CLAUDE_TASK.md \
   "$BUNDLE_DIR/CLAUDE_TASK.md"

cp client/src/shell/MissionDashboardWorkspace.tsx \
   "$BUNDLE_DIR/client/src/shell/"

cp client/src/shell/mission-dashboard.css \
   "$BUNDLE_DIR/client/src/shell/"

cp client/src/shell/mission-dashboard-presentation.css \
   "$BUNDLE_DIR/client/src/shell/"

cp client/src/mission-control/missionReadApi.ts \
   "$BUNDLE_DIR/client/src/mission-control/"

cp client/src/mission-control/missionPresentationMapper.ts \
   "$BUNDLE_DIR/client/src/mission-control/"

cp "$MOCKUP_PATH" \
   "$BUNDLE_DIR/reference/$(basename "$MOCKUP_PATH")"

cat > "$BUNDLE_DIR/BUNDLE_MANIFEST.md" << 'MANIFEST'
# Mission Control Presentation v1 Bundle

## Included

- CLAUDE_TASK.md
- MISSION_CONTROL_PRESENTATION_SPECIFICATION_V1.md
- MISSION_CONTROL_IMPLEMENTATION_PLAN_V1.md
- Approved mockup
- Minimal bounded frontend implementation files

## Authority

1. Architectural invariants
2. Presentation Specification
3. Implementation Plan
4. Approved mockup
5. Existing Mission Read frontend integration

## Boundary

No backend, database, governance, routing, project-context, conversation, or runtime changes are authorized.
MANIFEST

(
cd "$BUNDLE_DIR"

find . \
  -type f \
  ! -name SHA256SUMS \
  -print0 |
sort -z |
xargs -0 shasum -a 256 > SHA256SUMS
)

rm -f handoffs/mission-control-presentation-v1.zip

(
cd "$BUNDLE_ROOT"
zip -qr \
"$OLDPWD/handoffs/mission-control-presentation-v1.zip" \
mission-control-presentation-v1
)

printf '\n=== Bundle Contents ===\n'
unzip -l handoffs/mission-control-presentation-v1.zip

printf '\n=== SHA256 ===\n'
shasum -a 256 handoffs/mission-control-presentation-v1.zip
