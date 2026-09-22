#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="$(git rev-parse --short=9 HEAD)"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

for path in \
  client/src/approvals/ApprovalRequestProvider.tsx \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/canonicalPackageReadApi.ts
do
  test -f "$path"
  git diff --quiet -- "$path"
  git diff --cached --quiet -- "$path"
done

cat > client/src/approvals/ApprovalRequestProvider.tsx << 'TS'
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
TS

python3 << 'PY'
from pathlib import Path

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

import_anchor = 'import { useApprovalRequests } from "./useApprovalRequests";'
canonical_import = 'import type { CanonicalPackageReadModel } from "./canonicalPackageReadApi";'

if canonical_import not in text:
    if import_anchor not in text:
        raise SystemExit("STOP: useApprovalRequests import anchor missing")
    text = text.replace(
        import_anchor,
        canonical_import + "\n" + import_anchor,
        1,
    )

briefing_anchor = "function BriefingSection({"
if briefing_anchor not in text:
    raise SystemExit("STOP: BriefingSection anchor missing")

approved_list_component = r'''
function ApprovedPackageListItem({
  pkg,
  selected,
  onSelect,
}: {
  pkg: CanonicalPackageReadModel;
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
          {deriveDecisionListTitle(
            readText(
              pkg.approved_expected_outcome,
              pkg.approved_interpretation,
            ),
          )}
        </strong>
        <DecisionBadge>Approved</DecisionBadge>
      </div>

      <p className="executive-inbox-item__summary">
        {readText(pkg.approved_interpretation)}
      </p>

      <div className="executive-inbox-item__meta">
        <time dateTime={pkg.approval_timestamp}>
          {formatTimestamp(pkg.approval_timestamp)}
        </time>
      </div>
    </button>
  );
}

'''

if "function ApprovedPackageListItem" not in text:
    text = text.replace(
        briefing_anchor,
        approved_list_component + briefing_anchor,
        1,
    )

workspace_anchor = "export default function ApprovalsWorkspace() {"
if workspace_anchor not in text:
    raise SystemExit("STOP: ApprovalsWorkspace anchor missing")

approved_detail_component = r'''
function ApprovedCanonicalPackageBriefing({
  pkg,
  onClose,
}: {
  pkg: CanonicalPackageReadModel;
  onClose(): void;
}) {
  return (
    <article className="executive-briefing">
      <header className="executive-briefing__header executive-briefing__header--calm">
        <div>
          <div className="executive-briefing__status-line">
            <DecisionBadge>Approved</DecisionBadge>
          </div>

          <h2>Canonical Package</h2>

          <p className="executive-briefing__question">
            {readText(pkg.approved_interpretation)}
          </p>
        </div>
      </header>

      <BriefingSection title="Approved package">
        <dl className="executive-briefing-grid">
          <div>
            <dt>Expected outcome</dt>
            <dd>{readText(pkg.approved_expected_outcome)}</dd>
          </div>

          <div>
            <dt>Approved work</dt>
            <dd>{readText(pkg.approved_work)}</dd>
          </div>

          <div>
            <dt>Deliverables</dt>
            <dd>{readText(pkg.approved_artifacts)}</dd>
          </div>

          <div>
            <dt>Scope</dt>
            <dd>{readText(pkg.approved_scope)}</dd>
          </div>

          <div>
            <dt>Constraints</dt>
            <dd>{readText(pkg.approved_constraints)}</dd>
          </div>
        </dl>
      </BriefingSection>

      <details className="executive-briefing-technical">
        <summary>Technical details</summary>

        <dl className="executive-briefing-grid">
          <div>
            <dt>Package</dt>
            <dd>{pkg.package_id}</dd>
          </div>

          <div>
            <dt>Version</dt>
            <dd>{pkg.package_version}</dd>
          </div>

          <div>
            <dt>Draft package</dt>
            <dd>{pkg.draft_package_id}</dd>
          </div>

          <div>
            <dt>Draft revision</dt>
            <dd>{pkg.draft_revision_id ?? "Unavailable"}</dd>
          </div>

          <div>
            <dt>Conversation</dt>
            <dd>{pkg.conversation_id ?? "Unavailable"}</dd>
          </div>

          <div>
            <dt>Lineage</dt>
            <dd>{pkg.lineage_id}</dd>
          </div>

          <div>
            <dt>Approved by</dt>
            <dd>{pkg.approval_actor}</dd>
          </div>

          <div>
            <dt>Approved</dt>
            <dd>{formatTimestamp(pkg.approval_timestamp)}</dd>
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
          This Canonical Package is approved and read-only here.
          Approval does not delegate or execute the work.
        </p>
      </footer>
    </article>
  );
}

'''

if "function ApprovedCanonicalPackageBriefing" not in text:
    text = text.replace(
        workspace_anchor,
        approved_detail_component + workspace_anchor,
        1,
    )

old_destructure = '''  const {
    collection,
    loading,
    error,
    refresh,
  } = useApprovalRequests();
'''

new_destructure = '''  const {
    collection,
    canonicalCollection,
    loading,
    error,
    refresh,
  } = useApprovalRequests();
'''

if old_destructure not in text:
    raise SystemExit("STOP: Approvals provider destructure anchor missing")

text = text.replace(
    old_destructure,
    new_destructure,
    1,
)

requests_anchor = '''  const requests = useMemo(
    () => collection?.requests ?? [],
    [collection],
  );
'''

if requests_anchor not in text:
    raise SystemExit("STOP: requests memo anchor missing")

