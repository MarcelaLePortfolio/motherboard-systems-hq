
#!/bin/bash

set -e

echo "🔍 Phase 740 phase530 second syntax context inspection"

echo

echo "----- JS SYNTAX ERROR -----"

node --check public/js/phase530_visible_panels_bridge.js || true

echo

echo "----- CONTEXT AROUND ERROR LINE 2135 -----"

nl -ba public/js/phase530_visible_panels_bridge.js | sed -n '2070,2175p'

echo

echo "----- NEARBY FUNCTION SIGNATURES -----"

grep -n "phase735DecodeVisualArtifactHtmlTransport\|function phase735\|phase735" public/js/phase530_visible_panels_bridge.js | tail -n 80

echo

echo "----- RECENT COMMITS -----"

git log --oneline -n 8

echo

echo "----- GIT STATUS -----"

git status

