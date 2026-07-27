import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type PropsWithChildren,
} from "react";

import {
  getMissionReadModel,
  type MissionReadModel,
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
  loadMission(packageId: string): Promise<void>;
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
  const [lastPackageId, setLastPackageId] =
    useState<string | null>(null);

  const loadMission = useCallback(async (packageId: string) => {
    setStatus("loading");
    setError(null);

    try {
      const readModel: MissionReadModel =
        await getMissionReadModel(packageId);

      setMission(mapMissionReadToPresentation(readModel));
      setLastPackageId(packageId);
      setStatus("ready");
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Unknown error";

      if (message.includes("not found")) {
        setStatus("not_found");
      } else {
        setStatus("error");
      }

      setMission(null);
      setError(message);
    }
  }, []);

  const refresh = useCallback(async () => {
    if (lastPackageId) {
      await loadMission(lastPackageId);
    }
  }, [lastPackageId, loadMission]);

  const value = useMemo(
    () => ({
      status,
      mission,
      error,
      loadMission,
      refresh,
    }),
    [status, mission, error, loadMission, refresh],
  );

  return (
    <MissionControlContext.Provider value={value}>
      {children}
    </MissionControlContext.Provider>
  );
}

export function useMissionControlContext() {
  const context = useContext(MissionControlContext);

  if (!context) {
    throw new Error(
      "MissionControlProvider is required.",
    );
  }

  return context;
}
