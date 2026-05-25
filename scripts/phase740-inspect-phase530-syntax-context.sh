
#!/bin/bash

set -e

echo "🔍 Phase 740 phase530 syntax context inspection"

echo

echo "----- JS SYNTAX ERROR -----"

node --check public/js/phase530_visible_panels_bridge.js || true

echo

echo "----- CONTEXT AROUND ERROR LINE 1438 -----"

nl -ba public/js/phase530_visible_panels_bridge.js | sed -n '1380,1465p'

echo

echo "----- FUNCTION BOUNDARY SEARCH -----"

grep -n "phase736TryParseRenderNativeVisualMountCandidate\|function phase736\|PHASE736\|visual mount\|render-native" public/js/phase530_visible_panels_bridge.js | head -n 80

echo

echo "----- GIT STATUS -----"

git status

