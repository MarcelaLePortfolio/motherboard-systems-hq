#!/bin/bash
set -e

cp app/components/GuidancePanel.tsx app/components/GuidancePanel.tsx.bak_phase677_pre_diff

echo "=== GuidancePanel coherence references ==="
grep -n "coherence\|Coherence\|raw\|coherent" app/components/GuidancePanel.tsx || true

echo ""
echo "=== GuidancePanel component tail ==="
tail -n 220 app/components/GuidancePanel.tsx
