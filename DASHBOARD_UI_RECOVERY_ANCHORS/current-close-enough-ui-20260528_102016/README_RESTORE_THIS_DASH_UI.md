
# Restore This Dashboard UI

This folder is the current close-enough dashboard UI baseline.

## Status

- This is the restored usable dashboard UI.

- Backend/governed execution corridors were already verified separately.

- The true latest remembered UI was not found yet.

- This anchor exists so future backups make the dashboard UI baseline obvious.

## Restore command

```bash

cp "DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-20260528_102016/public/index.html" public/index.html

cp "DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-20260528_102016/public/dashboard.html" public/dashboard.html

cp "DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-20260528_102016/public/bundle.js" public/bundle.js

cp "DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-20260528_102016/public/js/phase530_visible_panels_bridge.js" public/js/phase530_visible_panels_bridge.js

docker compose build dashboard

docker compose up -d dashboard

```

## Commit

e847d7e823087e84b92ab6a1985cefc1de5fd097

## Files

```

5d718d5ba12e79286c1b275871f4292969b22e91  DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-20260528_102016/public/index.html
3e4279e382259d16623ffd8c3709bf06d8679326  DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-20260528_102016/public/dashboard.html
a27e680cbcf5a242def5777d1978ba6083ace079  DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-20260528_102016/public/bundle.js
5c1c62192d38a72ad61e0e977ccd20dfb92e9e56  DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-20260528_102016/public/js/phase530_visible_panels_bridge.js

```

