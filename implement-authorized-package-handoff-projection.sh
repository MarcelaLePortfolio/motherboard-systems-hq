#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

cat > db/canonical-package-mission-projection.ts << 'INNER'
import type Database from "better-sqlite3";

export interface CanonicalPackageMissionProjectionInput {
  project_id: string | null | undefined;
  package_id: string;
  package_version: number;
}

export interface CanonicalPackageMissionProjectionResult {
  package_id: string;
  package_version: number;
  project_id: string;
  conversation_id: string;
  requested_outcome: string;
  created_at: string;
  projected: true;
  idempotent: boolean;
  delegation_authorized: false;
  validation_authorized: false;
  envelope_authorized: false;
  execution_authorized: false;
}

type CanonicalProjectionSource = {
  package_id: string;
  package_version: number;
  project_id: string | null;
  conversation_id: string | null;
  approved_expected_outcome: string | null;
  status: string;
  created_at: string;
};

type ExistingMissionProjection = {
  package_id: string;
  package_version: number;
  project_id: string | null;
  conversation_id: string | null;
  requested_outcome: string | null;
  scope: string | null;
  containment: string | null;
  constraints: string | null;
  success_criteria: string | null;
  context: string | null;
  style_presentation_intent: string | null;
  exclusions: string | null;
  created_at: string;
};

