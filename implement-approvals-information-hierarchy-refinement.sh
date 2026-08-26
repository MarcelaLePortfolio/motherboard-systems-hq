#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 - << 'PY'
from pathlib import Path

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

text = text.replace(
'''      <div className="executive-inbox-item__heading">
        <strong>{artifactLabel(request, index)}</strong>
        <DecisionBadge>Pending</DecisionBadge>
      </div>

      <p className="executive-inbox-item__summary">
        {readText(
          request.evidence.expected_outcome,
          request.evidence.interpreted_objective,
        )}
      </p>

      <div className="executive-inbox-item__meta">
        <span>Approve Canonical Package</span>

        <time dateTime={request.updated_at}>
          {formatTimestamp(request.updated_at)}
        </time>
      </div>
''',
'''      <div className="executive-inbox-item__heading">
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
'''
)

text = text.replace(
'''      <header className="executive-briefing__header">
        <div>
          <div className="executive-briefing__status-line">
            <DecisionBadge>Needs review</DecisionBadge>

            <span>
              Artifact {artifactNumber} of {artifactCount}
            </span>

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
        <strong>Selected artifact:</strong>{" "}
        {request.draft_package_id}
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
''',
'''      <header className="executive-briefing__header executive-briefing__header--calm">
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
'''
)

text = text.replace(
'''      <BriefingSection title="Supporting evidence">
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
''',
'''      <details className="executive-briefing-technical">
'''
)

text = text.replace(
'''          <div>
            <dt>Lineage</dt>
            <dd>{request.lineage_id}</dd>
          </div>
        </dl>
      </details>
''',
'''          <div>
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
'''
)

path.write_text(text)
PY

echo "=== VERIFY AUTHORIZED CONTENT RECOMPOSITION ==="
rg -n \
  'Package Review|What you are approving|Approval effect|Needs review|Source status|Artifact position|Supporting evidence' \
  client/src/approvals/ApprovalsWorkspace.tsx

if rg -n \
  'Approve Canonical Package|Selected artifact:|<DecisionBadge>Pending</DecisionBadge>|BriefingSection title="Requested outcome"|BriefingSection title="Proposed work"|BriefingSection title="Proposed artifacts"' \
  client/src/approvals/ApprovalsWorkspace.tsx
then
  echo "LEGACY_PRIMARY_PRESENTATION=YES"
  exit 1
fi

(
  cd client
  npm run build
)

git diff --check

git add client/src/approvals/ApprovalsWorkspace.tsx
git commit -m "Refine Approvals information hierarchy"
git push
