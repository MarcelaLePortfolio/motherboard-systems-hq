#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="7198a4dd7"
DOC="docs/checkpoints/APPROVED_PACKAGE_BLANK_RENDER_CLASSIFICATION.md"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

cat > "$DOC" << 'DOC'
# Approved Canonical Package Blank Render — Classification

Date: 2026-09-22

## Conclusion

The browser failure is now classified.

The live server on port 3000 returns the approved Canonical Package without the required `delegation` projection.

The current client detail surface assumes that `pkg.delegation` exists and dereferences `pkg.delegation.state` during render.

Therefore, selecting the approved package causes a render-time failure when the browser receives the live payload currently being served.

## Evidence

LIVE_SERVER_PORT=3000
LIVE_CANONICAL_PACKAGE_HTTP_STATUS=200
LIVE_PAYLOAD_CONTAINS_DELEGATION_PROJECTION=NO

CLIENT_READ_MODEL_REQUIRES_DELEGATION=YES
CLIENT_DETAIL_RENDER_DEREFERENCES_DELEGATION_STATE=YES

SOURCE_REPOSITORY_CONTAINS_DELEGATION_PROJECTION=YES
COMPILED_REPOSITORY_CONTAINS_DELEGATION_PROJECTION=YES

## Classification

ROOT_CAUSE_CLASS=RUNNING_SERVER_RUNTIME_STALE_OR_NOT_USING_CURRENT_CANONICAL_PACKAGE_READ_PATH

The evidence does not currently support changing the Executive Delegation product implementation.

Both source and compiled repository code contain the new Delegation projection, while the live HTTP response does not. The next bounded action is runtime reconciliation: determine which process/code path the port-3000 server is serving and restart the current built server if it is stale.

## Governance / Mutation Boundary

PRODUCT_FIX_AUTHORIZED=NO
PRODUCT_CODE_MUTATION_REQUIRED_BY_CURRENT_EVIDENCE=NO
DATABASE_MUTATION_REQUIRED=NO
DATABASE_SCHEMA_MUTATION_REQUIRED=NO
AUTHORITY_CHANGE_REQUIRED=NO

Approval ≠ Delegation ≠ Execution.

## Current Status

BROWSER_VALIDATION=FAILED_DUE_TO_LIVE_RUNTIME_PAYLOAD_MISMATCH
EXECUTIVE_DELEGATION_IMPLEMENTATION_SOURCE=INTACT
COMPILED_DELEGATION_READ_MODEL=INTACT
LIVE_RUNTIME_RECONCILIATION_REQUIRED=YES

NEXT_ACTION=RECONCILE_RUNNING_SERVER_RUNTIME
CLEAR_STOPPING_POINT=YES
DOC

git diff --check -- "$DOC"

git add -- "$DOC" classify-approved-package-blank-render.sh
git commit -m "Classify approved package blank render"
git push origin "$BRANCH"