function requireText(
  value: string | null | undefined,
  field: string,
): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Canonical Package handoff requires ${field}.`);
  }

  return value;
}

function exactProjectionMatch(
  existing: ExistingMissionProjection,
  source: CanonicalProjectionSource,
): boolean {
  return (
    existing.package_id === source.package_id
    && existing.package_version === source.package_version
    && existing.project_id === source.project_id
    && existing.conversation_id === source.conversation_id
    && existing.requested_outcome === source.approved_expected_outcome
    && existing.created_at === source.created_at
    && existing.scope === null
    && existing.containment === null
    && existing.constraints === null
    && existing.success_criteria === null
    && existing.context === null
    && existing.style_presentation_intent === null
    && existing.exclusions === null
  );
}

export function projectCanonicalPackageToMissionPackage(
  sqlite: Database.Database,
  input: CanonicalPackageMissionProjectionInput,
): CanonicalPackageMissionProjectionResult {
  const project_id = requireText(input.project_id, "project_id");
  const package_id = requireText(input.package_id, "package_id");

  if (
    !Number.isInteger(input.package_version)
    || input.package_version < 1
  ) {
    throw new Error(
      "Canonical Package handoff requires package_version.",
    );
  }

  const package_version = input.package_version;

  const source = sqlite
    .prepare(`
      SELECT
        package_id,
        package_version,
        project_id,
        conversation_id,
        approved_expected_outcome,
        status,
        created_at
      FROM matilda_canonical_packages
      WHERE project_id = ?
        AND package_id = ?
        AND package_version = ?
      LIMIT 1
    `)
    .get(
      project_id,
      package_id,
      package_version,
    ) as CanonicalProjectionSource | undefined;

  if (!source) {
    throw new Error(
      "Canonical Package handoff source was not found for the exact project/package/version identity.",
    );
  }

  if (source.status !== "canonical_approved") {
    throw new Error(
      "Canonical Package handoff requires canonical_approved source status.",
    );
  }

  const conversation_id = requireText(
    source.conversation_id,
    "conversation_id",
  );

  const requested_outcome = requireText(
    source.approved_expected_outcome,
    "approved_expected_outcome",
  );

  const created_at = requireText(source.created_at, "created_at");

  const existing = sqlite
    .prepare(`
      SELECT
        package_id,
        package_version,
        project_id,
        conversation_id,
        requested_outcome,
        scope,
        containment,
        constraints,
        success_criteria,
        context,
        style_presentation_intent,
        exclusions,
        created_at
      FROM governance_packages
      WHERE package_id = ?
        AND package_version = ?
      LIMIT 1
    `)
    .get(
      package_id,
      package_version,
    ) as ExistingMissionProjection | undefined;

  if (existing) {
    if (!exactProjectionMatch(existing, source)) {
      throw new Error(
        "Canonical Package handoff target already exists with conflicting identity, semantics, or provenance.",
      );
    }

    return {
      package_id,
      package_version,
      project_id,
      conversation_id,
      requested_outcome,
      created_at,
      projected: true,
      idempotent: true,
      delegation_authorized: false,
      validation_authorized: false,
      envelope_authorized: false,
      execution_authorized: false,
    };
  }

  sqlite
    .prepare(`
      INSERT INTO governance_packages (
        package_id,
        package_version,
        project_id,
        conversation_id,
        requested_outcome,
        scope,
        containment,
        constraints,
        success_criteria,
        context,
        style_presentation_intent,
        exclusions,
        created_at
      ) VALUES (
        @package_id,
        @package_version,
        @project_id,
        @conversation_id,
        @requested_outcome,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        @created_at
      )
    `)
    .run({
      package_id,
      package_version,
      project_id,
      conversation_id,
      requested_outcome,
      created_at,
    });

  return {
    package_id,
    package_version,
    project_id,
    conversation_id,
    requested_outcome,
    created_at,
    projected: true,
    idempotent: false,
    delegation_authorized: false,
    validation_authorized: false,
    envelope_authorized: false,
    execution_authorized: false,
  };
}
INNER

cat > db/canonical-package-mission-projection.test.ts << 'INNER'
import assert from "node:assert/strict";
import test from "node:test";

import Database from "better-sqlite3";

import {
  projectCanonicalPackageToMissionPackage,
} from "./canonical-package-mission-projection";

function createFixture() {
  const sqlite = new Database(":memory:");

  sqlite.exec(`
    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      approved_expected_outcome TEXT,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      requested_outcome TEXT,
      scope TEXT,
      containment TEXT,
      constraints TEXT,
      success_criteria TEXT,
      context TEXT,
      style_presentation_intent TEXT,
      exclusions TEXT,
      created_at TEXT NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      PRIMARY KEY (package_id, package_version)
    );
  `);

  return sqlite;
}

function insertCanonical(
  sqlite: Database.Database,
  {
    package_id = "pkg-handoff",
    package_version = 1,
    project_id = "hq",
    conversation_id = "conversation-handoff",
    approved_expected_outcome = "Approved mission outcome",
    status = "canonical_approved",
    created_at = "2026-08-25T18:30:00.000Z",
  } = {},
) {
  sqlite.prepare(`
    INSERT INTO matilda_canonical_packages (
      package_id,
      package_version,
      project_id,
      conversation_id,
      approved_expected_outcome,
      status,
      created_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
  `).run(
    package_id,
    package_version,
    project_id,
    conversation_id,
    approved_expected_outcome,
    status,
    created_at,
  );
}

test("projects exact approved Canonical Package identity", () => {
  const sqlite = createFixture();
  insertCanonical(sqlite);

  const result = projectCanonicalPackageToMissionPackage(
    sqlite,
    {
      project_id: "hq",
      package_id: "pkg-handoff",
      package_version: 1,
    },
  );

  assert.equal(result.idempotent, false);
  assert.equal(result.project_id, "hq");
  assert.equal(result.package_id, "pkg-handoff");
  assert.equal(result.package_version, 1);
  assert.equal(result.conversation_id, "conversation-handoff");
  assert.equal(result.requested_outcome, "Approved mission outcome");
  assert.equal(result.delegation_authorized, false);
  assert.equal(result.execution_authorized, false);

  const row = sqlite.prepare(`
    SELECT *
    FROM governance_packages
    WHERE package_id = ?
      AND package_version = ?
  `).get("pkg-handoff", 1) as Record<string, unknown>;

  assert.equal(row.project_id, "hq");
  assert.equal(row.conversation_id, "conversation-handoff");
  assert.equal(row.requested_outcome, "Approved mission outcome");
  assert.equal(row.created_at, "2026-08-25T18:30:00.000Z");
  assert.equal(row.scope, null);
  assert.equal(row.containment, null);
  assert.equal(row.constraints, null);
  assert.equal(row.success_criteria, null);
  assert.equal(row.context, null);
  assert.equal(row.style_presentation_intent, null);
  assert.equal(row.exclusions, null);

  sqlite.close();
});

test("exact existing projection is idempotent", () => {
  const sqlite = createFixture();
  insertCanonical(sqlite);

  const input = {
    project_id: "hq",
    package_id: "pkg-handoff",
    package_version: 1,
  };

  projectCanonicalPackageToMissionPackage(sqlite, input);
  const second =
    projectCanonicalPackageToMissionPackage(sqlite, input);

  assert.equal(second.idempotent, true);

  const count = sqlite.prepare(`
    SELECT COUNT(*) AS count
    FROM governance_packages
    WHERE package_id = ?
      AND package_version = ?
  `).get("pkg-handoff", 1) as { count: number };

  assert.equal(count.count, 1);
  sqlite.close();
});

test("missing Canonical Package fails closed", () => {
  const sqlite = createFixture();

  assert.throws(
    () =>
      projectCanonicalPackageToMissionPackage(sqlite, {
        project_id: "hq",
        package_id: "pkg-missing",
        package_version: 1,
      }),
    /source was not found/,
  );

  sqlite.close();
});

test("non-approved Canonical Package fails closed", () => {
  const sqlite = createFixture();

  insertCanonical(sqlite, {
    status: "draft_non_authoritative",
  });

  assert.throws(
    () =>
      projectCanonicalPackageToMissionPackage(sqlite, {
        project_id: "hq",
        package_id: "pkg-handoff",
        package_version: 1,
      }),
    /canonical_approved/,
  );

  sqlite.close();
});

test("conflicting target fails closed without overwrite", () => {
  const sqlite = createFixture();
  insertCanonical(sqlite);

  sqlite.prepare(`
    INSERT INTO governance_packages (
      package_id,
      package_version,
      project_id,
      conversation_id,
      requested_outcome,
      created_at
    ) VALUES (?, ?, ?, ?, ?, ?)
  `).run(
    "pkg-handoff",
    1,
    "other-project",
    "legacy-conversation",
    "Legacy outcome",
    "2026-07-01T00:00:00.000Z",
  );

  assert.throws(
    () =>
      projectCanonicalPackageToMissionPackage(sqlite, {
        project_id: "hq",
        package_id: "pkg-handoff",
        package_version: 1,
      }),
    /conflicting identity, semantics, or provenance/,
  );

  const row = sqlite.prepare(`
    SELECT project_id, conversation_id, requested_outcome
    FROM governance_packages
    WHERE package_id = ?
      AND package_version = ?
  `).get("pkg-handoff", 1) as {
    project_id: string;
    conversation_id: string;
    requested_outcome: string;
  };

  assert.deepEqual(row, {
    project_id: "other-project",
    conversation_id: "legacy-conversation",
    requested_outcome: "Legacy outcome",
  });

  sqlite.close();
});
INNER

python3 <<'PY'
from pathlib import Path

path = Path("db/matilda-canonical-package-runtime.ts")
text = path.read_text()

import_anchor = (
    'import { generateReconciledIntentSummary } '
    'from "./matilda-reconciled-intent-runtime";'
)
import_line = (
    'import { projectCanonicalPackageToMissionPackage } '
    'from "./canonical-package-mission-projection";'
)

if import_anchor not in text:
    raise SystemExit("Expected canonical runtime import anchor not found")

if import_line not in text:
    text = text.replace(
        import_anchor,
        import_anchor + "\n" + import_line,
        1,
    )

return_anchor = '''  return {
    package_id,
    package_version,
    summary_id: summary.summary_id,
'''

projection_call = '''  projectCanonicalPackageToMissionPackage(
    sqlite,
    {
      project_id: summary.project_id,
      package_id,
      package_version,
    },
  );

  return {
    package_id,
    package_version,
    summary_id: summary.summary_id,
'''

if return_anchor not in text:
    raise SystemExit("Expected canonical runtime return anchor not found")

if text.count("projectCanonicalPackageToMissionPackage(") == 0:
    text = text.replace(return_anchor, projection_call, 1)

path.write_text(text)
PY

git diff --check
npx tsc --noEmit --pretty false
npx tsx --test db/canonical-package-mission-projection.test.ts

git add \
  db/canonical-package-mission-projection.ts \
  db/canonical-package-mission-projection.test.ts \
  db/matilda-canonical-package-runtime.ts

git commit -m "Implement canonical Package mission projection"
git push
