import { useEffect, useState } from "react";

import type {
  ApprovalRequestReadModel,
} from "./approvalRequestApi";
import { useApprovalRequests } from "./useApprovalRequests";

import "./approvals-workspace.css";

function ApprovalRequestListItem({
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
        "approvals-workspace-item",
        selected ? "approvals-workspace-item--selected" : "",
      ]
        .filter(Boolean)
        .join(" ")}
      onClick={onSelect}
    >
      <span className="approvals-workspace-item__status">
        Pending
      </span>

      <strong>
        {request.evidence.interpreted_objective}
      </strong>

      <span>Canonical Package approval</span>
    </button>
  );
}

function ApprovalRequestDetail({
  request,
}: {
  request: ApprovalRequestReadModel;
}) {
  return (
    <section className="approvals-workspace-detail">
      <div className="approvals-workspace-detail__header">
        <div>
          <p className="approvals-workspace-eyebrow">
            Executive decision
          </p>

          <h2>{request.executive_question}</h2>
        </div>

        <span className="approvals-workspace-status">
          Pending
        </span>
      </div>

      <div className="approvals-workspace-notice">
        This workspace is read-only. It presents
        authoritative Approval Request state but does not
        execute approval decisions.
      </div>

      <dl className="approvals-workspace-facts">
        <div>
          <dt>Request</dt>
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
          <dd>{request.conversation_id ?? "Unavailable"}</dd>
        </div>

        <div>
          <dt>Lineage</dt>
          <dd>{request.lineage_id}</dd>
        </div>

        <div>
          <dt>Available decision</dt>
          <dd>Approve Canonical Package</dd>
        </div>
      </dl>

      <div className="approvals-workspace-section">
        <h3>Interpreted objective</h3>
        <p>{request.evidence.interpreted_objective}</p>
      </div>

      <div className="approvals-workspace-section">
        <h3>Proposed work</h3>
        <p>
          {request.evidence.proposed_work ??
            "No proposed work recorded."}
        </p>
      </div>

      <div className="approvals-workspace-section">
        <h3>Proposed artifacts</h3>
        <p>
          {request.evidence.proposed_artifacts ??
            "No proposed artifacts recorded."}
        </p>
      </div>

      <div className="approvals-workspace-section">
        <h3>Scope and constraints</h3>

        <dl className="approvals-workspace-facts">
          <div>
            <dt>In scope</dt>
            <dd>
              {request.evidence.in_scope ?? "Not recorded"}
            </dd>
          </div>

          <div>
            <dt>Out of scope</dt>
            <dd>
              {request.evidence.out_of_scope ?? "Not recorded"}
            </dd>
          </div>

          <div>
            <dt>Constraints</dt>
            <dd>
              {request.evidence.constraints ?? "Not recorded"}
            </dd>
          </div>

          <div>
            <dt>Expected outcome</dt>
            <dd>
              {request.evidence.expected_outcome ??
                "Not recorded"}
            </dd>
          </div>
        </dl>
      </div>

      <div className="approvals-workspace-section">
        <h3>Evidence references</h3>

        {request.evidence.evidence_entry_ids.length > 0 ? (
          <ul className="approvals-workspace-evidence">
            {request.evidence.evidence_entry_ids.map(
              (evidenceId) => (
                <li key={evidenceId}>{evidenceId}</li>
              ),
            )}
          </ul>
        ) : (
          <p>No evidence references available.</p>
        )}
      </div>
    </section>
  );
}

export default function ApprovalsWorkspace() {
  const {
    collection,
    loading,
    error,
    refresh,
  } = useApprovalRequests();

  const requests = collection?.requests ?? [];

  const [
    selectedRequestId,
    setSelectedRequestId,
  ] = useState<string | null>(null);

  useEffect(() => {
    if (
      selectedRequestId &&
      requests.some(
        (request) =>
          request.approval_request_id === selectedRequestId,
      )
    ) {
      return;
    }

    setSelectedRequestId(
      requests[0]?.approval_request_id ?? null,
    );
  }, [requests, selectedRequestId]);

  const selectedRequest =
    requests.find(
      (request) =>
        request.approval_request_id === selectedRequestId,
    ) ?? null;

  return (
    <main className="approvals-workspace">
      <header className="approvals-workspace-header">
        <div>
          <p className="approvals-workspace-eyebrow">
            Executive inbox
          </p>

          <h1>Approvals</h1>

          <p>
            Pending decisions derived from authoritative
            project runtime state.
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

      <div className="approvals-workspace-notice">
        Approval Requests are projections over authoritative
        runtime state. This workspace does not create,
        approve, reject, confirm, authorize, or mutate
        anything.
      </div>

      {loading && !collection ? (
        <section className="approvals-workspace-state">
          Loading pending Approval Requests…
        </section>
      ) : null}

      {error ? (
        <section className="approvals-workspace-state">
          <h2>Approval Requests could not be loaded.</h2>
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
        <section className="approvals-workspace-state">
          <h2>No approvals need your attention.</h2>
          <p>
            Pending Canonical Package approvals will appear
            here when authoritative runtime state requires an
            executive decision.
          </p>
        </section>
      ) : null}

      {!error && requests.length > 0 ? (
        <div className="approvals-workspace-layout">
          <aside
            className="approvals-workspace-list"
            aria-label="Pending Approval Requests"
          >
            <div className="approvals-workspace-list__header">
              <h2>Pending</h2>
              <span>{requests.length}</span>
            </div>

            {requests.map((request) => (
              <ApprovalRequestListItem
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
          </aside>

          {selectedRequest ? (
            <ApprovalRequestDetail
              request={selectedRequest}
            />
          ) : null}
        </div>
      ) : null}
    </main>
  );
}
