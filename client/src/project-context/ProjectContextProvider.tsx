import {
  createContext,
  useCallback,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import {
  getProjectRegistry,
  setActiveProject,
} from "./projectRegistryApi";
import type { ProjectRegistryState } from "./types";

export interface ProjectContextValue {
  registry: ProjectRegistryState | null;
  loading: boolean;
  error: Error | null;
  refresh: () => Promise<void>;
  switchProject: (projectId: string) => Promise<void>;
}

export const ProjectContext = createContext<ProjectContextValue | null>(null);

interface ProjectContextProviderProps {
  children: ReactNode;
}

export function ProjectContextProvider({
  children,
}: ProjectContextProviderProps) {
  const [registry, setRegistry] = useState<ProjectRegistryState | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const state = await getProjectRegistry();
      setRegistry(state);
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Unknown error"));
    } finally {
      setLoading(false);
    }
  }, []);

  const switchProject = useCallback(async (projectId: string) => {
    setError(null);

    try {
      const state = await setActiveProject(projectId);
      setRegistry(state);
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Unknown error"));
      throw err;
    }
  }, []);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const value = useMemo<ProjectContextValue>(
    () => ({
      registry,
      loading,
      error,
      refresh,
      switchProject,
    }),
    [registry, loading, error, refresh, switchProject]
  );

  return (
    <ProjectContext.Provider value={value}>
      {children}
    </ProjectContext.Provider>
  );
}
