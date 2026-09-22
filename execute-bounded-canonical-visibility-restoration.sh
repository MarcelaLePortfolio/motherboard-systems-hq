#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="8b1ecd9ea"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

AUTHORIZED_NEW_PATHS=(
  "db/canonical-package-read-repository.ts"
  "routes/api-canonical-package-read.ts"
  "client/src/approvals/canonicalPackageReadApi.ts"
  "docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_IMPLEMENTATION.md"
)

AUTHORIZED_EXISTING_PATHS=(
  "server/index.ts"
  "client/src/approvals/ApprovalsWorkspace.tsx"
)

for path in "${AUTHORIZED_NEW_PATHS[@]}"; do
  test ! -e "$path" || {
    echo "STOP=AUTHORIZED_NEW_PATH_ALREADY_EXISTS:$path"
    exit 1
  }
done

for path in "${AUTHORIZED_EXISTING_PATHS[@]}"; do
  test -f "$path" || {
    echo "STOP=AUTHORIZED_EXISTING_PATH_MISSING:$path"
    exit 1
  }

  git diff --quiet -- "$path" || {
    echo "STOP=AUTHORIZED_EXISTING_PATH_MODIFIED:$path"
    exit 1
  }

  git diff --cached --quiet -- "$path" || {
    echo "STOP=AUTHORIZED_EXISTING_PATH_STAGED:$path"
    exit 1
  }
done

cat > db/canonical-package-read-repository.ts << 'TS'
import Database from "better-sqlite3";

export interface CanonicalPackageReadRecord {
  package_id: string;
  package_version: number;
  summary_id: string;
  draft_package_id: string;
  draft_revision_id: string | null;
  lineage_id: string;
  project_id: string;
  conversation_id: string | null;
  approved_interpretation: string;
  approved_work: string | null;
  approved_artifacts: string | null;
  approved_scope: string | null;
  approved_constraints: string | null;
  approved_expected_outcome: string | null;
  approval_actor: string;
  approval_timestamp: string;
  status: "canonical_approved";
  created_at: string;
}

export interface CanonicalPackageReadRepository {
  listByProject(projectId: string): CanonicalPackageReadRecord[];
  close(): void;
}

function requireIdentifier(
  value: string,
  name: string,
): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(`${name} is required.`);
  }

  return normalized;
}

export function createCanonicalPackageReadRepository(
  databasePath = "db/main.db",
): CanonicalPackageReadRepository {
  const db = new Database(databasePath, {
    readonly: true,
    fileMustExist: true,
  });

  const listStatement = db.prepare(`
    SELECT
      package_id,
      package_version,
      summary_id,
      draft_package_id,
      draft_revision_id,
      lineage_id,
      project_id,
      conversation_id,
      approved_interpretation,
      approved_work,
      approved_artifacts,
      approved_scope,
      approved_constraints,
      approved_expected_outcome,
      approval_actor,
      approval_timestamp,
      status,
      created_at
    FROM matilda_canonical_packages
    WHERE project_id = ?
      AND status = 'canonical_approved'
    ORDER BY approval_timestamp DESC, package_version DESC
  `);

  return {
    listByProject(projectId) {
      return listStatement.all(
        requireIdentifier(projectId, "projectId"),
      ) as CanonicalPackageReadRecord[];
    },

    close() {
      db.close();
    },
  };
}
TS

cat > routes/api-canonical-package-read.ts << 'TS'
import { Router } from "express";
import {
  createCanonicalPackageReadRepository,
} from "../db/canonical-package-read-repository";

const router = Router();

router.get("/api/canonical-packages", (req, res) => {
  const projectId =
    typeof req.query.project_id === "string"
      ? req.query.project_id.trim()
      : "";

  if (!projectId) {
    res.status(400).json({
      error: "Missing or invalid 'project_id' query parameter.",
    });
    return;
  }

  const repository = createCanonicalPackageReadRepository();

  try {
    res.json({
      project_id: projectId,
      packages: repository.listByProject(projectId),
    });
  } catch (error) {
    console.error(
      "[GET /api/canonical-packages] Error:",
      error,
    );

    res.status(500).json({
      error: "Unable to load approved Canonical Packages.",
    });
  } finally {
    repository.close();
  }
});

