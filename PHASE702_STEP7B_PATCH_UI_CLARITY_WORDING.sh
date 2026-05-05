#!/usr/bin/env bash
set -euo pipefail

echo "Committing UI clarity target helper..."

git add PHASE702_STEP7_IDENTIFY_UI_CLARITY_TARGETS.sh
git commit -m "Phase 702: add UI clarity target helper"
git push

echo "Applying minimal UI-only clarity wording patches..."

python3 - << 'PY'
from pathlib import Path

subsystem = Path("app/components/SubsystemStatusPanel.tsx")
s = subsystem.read_text()

old = """      <h3 style={headerStyle}>
        Subsystem Status <span style={{ opacity: 0.7 }}>({isStale ? 'STALE' : 'LIVE'})</span>
      </h3>

      <div style={sectionStyle}>"""

new = """      <h3 style={headerStyle}>
        Subsystem Status <span style={{ opacity: 0.7 }}>({isStale ? 'STALE' : 'LIVE'})</span>
      </h3>
      <div style={{ fontSize: '12px', opacity: 0.72, lineHeight: 1.4, marginBottom: '10px' }}>
        LIVE means the UI is receiving recent subsystem data. STALE means the last received data is older than the freshness threshold.
      </div>

      <div style={sectionStyle}>"""

if old not in s:
    raise SystemExit("Expected SubsystemStatusPanel header block not found")
subsystem.write_text(s.replace(old, new))

guidance = Path("app/components/GuidancePanel.tsx")
g = guidance.read_text()

old = """      <h3 style={headerStyle}>
        Operator Guidance ({total}){' '}
        <span style={{ opacity: 0.7 }}>
          ({isStale ? 'STALE' : 'LIVE'})
        </span>
      </h3>

      <div style={sectionStyle}>"""

new = """      <h3 style={headerStyle}>
        Operator Guidance ({total}){' '}
        <span style={{ opacity: 0.7 }}>
          ({isStale ? 'STALE' : 'LIVE'})
        </span>
      </h3>
      <div style={{ fontSize: '12px', opacity: 0.72, lineHeight: 1.4, marginBottom: '10px' }}>
        Guidance is advisory and read-only. It does not execute tasks or change system state.
      </div>

      <div style={sectionStyle}>"""

if old not in g:
    raise SystemExit("Expected GuidancePanel header block not found")
guidance.write_text(g.replace(old, new))
PY

git add app/components/SubsystemStatusPanel.tsx app/components/GuidancePanel.tsx PHASE702_STEP7B_PATCH_UI_CLARITY_WORDING.sh
git commit -m "Phase 702: clarify live stale and guidance authority wording"
git push

npm run verify:replay

git status --short
