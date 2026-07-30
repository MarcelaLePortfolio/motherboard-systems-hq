#!/usr/bin/env bash

set -euo pipefail

printf 'Enter the full path to the approved Mission Control mockup image: '
IFS= read -r MOCKUP_PATH

# Strip quotes that macOS Terminal may include.
MOCKUP_PATH="${MOCKUP_PATH#\'}"
MOCKUP_PATH="${MOCKUP_PATH%\'}"
MOCKUP_PATH="${MOCKUP_PATH#\"}"
MOCKUP_PATH="${MOCKUP_PATH%\"}"

if [ ! -f "$MOCKUP_PATH" ]; then
  printf '\nSTOP: mockup image not found.\n'
  printf 'Received path:\n%s\n\n' "$MOCKUP_PATH"
  printf 'Drag the image into Terminal again and press Return.\n'
  exit 1
fi

for FILE in \
  docs/MISSION_CONTROL_PRESENTATION_SPECIFICATION_V1.md \
  docs/claude-handoffs/MISSION_CONTROL_PRESENTATION_V1_CLAUDE_TASK.md \
  client/src/shell/MissionDashboardWorkspace.tsx \
  client/src/shell/mission-dashboard.css \
  client/src/shell/mission-dashboard-presentation.css
do
  if [ ! -f "$FILE" ]; then
    printf '\nSTOP: required file missing:\n%s\n' "$FILE"
    exit 1
  fi
done

BUNDLE_ROOT="$(mktemp -d)"
trap 'rm -rf "$BUNDLE_ROOT"' EXIT

BUNDLE_DIR="$BUNDLE_ROOT/mission-control-presentation-v1"

mkdir -p \
  "$BUNDLE_DIR/docs" \
  "$BUNDLE_DIR/client/src/shell" \
  "$BUNDLE_DIR/reference"

cp \
  docs/MISSION_CONTROL_PRESENTATION_SPECIFICATION_V1.md \
  "$BUNDLE_DIR/docs/MISSION_CONTROL_PRESENTATION_SPECIFICATION_V1.md"

cp \
  docs/claude-handoffs/MISSION_CONTROL_PRESENTATION_V1_CLAUDE_TASK.md \
  "$BUNDLE_DIR/CLAUDE_TASK.md"

for FILE in \
  client/src/shell/MissionDashboardWorkspace.tsx \
  client/src/shell/mission-dashboard.css \
  client/src/shell/mission-dashboard-presentation.css
do
  mkdir -p "$BUNDLE_DIR/$(dirname "$FILE")"
  cp "$FILE" "$BUNDLE_DIR/$FILE"
done

while IFS= read -r -d '' FILE
do
  case "$FILE" in
    client/src/shell/MissionDashboardWorkspace.tsx)
      ;;
    *)
      mkdir -p "$BUNDLE_DIR/$(dirname "$FILE")"
      cp "$FILE" "$BUNDLE_DIR/$FILE"
      ;;
  esac
done < <(
  find client/src \
    -type f \
    \( \
      -iname '*mission*present*.ts' \
      -o -iname '*mission*present*.tsx' \
      -o -iname '*mission*read*.ts' \
      -o -iname '*mission*read*.tsx' \
    \) \
    -print0
)

cp \
  "$MOCKUP_PATH" \
  "$BUNDLE_DIR/reference/$(basename "$MOCKUP_PATH")"

cat > "$BUNDLE_DIR/BUNDLE_MANIFEST.md" << 'MANIFEST'
# Mission Control Presentation v1 — Bundle Manifest

## Included authority

- CLAUDE_TASK.md
- Mission Control Presentation Specification
- Approved Mission Control mockup
- Bounded frontend implementation files

## Excluded authority

- Backend runtime
- Database
- Mission Read architecture
- Governance architecture
- Package semantics
- Delegation semantics
- Envelope semantics
- Project context
- Conversation architecture
- Disaster Recovery tooling

## Implementation Rule

The specification governs semantic meaning.

The mockup governs visual composition.

Existing frontend integration governs authoritative data access.

If those conflict, stop and report the conflict rather than inventing behavior.
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

printf '\nBundle created successfully:\n%s\n' \
  "$(pwd)/handoffs/mission-control-presentation-v1.zip"
