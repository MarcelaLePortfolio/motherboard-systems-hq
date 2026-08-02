import {
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";

import type {
  ApprovalRequestReadModel,
} from "./approvalRequestApi";
import { useApprovalRequests } from "./useApprovalRequests";

import "./approvals-workspace.css";

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
        <strong>Approve Canonical Package</strong>
        <DecisionBadge>Pending</DecisionBadge>
      </div>

      <p className="executive-inbox-item__summary">
        {readText(
          request.evidence.expected_outcome,
          request.evidence.interpreted_objective,
        )}
      </p>

      <div className="executive-inbox-item__meta">
        <span>Needs review</span>

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

function ExecutiveBriefing({
  request,
  onClose,
}: {
  request: ApprovalRequestReadModel;
  onClose(): void;
}) {
  return (
    <article className="executive-briefing">
      <header className="executive-briefing__header">
        <div>
          <div className="executive-briefing__status-line">
            <DecisionBadge>Needs review</DecisionBadge>

            <span>
              Source status: {request.source_draft_status}
            </span>
          </div>

          <h2>Approve Canonical Package</h2>

          <p className="executive-briefing__question">
            {request.executive_question}
          </p>
        </div>

        <DecisionBadge>Pending</DecisionBadge>
      </header>

      <div className="executive-briefing__notice">
        <strong>Decision context:</strong>{" "}
        this Living Draft is non-authoritative until explicitly approved.
      </div>

      <BriefingSection title="Executive summary">
        <p>
          {readText(request.evidence.interpreted_objective)}
        </p>
      </BriefingSection>

      <div className="executive-briefing__transition">
        <div>
          <span>Current state</span>
          <strong>Living Draft Package</strong>
        </div>

        <span aria-hidden="true">→</span>

        <div>
          <span>Proposed state</span>
          <strong>Canonical Package</strong>
        </div>
      </div>

      <BriefingSection title="Requested outcome">
        <p>
          {readText(request.evidence.expected_outcome)}
        </p>
      </BriefingSection>

      <BriefingSection title="Proposed work">
        <p>
          {readText(request.evidence.proposed_work)}
        </p>
      </BriefingSection>

      <BriefingSection title="Proposed artifacts">
        <p>
          {readText(request.evidence.proposed_artifacts)}
        </p>
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

      <BriefingSection title="Supporting evidence">
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
      </BriefingSection>

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
        </dl>
      </details>

      <footer className="executive-briefing__footer">
        <button
          type="button"
          onClick={onClose}
        >
          Close detail
        </button>

        <p>
          Decision controls remain disabled in this read-only corridor.
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
    if (
      selectedRequestId &&
      !requests.some(
        (request) =>
          request.approval_request_id === selectedRequestId,
      )
    ) {
      setSelectedRequestId(null);
    }
  }, [requests, selectedRequestId]);

  const selectedRequest =
    requests.find(
      (request) =>
        request.approval_request_id === selectedRequestId,
    ) ?? null;

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
        Pending items require executive review. No approval or mutation
        actions are enabled in this read-only release.
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

      {!loading && !error && requests.length === 0 ? (
        <section className="executive-inbox-state">
          <h2>Your Executive Inbox is clear.</h2>

          <p>
            No decisions currently require executive authority.
          </p>
        </section>
      ) : null}

      {!error && requests.length > 0 ? (
        <div className="executive-inbox-layout">
          <aside className="executive-inbox-list">
            <div className="executive-inbox-list__header">
              <div>
                <h2>Pending decisions</h2>

                <p>
                  Select an item to review its briefing.
                </p>
              </div>

              <span className="executive-inbox-count">
                {requests.length}
              </span>
            </div>

            <div className="executive-inbox-list__items">
              {requests.map((request) => (
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
              ))}
            </div>
          </aside>

          <section className="executive-inbox-reading-pane">
            {selectedRequest ? (
              <ExecutiveBriefing
                request={selectedRequest}
                onClose={() =>
                  setSelectedRequestId(null)
                }
              />
            ) : (
              <div className="executive-inbox-reading-pane__empty">
                Select a decision to view its executive briefing.
              </div>
            )}
          </section>
        </div>
      ) : null}
    </main>
  );
}
