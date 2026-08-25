#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT MINIMUM MISSION CONTROL PROJECT-SCOPED INTAKE ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=MISSION_CONTROL_INTAKE"
echo "AUTHORIZATION_COMMIT=8748d4bf"
echo "IMPLEMENTATION_AUTHORIZED=YES"

cat > client/src/mission-control/missionReadApi.ts << 'TS'
export type MissionStage =
  | "INTERPRETATION"
  | "GOVERNANCE_VALIDATION"
  | "DELEGATION"
  | "ASSIGNMENT"
  | "EXECUTION"
  | "REVIEW"
  | "ARCHIVED"
  | "ENVELOPE_CREATED"
  | string;

export type MissionOwner = string;

export type MissionHealth =
  | "HEALTHY"
  | "WARNING"
  | "BLOCKED"
  | "UNKNOWN"
  | string;

export interface MissionIdentity {
  package_id: string;
  package_version: number;
  project_id: string | null;
}

export interface MissionEvidence {
  artifact_count: number;
  lifecycle_event_count: number;
  integrity_warnings: string[];
  latest_timestamp: string | null;
}

export interface MissionTimelineEntry {
  stage?: string;
  event_type?: string;
  timestamp?: string | null;
  [key: string]: unknown;
}

export interface MissionReadModel {
  identity: MissionIdentity;
  requested_outcome: string;
  stage: MissionStage;
  owner: MissionOwner;
  health: MissionHealth;
  awaiting: string | null;
  evidence: MissionEvidence;
  timeline: MissionTimelineEntry[];
}

interface MissionReadSuccessResponse {
  ok: true;
  mission: MissionReadModel;
}

interface MissionReadErrorResponse {
  ok: false;
  error: string;
}

type MissionReadResponse =
  | MissionReadSuccessResponse
  | MissionReadErrorResponse;

export class MissionReadNotFoundError extends Error {
  constructor(readonly projectId: string) {
    super(`No active operational mission exists for project "${projectId}".`);
    this.name = "MissionReadNotFoundError";
  }
}

export class MissionReadRequestError extends Error {
  constructor(message: string, readonly status: number) {
    super(message);
    this.name = "MissionReadRequestError";
  }
}

export async function getMissionReadModel(
  projectId: string,
  signal?: AbortSignal,
): Promise<MissionReadModel> {
  const id = projectId.trim();

  if (!id) {
    throw new MissionReadRequestError(
      "A project ID is required.",
      400,
    );
  }

  const response = await fetch(
    `/api/mission-read/${encodeURIComponent(id)}`,
    {
      headers: { Accept: "application/json" },
      signal,
    },
  );

  let payload: MissionReadResponse;

  try {
    payload = (await response.json()) as MissionReadResponse;
  } catch {
    throw new MissionReadRequestError(
      `Mission Read API returned invalid JSON (${response.status}).`,
      response.status,
    );
  }

  if (response.status === 404) {
    throw new MissionReadNotFoundError(id);
  }

  if (!response.ok || !payload.ok) {
    throw new MissionReadRequestError(
      payload.ok ? "Mission Read request failed." : payload.error,
      response.status,
    );
  }

  return payload.mission;
}
TS

cat > client/src/mission-control/MissionControlProvider.tsx << 'TS'
import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useRef,
  useState,
  type PropsWithChildren,
} from "react";

import {
  getMissionReadModel,
  MissionReadNotFoundError,
} from "./missionReadApi";
import {
  mapMissionReadToPresentation,
  type MissionPresentationModel,
} from "./missionPresentationMapper";

export type MissionControlStatus =
  | "idle"
  | "loading"
  | "ready"
  | "not_found"
  | "error";

export interface MissionControlContextValue {
  status: MissionControlStatus;
  mission: MissionPresentationModel | null;
  error: string | null;
  loadMission(projectId: string): Promise<void>;
  clearMission(): void;
  refresh(): Promise<void>;
}

const MissionControlContext =
  createContext<MissionControlContextValue | null>(null);

