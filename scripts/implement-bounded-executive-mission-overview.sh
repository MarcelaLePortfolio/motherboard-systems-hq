#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

cat > /tmp/mission-read-model-types.py << 'PY'
from pathlib import Path
p = Path("db/mission-read-model-types.ts")
s = p.read_text()

s = s.replace(
"""export interface MissionSummary {
  identity: MissionIdentity;
  stage: MissionStage;
""",
"""export interface MissionSummary {
  identity: MissionIdentity;
  requested_outcome: string;
  stage: MissionStage;
"""
)

p.write_text(s)
PY
python3 /tmp/mission-read-model-types.py

cat > /tmp/mission-read-repository.py << 'PY'
from pathlib import Path
p = Path("db/mission-read-repository.ts")
s = p.read_text()

s = s.replace(
"""      package_version,
      project_id,
      conversation_id
""",
"""      package_version,
      project_id,
      conversation_id,
      requested_outcome
"""
)

s = s.replace(
"""            project_id: string | null;
            conversation_id: string | null;
""",
"""            project_id: string | null;
            conversation_id: string | null;
            requested_outcome: string;
"""
)

s = s.replace(
"""        conversation_id: pkg.conversation_id,
        lifecycle_state: envelope?.lifecycle_state ?? null,
""",
"""        conversation_id: pkg.conversation_id,
        requested_outcome: pkg.requested_outcome,
        lifecycle_state: envelope?.lifecycle_state ?? null,
"""
)

p.write_text(s)
PY
python3 /tmp/mission-read-repository.py

cat > /tmp/mission-read-assembler.py << 'PY'
from pathlib import Path
p = Path("db/mission-read-model-assembler.ts")
s = p.read_text()

s = s.replace(
"""  conversation_id: string | null;

  lifecycle_state: string | null;
""",
"""  conversation_id: string | null;
  requested_outcome: string;

  lifecycle_state: string | null;
"""
)

s = s.replace(
"""    },

    stage,
""",
"""    },

    requested_outcome: input.requested_outcome,

    stage,
"""
)

p.write_text(s)
PY
python3 /tmp/mission-read-assembler.py

cat > /tmp/mission-read-api.py << 'PY'
from pathlib import Path
p = Path("client/src/mission-control/missionReadApi.ts")
s = p.read_text()

needle = """  identity: {
    package_id: string;
"""
if needle not in s:
    raise SystemExit("Mission Read frontend contract shape not found")

s = s.replace(
"""  identity: {
    package_id: string;
    package_version: number;
    project_id: string | null;
  };
""",
"""  identity: {
    package_id: string;
    package_version: number;
    project_id: string | null;
  };
  requested_outcome: string;
"""
)

p.write_text(s)
PY
python3 /tmp/mission-read-api.py

cat > /tmp/mission-presentation.py << 'PY'
from pathlib import Path
p = Path("client/src/mission-control/missionPresentationMapper.ts")
s = p.read_text()

s = s.replace(
"""  packageId: string;
  projectId: string | null;
  version: number;

  stage: string;
""",
"""  packageId: string;
  projectId: string | null;
  version: number;
  requestedOutcome: string;

  stage: string;
"""
)

s = s.replace(
"""    packageId: mission.identity.package_id,
    projectId: mission.identity.project_id,
    version: mission.identity.package_version,

    stage: mission.stage,
""",
"""    packageId: mission.identity.package_id,
    projectId: mission.identity.project_id,
    version: mission.identity.package_version,
    requestedOutcome: mission.requested_outcome,

    stage: mission.stage,
"""
)

p.write_text(s)
PY
python3 /tmp/mission-presentation.py

cat > /tmp/mission-dashboard.py << 'PY'
from pathlib import Path
p = Path("client/src/shell/MissionDashboardWorkspace.tsx")
s = p.read_text()

old = """        <p className="mission-brief__title">
          Mission title not yet available
        </p>

        <p className="mission-brief__objective">
          Mission objective is not yet exposed by Mission Read for this
          package. Displaying identity and operational state only.
        </p>
"""

new = """        <p className="mission-brief__title">
          {mission.requestedOutcome}
        </p>

        <p className="mission-brief__objective">
          {mission.requestedOutcome}
        </p>
"""

if old not in s:
    raise SystemExit("Executive Brief placeholder block not found")

s = s.replace(old, new)
p.write_text(s)
PY
python3 /tmp/mission-dashboard.py

printf '\n=== BOUNDED IMPLEMENTATION DIFF ===\n'
git diff -- \
  db/mission-read-model-types.ts \
  db/mission-read-repository.ts \
  db/mission-read-model-assembler.ts \
  client/src/mission-control/missionReadApi.ts \
  client/src/mission-control/missionPresentationMapper.ts \
  client/src/shell/MissionDashboardWorkspace.tsx

printf '\n=== VALIDATION ===\n'
npm run build --prefix client

printf '\n=== AUTHORITY CHECK ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'Mission title not yet available|Mission objective is not yet exposed' \
  client/src/shell/MissionDashboardWorkspace.tsx && exit 1 || true

git status --short
