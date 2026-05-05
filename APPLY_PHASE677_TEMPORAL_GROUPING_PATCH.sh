#!/bin/bash
set -e

python3 - << 'PY'
from pathlib import Path

p = Path("app/components/GuidancePanel.tsx")
s = p.read_text()

old = """  const renderDiffSignals = (label: string, items: any[]) => {
    if (!items.length) {"""

new = """  const temporalGroups = rawSignals.reduce((groups: Record<string, any[]>, signal: any) => {
    const timestamp = signal?.timestamp ? new Date(signal.timestamp) : null;
    const key = timestamp && !Number.isNaN(timestamp.getTime())
      ? timestamp.toISOString().slice(0, 16).replace('T', ' ')
      : 'unknown-time';

    groups[key] = groups[key] || [];
    groups[key].push(signal);
    return groups;
  }, {});

  const temporalGroupEntries = Object.entries(temporalGroups)
    .sort(([a], [b]) => b.localeCompare(a))
    .slice(0, 6);

  const renderDiffSignals = (label: string, items: any[]) => {
    if (!items.length) {"""

if old not in s:
    raise SystemExit("Temporal insertion point not found")

s = s.replace(old, new)

old2 = """                {renderDiffSignals('Collapsed signals', collapsedSignals)}
                {renderDiffSignals('Introduced coherent signals', introducedSignals)}
              </div>"""

new2 = """                {renderDiffSignals('Collapsed signals', collapsedSignals)}
                {renderDiffSignals('Introduced coherent signals', introducedSignals)}

                <div style={{ marginTop: '10px', paddingTop: '8px', borderTop: '1px solid rgba(255,255,255,0.10)' }}>
                  <div style={{ fontWeight: 800, marginBottom: '4px' }}>Temporal Signal Groups</div>
                  {temporalGroupEntries.length ? (
                    temporalGroupEntries.map(([bucket, items]: any) => (
                      <div key={bucket} style={{ marginTop: '4px', opacity: 0.82 }}>
                        {bucket}: {items.length} signal{items.length === 1 ? '' : 's'}
                      </div>
                    ))
                  ) : (
                    <div style={{ opacity: 0.62 }}>No temporal groups available.</div>
                  )}
                </div>
              </div>"""

if old2 not in s:
    raise SystemExit("Temporal render insertion point not found")

s = s.replace(old2, new2)
p.write_text(s)
PY

echo "=== Temporal grouping markers ==="
grep -n "Temporal Signal Groups\|temporalGroups\|temporalGroupEntries" app/components/GuidancePanel.tsx

echo ""
echo "=== Active route check ==="
curl -i -s http://localhost:3000/api/guidance/coherence-shadow | head -c 600
printf '\n'

echo ""
echo "=== Docker status ==="
docker compose ps
