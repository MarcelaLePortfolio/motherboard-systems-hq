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
