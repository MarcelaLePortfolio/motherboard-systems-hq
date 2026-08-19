#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 - << 'PY'
from pathlib import Path

path = Path("client/src/shell/MissionDashboardWorkspace.tsx")
text = path.read_text()

anchor = '''function ActiveAgentCard({ mission }: { mission: MissionPresentationModel }) {
'''

pipeline_component = '''function MissionPipelineCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  const hasOwner = hasAuthoritativeValue(mission.owner);

  return (
    <MissionCard title="Mission Pipeline" className="mission-card--pipeline">
      <div className="mission-pipeline">
        <div className="mission-pipeline__node">
          <span className="mission-pipeline__node-label">Current Stage</span>
          <span className="mission-pipeline__node-value">
            {formatLabel(mission.stage)}
          </span>
        </div>

        <span className="mission-pipeline__arrow" aria-hidden="true">
          →
        </span>

        <div className="mission-pipeline__node">
          <span className="mission-pipeline__node-label">Current Owner</span>
          <span className="mission-pipeline__node-value">
            {hasOwner ? formatLabel(mission.owner) : "Unassigned"}
          </span>
        </div>

        <span className="mission-pipeline__arrow" aria-hidden="true">
          →
        </span>

        <div className="mission-pipeline__node">
          <span className="mission-pipeline__node-label">Awaiting</span>
          <span className="mission-pipeline__node-value">
            {mission.awaiting
              ? formatLabel(mission.awaiting)
              : "Nothing pending"}
          </span>
        </div>
      </div>
    </MissionCard>
  );
}

'''

if pipeline_component not in text:
    if anchor not in text:
        raise SystemExit("ActiveAgentCard anchor not found; refusing speculative edit.")
    text = text.replace(anchor, pipeline_component + anchor)

old = '''        <section
          className="mission-dashboard__action-region"
          aria-label="Executive action cards"
        >
          <LatestEventCard mission={mission} />
          <NextStepCard mission={mission} />
          <ActiveAgentCard mission={mission} />
        </section>
'''

new = '''        <section
          className="mission-dashboard__action-region"
          aria-label="Executive action cards"
        >
          <LatestEventCard mission={mission} />
          <NextStepCard mission={mission} />
          <ActiveAgentCard mission={mission} />
        </section>

        <section
          className="mission-dashboard__pipeline-region"
          aria-label="Mission pipeline position"
        >
          <MissionPipelineCard mission={mission} />
        </section>
'''

if old not in text:
    raise SystemExit("Executive action region not found; refusing speculative edit.")

text = text.replace(old, new)
path.write_text(text)
PY

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'ACTIVE_CORRIDOR=PIPELINE_POSITION' \
  'SOURCE_COMPONENT=ARCHIVED_MISSION_PIPELINE' \
  'PIPELINE_POSITION_SOURCE=MISSION_READ_STAGE_OWNER_AWAITING' \
  'PIPELINE_BOUNDARY=GOVERNANCE_MOVEMENT_ONLY' \
  'DEPARTMENT_OR_AGENT_INFERENCE=NO' \
  'NEW_SEMANTIC_AUTHORITY=NO' \
  'NEW_PERSISTENCE=NO'

printf '\n=== TARGETED DIFF ===\n'
git diff -- client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== CLIENT BUILD ===\n'
npm run build --prefix client

printf '\n=== BACKEND REGRESSION VALIDATION ===\n'
npx tsx db/mission-read-repository.test.ts
npx tsx db/mission-read-model.integration.test.ts

printf '\n=== WORKTREE ===\n'
git status --short
