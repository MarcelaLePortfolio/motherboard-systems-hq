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
  createMatildaConversation,
  getMatildaChatHistory,
  getMatildaConversations,
  sendMatildaMessage,
  setActiveMatildaConversation,
  type MatildaConversationSummary,
  type MatildaConversationTurn,
} from "./matildaChatApi";

export interface MatildaConversationContextValue {
  activeProjectId: string | null;
  conversationId: string | null;
  turns: MatildaConversationTurn[];
  conversations: MatildaConversationSummary[];
  loading: boolean;
  switching: boolean;
  submitting: boolean;
  requestError: string | null;
  createConversation: () => Promise<boolean>;
  switchConversation: (nextConversationId: string) => Promise<void>;
  sendMessage: (message: string) => Promise<boolean>;
}

export const MatildaConversationContext =
  createContext<MatildaConversationContextValue | null>(null);

interface MatildaConversationProviderProps {
  children: ReactNode;
}

export function MatildaConversationProvider({
  children,
}: MatildaConversationProviderProps) {
  const { registry } = useProjectContext();

  const [turnsByProject, setTurnsByProject] = useState<
    Record<string, MatildaConversationTurn[]>
  >({});
  const [conversationIdsByProject, setConversationIdsByProject] = useState<
    Record<string, string>
  >({});
  const [conversationsByProject, setConversationsByProject] = useState<
    Record<string, MatildaConversationSummary[]>
  >({});
  const [loadingByProject, setLoadingByProject] = useState<
    Record<string, boolean>
  >({});
  const [switchingByProject, setSwitchingByProject] = useState<
    Record<string, boolean>
  >({});
  const [submittingByProject, setSubmittingByProject] = useState<
    Record<string, boolean>
  >({});
  const [errorsByProject, setErrorsByProject] = useState<
    Record<string, string | null>
  >({});

  const activeProjectId = registry?.activeProjectId ?? null;

  const turns = activeProjectId ? turnsByProject[activeProjectId] ?? [] : [];
  const conversationId = activeProjectId
    ? conversationIdsByProject[activeProjectId] ?? null
    : null;
  const conversations = activeProjectId
    ? conversationsByProject[activeProjectId] ?? []
    : [];
  const loading = activeProjectId
    ? loadingByProject[activeProjectId] ?? false
    : false;
  const submitting = activeProjectId
    ? submittingByProject[activeProjectId] ?? false
    : false;
  const switching = activeProjectId
    ? switchingByProject[activeProjectId] ?? false
    : false;
  const requestError = activeProjectId
    ? errorsByProject[activeProjectId] ?? null
    : null;

  useEffect(() => {
    if (!activeProjectId) {
      return;
    }

    let cancelled = false;

    setLoadingByProject((current) => ({
      ...current,
      [activeProjectId]: true,
    }));

    void Promise.all([
      getMatildaConversations(activeProjectId),
      getMatildaChatHistory(activeProjectId),
    ])
      .then(([conversationState, history]) => {
        if (cancelled) {
          return;
        }

        setConversationsByProject((current) => ({
          ...current,
          [activeProjectId]: conversationState.conversations,
        }));
        setConversationIdsByProject((current) => ({
          ...current,
          [activeProjectId]: history.conversation_id,
        }));
        setTurnsByProject((current) => ({
          ...current,
          [activeProjectId]: history.turns,
        }));
      })
      .catch((error) => {
        if (!cancelled) {
          setErrorsByProject((current) => ({
            ...current,
            [activeProjectId]:
              error instanceof Error
                ? error.message
                : "Unable to load Matilda chat history",
          }));
        }
      })
      .finally(() => {
        if (!cancelled) {
          setLoadingByProject((current) => ({
            ...current,
            [activeProjectId]: false,
          }));
        }
      });

    return () => {
      cancelled = true;
    };
  }, [activeProjectId]);

  const createConversation = useCallback(async () => {
    const projectId = activeProjectId;

    if (!projectId || switchingByProject[projectId]) {
      return false;
    }

    setSwitchingByProject((current) => ({
      ...current,
      [projectId]: true,
    }));
    setErrorsByProject((current) => ({
      ...current,
      [projectId]: null,
    }));

    try {
      const response = await createMatildaConversation(projectId);

      setConversationsByProject((current) => ({
        ...current,
        [projectId]: response.conversations,
      }));
      setConversationIdsByProject((current) => ({
        ...current,
        [projectId]: response.conversation.conversation_id,
      }));
      setTurnsByProject((current) => ({
        ...current,
        [projectId]: [],
      }));

      return true;
    } catch (error) {
      setErrorsByProject((current) => ({
        ...current,
        [projectId]:
          error instanceof Error
            ? error.message
            : "Unable to create Matilda conversation",
      }));

      return false;
    } finally {
      setSwitchingByProject((current) => ({
        ...current,
        [projectId]: false,
      }));
    }
  }, [activeProjectId, switchingByProject]);

  const switchConversation = useCallback(
    async (nextConversationId: string) => {
      const projectId = activeProjectId;

      if (
        !projectId ||
        !nextConversationId ||
        nextConversationId === conversationIdsByProject[projectId] ||
        switchingByProject[projectId]
      ) {
        return;
      }

      setSwitchingByProject((current) => ({
        ...current,
        [projectId]: true,
      }));
      setErrorsByProject((current) => ({
        ...current,
        [projectId]: null,
      }));

      try {
        const response = await setActiveMatildaConversation(
          projectId,
          nextConversationId
        );
        const history = await getMatildaChatHistory(projectId);

        setConversationsByProject((current) => ({
          ...current,
          [projectId]: response.conversations,
        }));
        setConversationIdsByProject((current) => ({
          ...current,
          [projectId]: history.conversation_id,
        }));
        setTurnsByProject((current) => ({
          ...current,
          [projectId]: history.turns,
        }));
      } catch (error) {
        setErrorsByProject((current) => ({
          ...current,
          [projectId]:
            error instanceof Error
              ? error.message
              : "Unable to switch Matilda conversation",
        }));
      } finally {
        setSwitchingByProject((current) => ({
          ...current,
          [projectId]: false,
        }));
      }
    },
    [activeProjectId, conversationIdsByProject, switchingByProject]
  );

  const sendMessage = useCallback(
    async (message: string) => {
      const trimmedMessage = message.trim();
      const projectId = activeProjectId;

      if (!trimmedMessage || !projectId || submittingByProject[projectId]) {
        return false;
      }

      const activeConversationId = conversationIdsByProject[projectId] ?? null;

      if (!activeConversationId) {
        setErrorsByProject((current) => ({
          ...current,
          [projectId]: "Matilda conversation is still loading.",
        }));
        return false;
      }

      setSubmittingByProject((current) => ({
        ...current,
        [projectId]: true,
      }));
      setErrorsByProject((current) => ({
        ...current,
        [projectId]: null,
      }));

      try {
        const response = await sendMatildaMessage({
          message: trimmedMessage,
          projectId,
          conversationId: activeConversationId,
        });

        const persistedTurn = response.turn;

        if (
          persistedTurn.project_id !== projectId ||
          persistedTurn.conversation_id !== activeConversationId ||
          persistedTurn.interpretation_entry_id !==
            response.meta.interpretation_entry_id
        ) {
          throw new Error(
            "Matilda returned a persisted turn with mismatched conversation lineage."
          );
        }

        setTurnsByProject((current) => ({
          ...current,
          [projectId]: [...(current[projectId] ?? []), persistedTurn],
        }));

        return true;
      } catch (error) {
        setErrorsByProject((current) => ({
          ...current,
          [projectId]:
            error instanceof Error ? error.message : "Unknown Matilda chat error",
        }));

        return false;
      } finally {
        setSubmittingByProject((current) => ({
          ...current,
          [projectId]: false,
        }));
      }
    },
    [activeProjectId, conversationIdsByProject, submittingByProject]
  );

  const value = useMemo<MatildaConversationContextValue>(
    () => ({
      activeProjectId,
      conversationId,
      turns,
      conversations,
      loading,
      switching,
      submitting,
      requestError,
      createConversation,
      switchConversation,
      sendMessage,
    }),
    [
      activeProjectId,
      conversationId,
      turns,
      conversations,
      loading,
      switching,
      submitting,
      requestError,
      createConversation,
      switchConversation,
      sendMessage,
    ]
  );

  return (
    <MatildaConversationContext.Provider value={value}>
      {children}
    </MatildaConversationContext.Provider>
  );
}
