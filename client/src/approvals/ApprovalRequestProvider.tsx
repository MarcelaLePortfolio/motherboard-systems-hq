import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";

import {
  fetchApprovalRequests,
  type ApprovalRequestCollection,
} from "./approvalRequestApi";
import {
  fetchCanonicalPackages,
  type CanonicalPackageReadCollection,
} from "./canonicalPackageReadApi";

interface ApprovalRequestContextValue {
  collection: ApprovalRequestCollection | null;
  canonicalCollection: CanonicalPackageReadCollection | null;
  loading: boolean;
  error: Error | null;
  refresh(): Promise<void>;
}

const ApprovalRequestContext =
  createContext<ApprovalRequestContextValue | null>(null);

export interface ApprovalRequestProviderProps {
  projectId: string;
  children: ReactNode;
}

export function ApprovalRequestProvider({
  projectId,
  children,
}: ApprovalRequestProviderProps) {
  const [collection, setCollection] =
    useState<ApprovalRequestCollection | null>(null);

  const [canonicalCollection, setCanonicalCollection] =
    useState<CanonicalPackageReadCollection | null>(null);

  const [loading, setLoading] = useState(false);

  const [error, setError] =
    useState<Error | null>(null);

  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const [approvalRequests, canonicalPackages] =
        await Promise.all([
          fetchApprovalRequests(projectId),
          fetchCanonicalPackages(projectId),
        ]);

      setCollection(approvalRequests);
      setCanonicalCollection(canonicalPackages);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  }, [projectId]);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const value = useMemo(
    () => ({
      collection,
      canonicalCollection,
      loading,
      error,
      refresh,
    }),
    [
      collection,
      canonicalCollection,
      loading,
      error,
      refresh,
    ],
  );

  return (
    <ApprovalRequestContext.Provider value={value}>
      {children}
    </ApprovalRequestContext.Provider>
  );
}

export function useApprovalRequestContext() {
  const context = useContext(ApprovalRequestContext);

  if (!context) {
    throw new Error(
      "ApprovalRequestProvider is required.",
    );
  }

  return context;
}
