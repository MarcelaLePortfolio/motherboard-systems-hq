#!/bin/bash
set -e

python3 - << 'PY'
from pathlib import Path

p = Path("app/components/GuidancePanel.tsx")
s = p.read_text()

old = """  const diffSummary = {
    retained: retainedSignals.length,
    collapsed: collapsedSignals.length,
    introduced: introducedSignals.length
  };"""

new = """  const diffSummary = {
    retained: retainedSignals.length,
    collapsed: collapsedSignals.length,
    introduced: introducedSignals.length
  };

  const collapseRatio = rawSignals.length
    ? Math.round((collapsedSignals.length / rawSignals.length) * 100)
    : 0;

  const collapseIndicatorLabel = collapsedSignals.length > 0
    ? 'Coherence is reducing repeated/noisy signals'
    : 'No signal collapse detected';"""

if old not in s:
    raise SystemExit("Collapse summary insertion point not found")

s = s.replace(old, new)

old2 = """                <div>Retained: {diffSummary.retained}</div>
                <div>Collapsed: {diffSummary.collapsed}</div>
                <div>Introduced: {diffSummary.introduced}</div>
                {renderDiffSignals('Collapsed signals', collapsedSignals)}"""

new2 = """                <div>Retained: {diffSummary.retained}</div>
                <div>Collapsed: {diffSummary.collapsed}</div>
                <div>Introduced: {diffSummary.introduced}</div>

                <div style={{ marginTop: '8px', padding: '6px 8px', borderRadius: '8px', background: 'rgba(255,255,255,0.06)' }}>
                  <div style={{ fontWeight: 800 }}>Signal Collapse Indicator</div>
                  <div>Collapse ratio: {collapseRatio}%</div>
                  <div>{collapseIndicatorLabel}</div>
                </div>

                {renderDiffSignals('Collapsed signals', collapsedSignals)}"""

if old2 not in s:
    raise SystemExit("Collapse render insertion point not found")

s = s.replace(old2, new2)
p.write_text(s)
PY

echo "=== Collapse indicator markers ==="
grep -n "Signal Collapse Indicator\|collapseRatio\|collapseIndicatorLabel" app/components/GuidancePanel.tsx

echo ""
echo "=== Active route check ==="
curl -i -s http://localhost:3000/api/guidance/coherence-shadow | head -c 600
printf '\n'

echo ""
echo "=== Docker status ==="
docker compose ps
