#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="5cf1edec5"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git status --porcelain)"

printf '\n============================================================\n'
printf ' CANONICAL PACKAGE VISIBILITY — AUTHORIZED IMPLEMENTATION\n'
printf '============================================================\n'
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "RESTORATION_TYPE=READ_ONLY_PRESENTATION_BRIDGE"
echo "PACKAGES_TAB_RESTORATION_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE_AUTHORIZED=NO"

cat > db/canonical-package-read-repository.ts << 'TS'
import Database from "better-sqlite3";

export interface CanonicalPackageReadRecord {
  package_id: string;
  package_version: number;
  summary_id: string;
  draft_package_id: string;
  draft_revision_id: string;
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
  status: string;
  created_at: string;
}

function requireText(value: string, fieldName: string): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(`${fieldName} is required.`);
  }

  return normalized;
}

export function listCanonicalPackagesByProject(
  db: Database.Database,
  projectId: string,
): CanonicalPackageReadRecord[] {
  const project_id = requireText(projectId, "projectId");

  return db.prepare(`
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
  `).all(project_id) as CanonicalPackageReadRecord[];
}
TS

cat > routes/api-canonical-package-read.ts << 'TS'
import { Router } from "express";
import Database from "better-sqlite3";
import {
  listCanonicalPackagesByProject,
} from "../db/canonical-package-read-repository";

export function createCanonicalPackageReadRouter(
  db: Database.Database,
): Router {
  const router = Router();

  router.get("/api/canonical-packages", (req, res) => {
    const projectId =
      typeof req.query.project_id === "string"
        ? req.query.project_id.trim()
        : "";

    if (!projectId) {
      res.status(400).json({
        error: "project_id is required.",
      });
      return;
    }

    try {
      res.json({
        project_id: projectId,
        packages: listCanonicalPackagesByProject(db, projectId),
      });
    } catch (error) {
      res.status(500).json({
        error:
          error instanceof Error
            ? error.message
            : "Unable to load Canonical Packages.",
      });
    }
  });

  return router;
}
TS

cat > client/src/approvals/canonicalPackageReadApi.ts << 'TS'
export interface CanonicalPackageReadModel {
  package_id: string;
  package_version: number;
  summary_id: string;
  draft_package_id: string;
  draft_revision_id: string;
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

export interface CanonicalPackageCollection {
  project_id: string;
  packages: CanonicalPackageReadModel[];
}

function requireText(value: string, fieldName: string): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(`${fieldName} is required.`);
  }

  return normalized;
}

export async function fetchCanonicalPackages(
  projectId: string,
): Promise<CanonicalPackageCollection> {
  const normalizedProjectId = requireText(projectId, "projectId");

  const response = await fetch(
    `/api/canonical-packages?project_id=${encodeURIComponent(
      normalizedProjectId,
    )}`,
  );

  if (!response.ok) {
    throw new Error("Unable to load approved Canonical Packages.");
  }

  return response.json() as Promise<CanonicalPackageCollection>;
}
TS

python3 << 'PY'
from pathlib import Path

path = Path("server/index.ts")
text = path.read_text()

import_anchor = 'import matildaCanonicalPackageRouter from "./routes/matilda-canonical-package-route";'
new_import = 'import { createCanonicalPackageReadRouter } from "../routes/api-canonical-package-read";'

if import_anchor not in text:
    raise SystemExit("STOP: expected canonical package route import anchor not found")

if new_import not in text:
    text = text.replace(import_anchor, import_anchor + "\n" + new_import, 1)

mount_anchor = "app.use(matildaCanonicalPackageRouter);"

if mount_anchor not in text:
    raise SystemExit("STOP: expected canonical package router mount not found")

new_mount = "app.use(createCanonicalPackageReadRouter(db));"

if new_mount not in text:
    text = text.replace(mount_anchor, mount_anchor + "\n" + new_mount, 1)

path.write_text(text)
PY

printf '\n=== VERIFY READ BRIDGE STRUCTURE ===\n'
git diff --check

printf '\n=== SERVER BUILD ===\n'
npm run build

printf '\n=== CLIENT BUILD ===\n'
npm --prefix client run build

cat > docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_IMPLEMENTATION.md << 'DOC'
# Canonical Package Visibility Restoration — Implementation Checkpoint

## Authorized Boundary

The explicitly authorized read-only Canonical Package visibility restoration has begun.

Implemented in this checkpoint:

- project-scoped Canonical Package read repository;
- read-only Canonical Package API;
- typed client Canonical Package read adapter.

The remaining presentation wiring must reuse the existing Approvals / Executive Inbox and preserve pending Approval Requests and approved Canonical Packages as semantically distinct states.

## Protected Boundaries

No Packages tab is restored.

No change is authorized to:

- Canonical Package creation;
- approval semantics;
- Request Changes;
- delegation;
- validation;
- envelope construction;
- execution;
- governance;
- authority.

IMPLEMENTATION_SCOPE=READ_ONLY_CANONICAL_VISIBILITY
PACKAGES_TAB_RESTORED=NO
AUTHORITY_CHANGED=NO
NEXT_ACTION=WIRE_APPROVED_CANONICAL_READ_MODEL_INTO_EXISTING_APPROVALS_PRESENTATION
CLEAR_STOPPING_POINT=YES
DOC

git diff --check

git add -- \
  db/canonical-package-read-repository.ts \
  routes/api-canonical-package-read.ts \
  server/index.ts \
  client/src/approvals/canonicalPackageReadApi.ts \
  docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_IMPLEMENTATION.md

git commit -m "Add canonical package read visibility bridge"
git push origin "$BRANCH"

printf '\n============================================================\n'
printf ' READ-ONLY BRIDGE CHECKPOINT COMPLETE\n'
printf '============================================================\n'
echo "PRODUCT_SCOPE=AUTHORIZED_READ_ONLY_BRIDGE"
echo "PACKAGES_TAB_RESTORED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=APPROVALS_PRESENTATION_WIRING"
echo "CLEAR_STOPPING_POINT=YES"