export function MissionControlProvider({
  children,
}: PropsWithChildren) {
  const [status, setStatus] =
    useState<MissionControlStatus>("idle");
  const [mission, setMission] =
    useState<MissionPresentationModel | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [lastProjectId, setLastProjectId] =
    useState<string | null>(null);

  const requestSequenceRef = useRef(0);

  const clearMission = useCallback(() => {
    requestSequenceRef.current += 1;
    setLastProjectId(null);
    setMission(null);
    setError(null);
    setStatus("idle");
  }, []);

  const loadMission = useCallback(async (projectId: string) => {
    const normalizedProjectId = projectId.trim();
    const requestSequence = requestSequenceRef.current + 1;

    requestSequenceRef.current = requestSequence;

    if (!normalizedProjectId) {
      setLastProjectId(null);
      setMission(null);
      setError(null);
      setStatus("idle");
      return;
    }

    setLastProjectId(normalizedProjectId);
    setMission(null);
    setStatus("loading");
    setError(null);

    try {
      const readModel = await getMissionReadModel(normalizedProjectId);

      if (requestSequence !== requestSequenceRef.current) {
        return;
      }

      setMission(mapMissionReadToPresentation(readModel));
      setStatus("ready");
    } catch (caughtError) {
      if (requestSequence !== requestSequenceRef.current) {
        return;
      }

      const message =
        caughtError instanceof Error
          ? caughtError.message
          : "Unknown Mission Read error.";

      setMission(null);
      setError(message);
      setStatus(
        caughtError instanceof MissionReadNotFoundError
          ? "not_found"
          : "error",
      );
    }
  }, []);

  const refresh = useCallback(async () => {
    if (!lastProjectId) {
      return;
    }

    await loadMission(lastProjectId);
  }, [lastProjectId, loadMission]);

  const value = useMemo<MissionControlContextValue>(
    () => ({
      status,
      mission,
      error,
      loadMission,
      clearMission,
      refresh,
    }),
    [
      status,
      mission,
      error,
      loadMission,
      clearMission,
      refresh,
    ],
  );

  return (
    <MissionControlContext.Provider value={value}>
      {children}
    </MissionControlContext.Provider>
  );
}

export function useMissionControlContext(): MissionControlContextValue {
  const context = useContext(MissionControlContext);

  if (!context) {
    throw new Error("MissionControlProvider is required.");
  }

  return context;
}
TS

python3 << 'PY'
from pathlib import Path

path = Path("client/src/shell/MissionDashboardWorkspace.tsx")
text = path.read_text()

text = text.replace(
    'import { useMissionControl } from "../mission-control/useMissionControl";',
    'import { useMissionControl } from "../mission-control/useMissionControl";\n'
    'import { useProjectContext } from "../project-context/useProjectContext";'
)

text = text.replace(
    '\nconst ACTIVE_PACKAGE_ID = "corridor-smoke";\n',
    '\n'
)

old = '''export default function MissionDashboardWorkspace() {
  const { mission, status, error, loadMission, refresh } = useMissionControl();

  useEffect(() => {
    void loadMission(ACTIVE_PACKAGE_ID);
  }, [loadMission]);
'''

new = '''export default function MissionDashboardWorkspace() {
  const {
    mission,
    status,
    error,
    loadMission,
    clearMission,
    refresh,
  } = useMissionControl();
  const { registry } = useProjectContext();
  const activeProjectId = registry?.activeProjectId ?? null;

  useEffect(() => {
    if (!activeProjectId) {
      clearMission();
      return;
    }

    void loadMission(activeProjectId);
  }, [activeProjectId, clearMission, loadMission]);
'''

if old not in text:
    raise SystemExit("Expected MissionDashboardWorkspace intake block not found.")

text = text.replace(old, new)
path.write_text(text)
PY

cat > client/src/mission-control/mission-control-project-scoped-intake.test.ts << 'TS'
import assert from "node:assert/strict";
import test from "node:test";

import {
  getMissionReadModel,
  MissionReadNotFoundError,
  MissionReadRequestError,
} from "./missionReadApi";

