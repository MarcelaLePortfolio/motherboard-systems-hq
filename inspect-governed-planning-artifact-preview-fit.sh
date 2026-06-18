
#!/usr/bin/env bash

set -euo pipefail

echo "--- Phase719 artifact preview entrypoints ---"

grep -nE "phase719|artifact-preview|data-phase719-preview-artifact|Preview" public/js/phase530_visible_panels_bridge.js server.mjs server/routes/*.mjs 2>/dev/null || true

echo

echo "--- task artifact preview API routes ---"

git grep -nE "artifact-preview|artifact_preview|preview.*artifact|rendered artifact|artifact content" -- server server.mjs public/js ':!public/bundle.js' ':!public/bundle.js.map' || true

echo

echo "--- artifact fields expected by preview UI ---"

sed -n '120,215p' public/js/phase530_visible_panels_bridge.js

echo

echo "--- Phase719 modal fetch/render path ---"

sed -n '696,760p' public/js/phase530_visible_panels_bridge.js

sed -n '2290,2405p' public/js/phase530_visible_panels_bridge.js

echo

echo "--- governed planning bundle shape ---"

sed -n '1,240p' server/execution/build-governed-planning-artifact-bundle.mjs

echo

echo "--- governed planning route response shape ---"

sed -n '286,338p' server/routes/governed-planning-route.mjs

echo

echo "--- existing artifact persistence/read surfaces ---"

git grep -nE "artifacts|artifact|filename|path|content|metadata|payload.artifact" -- server public/js ':!public/bundle.js' ':!public/bundle.js.map' | head -260 || true

echo

echo "--- proposed preview fit summary target ---"

cat << 'SUMMARY'

Questions to answer from this inspection:

1. Does Phase719 require a task_id, or can it preview a standalone artifact?

2. Does the preview API read artifacts only from completed task records?

3. Can governed planning bundle output be transformed into the expected artifact shape?

4. Is the smallest safe bridge a read-only governed planning preview artifact, rather than a task record?

SUMMARY

