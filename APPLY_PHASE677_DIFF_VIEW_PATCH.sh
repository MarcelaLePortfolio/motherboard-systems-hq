#!/bin/bash
set -e

python3 - << 'PY'
from pathlib import Path

p = Path("app/components/GuidancePanel.tsx")
s = p.read_text()

old = """  const grouped = groupBySeverity(data.guidance || []);
  const total = data.guidance?.length || 0;

  const renderGroup = (label: string, items: any[], emphasis: number) => {"""

new = """  const grouped = groupBySeverity(data.guidance || []);
  const total = data.guidance?.length || 0;

  const getSignalKey = (signal: any) =>
    [
      signal?.type || '',
      signal?.subsystem || '',
      signal?.message || '',
      signal?.suggested_action || ''
    ].join('::');

  const rawSignals = coherenceData?.raw || [];
  const coherentSignals = coherenceData?.coherent || [];
  const coherentKeys = new Set(coherentSignals.map(getSignalKey));
  const rawKeys = new Set(rawSignals.map(getSignalKey));

  const retainedSignals = rawSignals.filter((signal: any) => coherentKeys.has(getSignalKey(signal)));
  const collapsedSignals = rawSignals.filter((signal: any) => !coherentKeys.has(getSignalKey(signal)));
  const introducedSignals = coherentSignals.filter((signal: any) => !rawKeys.has(getSignalKey(signal)));

  const diffSummary = {
    retained: retainedSignals.length,
    collapsed: collapsedSignals.length,
    introduced: introducedSignals.length
  };

  const renderDiffSignals = (label: string, items: any[]) => {
    if (!items.length) {
      return (
        <div style={{ marginTop: '4px', opacity: 0.62 }}>
          {label}: none
        </div>
      );
    }

    return (
      <div style={{ marginTop: '6px' }}>
        <div style={{ fontWeight: 700 }}>{label}: {items.length}</div>
        {items.slice(0, 3).map((signal: any, i: number) => (
          <div
            key={`${label}-${i}`}
            style={{
              marginTop: '4px',
              padding: '5px 7px',
              borderRadius: '7px',
              background: 'rgba(255,255,255,0.05)',
              opacity: 0.82
            }}
          >
            <span style={{ fontWeight: 700 }}>{signal?.subsystem || 'unknown'}:</span>{' '}
            {signal?.message || 'No message'}
          </div>
        ))}
      </div>
    );
  };

  const renderGroup = (label: string, items: any[], emphasis: number) => {"""

if old not in s:
    raise SystemExit("Target insertion point not found")

s = s.replace(old, new)

old2 = """              <div>Source: {coherenceData.source || 'unknown'}</div>
            </>
          ) : ("""

new2 = """              <div>Source: {coherenceData.source || 'unknown'}</div>

              <div style={{ marginTop: '10px', paddingTop: '8px', borderTop: '1px solid rgba(255,255,255,0.12)' }}>
                <div style={{ fontWeight: 800, marginBottom: '4px' }}>Raw vs Coherent Diff</div>
                <div>Retained: {diffSummary.retained}</div>
                <div>Collapsed: {diffSummary.collapsed}</div>
                <div>Introduced: {diffSummary.introduced}</div>
                {renderDiffSignals('Collapsed signals', collapsedSignals)}
                {renderDiffSignals('Introduced coherent signals', introducedSignals)}
              </div>
            </>
          ) : ("""

if old2 not in s:
    raise SystemExit("Target coherence preview block not found")

s = s.replace(old2, new2)
p.write_text(s)
PY

npm run lint || true

git diff -- app/components/GuidancePanel.tsx