test("Mission Read client requests the project-scoped endpoint", async () => {
  const originalFetch = globalThis.fetch;
  let requestedUrl = "";

  globalThis.fetch = async (input) => {
    requestedUrl = String(input);

    return new Response(
      JSON.stringify({
        ok: true,
        mission: {
          identity: {
            package_id: "pkg-1",
            package_version: 1,
            project_id: "hq",
          },
          requested_outcome: "Outcome",
          stage: "INTERPRETATION",
          owner: "UNKNOWN",
          health: "UNKNOWN",
          awaiting: null,
          evidence: {
            artifact_count: 0,
            lifecycle_event_count: 0,
            integrity_warnings: [],
            latest_timestamp: null,
          },
          timeline: [],
        },
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  };

  try {
    const mission = await getMissionReadModel("hq");

    assert.equal(requestedUrl, "/api/mission-read/hq");
    assert.equal(mission.identity.project_id, "hq");
    assert.equal(mission.identity.package_id, "pkg-1");
    assert.equal(mission.identity.package_version, 1);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("Mission Read client rejects an empty project id", async () => {
  await assert.rejects(
    () => getMissionReadModel("   "),
    (error: unknown) =>
      error instanceof MissionReadRequestError &&
      error.status === 400,
  );
});

test("404 represents no active operational mission", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = async () =>
    new Response(
      JSON.stringify({
        ok: false,
        error: "No active operational mission for project.",
      }),
      {
        status: 404,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );

  try {
    await assert.rejects(
      () => getMissionReadModel("hq"),
      (error: unknown) =>
        error instanceof MissionReadNotFoundError &&
        error.projectId === "hq",
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("409 fails closed as a Mission Read request error", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = async () =>
    new Response(
      JSON.stringify({
        ok: false,
        error: "Operational mission identity mismatch.",
      }),
      {
        status: 409,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );

  try {
    await assert.rejects(
      () => getMissionReadModel("hq"),
      (error: unknown) =>
        error instanceof MissionReadRequestError &&
        error.status === 409,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
TS

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false
echo "TYPECHECK=PASS"

echo
echo "=== TARGETED CLIENT TESTS ==="
npx tsx --test client/src/mission-control/mission-control-project-scoped-intake.test.ts

echo
echo "=== STATIC AUTHORITY BOUNDARY VALIDATION ==="
if rg -n 'ACTIVE_PACKAGE_ID|corridor-smoke' \
  client/src/shell/MissionDashboardWorkspace.tsx \
  client/src/mission-control/MissionControlProvider.tsx \
  client/src/mission-control/missionReadApi.ts; then
  echo "HARDCODED_PACKAGE_AUTHORITY_ABSENT=NO"
  exit 1
fi
echo "HARDCODED_PACKAGE_AUTHORITY_ABSENT=YES"

if ! rg -n 'activeProjectId' client/src/shell/MissionDashboardWorkspace.tsx >/dev/null; then
  echo "ACTIVE_PROJECT_INTAKE_WIRING=NOT_FOUND"
  exit 1
fi
echo "ACTIVE_PROJECT_INTAKE_WIRING=FOUND"

if ! rg -n '/api/mission-read/' client/src/mission-control/missionReadApi.ts >/dev/null; then
  echo "PROJECT_SCOPED_ENDPOINT_WIRING=NOT_FOUND"
  exit 1
fi
echo "PROJECT_SCOPED_ENDPOINT_WIRING=FOUND"

echo
echo "=== NON-ESCALATION VALIDATION ==="
git diff --name-only 8748d4bf -- \
  db \
  routes \
  drizzle \
  client/src/project-context \
  client/src/packages || true

UNAUTHORIZED_DIFF_COUNT="$(git diff --name-only 8748d4bf -- \
  db \
  routes \
  drizzle \
  client/src/project-context \
  client/src/packages | wc -l | tr -d ' ')"

if [ "${UNAUTHORIZED_DIFF_COUNT}" != "0" ]; then
  echo "UNAUTHORIZED_SURFACE_CHANGE=YES"
  exit 1
fi

echo "UNAUTHORIZED_SURFACE_CHANGE=NO"
echo "MISSION_CONTROL_SELECTS_ACTIVE_PROJECT=NO"
echo "MISSION_CONTROL_SELECTS_OPERATIONAL_PACKAGE=NO"
echo "MISSION_CONTROL_MUTATES_OPERATIONAL_AUTHORITY=NO"
echo "DELEGATION_CHANGE=NO"
echo "VALIDATION_CHANGE=NO"
echo "ROUTING_CHANGE=NO"
echo "ASSIGNMENT_CHANGE=NO"
echo "EXECUTION_CHANGE=NO"

echo
echo "=== IMPLEMENTATION RESULT ==="
echo "MISSION_CONTROL_PROJECT_SCOPED_INTAKE=IMPLEMENTED"
echo "CLIENT_MISSION_READ_INPUT=projectId"
echo "HARDCODED_corridor-smoke=REMOVED"
echo "PROJECT_SWITCH_REQUEST_SOURCE=ProjectContextProvider.registry.activeProjectId"
echo "STALE_MISSION_CLEARED_BEFORE_PROJECT_SCOPED_REQUEST=YES"
echo "NO_ACTIVE_PROJECT_CLEARS_MISSION=YES"
echo "SERVER_404_MAPS_TO_NO_ACTIVE_MISSION=YES"
echo "SERVER_409_FAILS_CLOSED=YES"
echo "MISSION_CONTROL_PACKAGE_AUTHORITY=NONE"
echo "HANDOFF_VALIDATION_AND_PHASE_CLOSURE_STARTED=NO"
echo "NEXT_ACTION=CLASSIFY_MISSION_CONTROL_INTAKE_IMPLEMENTATION_AND_CLOSURE_READINESS"
