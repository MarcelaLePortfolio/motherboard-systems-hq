
#!/usr/bin/env bash

set -euo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"

ANCHOR_DIR="DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-${STAMP}"

MANIFEST="$ANCHOR_DIR/README_RESTORE_THIS_DASH_UI.md"

mkdir -p "$ANCHOR_DIR/public/js"

cp public/index.html "$ANCHOR_DIR/public/index.html"

cp public/dashboard.html "$ANCHOR_DIR/public/dashboard.html"

cp public/bundle.js "$ANCHOR_DIR/public/bundle.js"

cp public/js/phase530_visible_panels_bridge.js "$ANCHOR_DIR/public/js/phase530_visible_panels_bridge.js"

cat > "$MANIFEST" << MD

# Restore This Dashboard UI

This folder is the current close-enough dashboard UI baseline.

## Status

- This is the restored usable dashboard UI.

- Backend/governed execution corridors were already verified separately.

- The true latest remembered UI was not found yet.

- This anchor exists so future backups make the dashboard UI baseline obvious.

## Restore command

\`\`\`bash

cp "$ANCHOR_DIR/public/index.html" public/index.html

cp "$ANCHOR_DIR/public/dashboard.html" public/dashboard.html

cp "$ANCHOR_DIR/public/bundle.js" public/bundle.js

cp "$ANCHOR_DIR/public/js/phase530_visible_panels_bridge.js" public/js/phase530_visible_panels_bridge.js

docker compose build dashboard

docker compose up -d dashboard

\`\`\`

## Commit

$(git rev-parse HEAD)

## Files

\`\`\`

$(shasum "$ANCHOR_DIR/public/index.html" "$ANCHOR_DIR/public/dashboard.html" "$ANCHOR_DIR/public/bundle.js" "$ANCHOR_DIR/public/js/phase530_visible_panels_bridge.js")

\`\`\`

MD

tar -czf "$ANCHOR_DIR.tar.gz" "$ANCHOR_DIR"

git add "$ANCHOR_DIR" "$ANCHOR_DIR.tar.gz" create-dashboard-ui-recovery-anchor.sh

git commit -m "Create dashboard UI recovery anchor"

git push

echo "Created: $ANCHOR_DIR"

echo "Archive: $ANCHOR_DIR.tar.gz"

