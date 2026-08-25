#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 - << 'PY'
from pathlib import Path

path = Path("client/src/shell/MissionDashboardWorkspace.tsx")
text = path.read_text()

old = '''      ? ({
          packageId: "No active mission",
          version: 0,
          projectId: activeProjectId ?? "No active project",
          stage: "idle",
          owner: null,
          health: "idle",
          awaiting: null,
          evidenceCount: 0,
          progressPosition: null,
          progressTotal: 0,
          progressStages: null,
          latestEvent: null,
          nextStep: null,
          activeAgent: null,
        } satisfies MissionPresentationModel)'''

new = '''      ? ({
          packageId: "No active mission",
          projectId: activeProjectId,
          version: 0,
          requestedOutcome: "No active mission",
          stage: "idle",
          owner: "",
          health: "idle",
          awaiting: null,
          artifactCount: 0,
          lifecycleEventCount: 0,
          integrityWarnings: [],
          latestTimestamp: null,
          timeline: [],
          startedTimestamp: null,
          progressStages: null,
          progressPosition: null,
          progressTotal: 0,
          nextStageLabel: null,
        } satisfies MissionPresentationModel)'''

if old not in text:
    raise SystemExit("AUTHORIZED_EMPTY_MISSION_PATTERN_NOT_FOUND")

path.write_text(text.replace(old, new, 1))
PY

git diff --check

(
  cd client
  npm run build
)

git add client/src/shell/MissionDashboardWorkspace.tsx
git commit -m "Repair empty Mission presentation object"
git push

echo "=== VALIDATION ==="
echo "CLIENT_BUILD=PASS"
echo "EMPTY_MISSION_MODEL_CONTRACT=SATISFIED"
echo "ACTIVE_MISSION_PATH_CHANGED=NO"
echo "PROJECT_CONTEXT_CHANGED=NO"
echo "SERVER_CHANGED=NO"
echo "NEXT_ACTION=RELOAD_UI_AND_VERIFY_EMPTY_MISSION_CONTROL_RENDERING"