approved_state = r'''
  const approvedPackages = useMemo(
    () => canonicalCollection?.packages ?? [],
    [canonicalCollection],
  );

  const [
    selectedApprovedPackageId,
    setSelectedApprovedPackageId,
  ] = useState<string | null>(null);

  useEffect(() => {
    const selectionExists = approvedPackages.some(
      (pkg) => pkg.package_id === selectedApprovedPackageId,
    );

    if (
      selectedApprovedPackageId !== null &&
      !selectionExists
    ) {
      setSelectedApprovedPackageId(null);
    }
  }, [
    approvedPackages,
    selectedApprovedPackageId,
  ]);

  const selectedApprovedPackage =
    approvedPackages.find(
      (pkg) =>
        pkg.package_id === selectedApprovedPackageId,
    ) ?? null;
'''

if "const approvedPackages = useMemo(" not in text:
    text = text.replace(
        requests_anchor,
        requests_anchor + approved_state,
        1,
    )

list_close_anchor = '''              </div>
            </aside>
'''

if list_close_anchor not in text:
    raise SystemExit("STOP: decision-list close anchor missing")

approved_list_render = r'''
              {approvedPackages.length > 0 ? (
                <>
                  <div className="executive-inbox-list__section-heading">
                    <span>Approved</span>
                    <strong>{approvedPackages.length}</strong>
                  </div>

                  {approvedPackages.map((pkg) => (
                    <ApprovedPackageListItem
                      key={`${pkg.package_id}:${pkg.package_version}`}
                      pkg={pkg}
                      selected={
                        pkg.package_id ===
                        selectedApprovedPackageId
                      }
                      onSelect={() => {
                        setSelectedRequestId(null);
                        setSelectedApprovedPackageId(
                          pkg.package_id,
                        );
                      }}
                    />
                  ))}
                </>
              ) : null}

'''

if "approvedPackages.map((pkg)" not in text:
    text = text.replace(
        list_close_anchor,
        approved_list_render + list_close_anchor,
        1,
    )

selected_pending_anchor = '''              {selectedRequest ? (
                <ExecutiveBriefing
'''

if selected_pending_anchor not in text:
    raise SystemExit("STOP: selectedRequest presentation anchor missing")

approved_detail_render = r'''
              {selectedApprovedPackage ? (
                <ApprovedCanonicalPackageBriefing
                  key={`${selectedApprovedPackage.package_id}:${selectedApprovedPackage.package_version}`}
                  pkg={selectedApprovedPackage}
                  onClose={() =>
                    setSelectedApprovedPackageId(null)
                  }
                />
              ) : null}

'''

if "selectedApprovedPackage ? (" not in text:
    text = text.replace(
        selected_pending_anchor,
        approved_detail_render + selected_pending_anchor,
        1,
    )

path.write_text(text)
PY

cat > client/src/approvals/canonicalPackageReadApi.test.ts << 'TS'
import assert from "node:assert/strict";
import test from "node:test";

import {
  fetchCanonicalPackages,
} from "./canonicalPackageReadApi";

test("fetchCanonicalPackages encodes project_id", async () => {
  const originalFetch = globalThis.fetch;
  let requestedUrl = "";

  globalThis.fetch = async (
    input: RequestInfo | URL,
  ) => {
    requestedUrl = String(input);

    return new Response(
      JSON.stringify({
        project_id: "hq project",
        packages: [],
      }),
      {
        status: 200,
        headers: {
          "content-type": "application/json",
        },
      },
    );
  };

  try {
    const result =
      await fetchCanonicalPackages("hq project");

    assert.equal(
      requestedUrl,
      "/api/canonical-packages?project_id=hq%20project",
    );
    assert.deepEqual(result.packages, []);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("fetchCanonicalPackages fails closed on non-ok response", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = async () =>
    new Response("failure", {
      status: 500,
    });

  try {
    await assert.rejects(
      () => fetchCanonicalPackages("hq"),
      /Unable to load approved Canonical Packages/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
TS

cat > docs/checkpoints/CANONICAL_PACKAGE_APPROVALS_PRESENTATION_IMPLEMENTATION.md << 'DOC'
# Canonical Package Approvals Presentation — Implementation

Implemented within the explicitly authorized presentation boundary:

- `ApprovalRequestProvider` fetches both pending Approval Requests and approved Canonical Packages for the same existing `projectId`;
- pending Approval Requests remain unchanged and actionable;
- approved Canonical Packages appear as a distinct `Approved` state;
- approved Canonical Package detail is read-only;
- approved Canonical Packages expose no Approve or Request Changes actions;
- no Packages tab is restored.

Protected semantics remain unchanged:

- Canonical Package creation and persistence;
- approval;
- Request Changes;
- delegation;
- validation;
- envelope construction;
- execution;
- governance;
- authority.

APPROVED_PRESENTATION=IMPLEMENTED
PENDING_PRESENTATION=UNCHANGED
PACKAGES_TAB_RESTORED=NO
AUTHORITY_CHANGED=NO
NEXT_ACTION=STATIC_AND_RUNTIME_VALIDATION
DOC

git diff --check

npm run build
npm --prefix client run build

git add -- \
  client/src/approvals/ApprovalRequestProvider.tsx \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/canonicalPackageReadApi.test.ts \
  docs/checkpoints/CANONICAL_PACKAGE_APPROVALS_PRESENTATION_IMPLEMENTATION.md

git diff --cached --check

git commit -m "Present approved canonical packages in Approvals"
git push origin "$BRANCH"

echo "APPROVED_PRESENTATION_IMPLEMENTED=YES"
echo "PENDING_ACTIONS_PRESERVED=YES"
echo "APPROVED_ACTIONS=NONE"
echo "PACKAGES_TAB_RESTORED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=RUNTIME_VALIDATE_APPROVED_CANONICAL_VISIBILITY"
