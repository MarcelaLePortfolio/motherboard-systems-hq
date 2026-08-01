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

interface ApprovalRequestContextValue {
  collection: ApprovalRequestCollection | null;
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

  const [loading, setLoading] = useState(false);

  const [error, setError] =
    useState<Error | null>(null);

  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const result =
        await fetchApprovalRequests(projectId);

      setCollection(result);
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
      loading,
      error,
      refresh,
    }),
    [collection, loading, error, refresh],
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
