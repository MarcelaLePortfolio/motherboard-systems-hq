import {
  useEffect,
  useMemo,
  useState,
  type FormEvent,
  type ReactNode,
} from "react";

import {
  approveCanonicalPackage,
  type ApprovalRequestDecision,
  type ApprovalRequestReadModel,
} from "./approvalRequestApi";
import { useApprovalRequests } from "./useApprovalRequests";

import "./approvals-workspace.css";

type DecisionActionPresentation = {
  label: string;
  consequence: string;
};

const DECISION_ACTION_PRESENTATION: Record<
  ApprovalRequestDecision,
  DecisionActionPresentation
> = {
  approve_canonical_package: {
    label: "Approve",
    consequence:
      "Creates the authoritative Canonical Package. It does not delegate or execute the work.",
  },
};

function formatTimestamp(value: string): string {
  const timestamp = new Date(value);

  if (Number.isNaN(timestamp.getTime())) {
    return value;
  }

  return new Intl.DateTimeFormat(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(timestamp);
}

function readText(
  value: string | null,
  fallback = "Not recorded.",
): string {
  const normalized = value?.trim() ?? "";

  return normalized || fallback;
}

function DecisionBadge({
  children,
}: {
  children: ReactNode;
}) {
  return (
    <span className="executive-inbox-badge">
      {children}
    </span>
  );
}

function DecisionListItem({
  request,
  selected,
  onSelect,
}: {
  request: ApprovalRequestReadModel;
  selected: boolean;
  onSelect(): void;
}) {
  return (
    <button
      type="button"
      className={[
        "executive-inbox-item",
        selected ? "executive-inbox-item--selected" : "",
      ]
        .filter(Boolean)
        .join(" ")}
      aria-current={selected ? "true" : undefined}
      onClick={onSelect}
    >
      <div className="executive-inbox-item__heading">
        <strong>
          {readText(
            request.evidence.expected_outcome,
            request.evidence.interpreted_objective,
          )}
        </strong>
        <DecisionBadge>Needs review</DecisionBadge>
      </div>

      <p className="executive-inbox-item__summary">
        {readText(request.evidence.interpreted_objective)}
      </p>

      <div className="executive-inbox-item__meta">
        <time dateTime={request.updated_at}>
          {formatTimestamp(request.updated_at)}
        </time>
      </div>
    </button>
  );
}

function BriefingSection({
  title,
  children,
}: {
  title: string;
  children: ReactNode;
}) {
  return (
    <section className="executive-briefing-section">
      <h3>{title}</h3>
      {children}
    </section>
  );
}

function DecisionActions({
  request,
  onApproved,
}: {
  request: ApprovalRequestReadModel;
  onApproved(): Promise<void>;
}) {
  const [changesOpen, setChangesOpen] = useState(false);
  const [feedback, setFeedback] = useState("");
  const [feedbackReady, setFeedbackReady] = useState(false);
  const [approving, setApproving] = useState(false);
  const [approvalError, setApprovalError] =
    useState<string | null>(null);

  useEffect(() => {
    setChangesOpen(false);
    setFeedback("");
    setFeedbackReady(false);
    setApproving(false);
    setApprovalError(null);
  }, [request.approval_request_id]);

  const primaryDecision =
    request.available_decisions[0] ?? null;

  const primaryPresentation = primaryDecision
    ? DECISION_ACTION_PRESENTATION[primaryDecision]
    : null;

  async function handleApprove(): Promise<void> {
    if (
      approving ||
      primaryDecision !== "approve_canonical_package"
    ) {
      return;
    }

    setApproving(true);
    setApprovalError(null);

    try {
      await approveCanonicalPackage(
        request.draft_package_id,
      );
      await onApproved();
    } catch (error) {
      setApprovalError(
        error instanceof Error
          ? error.message
          : "The Package could not be approved.",
      );
    } finally {
      setApproving(false);
    }
  }

  function handleFeedbackSubmit(
    event: FormEvent<HTMLFormElement>,
  ): void {
    event.preventDefault();

    if (!feedback.trim()) {
      return;
    }

    setFeedbackReady(true);
  }

  return (
    <section
      className="executive-decision-actions"
      aria-labelledby="executive-decision-actions-title"
    >
      <div className="executive-decision-actions__heading">
        <div>
          <h3 id="executive-decision-actions-title">
            Your decision
          </h3>

          <p>
            Move this work forward or explain what needs to change.
          </p>
        </div>
      </div>

      <div className="executive-decision-actions__options">
        <div className="executive-decision-option">
          <button
            type="button"
            className="executive-decision-button executive-decision-button--primary"
            disabled={
              approving ||
              primaryDecision !== "approve_canonical_package"
            }
            onClick={() => void handleApprove()}
          >
            {approving
              ? "Approving…"
              : primaryPresentation?.label ?? "Approve"}
          </button>

          <p>
            {primaryPresentation?.consequence ??
              "Moves the selected decision forward."}
          </p>
        </div>

        <div className="executive-decision-option">
          <button
            type="button"
            className="executive-decision-button"
            aria-expanded={changesOpen}
            disabled={approving}
            onClick={() => {
              setChangesOpen((current) => !current);
              setFeedbackReady(false);
              setApprovalError(null);
            }}
          >
            Request Changes
          </button>

          <p>
            Returns this draft for revision without granting downstream authority.
          </p>
        </div>
      </div>

      {approvalError ? (
        <p
          className="executive-change-request__status"
          role="alert"
        >
          {approvalError}
        </p>
      ) : null}

      {changesOpen ? (
        <form
          className="executive-change-request"
          onSubmit={handleFeedbackSubmit}
        >
          <label htmlFor="executive-change-request-feedback">
            What should change?
          </label>

          <textarea
            id="executive-change-request-feedback"
            rows={4}
            value={feedback}
            placeholder="Describe the correction Matilda should make."
            onChange={(event) => {
              setFeedback(event.target.value);
              setFeedbackReady(false);
            }}
          />

          <div className="executive-change-request__footer">
            <button
              type="button"
              onClick={() => {
                setChangesOpen(false);
                setFeedback("");
                setFeedbackReady(false);
              }}
            >
              Cancel
            </button>

            <button
              type="submit"
              disabled={!feedback.trim()}
            >
              Prepare Changes Request
            </button>
          </div>

          {feedbackReady ? (
            <p
              className="executive-change-request__status"
              role="status"
            >
              Feedback is ready. Submission remains disabled until the Request
              Changes persistence corridor is authorized.
            </p>
          ) : null}
        </form>
      ) : null}
    </section>
  );
}

function ExecutiveBriefing({
  request,
  artifactNumber,
  artifactCount,
  onClose,
  onApproved,
}: {
  request: ApprovalRequestReadModel;
  artifactNumber: number;
  artifactCount: number;
  onClose(): void;
  onApproved(): Promise<void>;
}) {
  return (
    <article className="executive-briefing">
      <header className="executive-briefing__header executive-briefing__header--calm">
        <div>
          <div className="executive-briefing__status-line">
            <DecisionBadge>Needs review</DecisionBadge>
          </div>

          <h2>Package Review</h2>

          <p className="executive-briefing__question">
            {readText(request.evidence.interpreted_objective)}
          </p>
        </div>
      </header>

      <div className="executive-briefing__transition executive-briefing__transition--compact">
        <div>
          <span>Approval effect</span>
          <strong>Living Draft → Canonical Package</strong>
        </div>
      </div>

      <BriefingSection title="What you are approving">
        <dl className="executive-briefing-grid">
          <div>
            <dt>Expected outcome</dt>
            <dd>{readText(request.evidence.expected_outcome)}</dd>
          </div>
          <div>
            <dt>Proposed work</dt>
            <dd>{readText(request.evidence.proposed_work)}</dd>
          </div>
          <div>
            <dt>Deliverables</dt>
            <dd>{readText(request.evidence.proposed_artifacts)}</dd>
          </div>
        </dl>
      </BriefingSection>

      <BriefingSection title="Scope">
        <dl className="executive-briefing-grid">
          <div>
            <dt>In scope</dt>
            <dd>
              {readText(request.evidence.in_scope)}
            </dd>
          </div>

          <div>
            <dt>Out of scope</dt>
            <dd>
              {readText(request.evidence.out_of_scope)}
            </dd>
          </div>
        </dl>
      </BriefingSection>

      <BriefingSection title="Constraints">
        <p>
          {readText(request.evidence.constraints)}
        </p>
      </BriefingSection>

      {request.evidence.unresolved_questions ? (
        <BriefingSection title="Open questions">
          <p>
            {request.evidence.unresolved_questions}
          </p>
        </BriefingSection>
      ) : null}

      <details className="executive-briefing-technical">
        <summary>Technical details</summary>

        <dl className="executive-briefing-grid">
          <div>
            <dt>Approval request</dt>
            <dd>{request.approval_request_id}</dd>
          </div>

          <div>
            <dt>Draft package</dt>
            <dd>{request.draft_package_id}</dd>
          </div>

          <div>
            <dt>Conversation</dt>
            <dd>
              {request.conversation_id ?? "Unavailable"}
            </dd>
          </div>

          <div>
            <dt>Lineage</dt>
            <dd>{request.lineage_id}</dd>
          </div>
          <div>
            <dt>Source status</dt>
            <dd>{request.source_draft_status}</dd>
          </div>
          <div>
            <dt>Artifact position</dt>
            <dd>
              {artifactNumber} of {artifactCount}
            </dd>
          </div>
        </dl>

        <div className="executive-briefing-technical__evidence">
          <span>Supporting evidence</span>
          {request.evidence.evidence_entry_ids.length > 0 ? (
            <ul className="executive-briefing-evidence">
              {request.evidence.evidence_entry_ids.map(
                (evidenceId) => (
                  <li key={evidenceId}>
                    {evidenceId}
                  </li>
                ),
              )}
            </ul>
          ) : (
            <p>No evidence references are available.</p>
          )}
        </div>
      </details>

      <DecisionActions
        request={request}
        onApproved={onApproved}
      />

      <footer className="executive-briefing__footer">
        <button
          type="button"
          onClick={onClose}
        >
          Close detail
        </button>

        <p>
          Approval creates a Canonical Package only. Delegation and execution
          remain unauthorized.
        </p>
      </footer>
    </article>
  );
}

export default function ApprovalsWorkspace() {
  const {
    collection,
    loading,
    error,
    refresh,
  } = useApprovalRequests();

  const requests = useMemo(
    () => collection?.requests ?? [],
    [collection],
  );

  const [
    selectedRequestId,
    setSelectedRequestId,
  ] = useState<string | null>(null);

  useEffect(() => {
    if (requests.length === 0) {
      setSelectedRequestId(null);
      return;
    }

    const selectionExists = requests.some(
      (request) =>
        request.approval_request_id === selectedRequestId,
    );

    if (!selectionExists) {
      setSelectedRequestId(
        requests[0].approval_request_id,
      );
    }
  }, [requests, selectedRequestId]);

  const selectedIndex = requests.findIndex(
    (request) =>
      request.approval_request_id === selectedRequestId,
  );

  const selectedRequest =
    selectedIndex >= 0
      ? requests[selectedIndex]
      : null;

  return (
    <main className="executive-inbox-workspace">
      <header className="executive-inbox-header">
        <div>
          <h1>Executive Inbox</h1>

          <p>
            Review decisions generated for the active project.
          </p>
        </div>

        <button
          type="button"
          onClick={() => void refresh()}
          disabled={loading}
        >
          {loading ? "Refreshing…" : "Refresh"}
        </button>
      </header>

      <div className="executive-inbox-notice">
        Approving a Reconciled Interpretation Summary creates its authoritative
        Canonical Package. It does not delegate or execute the work.
      </div>

      {loading && !collection ? (
        <section className="executive-inbox-state">
          Loading Executive Inbox…
        </section>
      ) : null}

      {error ? (
        <section className="executive-inbox-state">
          <h2>Unable to load Executive Inbox.</h2>
          <p>Please retry the request.</p>

          <button
            type="button"
            onClick={() => void refresh()}
          >
            Try again
          </button>
        </section>
      ) : null}

      {!loading && !error ? (
        <>
          <div className="executive-inbox-layout">
            <aside className="executive-inbox-list">
              <div className="executive-inbox-list__header">
                <div>
                  <h2>Pending decisions</h2>

                  <p>
                    Select an artifact to review its briefing.
                  </p>
                </div>

                <span className="executive-inbox-count">
                  {requests.length}
                </span>
              </div>

              <div className="executive-inbox-list__items">
                {requests.length === 0 ? (
                  <div className="executive-inbox-reading-pane__empty">
                    No approval requests currently require executive review.
                  </div>
                ) : (
                  requests.map((request) => (
                    <DecisionListItem
                      key={request.approval_request_id}
                      request={request}
                      selected={
                        request.approval_request_id ===
                        selectedRequestId
                      }
                      onSelect={() =>
                        setSelectedRequestId(
                          request.approval_request_id,
                        )
                      }
                    />
                  ))
                )}
              </div>
            </aside>

            <section className="executive-inbox-reading-pane">
              {selectedRequest ? (
                <ExecutiveBriefing
                  key={selectedRequest.approval_request_id}
                  request={selectedRequest}
                  artifactNumber={selectedIndex + 1}
                  artifactCount={requests.length}
                  onClose={() =>
                    setSelectedRequestId(null)
                  }
                  onApproved={refresh}
                />
              ) : (
                <div className="executive-inbox-reading-pane__empty">
                  {requests.length === 0
                    ? "Reconciled Interpretation Summaries will appear here after Matilda determines that an interpretation is stable enough for executive review."
                    : "Select an approval artifact to view its executive briefing."}
                </div>
              )}
            </section>
          </div>
        </>
      ) : null}
    </main>
  );
}
