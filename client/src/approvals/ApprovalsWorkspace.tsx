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

function optionalText(
  value: string | null,
  fallback = "Not recorded",
): string {
  const normalized = value?.trim() ?? "";

  return normalized || fallback;
}

function ApprovalInboxItem({
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
        "approval-inbox-item",
        selected ? "approval-inbox-item--selected" : "",
      ]
        .filter(Boolean)
        .join(" ")}
      aria-current={selected ? "true" : undefined}
      onClick={onSelect}
    >
      <span className="approval-inbox-item__topline">
        <span className="approval-status-badge">
          Pending
        </span>

        <time dateTime={request.updated_at}>
          {formatTimestamp(request.updated_at)}
        </time>
      </span>

      <strong className="approval-inbox-item__title">
        {request.evidence.interpreted_objective}
      </strong>

      <span className="approval-inbox-item__type">
        Canonical Package approval
      </span>

      <span className="approval-inbox-item__summary">
        {optionalText(
          request.evidence.expected_outcome,
          "Executive review required.",
        )}
      </span>
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
    <section className="approval-briefing-section">
      <h3>{title}</h3>
      {children}
    </section>
  );
}

function ApprovalBriefing({
  request,
}: {
  request: ApprovalRequestReadModel;
}) {
  return (
    <article className="approval-briefing">
      <header className="approval-briefing__header">
        <div>
          <p className="approval-eyebrow">
            Executive briefing
          </p>

          <h2>
            {request.evidence.interpreted_objective}
          </h2>

          <p className="approval-briefing__question">
            {request.executive_question}
          </p>
        </div>

        <span className="approval-status-badge">
          Pending
        </span>
      </header>

      <div className="approval-transition">
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
          {optionalText(request.evidence.expected_outcome)}
        </p>
      </BriefingSection>

      <BriefingSection title="Proposed work">
        <p>
          {optionalText(request.evidence.proposed_work)}
        </p>
      </BriefingSection>

      <BriefingSection title="Proposed artifacts">
        <p>
          {optionalText(
            request.evidence.proposed_artifacts,
          )}
        </p>
      </BriefingSection>

      <BriefingSection title="Scope">
        <dl className="approval-briefing-grid">
          <div>
            <dt>In scope</dt>
            <dd>
              {optionalText(request.evidence.in_scope)}
            </dd>
          </div>

          <div>
            <dt>Out of scope</dt>
            <dd>
              {optionalText(
                request.evidence.out_of_scope,
              )}
            </dd>
          </div>
        </dl>
      </BriefingSection>

      <BriefingSection title="Constraints">
        <p>
          {optionalText(request.evidence.constraints)}
        </p>
      </BriefingSection>

      {request.evidence.unresolved_questions ? (
        <BriefingSection title="Unresolved questions">
          <p>
            {request.evidence.unresolved_questions}
          </p>
        </BriefingSection>
      ) : null}

      <BriefingSection title="Supporting evidence">
        {request.evidence.evidence_entry_ids.length > 0 ? (
          <ul className="approval-evidence-list">
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

      <details className="approval-technical-details">
        <summary>Technical details</summary>

        <dl className="approval-briefing-grid">
          <div>
            <dt>Approval Request</dt>
            <dd>{request.approval_request_id}</dd>
          </div>

          <div>
            <dt>Living Draft</dt>
            <dd>{request.draft_package_id}</dd>
          </div>

          <div>
            <dt>Project</dt>
            <dd>{request.project_id}</dd>
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
            <dt>Last updated</dt>
            <dd>{formatTimestamp(request.updated_at)}</dd>
          </div>
        </dl>
      </details>

      <footer className="approval-briefing__footer">
        <p>
          Decision controls are not enabled in this
          read-only release.
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
    const selectionStillExists = requests.some(
      (request) =>
        request.approval_request_id ===
        selectedRequestId,
    );

    if (!selectionStillExists) {
      setSelectedRequestId(
        requests[0]?.approval_request_id ?? null,
      );
    }
  }, [requests, selectedRequestId]);

  const selectedRequest =
    requests.find(
      (request) =>
        request.approval_request_id ===
        selectedRequestId,
    ) ?? null;

  return (
    <main className="approvals-workspace">
      <header className="approvals-workspace__header">
        <div>
          <p className="approval-eyebrow">
            Executive inbox
          </p>

          <h1>Approvals</h1>

          <p>
            Decisions waiting for executive attention.
          </p>
        </div>

        <button
          type="button"
          className="approval-refresh-button"
          onClick={() => void refresh()}
          disabled={loading}
        >
          {loading ? "Refreshing…" : "Refresh"}
        </button>
      </header>

      <p className="approvals-readonly-note">
        Read-only preview · Decision controls will be
        introduced in a separately authorized corridor.
      </p>

      {loading && !collection ? (
        <section className="approval-inbox-state">
          <h2>Loading your executive inbox…</h2>
        </section>
      ) : null}

      {error ? (
        <section className="approval-inbox-state">
          <h2>Approvals could not be loaded.</h2>
          <p>{error.message}</p>

          <button
            type="button"
            onClick={() => void refresh()}
          >
            Retry
          </button>
        </section>
      ) : null}

      {!loading && !error && requests.length === 0 ? (
        <section className="approval-inbox-state">
          <h2>Your executive inbox is clear.</h2>
          <p>
            New decisions will appear here when
            authoritative project state requires your
            attention.
          </p>
        </section>
      ) : null}

      {!error && requests.length > 0 ? (
        <div className="approval-inbox-layout">
          <aside
            className="approval-inbox"
            aria-label="Pending executive decisions"
          >
            <header className="approval-inbox__header">
              <div>
                <p className="approval-eyebrow">
                  Inbox
                </p>

                <h2>Pending decisions</h2>
              </div>

              <span className="approval-inbox__count">
                {requests.length}
              </span>
            </header>

            <div className="approval-inbox__items">
              {requests.map((request) => (
                <ApprovalInboxItem
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

          {selectedRequest ? (
            <ApprovalBriefing
              request={selectedRequest}
            />
          ) : (
            <section className="approval-inbox-state">
              Select a decision to review its executive
              briefing.
            </section>
          )}
        </div>
      ) : null}
    </main>
  );
}
