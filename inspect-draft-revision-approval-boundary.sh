#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="e0531b5ad"
DR_BOUNDARY="20260918_153528"
PRE_HEAD="$(git rev-parse HEAD)"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== BASELINE ===\n'
echo "MODE=READ_ONLY"
echo "KNOWN_FAILURE=draft_revision_id_is_required"
echo "CURRENT_DRAFT_REVISION_COUNT=0"
echo "DR_RECOVERY_BOUNDARY=$DR_BOUNDARY"

printf '\n=== DRAFT REVISION RUNTIME ===\n'
nl -ba db/matilda-draft-revision-runtime.ts | sed -n '1,230p'

printf '\n=== APPROVAL READ MODEL AND API ===\n'
nl -ba client/src/approvals/approvalRequestApi.ts | sed -n '1,280p'

printf '\n=== REVISION CREATOR CALL SITES ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  'createDraftRevisionForApprovalReview' \
  server db client/src 2>/dev/null || true

printf '\n=== APPROVAL REQUEST CONSTRUCTION PATHS ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E 'approval_request_id|canonical_package_approval|ApprovalRequestReadModel|draft_revision_id' \
  server db client/src/approvals 2>/dev/null | head -n 900 || true

printf '\n=== CURRENT SOURCE DRAFT / REVISION STATE ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

try {
  const draft = db.prepare(`
    SELECT
      draft_package_id,
      lineage_id,
      project_id,
      conversation_id,
      status,
      updated_at
    FROM matilda_living_draft_packages
    WHERE draft_package_id = ?
  `).get("matilda-draft-matilda-conversation-hq");

  const revisions = db.prepare(`
    SELECT *
    FROM matilda_draft_revisions
    WHERE draft_package_id = ?
    ORDER BY created_at DESC
  `).all("matilda-draft-matilda-conversation-hq");

  console.log(`SOURCE_DRAFT=${JSON.stringify(draft ?? null)}`);
  console.log(`DRAFT_REVISION_COUNT=${revisions.length}`);

  if (!draft) {
    throw new Error("EXPECTED_SOURCE_DRAFT_NOT_FOUND");
  }

  if (revisions.length !== 0) {
    throw new Error(
      `EXPECTED_ZERO_REVISIONS_BEFORE_FIX_BUT_FOUND=${revisions.length}`,
    );
  }

  console.log("REVISION_CREATION_GAP=CONFIRMED");
} finally {
  db.close();
}
NODE

printf '\n=== CLASSIFY HANDOFF GAP ===\n'
node <<'NODE'
const fs = require("fs");

const revisionRuntime =
  fs.readFileSync("db/matilda-draft-revision-runtime.ts", "utf8");

const canonicalRoute =
  fs.readFileSync(
    "server/routes/matilda-canonical-package-route.ts",
    "utf8",
  );

const approvalApi =
  fs.readFileSync(
    "client/src/approvals/approvalRequestApi.ts",
    "utf8",
  );

const creatorExists =
  revisionRuntime.includes("createDraftRevisionForApprovalReview");

const canonicalRequiresRevision =
  canonicalRoute.includes("req.body?.draft_revision_id");

const clientSendsRevision =
  approvalApi.includes("draft_revision_id");

console.log(
  `REVISION_CREATOR_EXISTS=${creatorExists ? "YES" : "NO"}`,
);
console.log(
  `CANONICAL_ROUTE_REQUIRES_REVISION=${
    canonicalRequiresRevision ? "YES" : "NO"
  }`,
);
console.log(
  `CLIENT_CANONICAL_REQUEST_SENDS_REVISION=${
    clientSendsRevision ? "YES" : "NO"
  }`,
);

if (
  creatorExists &&
  canonicalRequiresRevision &&
  !clientSendsRevision
) {
  console.log(
    "HANDOFF_GAP=REVISION_NOT_CREATED_OR_PROPAGATED_TO_CANONICAL_APPROVAL_REQUEST",
  );
  console.log(
    "FIX_DIRECTION=PROVE_APPROVAL_REVIEW_REVISION_CREATION_BOUNDARY_AND_PROPAGATE_EXACT_REVISION_ID",
  );
} else {
  console.log(
    "HANDOFF_GAP=REQUIRES_FURTHER_CLASSIFICATION",
  );
}
NODE

printf '\n=== VERIFY READ ONLY ===\n'
test "$(git rev-parse HEAD)" = "$PRE_HEAD"
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  db/main.db \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  client/src/approvals

printf '\n=== STOPPING POINT ===\n'
echo "DRAFT_REVISION_APPROVAL_BOUNDARY_INSPECTION=COMPLETE"
echo "FIX_EXECUTED=NO"
echo "DATABASE_MUTATED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "CANONICAL_MUTATION=NO"
echo "GOVERNANCE_MUTATION=NO"
echo "AUTHORITY_CHANGE=NO"
echo "DR_RECOVERY_BOUNDARY=$DR_BOUNDARY"
echo "NEXT_ACTION=USE_CALL_SITE_EVIDENCE_TO_DEFINE_ONE_EXACT_REVISION_HANDOFF_FIX"
echo "CLEAR_STOPPING_POINT=YES"
