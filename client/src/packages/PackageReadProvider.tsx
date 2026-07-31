import {
  createContext,
  useCallback,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";

import { useProjectContext } from "../project-context/useProjectContext";
import {
  getPackageReadCollection,
  getPackageReadDetail,
  type ExecutivePackageReadCollection,
  type ExecutivePackageReadModel,
} from "./packageReadApi";

export type PackageReadStatus =
  | "idle"
  | "loading"
  | "ready"
  | "error";

export interface PackageReadContextValue {
  projectId: string | null;
  collection: ExecutivePackageReadCollection | null;
  packages: ExecutivePackageReadModel[];
  selectedPackage: ExecutivePackageReadModel | null;
  selectedPackageId: string | null;
  status: PackageReadStatus;
  detailStatus: PackageReadStatus;
  error: string | null;
  detailError: string | null;
  refresh(): Promise<void>;
  selectPackage(packageId: string): Promise<void>;
  clearSelection(): void;
}

export const PackageReadContext =
  createContext<PackageReadContextValue | null>(null);

type PackageReadProviderProps = {
  children: ReactNode;
};

function errorMessage(
  error: unknown,
  fallback: string,
): string {
  return error instanceof Error && error.message.trim()
    ? error.message
    : fallback;
}

export function PackageReadProvider({
  children,
}: PackageReadProviderProps) {
  const { registry } = useProjectContext();

  const activeProjectId =
    registry?.activeProject?.projectId ??
    registry?.activeProjectId ??
    null;

  const [collection, setCollection] =
    useState<ExecutivePackageReadCollection | null>(null);

  const [selectedPackage, setSelectedPackage] =
    useState<ExecutivePackageReadModel | null>(null);

  const [selectedPackageId, setSelectedPackageId] =
    useState<string | null>(null);

  const [status, setStatus] =
    useState<PackageReadStatus>("idle");

  const [detailStatus, setDetailStatus] =
    useState<PackageReadStatus>("idle");

  const [error, setError] =
    useState<string | null>(null);

  const [detailError, setDetailError] =
    useState<string | null>(null);

  const refresh = useCallback(async () => {
    const projectId = activeProjectId?.trim() ?? "";

    if (!projectId) {
      setCollection(null);
      setSelectedPackage(null);
      setSelectedPackageId(null);
      setStatus("idle");
      setDetailStatus("idle");
      setError(null);
      setDetailError(null);
      return;
    }

    setStatus("loading");
    setError(null);

    try {
      const next =
        await getPackageReadCollection(projectId);

      setCollection(next);
      setStatus("ready");
    } catch (err) {
      setCollection(null);
      setStatus("error");
      setError(
        errorMessage(err, "Unable to load Packages."),
      );
    }
  }, [activeProjectId]);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const selectPackage = useCallback(
    async (packageId: string) => {
      const projectId = activeProjectId?.trim() ?? "";
      const normalizedPackageId = packageId.trim();

      if (!projectId) {
        throw new Error("No active project is available.");
      }

      if (!normalizedPackageId) {
        throw new Error("packageId is required.");
      }

      setSelectedPackageId(normalizedPackageId);
      setSelectedPackage(null);
      setDetailStatus("loading");
      setDetailError(null);

      try {
        const detail = await getPackageReadDetail(
          projectId,
          normalizedPackageId,
        );

        setSelectedPackage(detail);
        setDetailStatus("ready");
      } catch (err) {
        setSelectedPackage(null);
        setDetailStatus("error");
        setDetailError(
          errorMessage(
            err,
            "Unable to load Package details.",
          ),
        );
      }
    },
    [activeProjectId],
  );

  const clearSelection = useCallback(() => {
    setSelectedPackage(null);
    setSelectedPackageId(null);
    setDetailStatus("idle");
    setDetailError(null);
  }, []);

  const value = useMemo<PackageReadContextValue>(
    () => ({
      projectId: activeProjectId,
      collection,
      packages: collection?.packages ?? [],
      selectedPackage,
      selectedPackageId,
      status,
      detailStatus,
      error,
      detailError,
      refresh,
      selectPackage,
      clearSelection,
    }),
    [
      activeProjectId,
      collection,
      selectedPackage,
      selectedPackageId,
      status,
      detailStatus,
      error,
      detailError,
      refresh,
      selectPackage,
      clearSelection,
    ],
  );

  return (
    <PackageReadContext.Provider value={value}>
      {children}
    </PackageReadContext.Provider>
  );
}
