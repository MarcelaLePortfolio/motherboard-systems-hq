import {
  createContext,
  useCallback,
  useContext,
  useEffect,
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
  projectId: string | null;
  status: MissionControlStatus;
  mission: MissionPresentationModel | null;
  error: string | null;
  loadMission(packageId: string): Promise<void>;
  refresh(): Promise<void>;
}

const MissionControlContext =
  createContext<MissionControlContextValue | null>(null);

type MissionControlProviderProps = PropsWithChildren<{
  projectId: string | null;
}>;

export function MissionControlProvider({
  children,
  projectId,
}: MissionControlProviderProps) {
  const normalizedProjectId = projectId?.trim() || null;

  const [status, setStatus] =
    useState<MissionControlStatus>("idle");
  const [mission, setMission] =
    useState<MissionPresentationModel | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [lastPackageId, setLastPackageId] =
    useState<string | null>(null);

  const requestSequenceRef = useRef(0);

  useEffect(() => {
    requestSequenceRef.current += 1;
    setMission(null);
    setLastPackageId(null);
    setError(null);
    setStatus("idle");
  }, [normalizedProjectId]);

  const loadMission = useCallback(
    async (packageId: string) => {
      if (!normalizedProjectId) {
        requestSequenceRef.current += 1;
        setMission(null);
        setLastPackageId(null);
        setError(null);
        setStatus("idle");
        return;
      }

      const normalizedPackageId = packageId.trim();

      if (!normalizedPackageId) {
        requestSequenceRef.current += 1;
        setMission(null);
        setLastPackageId(null);
        setError("A mission package ID is required.");
        setStatus("error");
        return;
      }

      const requestSequence = requestSequenceRef.current + 1;

      requestSequenceRef.current = requestSequence;
      setLastPackageId(normalizedPackageId);
      setStatus("loading");
      setError(null);

      try {
        const readModel =
          await getMissionReadModel(normalizedPackageId);

        if (requestSequence !== requestSequenceRef.current) {
          return;
        }

        if (readModel.identity.project_id !== normalizedProjectId) {
          setMission(null);
          setError(
            `Mission package "${normalizedPackageId}" does not belong to the active project.`,
          );
          setStatus("error");
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
    },
    [normalizedProjectId],
  );

  const refresh = useCallback(async () => {
    if (!lastPackageId || !normalizedProjectId) {
      return;
    }

    await loadMission(lastPackageId);
  }, [lastPackageId, loadMission, normalizedProjectId]);

  const value = useMemo<MissionControlContextValue>(
    () => ({
      projectId: normalizedProjectId,
      status,
      mission,
      error,
      loadMission,
      refresh,
    }),
    [
      normalizedProjectId,
      status,
      mission,
      error,
      loadMission,
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
