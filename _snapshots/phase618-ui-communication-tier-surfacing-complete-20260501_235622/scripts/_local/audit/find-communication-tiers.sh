#!/bin/bash
set -e

echo "🔍 Searching for execution communication tier wiring/documentation..."

echo ""
echo "=== SEARCH: Tier 1 ==="
grep -RIn "Tier 1\|tier 1\|TIER 1" . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=_snapshots || true

echo ""
echo "=== SEARCH: Tier 2 ==="
grep -RIn "Tier 2\|tier 2\|TIER 2" . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=_snapshots || true

echo ""
echo "=== SEARCH: Tier 3 ==="
grep -RIn "Tier 3\|tier 3\|TIER 3" . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=_snapshots || true

echo ""
echo "=== SEARCH: communication tier variants ==="
grep -RIn "communication.*tier\|tier.*communication\|execution.*tier\|tier.*execution" . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=_snapshots || true

echo ""
echo "✅ Tier audit complete. Use the matches to cherry-pick existing execution communication wiring instead of inventing a new result shape."
