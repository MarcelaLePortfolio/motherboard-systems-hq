import {
  createContext,
  useCallback,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import {
  archiveProject as archiveProjectRequest,
  getProjectRegistry,
  registerProject as registerProjectRequest,
  restoreProject as restoreProjectRequest,
  setActiveProject,
  type RegisterProjectInput,
} from "./projectRegistryApi";
import type { ProjectRegistryState } from "./types";

export interface ProjectContextValue {
  registry: ProjectRegistryState | null;
  loading: boolean;
  error: Error | null;
  refresh: () => Promise<void>;
  switchProject: (projectId: string) => Promise<void>;
  registerProject: (input: RegisterProjectInput) => Promise<void>;
  archiveProject: (projectId: string) => Promise<void>;
  restoreProject: (projectId: string) => Promise<void>;
}

export const ProjectContext = createContext<ProjectContextValue | null>(null);

export function ProjectContextProvider({ children }: { children: ReactNode }) {
  const [registry, setRegistry] = useState<ProjectRegistryState | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setRegistry(await getProjectRegistry());
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Unknown error"));
    } finally {
      setLoading(false);
    }
  }, []);

  const switchProject = useCallback(async (projectId: string) => {
    setError(null);
    try {
      setRegistry(await setActiveProject(projectId));
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Unknown error"));
      throw err;
    }
  }, []);

  const registerProject = useCallback(async (input: RegisterProjectInput) => {
    setError(null);
    try {
      setRegistry(await registerProjectRequest(input));
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Unknown error"));
      throw err;
    }
  }, []);

  const archiveProject = useCallback(async (projectId: string) => {
    setError(null);
    try {
      setRegistry(await archiveProjectRequest(projectId));
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Unknown error"));
      throw err;
    }
  }, []);

  const restoreProject = useCallback(async (projectId: string) => {
    setError(null);
    try {
      setRegistry(await restoreProjectRequest(projectId));
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Unknown error"));
      throw err;
    }
  }, []);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const value = useMemo(
    () => ({
      registry,
      loading,
      error,
      refresh,
      switchProject,
      registerProject,
      archiveProject,
      restoreProject,
    }),
    [
      registry,
      loading,
      error,
      refresh,
      switchProject,
      registerProject,
      archiveProject,
      restoreProject,
    ]
  );

  return (
    <ProjectContext.Provider value={value}>
      {children}
    </ProjectContext.Provider>
  );
}