export default router;
TS

cat > client/src/approvals/canonicalPackageReadApi.ts << 'TS'
export interface CanonicalPackageReadModel {
  package_id: string;
  package_version: number;
  summary_id: string;
  draft_package_id: string;
  draft_revision_id: string | null;
  lineage_id: string;
  project_id: string;
  conversation_id: string | null;
  approved_interpretation: string;
  approved_work: string | null;
  approved_artifacts: string | null;
  approved_scope: string | null;
  approved_constraints: string | null;
  approved_expected_outcome: string | null;
  approval_actor: string;
  approval_timestamp: string;
  status: "canonical_approved";
  created_at: string;
}

export interface CanonicalPackageReadCollection {
  project_id: string;
  packages: CanonicalPackageReadModel[];
}

function requireText(
  value: string,
  fieldName: string,
): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(`${fieldName} is required.`);
  }

  return normalized;
}

export async function fetchCanonicalPackages(
  projectId: string,
): Promise<CanonicalPackageReadCollection> {
  const normalizedProjectId = requireText(
    projectId,
    "projectId",
  );

  const response = await fetch(
    `/api/canonical-packages?project_id=${encodeURIComponent(
      normalizedProjectId,
    )}`,
  );

  if (!response.ok) {
    throw new Error(
      "Unable to load approved Canonical Packages.",
    );
  }

  return response.json() as Promise<CanonicalPackageReadCollection>;
}
TS

python3 << 'PY'
from pathlib import Path

path = Path("server/index.ts")
text = path.read_text()

import_anchor = 'import matildaCanonicalPackageRouter from "./routes/matilda-canonical-package-route";'
mount_anchor = "app.use(matildaCanonicalPackageRouter);"
new_import = 'import canonicalPackageReadRouter from "../routes/api-canonical-package-read";'
new_mount = "app.use(canonicalPackageReadRouter);"

if import_anchor not in text:
    raise SystemExit("STOP: canonical package import anchor missing")

if mount_anchor not in text:
    raise SystemExit("STOP: canonical package mount anchor missing")

if new_import not in text:
    text = text.replace(
        import_anchor,
        import_anchor + "\n" + new_import,
        1,
    )

if new_mount not in text:
    text = text.replace(
        mount_anchor,
        mount_anchor + "\n" + new_mount,
        1,
    )

path.write_text(text)
PY

cat > docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_IMPLEMENTATION.md << 'DOC'
# Canonical Package Visibility Restoration — Implementation Checkpoint

Implemented within the explicitly authorized read-only boundary:

- project-scoped Canonical Package read repository;
- read-only Canonical Package API;
- typed Approvals client adapter;
- server route mount.

No Canonical Package creation, approval, Request Changes, delegation, validation, envelope, execution, governance, or authority semantics are changed.

No Packages tab is restored.

The remaining work after this bridge is bounded Approvals / Executive Inbox presentation wiring and validation.

IMPLEMENTATION_SCOPE=READ_ONLY_CANONICAL_VISIBILITY
PACKAGES_TAB_RESTORED=NO
AUTHORITY_CHANGED=NO
NEXT_ACTION=APPROVALS_PRESENTATION_WIRING
DOC

git diff --check

npm run build
npm --prefix client run build

git add -- \
  db/canonical-package-read-repository.ts \
  routes/api-canonical-package-read.ts \
  client/src/approvals/canonicalPackageReadApi.ts \
  server/index.ts \
  docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_IMPLEMENTATION.md

git diff --cached --check

git commit -m "Add canonical package read visibility bridge"
git push origin "$BRANCH"

echo "AUTHORIZED_PRODUCT_COMMIT_CREATED=YES"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
echo "PACKAGES_TAB_RESTORED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=APPROVALS_PRESENTATION_WIRING"
