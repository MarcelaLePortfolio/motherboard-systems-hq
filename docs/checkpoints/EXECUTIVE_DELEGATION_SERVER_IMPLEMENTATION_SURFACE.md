# Executive Delegation — Server Implementation Surface

Branch: feature/support-source-references-runtime
Baseline: 279d1388d

## Verified Existing Files

- `db/approval-request-repository.test.ts`
- `db/approval-request-repository.ts`
- `db/canonical-package-mission-projection.test.ts`
- `db/canonical-package-mission-projection.ts`
- `db/canonical-package-read-repository.ts`
- `db/governance-delegation-persistence.test.ts`
- `db/governance-execution-read-repository.test.ts`
- `db/governance-execution-read-repository.ts`
- `db/governance-runtime.ts`
- `db/governance-runtime.ts.bak`
- `db/governance-stale-delegation-fk-migration.test.ts`
- `db/governance-stale-delegation-fk-migration.ts`
- `db/matilda-canonical-package-runtime.test.ts`
- `db/matilda-canonical-package-runtime.ts`
- `db/mission-read-project-scoped-handoff.test.ts`
- `db/mission-read-repository.test.ts`
- `db/mission-read-repository.ts`
- `db/operational-intake-runtime.test.ts`
- `db/operational-package-authority.test.ts`
- `db/operational-package-authority.ts`
- `server/atlas/atlas-canonical-package-observation.test.ts`
- `server/atlas/atlas-canonical-package-observation.ts`
- `server/index.ts`
- `server/matilda-chat-workflow.explicit-target.integration.test.ts`
- `server/routes/governance-delegation-route.ts`

## File Contents

### db/approval-request-repository.test.ts

```text
import assert from "node:assert/strict";
import test from "node:test";
import Database from "better-sqlite3";

import { createApprovalRequestRepository } from "./approval-request-repository";

function createFixtureDatabase(databasePath: string): void {
  const db = new Database(databasePath);

  db.exec(`
    CREATE TABLE matilda_living_draft_packages (
      draft_package_id TEXT PRIMARY KEY,
      lineage_id TEXT NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      current_interpretation TEXT NOT NULL,
      proposed_work TEXT,
      proposed_artifacts TEXT,
      in_scope TEXT,
      out_of_scope TEXT,
      constraints TEXT,
      expected_outcome TEXT,
      unresolved_questions TEXT,
      evidence_entry_ids TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    CREATE TABLE matilda_canonical_packages (
      package_id TEXT PRIMARY KEY,
      summary_id TEXT NOT NULL,
      draft_package_id TEXT NOT NULL,
      lineage_id TEXT NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      approved_interpretation TEXT NOT NULL,
      approved_work TEXT,
      approved_artifacts TEXT,
      approved_scope TEXT,
      approved_constraints TEXT,
      approved_expected_outcome TEXT,
      approval_actor TEXT NOT NULL,
      approval_timestamp TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL
    );
  `);

  const insertDraft = db.prepare(`
    INSERT INTO matilda_living_draft_packages (
      draft_package_id,
      lineage_id,
      project_id,
      conversation_id,
      current_interpretation,
      proposed_work,
      proposed_artifacts,
      in_scope,
      out_of_scope,
      constraints,
      expected_outcome,
      unresolved_questions,
      evidence_entry_ids,
      status,
      created_at,
      updated_at
    ) VALUES (
      @draft_package_id,
      @lineage_id,
      @project_id,
      @conversation_id,
      @current_interpretation,
      @proposed_work,
      @proposed_artifacts,
      @in_scope,
      @out_of_scope,
      @constraints,
      @expected_outcome,
      @unresolved_questions,
      @evidence_entry_ids,
      @status,
      @created_at,
      @updated_at
    )
  `);

  insertDraft.run({
    draft_package_id: "draft-hq-pending",
    lineage_id: "lineage-hq-pending",
    project_id: "hq",
    conversation_id: "conversation-hq",
    current_interpretation: "Prepare the HQ approval repository.",
    proposed_work: "Build a read-only repository.",
    proposed_artifacts: "Repository and tests.",
    in_scope: "Canonical Package approval requests.",
    out_of_scope: "Decision execution.",
    constraints: "Read-only.",
    expected_outcome: "One pending approval request.",
    unresolved_questions: null,
    evidence_entry_ids: JSON.stringify(["evidence-1"]),
    status: "draft_non_authoritative",
    created_at: "2026-08-01T06:00:00.000Z",
    updated_at: "2026-08-01T07:00:00.000Z",
  });

  insertDraft.run({
    draft_package_id: "draft-hq-completed",
    lineage_id: "lineage-hq-completed",
    project_id: "hq",
    conversation_id: "conversation-hq",
    current_interpretation: "Already approved work.",
    proposed_work: null,
    proposed_artifacts: null,
    in_scope: null,
    out_of_scope: null,
    constraints: null,
    expected_outcome: null,
    unresolved_questions: null,
    evidence_entry_ids: JSON.stringify(["evidence-2"]),
    status: "draft_non_authoritative",
    created_at: "2026-08-01T05:00:00.000Z",
    updated_at: "2026-08-01T05:30:00.000Z",
  });

  insertDraft.run({
    draft_package_id: "draft-other-project",
    lineage_id: "lineage-other-project",
    project_id: "other",
    conversation_id: "conversation-other",
    current_interpretation: "Other project work.",
    proposed_work: null,
    proposed_artifacts: null,
    in_scope: null,
    out_of_scope: null,
    constraints: null,
    expected_outcome: null,
    unresolved_questions: null,
    evidence_entry_ids: JSON.stringify(["evidence-3"]),
    status: "draft_non_authoritative",
    created_at: "2026-08-01T04:00:00.000Z",
    updated_at: "2026-08-01T04:30:00.000Z",
  });

  db.prepare(`
    INSERT INTO matilda_canonical_packages (
      package_id,
      summary_id,
      draft_package_id,
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
    ) VALUES (
      'pkg-hq-completed',
      'summary-hq-completed',
      'draft-hq-completed',
      'lineage-hq-completed',
      'hq',
      'conversation-hq',
      'Already approved work.',
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      'Marcela',
      '2026-08-01T05:45:00.000Z',
      'canonical_approved',
      '2026-08-01T05:45:00.000Z'
    )
  `).run();

  db.close();
}

test("lists pending Canonical Package approvals for the selected project", () => {
  const databasePath = `/tmp/approval-request-repository-${process.pid}-list.db`;

  createFixtureDatabase(databasePath);

  const repository = createApprovalRequestRepository(databasePath);

  try {
    const records =
      repository.listPendingCanonicalPackageApprovalsByProject("hq");

    assert.equal(records.length, 1);
    assert.equal(records[0]?.draft_package_id, "draft-hq-pending");
  } finally {
    repository.close();
  }
});

```

### db/approval-request-repository.ts

```text
import Database from "better-sqlite3";

export type ApprovalRequestSourceRecord = {
  draft_package_id: string;
  lineage_id: string;
  project_id: string;
  conversation_id: string | null;
  current_interpretation: string;
  proposed_work: string | null;
  proposed_artifacts: string | null;
  in_scope: string | null;
  out_of_scope: string | null;
  constraints: string | null;
  expected_outcome: string | null;
  unresolved_questions: string | null;
  evidence_entry_ids: string;
  source_draft_status: string;
  created_at: string;
  updated_at: string;
};

export interface ApprovalRequestRepository {
  listPendingCanonicalPackageApprovalsByProject(
    projectId: string,
  ): ApprovalRequestSourceRecord[];

  getPendingCanonicalPackageApprovalById(
    projectId: string,
    draftPackageId: string,
  ): ApprovalRequestSourceRecord | null;

  getPendingCanonicalPackageApprovalByDraftPackageId(
    draftPackageId: string,
  ): ApprovalRequestSourceRecord | null;

  close(): void;
}

function requireIdentifier(value: string, name: string): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(`${name} is required.`);
  }

  return normalized;
}

export function createApprovalRequestRepository(
  databasePath = "db/main.db",
): ApprovalRequestRepository {
  const db = new Database(databasePath, {
    readonly: true,
    fileMustExist: true,
  });

  const listStatement = db.prepare(`
    SELECT
      draft.draft_package_id,
      draft.lineage_id,
      draft.project_id,
      draft.conversation_id,
      draft.current_interpretation,
      draft.proposed_work,
      draft.proposed_artifacts,
      draft.in_scope,
      draft.out_of_scope,
      draft.constraints,
      draft.expected_outcome,
      draft.unresolved_questions,
      draft.evidence_entry_ids,
      draft.status AS source_draft_status,
      draft.created_at,
      draft.updated_at
    FROM matilda_living_draft_packages AS draft
    LEFT JOIN matilda_canonical_packages AS canonical
      ON canonical.draft_package_id = draft.draft_package_id
    WHERE draft.project_id = ?
      AND canonical.package_id IS NULL
    ORDER BY draft.updated_at DESC, draft.draft_package_id ASC
  `);

  const detailStatement = db.prepare(`
    SELECT
      draft.draft_package_id,
      draft.lineage_id,
      draft.project_id,
      draft.conversation_id,
      draft.current_interpretation,
      draft.proposed_work,
      draft.proposed_artifacts,
      draft.in_scope,
      draft.out_of_scope,
      draft.constraints,
      draft.expected_outcome,
      draft.unresolved_questions,
      draft.evidence_entry_ids,
      draft.status AS source_draft_status,
      draft.created_at,
      draft.updated_at
    FROM matilda_living_draft_packages AS draft
    LEFT JOIN matilda_canonical_packages AS canonical
      ON canonical.draft_package_id = draft.draft_package_id
    WHERE draft.project_id = ?
      AND draft.draft_package_id = ?
      AND canonical.package_id IS NULL
    LIMIT 1
  `);

  const detailByDraftPackageIdStatement = db.prepare(`
    SELECT
      draft.draft_package_id,
      draft.lineage_id,
      draft.project_id,
      draft.conversation_id,
      draft.current_interpretation,
      draft.proposed_work,
      draft.proposed_artifacts,
      draft.in_scope,
      draft.out_of_scope,
      draft.constraints,
      draft.expected_outcome,
      draft.unresolved_questions,
      draft.evidence_entry_ids,
      draft.status AS source_draft_status,
      draft.created_at,
      draft.updated_at
    FROM matilda_living_draft_packages AS draft
    LEFT JOIN matilda_canonical_packages AS canonical
      ON canonical.draft_package_id = draft.draft_package_id
    WHERE draft.draft_package_id = ?
      AND canonical.package_id IS NULL
    LIMIT 1
  `);

  return {
    listPendingCanonicalPackageApprovalsByProject(projectId) {
      return listStatement.all(
        requireIdentifier(projectId, "projectId"),
      ) as ApprovalRequestSourceRecord[];
    },

    getPendingCanonicalPackageApprovalById(projectId, draftPackageId) {
      return (
        (detailStatement.get(
          requireIdentifier(projectId, "projectId"),
          requireIdentifier(draftPackageId, "draftPackageId"),
        ) as ApprovalRequestSourceRecord | undefined) ?? null
      );
    },

    getPendingCanonicalPackageApprovalByDraftPackageId(draftPackageId) {
      return (
        (detailByDraftPackageIdStatement.get(
          requireIdentifier(draftPackageId, "draftPackageId"),
        ) as ApprovalRequestSourceRecord | undefined) ?? null
      );
    },

    close() {
      db.close();
    },
  };
}

```

### db/canonical-package-mission-projection.test.ts

```text
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

```

### db/canonical-package-mission-projection.ts

```text
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

```

### db/canonical-package-read-repository.ts

```text
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

```

### db/governance-delegation-persistence.test.ts

```text
import assert from "node:assert/strict";
import test from "node:test";
import Database from "better-sqlite3";

test("project-scoped Delegation persistence binds and stores project_id", () => {
  const db = new Database(":memory:");

  db.exec(`
    PRAGMA foreign_keys = ON;

    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      status TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE UNIQUE INDEX idx_matilda_canonical_packages_project_package_version
    ON matilda_canonical_packages(project_id, package_id, package_version);

    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      project_id TEXT,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (project_id, package_id, package_version)
        REFERENCES matilda_canonical_packages(project_id, package_id, package_version)
    );

    INSERT INTO matilda_canonical_packages (
      package_id,
      package_version,
      project_id,
      status
    ) VALUES (
      'pkg-direct-persistence',
      1,
      'hq',
      'canonical_approved'
    );
  `);

  const insert = db.prepare(`
    INSERT INTO governance_delegations (
      delegation_id,
      project_id,
      package_id,
      package_version,
      authorization_state,
      authorization_timestamp,
      delegated_by,
      created_at
    ) VALUES (
      @delegation_id,
      @project_id,
      @package_id,
      @package_version,
      @authorization_state,
      @authorization_timestamp,
      @delegated_by,
      @created_at
    )
  `);

  insert.run({
    delegation_id: "delegation-direct-persistence",
    project_id: "hq",
    package_id: "pkg-direct-persistence",
    package_version: 1,
    authorization_state: "AUTHORIZED",
    authorization_timestamp: "2026-08-25T18:05:00.000Z",
    delegated_by: "marcela",
    created_at: "2026-08-25T18:05:00.000Z",
  });

  const persisted = db.prepare(`
    SELECT project_id, package_id, package_version
    FROM governance_delegations
    WHERE delegation_id = 'delegation-direct-persistence'
  `).get() as {
    project_id: string;
    package_id: string;
    package_version: number;
  };

  assert.deepEqual(persisted, {
    project_id: "hq",
    package_id: "pkg-direct-persistence",
    package_version: 1,
  });

  assert.throws(
    () =>
      insert.run({
        delegation_id: "delegation-cross-project",
        project_id: "other",
        package_id: "pkg-direct-persistence",
        package_version: 1,
        authorization_state: "AUTHORIZED",
        authorization_timestamp: "2026-08-25T18:05:00.000Z",
        delegated_by: "marcela",
        created_at: "2026-08-25T18:05:00.000Z",
      }),
    /FOREIGN KEY constraint failed/,
  );

  db.close();
});

```

### db/governance-execution-read-repository.test.ts

```text
import test from "node:test";
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import { loadGovernanceExecutionReadChain } from "./governance-execution-read-repository";

function createDb() {
  const db = new Database(":memory:");
  db.exec(`
    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY, project_id TEXT NOT NULL,
      package_id TEXT NOT NULL, package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL, authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL, created_at TEXT NOT NULL
    );
    CREATE TABLE governance_validation_results (
      validation_result_id TEXT PRIMARY KEY, package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL, delegation_id TEXT NOT NULL,
      validation_status TEXT NOT NULL, governance_findings TEXT,
      operational_requirements TEXT, capability_requirements TEXT,
      escalations TEXT, validation_timestamp TEXT NOT NULL, created_at TEXT NOT NULL
    );
    CREATE TABLE governance_envelope_gates (
      envelope_gate_id TEXT PRIMARY KEY, package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL, delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL, gate_status TEXT NOT NULL,
      gate_reason TEXT, gate_decision_timestamp TEXT NOT NULL, created_at TEXT NOT NULL
    );
    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY, package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL, delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL, envelope_gate_id TEXT NOT NULL,
      validation_status TEXT NOT NULL, required_capabilities TEXT,
      operational_corridor TEXT, lifecycle_state TEXT NOT NULL, created_at TEXT NOT NULL
    );
  `);
  return db;
}

function seed(
  db: Database.Database,
  delegationStatus = "AUTHORIZED",
  validationStatus = "VALIDATION_PASSED",
  gateStatus = "OPEN",
) {
  const t = "2026-08-27T22:40:00.000Z";
  db.prepare("INSERT INTO governance_delegations VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
    .run("d1", "hq", "p1", 1, delegationStatus, t, "marcela", t);
  db.prepare("INSERT INTO governance_validation_results VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
    .run("v1", "p1", 1, "d1", validationStatus, null, null, null, null, t, t);
  db.prepare("INSERT INTO governance_envelope_gates VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")
    .run("g1", "p1", 1, "d1", "v1", gateStatus, null, t, t);
  db.prepare("INSERT INTO governance_envelopes VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
    .run("e1", "p1", 1, "d1", "v1", "g1", validationStatus,
      "governed_git_commit", "self_improvement_execution_activation", "ready", t);
}

const identity = {
  envelope_id: "e1",
  package_id: "p1",
  package_version: 1,
  delegation_id: "d1",
  validation_result_id: "v1",
  envelope_gate_id: "g1",
};

test("reads exact authorized correlated governance chain", () => {
  const db = createDb();
  seed(db);
  assert.equal(loadGovernanceExecutionReadChain(db, identity).governance.ok, true);
});

test("rejects unauthorized delegation", () => {
  const db = createDb();
  seed(db, "PENDING");
  assert.throws(() => loadGovernanceExecutionReadChain(db, identity), /not authorized/);
});

test("rejects failed validation", () => {
  const db = createDb();
  seed(db, "AUTHORIZED", "VALIDATION_FAILED");
  assert.throws(() => loadGovernanceExecutionReadChain(db, identity), /has not passed/);
});

test("rejects closed gate", () => {
  const db = createDb();
  seed(db, "AUTHORIZED", "VALIDATION_PASSED", "CLOSED");
  assert.throws(() => loadGovernanceExecutionReadChain(db, identity), /not open/);
});

test("rejects lineage mismatch", () => {
  const db = createDb();
  seed(db);
  assert.throws(
    () => loadGovernanceExecutionReadChain(db, { ...identity, delegation_id: "wrong" }),
    /not found or ambiguous/,
  );
});

test("rejects missing artifact", () => {
  const db = createDb();
  assert.throws(() => loadGovernanceExecutionReadChain(db, identity), /not found or ambiguous/);
});

```

### db/governance-execution-read-repository.ts

```text
import type { Database } from "better-sqlite3";

import {
  assertEnvelopeCreationEligible,
  assertValidationEligible,
} from "./governance-lifecycle-enforcement";

export type GovernanceExecutionReadIdentity = {
  envelope_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  envelope_gate_id: string;
};

export type GovernanceExecutionReadChain = {
  delegation: {
    delegation_id: string;
    project_id: string;
    package_id: string;
    package_version: number;
    authorization_state: string;
    authorization_timestamp: string;
    delegated_by: string;
    created_at: string;
  };
  validation_result: {
    validation_result_id: string;
    package_id: string;
    package_version: number;
    delegation_id: string;
    validation_status: string;
    governance_findings: string | null;
    operational_requirements: string | null;
    capability_requirements: string | null;
    escalations: string | null;
    validation_timestamp: string;
    created_at: string;
  };
  envelope_gate: {
    envelope_gate_id: string;
    package_id: string;
    package_version: number;
    delegation_id: string;
    validation_result_id: string;
    gate_status: string;
    gate_reason: string | null;
    gate_decision_timestamp: string;
    created_at: string;
  };
  envelope: {
    envelope_id: string;
    package_id: string;
    package_version: number;
    delegation_id: string;
    validation_result_id: string;
    envelope_gate_id: string;
    validation_status: string;
    required_capabilities: string | null;
    operational_corridor: string | null;
    lifecycle_state: string;
    created_at: string;
  };
  governance: {
    ok: true;
    authorization_state: string;
    validation_status: string;
    gate_status: string;
  };
};

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Missing required governance execution read field: ${field}`);
  }
  return value.trim();
}

function requirePackageVersion(value: unknown): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw new Error(
      "Missing required governance execution read field: package_version",
    );
  }
  return Number(value);
}

function requireExactlyOne<T>(rows: T[], label: string): T {
  if (rows.length !== 1) {
    throw new Error(`Governance execution ${label} not found or ambiguous.`);
  }
  return rows[0];
}

export function loadGovernanceExecutionReadChain(
  db: Database,
  identity: GovernanceExecutionReadIdentity,
): GovernanceExecutionReadChain {
  const envelope_id = requireText(identity.envelope_id, "envelope_id");
  const package_id = requireText(identity.package_id, "package_id");
  const package_version = requirePackageVersion(identity.package_version);
  const delegation_id = requireText(identity.delegation_id, "delegation_id");
  const validation_result_id = requireText(identity.validation_result_id, "validation_result_id");
  const envelope_gate_id = requireText(identity.envelope_gate_id, "envelope_gate_id");

  const delegation = requireExactlyOne(
    db.prepare(`
      SELECT delegation_id, project_id, package_id, package_version,
             authorization_state, authorization_timestamp, delegated_by, created_at
      FROM governance_delegations
      WHERE delegation_id = ? AND package_id = ? AND package_version = ?
      LIMIT 2
    `).all(delegation_id, package_id, package_version) as GovernanceExecutionReadChain["delegation"][],
    "delegation",
  );

  const validationResult = requireExactlyOne(
    db.prepare(`
      SELECT validation_result_id, package_id, package_version, delegation_id,
             validation_status, governance_findings, operational_requirements,
             capability_requirements, escalations, validation_timestamp, created_at
      FROM governance_validation_results
      WHERE validation_result_id = ? AND delegation_id = ?
        AND package_id = ? AND package_version = ?
      LIMIT 2
    `).all(
      validation_result_id,
      delegation_id,
      package_id,
      package_version,
    ) as GovernanceExecutionReadChain["validation_result"][],
    "validation result",
  );

  const envelopeGate = requireExactlyOne(
    db.prepare(`
      SELECT envelope_gate_id, package_id, package_version, delegation_id,
             validation_result_id, gate_status, gate_reason,
             gate_decision_timestamp, created_at
      FROM governance_envelope_gates
      WHERE envelope_gate_id = ? AND validation_result_id = ?
        AND delegation_id = ? AND package_id = ? AND package_version = ?
      LIMIT 2
    `).all(
      envelope_gate_id,
      validation_result_id,
      delegation_id,
      package_id,
      package_version,
    ) as GovernanceExecutionReadChain["envelope_gate"][],
    "envelope gate",
  );

  const envelope = requireExactlyOne(
    db.prepare(`
      SELECT envelope_id, package_id, package_version, delegation_id,
             validation_result_id, envelope_gate_id, validation_status,
             required_capabilities, operational_corridor, lifecycle_state, created_at
      FROM governance_envelopes
      WHERE envelope_id = ? AND envelope_gate_id = ?
        AND validation_result_id = ? AND delegation_id = ?
        AND package_id = ? AND package_version = ?
      LIMIT 2
    `).all(
      envelope_id,
      envelope_gate_id,
      validation_result_id,
      delegation_id,
      package_id,
      package_version,
    ) as GovernanceExecutionReadChain["envelope"][],
    "envelope",
  );

  if (
    validationResult.delegation_id !== delegation.delegation_id ||
    envelopeGate.delegation_id !== delegation.delegation_id ||
    envelopeGate.validation_result_id !== validationResult.validation_result_id ||
    envelope.delegation_id !== delegation.delegation_id ||
    envelope.validation_result_id !== validationResult.validation_result_id ||
    envelope.envelope_gate_id !== envelopeGate.envelope_gate_id
  ) {
    throw new Error("Governance execution artifact lineage mismatch.");
  }

  assertValidationEligible({ delegation });
  assertEnvelopeCreationEligible({
    validationResult,
    envelopeGate,
    envelope,
  });

  return {
    delegation,
    validation_result: validationResult,
    envelope_gate: envelopeGate,
    envelope,
    governance: {
      ok: true,
      authorization_state: delegation.authorization_state,
      validation_status: validationResult.validation_status,
      gate_status: envelopeGate.gate_status,
    },
  };
}

```

### db/governance-runtime.ts

```text

import Database from "better-sqlite3";

import { ensureGovernanceLifecycleEventTable } from "./governance-lifecycle-persistence";
import { repairStaleGovernanceDelegationForeignKeys } from "./governance-stale-delegation-fk-migration";

export type CreateGovernancePackageInput = {

  package_id: string;

  package_version: number;

  project_id: string;

  conversation_id: string;

  requested_outcome: string;

  scope: string;

  containment: string;

  constraints: string;

  success_criteria: string;

  context?: string | null;

  style_presentation_intent?: string | null;

  exclusions?: string | null;

};

export type CreatedGovernancePackage = {

  package_id: string;

  package_version: number;

  project_id: string;

  conversation_id: string;

  created_at: string;

};

export type CreateGovernanceDelegationInput = {

  delegation_id: string;

  project_id: string;

  package_id: string;

  package_version: number;

  authorization_state: string;

  authorization_timestamp?: string | null;

  delegated_by: string;

};

export type CreatedGovernanceDelegation = {

  delegation_id: string;

  project_id: string;

  package_id: string;

  package_version: number;

  authorization_state: string;

  authorization_timestamp: string;

  delegated_by: string;

  created_at: string;

};

export type CreateGovernanceValidationResultInput = {

  validation_result_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_status: string;

  governance_findings?: string | null;

  operational_requirements?: string | null;

  capability_requirements?: string | null;

  escalations?: string | null;

  validation_timestamp?: string | null;

};

export type CreatedGovernanceValidationResult = {

  validation_result_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_status: string;

  validation_timestamp: string;

  created_at: string;

};

export type CreateGovernanceEnvelopeGateInput = {

  envelope_gate_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_result_id: string;

  gate_status: string;

  gate_reason?: string | null;

  gate_decision_timestamp?: string | null;

};

export type CreatedGovernanceEnvelopeGate = {

  envelope_gate_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_result_id: string;

  gate_status: string;

  gate_decision_timestamp: string;

  created_at: string;

};

export type CreateGovernanceEnvelopeInput = {

  envelope_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_result_id: string;

  envelope_gate_id: string;

  validation_status: string;

  required_capabilities?: string | null;

  operational_corridor?: string | null;

  lifecycle_state: string;

};

export type CreatedGovernanceEnvelope = {

  envelope_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_result_id: string;

  envelope_gate_id: string;

  validation_status: string;

  lifecycle_state: string;

  created_at: string;

};

const sqlite = new Database("db/main.db");

sqlite.pragma("foreign_keys = ON");

export function ensureGovernanceRuntimeTables(): void {
  sqlite.exec(`
    CREATE TABLE IF NOT EXISTS governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      requested_outcome TEXT,
      scope TEXT,
      containment TEXT,
      constraints TEXT,
      success_criteria TEXT,
      context TEXT,
      style_presentation_intent TEXT,
      exclusions TEXT,
      created_at TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE UNIQUE INDEX IF NOT EXISTS idx_matilda_canonical_packages_project_package_version
      ON matilda_canonical_packages(project_id, package_id, package_version);

    CREATE TABLE IF NOT EXISTS governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      project_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (project_id, package_id, package_version)
        REFERENCES matilda_canonical_packages(project_id, package_id, package_version)
    );

    CREATE TABLE IF NOT EXISTS governance_validation_results (
      validation_result_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_status TEXT NOT NULL,
      governance_findings TEXT,
      operational_requirements TEXT,
      capability_requirements TEXT,
      escalations TEXT,
      validation_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id)
    );

    CREATE TABLE IF NOT EXISTS governance_envelope_gates (
      envelope_gate_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      gate_status TEXT NOT NULL,
      gate_reason TEXT,
      gate_decision_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results(validation_result_id)
    );

    CREATE TABLE IF NOT EXISTS governance_envelopes (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      envelope_gate_id TEXT NOT NULL,
      validation_status TEXT NOT NULL,
      required_capabilities TEXT,
      operational_corridor TEXT,
      lifecycle_state TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results(validation_result_id),
      FOREIGN KEY (envelope_gate_id)
        REFERENCES governance_envelope_gates(envelope_gate_id)
    );
  `);

  const governancePackageColumns = sqlite
    .prepare("PRAGMA table_info(governance_packages)")
    .all() as Array<{ name: string }>;

  if (!governancePackageColumns.some((column) => column.name === "project_id")) {
    sqlite.exec(`
      ALTER TABLE governance_packages
      ADD COLUMN project_id TEXT;
    `);
  }

  if (
    !governancePackageColumns.some(
      (column) => column.name === "conversation_id",
    )
  ) {
    sqlite.exec(`
      ALTER TABLE governance_packages
      ADD COLUMN conversation_id TEXT;
    `);
  }

  repairStaleGovernanceDelegationForeignKeys(sqlite);

  ensureGovernanceLifecycleEventTable(sqlite);
}

const requiredPackageTextFields = [

  "package_id",

  "project_id",

  "conversation_id",

  "requested_outcome",

  "scope",

  "containment",

  "constraints",

  "success_criteria",

] as const;

const requiredDelegationTextFields = [

  "delegation_id",

  "project_id",

  "package_id",

  "authorization_state",

  "delegated_by",

] as const;

const requiredValidationTextFields = [

  "validation_result_id",

  "package_id",

  "delegation_id",

  "validation_status",

] as const;

const requiredEnvelopeGateTextFields = [

  "envelope_gate_id",

  "package_id",

  "delegation_id",

  "validation_result_id",

  "gate_status",

] as const;

const requiredEnvelopeTextFields = [

  "envelope_id",

  "package_id",

  "delegation_id",

  "validation_result_id",

  "envelope_gate_id",

  "validation_status",

  "lifecycle_state",

] as const;

function requirePackageText(

  input: CreateGovernancePackageInput,

  field: (typeof requiredPackageTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Package field: ${field}`);

  }

  return value;

}

function requireDelegationText(

  input: CreateGovernanceDelegationInput,

  field: (typeof requiredDelegationTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Delegation field: ${field}`);

  }

  return value;

}

function requireValidationText(

  input: CreateGovernanceValidationResultInput,

  field: (typeof requiredValidationTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Validation field: ${field}`);

  }

  return value;

}

function requireEnvelopeGateText(

  input: CreateGovernanceEnvelopeGateInput,

  field: (typeof requiredEnvelopeGateTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Envelope Gate field: ${field}`);

  }

  return value;

}

function requireEnvelopeText(

  input: CreateGovernanceEnvelopeInput,

  field: (typeof requiredEnvelopeTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Envelope field: ${field}`);

  }

  return value;

}

function requirePackageVersion(

  value: unknown,

  artifact: "Package" | "Delegation" | "Validation" | "Envelope Gate" | "Envelope",

): number {

  if (!Number.isInteger(value) || Number(value) < 1) {

    throw new Error(`Missing required governance ${artifact} field: package_version`);

  }

  return Number(value);

}

function optionalText(value: string | null | undefined): string | null {

  if (value === undefined || value === null) {

    return null;

  }

  return String(value);

}

function optionalTimestamp(

  value: string | null | undefined,

  artifact: "Delegation" | "Validation" | "Envelope Gate",

  field: "authorization_timestamp" | "validation_timestamp" | "gate_decision_timestamp",

): string {

  if (value === undefined || value === null) {

    return new Date().toISOString();

  }

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance ${artifact} field: ${field}`);

  }

  return value;

}

export function createGovernancePackage(input: CreateGovernancePackageInput): CreatedGovernancePackage {

  ensureGovernanceRuntimeTables();

  const package_id = requirePackageText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Package");

  const project_id = requirePackageText(input, "project_id");

  const conversation_id = requirePackageText(input, "conversation_id");

  const requested_outcome = requirePackageText(input, "requested_outcome");

  const scope = requirePackageText(input, "scope");

  const containment = requirePackageText(input, "containment");

  const constraints = requirePackageText(input, "constraints");

  const success_criteria = requirePackageText(input, "success_criteria");

  const created_at = new Date().toISOString();

  sqlite.prepare(`

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

      @scope,

      @containment,

      @constraints,

      @success_criteria,

      @context,

      @style_presentation_intent,

      @exclusions,

      @created_at

    )

  `).run({

    package_id,

    package_version,

    project_id,

    conversation_id,

    requested_outcome,

    scope,

    containment,

    constraints,

    success_criteria,

    context: optionalText(input.context),

    style_presentation_intent: optionalText(input.style_presentation_intent),

    exclusions: optionalText(input.exclusions),

    created_at,

  });

  return {

    package_id,

    package_version,

    project_id,

    conversation_id,

    created_at,

  };

}

export function createGovernanceDelegation(

  input: CreateGovernanceDelegationInput,

): CreatedGovernanceDelegation {

  ensureGovernanceRuntimeTables();

  const delegation_id = requireDelegationText(input, "delegation_id");

  const project_id = requireDelegationText(input, "project_id");

  const package_id = requireDelegationText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Delegation");

  const authorization_state = requireDelegationText(input, "authorization_state");

  const authorization_timestamp = optionalTimestamp(input.authorization_timestamp, "Delegation", "authorization_timestamp");

  const delegated_by = requireDelegationText(input, "delegated_by");

  const canonicalPackage = sqlite.prepare(`
    SELECT
      project_id,
      package_id,
      package_version
    FROM matilda_canonical_packages
    WHERE project_id = ?
      AND package_id = ?
      AND package_version = ?
    LIMIT 1
  `).get(
    project_id,
    package_id,
    package_version,
  ) as
    | {
        project_id: string;
        package_id: string;
        package_version: number;
      }
    | undefined;

  if (!canonicalPackage) {
    throw new Error(
      `Delegation requires an existing Canonical Package version: "${package_id}" version ${package_version}.`,
    );
  }

  const created_at = new Date().toISOString();

  sqlite.prepare(`

    INSERT INTO governance_delegations (

      delegation_id,

      project_id,

      package_id,

      package_version,

      authorization_state,

      authorization_timestamp,

      delegated_by,

      created_at

    ) VALUES (

      @delegation_id,

      @project_id,

      @package_id,

      @package_version,

      @authorization_state,

      @authorization_timestamp,

      @delegated_by,

      @created_at

    )

  `).run({

    delegation_id,

    project_id,

    package_id,

    package_version,

    authorization_state,

    authorization_timestamp,

    delegated_by,

    created_at,

  });

  return {

    delegation_id,

    project_id,

    package_id,

    package_version,

    authorization_state,

    authorization_timestamp,

    delegated_by,

    created_at,

  };

}

export function createGovernanceValidationResult(

  input: CreateGovernanceValidationResultInput,

): CreatedGovernanceValidationResult {

  ensureGovernanceRuntimeTables();

  const validation_result_id = requireValidationText(input, "validation_result_id");

  const package_id = requireValidationText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Validation");

  const delegation_id = requireValidationText(input, "delegation_id");

  const validation_status = requireValidationText(input, "validation_status");

  const validation_timestamp = optionalTimestamp(input.validation_timestamp, "Validation", "validation_timestamp");

  const created_at = new Date().toISOString();

  sqlite.prepare(`

    INSERT INTO governance_validation_results (

      validation_result_id,

      package_id,

      package_version,

      delegation_id,

      validation_status,

      governance_findings,

      operational_requirements,

      capability_requirements,

      escalations,

      validation_timestamp,

      created_at

    ) VALUES (

      @validation_result_id,

      @package_id,

      @package_version,

      @delegation_id,

      @validation_status,

      @governance_findings,

      @operational_requirements,

      @capability_requirements,

      @escalations,

      @validation_timestamp,

      @created_at

    )

  `).run({

    validation_result_id,

    package_id,

    package_version,

    delegation_id,

    validation_status,

    governance_findings: optionalText(input.governance_findings),

    operational_requirements: optionalText(input.operational_requirements),

    capability_requirements: optionalText(input.capability_requirements),

    escalations: optionalText(input.escalations),

    validation_timestamp,

    created_at,

  });

  return {

    validation_result_id,

    package_id,

    package_version,

    delegation_id,

    validation_status,

    validation_timestamp,

    created_at,

  };

}

export function createGovernanceEnvelopeGate(

  input: CreateGovernanceEnvelopeGateInput,

): CreatedGovernanceEnvelopeGate {

  ensureGovernanceRuntimeTables();

  const envelope_gate_id = requireEnvelopeGateText(input, "envelope_gate_id");

  const package_id = requireEnvelopeGateText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Envelope Gate");

  const delegation_id = requireEnvelopeGateText(input, "delegation_id");

  const validation_result_id = requireEnvelopeGateText(input, "validation_result_id");

  const gate_status = requireEnvelopeGateText(input, "gate_status");

  const gate_decision_timestamp = optionalTimestamp(

    input.gate_decision_timestamp,

    "Envelope Gate",

    "gate_decision_timestamp",

  );

  const created_at = new Date().toISOString();

  sqlite.prepare(`

    INSERT INTO governance_envelope_gates (

      envelope_gate_id,

      package_id,

      package_version,

      delegation_id,

      validation_result_id,

      gate_status,

      gate_reason,

      gate_decision_timestamp,

      created_at

    ) VALUES (

      @envelope_gate_id,

      @package_id,

      @package_version,

      @delegation_id,

      @validation_result_id,

      @gate_status,

      @gate_reason,

      @gate_decision_timestamp,

      @created_at

    )

  `).run({

    envelope_gate_id,

    package_id,

    package_version,

    delegation_id,

    validation_result_id,

    gate_status,

    gate_reason: optionalText(input.gate_reason),

    gate_decision_timestamp,

    created_at,

  });

  return {

    envelope_gate_id,

    package_id,

    package_version,

    delegation_id,

    validation_result_id,

    gate_status,

    gate_decision_timestamp,

    created_at,

  };

}

export function createGovernanceEnvelope(

  input: CreateGovernanceEnvelopeInput,

): CreatedGovernanceEnvelope {

  ensureGovernanceRuntimeTables();

  const envelope_id = requireEnvelopeText(input, "envelope_id");

  const package_id = requireEnvelopeText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Envelope");

  const delegation_id = requireEnvelopeText(input, "delegation_id");

  const validation_result_id = requireEnvelopeText(input, "validation_result_id");

  const envelope_gate_id = requireEnvelopeText(input, "envelope_gate_id");

  const validation_status = requireEnvelopeText(input, "validation_status");

  const lifecycle_state = requireEnvelopeText(input, "lifecycle_state");

  const created_at = new Date().toISOString();

  sqlite.prepare(`

    INSERT INTO governance_envelopes (

      envelope_id,

      package_id,

      package_version,

      delegation_id,

      validation_result_id,

      envelope_gate_id,

      validation_status,

      required_capabilities,

      operational_corridor,

      lifecycle_state,

      created_at

    ) VALUES (

      @envelope_id,

      @package_id,

      @package_version,

      @delegation_id,

      @validation_result_id,

      @envelope_gate_id,

      @validation_status,

      @required_capabilities,

      @operational_corridor,

      @lifecycle_state,

      @created_at

    )

  `).run({

    envelope_id,

    package_id,

    package_version,

    delegation_id,

    validation_result_id,

    envelope_gate_id,

    validation_status,

    required_capabilities: optionalText(input.required_capabilities),

    operational_corridor: optionalText(input.operational_corridor),

    lifecycle_state,

    created_at,

  });

  return {

    envelope_id,

    package_id,

    package_version,

    delegation_id,

    validation_result_id,

    envelope_gate_id,

    validation_status,

    lifecycle_state,

    created_at,

  };

}


```

### db/governance-runtime.ts.bak

```text

import Database from "better-sqlite3";

export type CreateGovernancePackageInput = {

  package_id: string;

  package_version: number;

  requested_outcome: string;

  scope: string;

  containment: string;

  constraints: string;

  success_criteria: string;

  context?: string | null;

  style_presentation_intent?: string | null;

  exclusions?: string | null;

};

export type CreatedGovernancePackage = {

  package_id: string;

  package_version: number;

  created_at: string;

};

export type CreateGovernanceDelegationInput = {

  delegation_id: string;

  package_id: string;

  package_version: number;

  authorization_state: string;

  authorization_timestamp?: string | null;

  delegated_by: string;

};

export type CreatedGovernanceDelegation = {

  delegation_id: string;

  package_id: string;

  package_version: number;

  authorization_state: string;

  authorization_timestamp: string;

  delegated_by: string;

  created_at: string;

};

export type CreateGovernanceValidationResultInput = {

  validation_result_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_status: string;

  governance_findings?: string | null;

  operational_requirements?: string | null;

  capability_requirements?: string | null;

  escalations?: string | null;

  validation_timestamp?: string | null;

};

export type CreatedGovernanceValidationResult = {

  validation_result_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_status: string;

  validation_timestamp: string;

  created_at: string;

};

export type CreateGovernanceEnvelopeGateInput = {

  envelope_gate_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_result_id: string;

  gate_status: string;

  gate_reason?: string | null;

  gate_decision_timestamp?: string | null;

};

export type CreatedGovernanceEnvelopeGate = {

  envelope_gate_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_result_id: string;

  gate_status: string;

  gate_decision_timestamp: string;

  created_at: string;

};

export type CreateGovernanceEnvelopeInput = {

  envelope_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_result_id: string;

  envelope_gate_id: string;

  validation_status: string;

  required_capabilities?: string | null;

  operational_corridor?: string | null;

  lifecycle_state: string;

};

export type CreatedGovernanceEnvelope = {

  envelope_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_result_id: string;

  envelope_gate_id: string;

  validation_status: string;

  lifecycle_state: string;

  created_at: string;

};

const sqlite = new Database("db/main.db");

db.pragma("foreign_keys = ON");

const requiredPackageTextFields = [

  "package_id",

  "requested_outcome",

  "scope",

  "containment",

  "constraints",

  "success_criteria",

] as const;

const requiredDelegationTextFields = [

  "delegation_id",

  "package_id",

  "authorization_state",

  "delegated_by",

] as const;

const requiredValidationTextFields = [

  "validation_result_id",

  "package_id",

  "delegation_id",

  "validation_status",

] as const;

const requiredEnvelopeGateTextFields = [

  "envelope_gate_id",

  "package_id",

  "delegation_id",

  "validation_result_id",

  "gate_status",

] as const;

const requiredEnvelopeTextFields = [

  "envelope_id",

  "package_id",

  "delegation_id",

  "validation_result_id",

  "envelope_gate_id",

  "validation_status",

  "lifecycle_state",

] as const;

function requirePackageText(

  input: CreateGovernancePackageInput,

  field: (typeof requiredPackageTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === false) {

    throw new Error(`Missing required governance Package field: ${field}`);

  }

  return value;

}

function requireDelegationText(

  input: CreateGovernanceDelegationInput,

  field: (typeof requiredDelegationTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === false) {

    throw new Error(`Missing required governance Delegation field: ${field}`);

  }

  return value;

}

function requireValidationText(

  input: CreateGovernanceValidationResultInput,

  field: (typeof requiredValidationTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === false) {

    throw new Error(`Missing required governance Validation field: ${field}`);

  }

  return value;

}

function requireEnvelopeGateText(

  input: CreateGovernanceEnvelopeGateInput,

  field: (typeof requiredEnvelopeGateTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === false) {

    throw new Error(`Missing required governance Envelope Gate field: ${field}`);

  }

  return value;

}

function requireEnvelopeText(

  input: CreateGovernanceEnvelopeInput,

  field: (typeof requiredEnvelopeTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === false) {

    throw new Error(`Missing required governance Envelope field: ${field}`);

  }

  return value;

}

function requirePackageVersion(

  value: unknown,

  artifact: "Package" | "Delegation" | "Validation" | "Envelope Gate" | "Envelope",

): number {

  if (!Number.isInteger(value) || Number(value) < 1) {

    throw new Error(`Missing required governance ${artifact} field: package_version`);

  }

  return Number(value);

}

function optionalText(value: string | null | undefined): string | null {

  if (value === undefined || value === null) {

    return null;

  }

  return String(value);

}

function optionalTimestamp(

  value: string | null | undefined,

  artifact: "Delegation" | "Validation" | "Envelope Gate",

  field: "authorization_timestamp" | "validation_timestamp" | "gate_decision_timestamp",

): string {

  if (value === undefined || value === null) {

    return new Date().toISOString();

  }

  if (typeof value !== "string" || value.trim().length === false) {

    throw new Error(`Missing required governance ${artifact} field: ${field}`);

  }

  return value;

}

export function createGovernancePackage(input: CreateGovernancePackageInput): CreatedGovernancePackage {

  const package_id = requirePackageText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Package");

  const requested_outcome = requirePackageText(input, "requested_outcome");

  const scope = requirePackageText(input, "scope");

  const containment = requirePackageText(input, "containment");

  const constraints = requirePackageText(input, "constraints");

  const success_criteria = requirePackageText(input, "success_criteria");

  const created_at = new Date().toISOString();

// REMOVED: migrated to db/index.ts facade boundary

    INSERT INTO governance_packages (

      package_id,

      package_version,

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

      @requested_outcome,

      @scope,

      @containment,

      @constraints,

      @success_criteria,

      @context,

      @style_presentation_intent,

      @exclusions,

      @created_at

    )

  `).run({

    package_id,

    package_version,

    requested_outcome,

    scope,

    containment,

    constraints,

    success_criteria,

    context: optionalText(input.context),

    style_presentation_intent: optionalText(input.style_presentation_intent),

    exclusions: optionalText(input.exclusions),

    created_at,

  });

  return {

    package_id,

    package_version,

    created_at,

  };

}

export function createGovernanceDelegation(

  input: CreateGovernanceDelegationInput,

): CreatedGovernanceDelegation {

  const delegation_id = requireDelegationText(input, "delegation_id");

  const package_id = requireDelegationText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Delegation");

  const authorization_state = requireDelegationText(input, "authorization_state");

  const authorization_timestamp = optionalTimestamp(input.authorization_timestamp, "Delegation", "authorization_timestamp");

  const delegated_by = requireDelegationText(input, "delegated_by");

  const created_at = new Date().toISOString();

// REMOVED: migrated to db/index.ts facade boundary

    INSERT INTO governance_delegations (

      delegation_id,

      package_id,

      package_version,

      authorization_state,

      authorization_timestamp,

      delegated_by,

      created_at

    ) VALUES (

      @delegation_id,

      @package_id,

      @package_version,

      @authorization_state,

      @authorization_timestamp,

      @delegated_by,

      @created_at

    )

  `).run({

    delegation_id,

    package_id,

    package_version,

    authorization_state,

    authorization_timestamp,

    delegated_by,

    created_at,

  });

  return {

    delegation_id,

    package_id,

    package_version,

    authorization_state,

    authorization_timestamp,

    delegated_by,

    created_at,

  };

}

export function createGovernanceValidationResult(

  input: CreateGovernanceValidationResultInput,

): CreatedGovernanceValidationResult {

  const validation_result_id = requireValidationText(input, "validation_result_id");

  const package_id = requireValidationText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Validation");

  const delegation_id = requireValidationText(input, "delegation_id");

  const validation_status = requireValidationText(input, "validation_status");

  const validation_timestamp = optionalTimestamp(input.validation_timestamp, "Validation", "validation_timestamp");

  const created_at = new Date().toISOString();

// REMOVED: migrated to db/index.ts facade boundary

    INSERT INTO governance_validation_results (

      validation_result_id,

      package_id,

      package_version,

      delegation_id,

      validation_status,

      governance_findings,

      operational_requirements,

      capability_requirements,

      escalations,

      validation_timestamp,

      created_at

    ) VALUES (

      @validation_result_id,

      @package_id,

      @package_version,

      @delegation_id,

      @validation_status,

      @governance_findings,

      @operational_requirements,

      @capability_requirements,

      @escalations,

      @validation_timestamp,

      @created_at

    )

  `).run({

    validation_result_id,

    package_id,

    package_version,

    delegation_id,

    validation_status,

    governance_findings: optionalText(input.governance_findings),

    operational_requirements: optionalText(input.operational_requirements),

    capability_requirements: optionalText(input.capability_requirements),

    escalations: optionalText(input.escalations),

    validation_timestamp,

    created_at,

  });

  return {

    validation_result_id,

    package_id,

    package_version,

    delegation_id,

    validation_status,

    validation_timestamp,

    created_at,

  };

}

export function createGovernanceEnvelopeGate(

  input: CreateGovernanceEnvelopeGateInput,

): CreatedGovernanceEnvelopeGate {

  const envelope_gate_id = requireEnvelopeGateText(input, "envelope_gate_id");

  const package_id = requireEnvelopeGateText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Envelope Gate");

  const delegation_id = requireEnvelopeGateText(input, "delegation_id");

  const validation_result_id = requireEnvelopeGateText(input, "validation_result_id");

  const gate_status = requireEnvelopeGateText(input, "gate_status");

  const gate_decision_timestamp = optionalTimestamp(

    input.gate_decision_timestamp,

    "Envelope Gate",

    "gate_decision_timestamp",

  );

  const created_at = new Date().toISOString();

// REMOVED: migrated to db/index.ts facade boundary

    INSERT INTO governance_envelope_gates (

      envelope_gate_id,

      package_id,

      package_version,

      delegation_id,

      validation_result_id,

      gate_status,

      gate_reason,

      gate_decision_timestamp,

      created_at

    ) VALUES (

      @envelope_gate_id,

      @package_id,

      @package_version,

      @delegation_id,

      @validation_result_id,

      @gate_status,

      @gate_reason,

      @gate_decision_timestamp,

      @created_at

    )

  `).run({

    envelope_gate_id,

    package_id,

    package_version,

    delegation_id,

    validation_result_id,

    gate_status,

    gate_reason: optionalText(input.gate_reason),

    gate_decision_timestamp,

    created_at,

  });

  return {

    envelope_gate_id,

    package_id,

    package_version,

    delegation_id,

    validation_result_id,

    gate_status,

    gate_decision_timestamp,

    created_at,

  };

}

export function createGovernanceEnvelope(

  input: CreateGovernanceEnvelopeInput,

): CreatedGovernanceEnvelope {

  const envelope_id = requireEnvelopeText(input, "envelope_id");

  const package_id = requireEnvelopeText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Envelope");

  const delegation_id = requireEnvelopeText(input, "delegation_id");

  const validation_result_id = requireEnvelopeText(input, "validation_result_id");

  const envelope_gate_id = requireEnvelopeText(input, "envelope_gate_id");

  const validation_status = requireEnvelopeText(input, "validation_status");

  const lifecycle_state = requireEnvelopeText(input, "lifecycle_state");

  const created_at = new Date().toISOString();

// REMOVED: migrated to db/index.ts facade boundary

    INSERT INTO governance_envelopes (

      envelope_id,

      package_id,

      package_version,

      delegation_id,

      validation_result_id,

      envelope_gate_id,

      validation_status,

      required_capabilities,

      operational_corridor,

      lifecycle_state,

      created_at

    ) VALUES (

      @envelope_id,

      @package_id,

      @package_version,

      @delegation_id,

      @validation_result_id,

      @envelope_gate_id,

      @validation_status,

      @required_capabilities,

      @operational_corridor,

      @lifecycle_state,

      @created_at

    )

  `).run({

    envelope_id,

    package_id,

    package_version,

    delegation_id,

    validation_result_id,

    envelope_gate_id,

    validation_status,

    required_capabilities: optionalText(input.required_capabilities),

    operational_corridor: optionalText(input.operational_corridor),

    lifecycle_state,

    created_at,

  });

  return {

    envelope_id,

    package_id,

    package_version,

    delegation_id,

    validation_result_id,

    envelope_gate_id,

    validation_status,

    lifecycle_state,

    created_at,

  };

}


```

### db/governance-stale-delegation-fk-migration.test.ts

```text
import assert from "node:assert/strict";
import test from "node:test";

import Database from "better-sqlite3";

import { repairStaleGovernanceDelegationForeignKeys } from "./governance-stale-delegation-fk-migration";

function foreignKeyParents(
  db: Database.Database,
  table: string,
): string[] {
  return (
    db.prepare(`PRAGMA foreign_key_list("${table}")`).all() as Array<{
      table: string;
    }>
  ).map((row) => row.table);
}

test("repairs stale Delegation FK targets without rewriting downstream lifecycle lineage", () => {
  const db = new Database(":memory:");

  db.pragma("foreign_keys = OFF");

  db.exec(`
    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY
    );

    CREATE TABLE governance_delegations_legacy_root (
      delegation_id TEXT PRIMARY KEY
    );

    CREATE TABLE governance_validation_results (
      validation_result_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_status TEXT NOT NULL,
      governance_findings TEXT,
      operational_requirements TEXT,
      capability_requirements TEXT,
      escalations TEXT,
      validation_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations_legacy_root(delegation_id)
    );

    CREATE TABLE governance_envelope_gates (
      envelope_gate_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      gate_status TEXT NOT NULL,
      gate_reason TEXT,
      gate_decision_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations_legacy_root(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results(validation_result_id)
    );

    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      envelope_gate_id TEXT NOT NULL,
      validation_status TEXT NOT NULL,
      required_capabilities TEXT,
      operational_corridor TEXT,
      lifecycle_state TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations_legacy_root(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results(validation_result_id),
      FOREIGN KEY (envelope_gate_id)
        REFERENCES governance_envelope_gates(envelope_gate_id)
    );

    CREATE TABLE governance_lifecycle_events (
      event_id INTEGER PRIMARY KEY AUTOINCREMENT,
      envelope_id TEXT NOT NULL,
      transition_authorization TEXT NOT NULL,
      persisted_at TEXT NOT NULL,
      FOREIGN KEY (envelope_id)
        REFERENCES governance_envelopes(envelope_id)
    );

    INSERT INTO governance_packages VALUES ('corridor-smoke', 1);
    INSERT INTO governance_delegations VALUES ('corridor-delegation');

    INSERT INTO governance_validation_results VALUES (
      'corridor-validation',
      'corridor-smoke',
      1,
      'corridor-delegation',
      'VALIDATION_PASSED',
      NULL,
      NULL,
      NULL,
      NULL,
      '2026-07-29T04:10:30.000Z',
      '2026-07-29T04:10:30.000Z'
    );

    INSERT INTO governance_envelope_gates VALUES (
      'corridor-gate',
      'corridor-smoke',
      1,
      'corridor-delegation',
      'corridor-validation',
      'PASSED',
      NULL,
      '2026-07-29T04:20:30.000Z',
      '2026-07-29T04:20:30.000Z'
    );

    INSERT INTO governance_envelopes VALUES (
      'corridor-envelope',
      'corridor-smoke',
      1,
      'corridor-delegation',
      'corridor-validation',
      'corridor-gate',
      'VALIDATION_PASSED',
      NULL,
      NULL,
      'ENVELOPE_CREATED',
      '2026-07-29T04:30:30.000Z'
    );

    INSERT INTO governance_envelopes VALUES (
      'demo-env-1',
      'corridor-smoke',
      1,
      'missing-demo-delegation',
      'missing-demo-validation',
      'missing-demo-gate',
      'PENDING',
      NULL,
      NULL,
      'ENVELOPE_CREATED',
      '2026-07-28T21:36:59.000Z'
    );

    INSERT INTO governance_lifecycle_events (
      envelope_id,
      transition_authorization,
      persisted_at
    ) VALUES (
      'corridor-envelope',
      'MISSION_COMPLETED',
      '2026-07-29T04:30:30.000Z'
    );

    INSERT INTO governance_lifecycle_events (
      envelope_id,
      transition_authorization,
      persisted_at
    ) VALUES (
      'demo-env-1',
      'ENVELOPE_CREATED',
      '2026-07-29T00:36:09.000Z'
    );

    DROP TABLE governance_delegations_legacy_root;
  `);

  db.pragma("foreign_keys = ON");

  assert.equal(repairStaleGovernanceDelegationForeignKeys(db), true);

  for (const table of [
    "governance_validation_results",
    "governance_envelope_gates",
    "governance_envelopes",
  ]) {
    const parents = foreignKeyParents(db, table);

    assert.equal(
      parents.includes("governance_delegations_legacy_root"),
      false,
    );

    assert.equal(
      parents.includes("governance_delegations"),
      true,
    );
  }

  assert.deepEqual(
    foreignKeyParents(db, "governance_lifecycle_events"),
    ["governance_envelopes"],
  );

  assert.deepEqual(
    db
      .prepare(`
        SELECT envelope_id
        FROM governance_envelopes
        ORDER BY envelope_id
      `)
      .all(),
    [
      { envelope_id: "corridor-envelope" },
      { envelope_id: "demo-env-1" },
    ],
  );

  assert.deepEqual(
    db
      .prepare(`
        SELECT envelope_id, transition_authorization
        FROM governance_lifecycle_events
        ORDER BY event_id
      `)
      .all(),
    [
      {
        envelope_id: "corridor-envelope",
        transition_authorization: "MISSION_COMPLETED",
      },
      {
        envelope_id: "demo-env-1",
        transition_authorization: "ENVELOPE_CREATED",
      },
    ],
  );

  assert.equal(
    repairStaleGovernanceDelegationForeignKeys(db),
    false,
  );

  db.close();
});

```

### db/governance-stale-delegation-fk-migration.ts

```text
import type Database from "better-sqlite3";

const STALE_DELEGATION_PARENT = "governance_delegations_legacy_root";

const affectedTables = [
  "governance_validation_results",
  "governance_envelope_gates",
  "governance_envelopes",
] as const;

type AffectedTable = (typeof affectedTables)[number];

type ForeignKeyRow = {
  table: string;
};

function hasStaleDelegationForeignKey(
  sqlite: Database.Database,
  table: AffectedTable,
): boolean {
  const rows = sqlite
    .prepare(`PRAGMA foreign_key_list("${table}")`)
    .all() as ForeignKeyRow[];

  return rows.some((row) => row.table === STALE_DELEGATION_PARENT);
}

function rebuildValidationResults(sqlite: Database.Database): void {
  sqlite.exec(`
    CREATE TABLE governance_validation_results_repaired_delegation_fk (
      validation_result_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_status TEXT NOT NULL,
      governance_findings TEXT,
      operational_requirements TEXT,
      capability_requirements TEXT,
      escalations TEXT,
      validation_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id)
    );

    INSERT INTO governance_validation_results_repaired_delegation_fk (
      validation_result_id,
      package_id,
      package_version,
      delegation_id,
      validation_status,
      governance_findings,
      operational_requirements,
      capability_requirements,
      escalations,
      validation_timestamp,
      created_at
    )
    SELECT
      validation_result_id,
      package_id,
      package_version,
      delegation_id,
      validation_status,
      governance_findings,
      operational_requirements,
      capability_requirements,
      escalations,
      validation_timestamp,
      created_at
    FROM governance_validation_results;

    DROP TABLE governance_validation_results;

    ALTER TABLE governance_validation_results_repaired_delegation_fk
    RENAME TO governance_validation_results;
  `);
}

function rebuildEnvelopeGates(sqlite: Database.Database): void {
  sqlite.exec(`
    CREATE TABLE governance_envelope_gates_repaired_delegation_fk (
      envelope_gate_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      gate_status TEXT NOT NULL,
      gate_reason TEXT,
      gate_decision_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results(validation_result_id)
    );

    INSERT INTO governance_envelope_gates_repaired_delegation_fk (
      envelope_gate_id,
      package_id,
      package_version,
      delegation_id,
      validation_result_id,
      gate_status,
      gate_reason,
      gate_decision_timestamp,
      created_at
    )
    SELECT
      envelope_gate_id,
      package_id,
      package_version,
      delegation_id,
      validation_result_id,
      gate_status,
      gate_reason,
      gate_decision_timestamp,
      created_at
    FROM governance_envelope_gates;

    DROP TABLE governance_envelope_gates;

    ALTER TABLE governance_envelope_gates_repaired_delegation_fk
    RENAME TO governance_envelope_gates;
  `);
}

function rebuildEnvelopes(sqlite: Database.Database): void {
  sqlite.exec(`
    CREATE TABLE governance_envelopes_repaired_delegation_fk (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      envelope_gate_id TEXT NOT NULL,
      validation_status TEXT NOT NULL,
      required_capabilities TEXT,
      operational_corridor TEXT,
      lifecycle_state TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results(validation_result_id),
      FOREIGN KEY (envelope_gate_id)
        REFERENCES governance_envelope_gates(envelope_gate_id)
    );

    INSERT INTO governance_envelopes_repaired_delegation_fk (
      envelope_id,
      package_id,
      package_version,
      delegation_id,
      validation_result_id,
      envelope_gate_id,
      validation_status,
      required_capabilities,
      operational_corridor,
      lifecycle_state,
      created_at
    )
    SELECT
      envelope_id,
      package_id,
      package_version,
      delegation_id,
      validation_result_id,
      envelope_gate_id,
      validation_status,
      required_capabilities,
      operational_corridor,
      lifecycle_state,
      created_at
    FROM governance_envelopes;

    DROP TABLE governance_envelopes;

    ALTER TABLE governance_envelopes_repaired_delegation_fk
    RENAME TO governance_envelopes;
  `);
}

export function repairStaleGovernanceDelegationForeignKeys(
  sqlite: Database.Database,
): boolean {
  const staleTables = affectedTables.filter((table) =>
    hasStaleDelegationForeignKey(sqlite, table),
  );

  if (staleTables.length === 0) {
    return false;
  }

  const foreignKeysWereEnabled =
    Number(sqlite.pragma("foreign_keys", { simple: true })) === 1;

  sqlite.pragma("foreign_keys = OFF");

  try {
    sqlite.transaction(() => {
      if (staleTables.includes("governance_validation_results")) {
        rebuildValidationResults(sqlite);
      }

      if (staleTables.includes("governance_envelope_gates")) {
        rebuildEnvelopeGates(sqlite);
      }

      if (staleTables.includes("governance_envelopes")) {
        rebuildEnvelopes(sqlite);
      }
    })();
  } finally {
    sqlite.pragma(
      `foreign_keys = ${foreignKeysWereEnabled ? "ON" : "OFF"}`,
    );
  }

  return true;
}

```

### db/matilda-canonical-package-runtime.test.ts

```text
import assert from "node:assert/strict";
import {
  mkdtempSync,
  mkdirSync,
  rmSync,
} from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

import Database from "better-sqlite3";

type FixtureOptions = {
  expectedOutcome: string | null;
  conflictingGovernanceTarget?: boolean;
};

const repositoryRoot = process.cwd();
const temporaryRoot = mkdtempSync(
  path.join(tmpdir(), "matilda-canonical-package-runtime-test-"),
);
mkdirSync(path.join(temporaryRoot, "db"));

const databasePath = path.join(temporaryRoot, "db", "main.db");
const previousWorkingDirectory = process.cwd();

function initializeFixtureSchema(): void {
  const sqlite = new Database(databasePath);

  sqlite.exec(`
    CREATE TABLE matilda_living_draft_packages (
      draft_package_id TEXT PRIMARY KEY,
      lineage_id TEXT NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      current_interpretation TEXT NOT NULL,
      proposed_work TEXT,
      proposed_artifacts TEXT,
      in_scope TEXT,
      out_of_scope TEXT,
      constraints TEXT,
      expected_outcome TEXT,
      unresolved_questions TEXT,
      evidence_entry_ids TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    CREATE TABLE matilda_draft_revisions (
      draft_revision_id TEXT PRIMARY KEY,
      draft_package_id TEXT NOT NULL,
      lineage_id TEXT NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      current_interpretation TEXT NOT NULL,
      proposed_work TEXT,
      proposed_artifacts TEXT,
      in_scope TEXT,
      out_of_scope TEXT,
      constraints TEXT,
      expected_outcome TEXT,
      unresolved_questions TEXT,
      evidence_entry_ids TEXT NOT NULL,
      source_draft_status TEXT NOT NULL,
      source_draft_updated_at TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      UNIQUE (draft_package_id, source_draft_updated_at)
    );

    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      summary_id TEXT NOT NULL,
      draft_package_id TEXT NOT NULL,
      draft_revision_id TEXT NOT NULL,
      lineage_id TEXT NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      approved_interpretation TEXT NOT NULL,
      approved_work TEXT,
      approved_artifacts TEXT,
      approved_scope TEXT,
      approved_constraints TEXT,
      approved_expected_outcome TEXT,
      approval_actor TEXT NOT NULL,
      approval_timestamp TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version),
      UNIQUE (draft_revision_id)
    );

    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT NOT NULL,
      conversation_id TEXT,
      requested_outcome TEXT NOT NULL,
      scope TEXT,
      containment TEXT,
      constraints TEXT,
      success_criteria TEXT,
      context TEXT,
      style_presentation_intent TEXT,
      exclusions TEXT,
      created_at TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );
  `);

  sqlite.close();
}

function resetFixture({
  expectedOutcome,
  conflictingGovernanceTarget = false,
}: FixtureOptions): void {
  const sqlite = new Database(databasePath);

  sqlite.exec(`
    DELETE FROM governance_packages;
    DELETE FROM matilda_canonical_packages;
    DELETE FROM matilda_draft_revisions;
    DELETE FROM matilda_living_draft_packages;
  `);

  sqlite.prepare(`
    INSERT INTO matilda_draft_revisions (
      draft_revision_id,
      draft_package_id,
      lineage_id,
      project_id,
      conversation_id,
      current_interpretation,
      proposed_work,
      proposed_artifacts,
      in_scope,
      out_of_scope,
      constraints,
      expected_outcome,
      unresolved_questions,
      evidence_entry_ids,
      source_draft_status,
      source_draft_updated_at,
      status,
      created_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    "revision-canonical-test",
    "draft-canonical-test",
    "lineage-canonical-test",
    "hq",
    "conversation-canonical-test",
    "Validate Canonical Package approval safely.",
    "Exercise the existing authoritative transition.",
    "Canonical Package and Mission Package projection.",
    "Canonical approval persistence only.",
    "Delegation, validation, execution, and push.",
    "Fail closed without partial authoritative persistence.",
    expectedOutcome,
    null,
    JSON.stringify(["iel-canonical-test"]),
    "draft_non_authoritative",
    "2026-08-31T00:00:00.000Z",
    "approval_review_candidate",
    "2026-08-31T00:00:01.000Z",
  );

  if (conflictingGovernanceTarget) {
    sqlite.prepare(`
      INSERT INTO matilda_canonical_packages (
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
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      "pkg-canonical-test",
      1,
      "summary-prior-canonical-test",
      "draft-canonical-test",
      "revision-prior-canonical-test",
      "lineage-canonical-test",
      "hq",
      "conversation-prior-canonical-test",
      "Prior approved interpretation.",
      null,
      null,
      null,
      null,
      "Prior approved outcome.",
      "marcela",
      "2026-08-30T00:00:00.000Z",
      "canonical_approved",
      "2026-08-30T00:00:00.000Z",
    );

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
      "pkg-canonical-test",
      2,
      "other-project",
      "legacy-conversation",
      "Conflicting legacy outcome.",
      "2026-08-30T00:00:01.000Z",
    );
  }

  sqlite.close();
}

function countRows(table: string): number {
  const sqlite = new Database(databasePath, { readonly: true });

  try {
    const row = sqlite
      .prepare(`SELECT COUNT(*) AS count FROM ${table}`)
      .get() as { count: number };

    return row.count;
  } finally {
    sqlite.close();
  }
}

initializeFixtureSchema();
process.chdir(temporaryRoot);

const runtime = require(
  path.join(repositoryRoot, "db", "matilda-canonical-package-runtime.ts"),
) as typeof import("./matilda-canonical-package-runtime");

test(
  "incomplete expected outcome fails before authoritative persistence",
  () => {
    resetFixture({ expectedOutcome: null });

    assert.throws(
      () =>
        runtime.createCanonicalPackageFromApprovedSummary(
          {
            draft_revision_id: "revision-canonical-test",
            approval_actor: "marcela",
          },
          { schemaReady: true },
        ),
      /requires a non-empty expected_outcome/,
    );

    assert.equal(countRows("matilda_canonical_packages"), 0);
    assert.equal(countRows("governance_packages"), 0);
  },
);

test(
  "projection conflict rolls back Canonical Package persistence",
  () => {
    resetFixture({
      expectedOutcome: "One safely projected Canonical Package.",
      conflictingGovernanceTarget: true,
    });

    assert.throws(
      () =>
        runtime.createCanonicalPackageFromApprovedSummary(
          {
            draft_revision_id: "revision-canonical-test",
            approval_actor: "marcela",
          },
          { schemaReady: true },
        ),
      /conflicting identity, semantics, or provenance/,
    );

    assert.equal(countRows("matilda_canonical_packages"), 1);

    const sqlite = new Database(databasePath, { readonly: true });

    try {
      const row = sqlite.prepare(`
        SELECT
          project_id,
          conversation_id,
          requested_outcome
        FROM governance_packages
        WHERE package_id = ?
          AND package_version = ?
      `).get(
        "pkg-canonical-test",
        2,
      ) as {
        project_id: string;
        conversation_id: string;
        requested_outcome: string;
      };

      assert.deepEqual(row, {
        project_id: "other-project",
        conversation_id: "legacy-conversation",
        requested_outcome: "Conflicting legacy outcome.",
      });

      const canonicalRows = sqlite.prepare(`
        SELECT
          package_id,
          package_version,
          draft_revision_id,
          approved_expected_outcome
        FROM matilda_canonical_packages
        ORDER BY package_version
      `).all() as Array<{
        package_id: string;
        package_version: number;
        draft_revision_id: string;
        approved_expected_outcome: string;
      }>;

      assert.deepEqual(canonicalRows, [
        {
          package_id: "pkg-canonical-test",
          package_version: 1,
          draft_revision_id: "revision-prior-canonical-test",
          approved_expected_outcome: "Prior approved outcome.",
        },
      ]);
    } finally {
      sqlite.close();
    }
  },
);

test(
  "valid approval atomically persists Canonical Package and projection",
  () => {
    resetFixture({
      expectedOutcome: "One safely projected Canonical Package.",
    });

    const result =
      runtime.createCanonicalPackageFromApprovedSummary(
        {
          draft_revision_id: "revision-canonical-test",
          approval_actor: "marcela",
        },
        { schemaReady: true },
      );

    assert.equal(result.status, "canonical_approved");
    assert.equal(
      result.approved_expected_outcome,
      "One safely projected Canonical Package.",
    );
    assert.equal(result.delegation_authorized, false);
    assert.equal(result.validation_authorized, false);
    assert.equal(result.envelope_authorized, false);
    assert.equal(result.execution_authorized, false);

    assert.equal(countRows("matilda_canonical_packages"), 1);
    assert.equal(countRows("governance_packages"), 1);

    const sqlite = new Database(databasePath, { readonly: true });

    try {
      const canonical = sqlite.prepare(`
        SELECT
          project_id,
          conversation_id,
          approved_expected_outcome,
          status
        FROM matilda_canonical_packages
        LIMIT 1
      `).get() as {
        project_id: string;
        conversation_id: string;
        approved_expected_outcome: string;
        status: string;
      };

      const projection = sqlite.prepare(`
        SELECT
          project_id,
          conversation_id,
          requested_outcome
        FROM governance_packages
        LIMIT 1
      `).get() as {
        project_id: string;
        conversation_id: string;
        requested_outcome: string;
      };

      assert.deepEqual(canonical, {
        project_id: "hq",
        conversation_id: "conversation-canonical-test",
        approved_expected_outcome:
          "One safely projected Canonical Package.",
        status: "canonical_approved",
      });

      assert.deepEqual(projection, {
        project_id: "hq",
        conversation_id: "conversation-canonical-test",
        requested_outcome:
          "One safely projected Canonical Package.",
      });
    } finally {
      sqlite.close();
    }
  },
);

test.after(() => {
  process.chdir(previousWorkingDirectory);
  rmSync(temporaryRoot, { recursive: true, force: true });
});

```

### db/matilda-canonical-package-runtime.ts

```text
import { randomUUID } from "node:crypto";

import Database from "better-sqlite3";

import { initializeDraftRevisionSchema } from "./matilda-draft-revision-runtime";
import { generateReconciledIntentSummary } from "./matilda-reconciled-intent-runtime";
import { projectCanonicalPackageToMissionPackage } from "./canonical-package-mission-projection";

const sqlite = new Database("db/main.db");

sqlite.pragma("foreign_keys = ON");

export class CanonicalPackageSchemaUnavailableError extends Error {
  readonly code = "CANONICAL_PACKAGE_SCHEMA_UNAVAILABLE";

  constructor(
    message =
      "Canonical Package schema has not been initialized. " +
      "initializeCanonicalPackageSchema() must complete successfully during " +
      "application startup before Canonical Package creation can proceed.",
  ) {
    super(message);
    this.name = "CanonicalPackageSchemaUnavailableError";
    Object.setPrototypeOf(
      this,
      CanonicalPackageSchemaUnavailableError.prototype,
    );
  }
}

function createCanonicalPackageTable() {
  sqlite.exec(`
    CREATE TABLE IF NOT EXISTS matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL CHECK (package_version >= 1),
      summary_id TEXT NOT NULL,
      draft_package_id TEXT NOT NULL,
      draft_revision_id TEXT,
      lineage_id TEXT NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      approved_interpretation TEXT NOT NULL,
      approved_work TEXT,
      approved_artifacts TEXT,
      approved_scope TEXT,
      approved_constraints TEXT,
      approved_expected_outcome TEXT,
      approval_actor TEXT NOT NULL,
      approval_timestamp TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    )
  `);
}

function migrateLegacyCanonicalPackageTableIfRequired() {
  const table = sqlite
    .prepare(`
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name = 'matilda_canonical_packages'
      LIMIT 1
    `)
    .get() as { name: string } | undefined;

  if (!table) {
    createCanonicalPackageTable();
    return;
  }

  const columns = sqlite
    .prepare("PRAGMA table_info(matilda_canonical_packages)")
    .all() as Array<{
      name: string;
      pk: number;
    }>;

  const hasPackageVersion = columns.some(
    (column) => column.name === "package_version",
  );

  const hasDraftRevisionId = columns.some(
    (column) => column.name === "draft_revision_id",
  );

  const packageIdPrimaryKeyOnly =
    columns.find((column) => column.name === "package_id")?.pk === 1
    && !columns.some(
      (column) =>
        column.name === "package_version"
        && column.pk > 0,
    );

  if (
    hasPackageVersion
    && hasDraftRevisionId
    && !packageIdPrimaryKeyOnly
  ) {
    return;
  }

  sqlite.transaction(() => {
    sqlite.exec(`
      DROP INDEX IF EXISTS idx_matilda_canonical_packages_draft_package_id;
    `);

    sqlite.exec(`
      ALTER TABLE matilda_canonical_packages
      RENAME TO matilda_canonical_packages_legacy_version_identity;
    `);

    createCanonicalPackageTable();

    sqlite.exec(`
      INSERT INTO matilda_canonical_packages (
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
      )
      SELECT
        package_id,
        1,
        summary_id,
        draft_package_id,
        NULL,
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
      FROM matilda_canonical_packages_legacy_version_identity;
    `);

    sqlite.exec(`
      DROP TABLE matilda_canonical_packages_legacy_version_identity;
    `);
  })();
}

export function initializeCanonicalPackageSchema() {
  initializeDraftRevisionSchema();

  migrateLegacyCanonicalPackageTableIfRequired();

  sqlite.exec(`
    CREATE UNIQUE INDEX IF NOT EXISTS
      idx_matilda_canonical_packages_draft_revision_id
    ON matilda_canonical_packages (draft_revision_id)
    WHERE draft_revision_id IS NOT NULL;
  `);

  sqlite.exec(`
    CREATE INDEX IF NOT EXISTS
      idx_matilda_canonical_packages_draft_package_version
    ON matilda_canonical_packages (
      draft_package_id,
      package_version
    );
  `);

  sqlite.exec(`
    CREATE INDEX IF NOT EXISTS
      idx_matilda_canonical_packages_lineage_version
    ON matilda_canonical_packages (
      lineage_id,
      package_version
    );
  `);
}

export function createCanonicalPackageFromApprovedSummary(
  {
    draft_revision_id,
    approval_actor,
  }: {
    draft_revision_id: string;
    approval_actor: string;
  },
  { schemaReady }: { schemaReady: boolean },
) {
  if (!schemaReady) {
    throw new CanonicalPackageSchemaUnavailableError();
  }

  if (
    typeof draft_revision_id !== "string"
    || draft_revision_id.trim().length === 0
  ) {
    throw new Error("draft_revision_id is required");
  }

  const normalizedDraftRevisionId = draft_revision_id.trim();

  const alreadyCanonicalized = sqlite
    .prepare(`
      SELECT
        package_id,
        package_version
      FROM matilda_canonical_packages
      WHERE draft_revision_id = ?
      LIMIT 1
    `)
    .get(normalizedDraftRevisionId) as
      | {
          package_id: string;
          package_version: number;
        }
      | undefined;

  if (alreadyCanonicalized) {
    throw new Error(
      `Draft Revision "${normalizedDraftRevisionId}" already produced Canonical Package `
      + `"${alreadyCanonicalized.package_id}" version ${alreadyCanonicalized.package_version}.`,
    );
  }

  const summary = generateReconciledIntentSummary({
    draft_revision_id: normalizedDraftRevisionId,
  });

  if (summary.approval_required !== true) {
    throw new Error("Summary is not eligible for approval.");
  }

  if (!summary.draft_revision_id) {
    throw new Error(
      "Canonical Package creation requires immutable Draft Revision provenance.",
    );
  }

  if (
    typeof summary.expected_outcome !== "string"
    || summary.expected_outcome.trim().length === 0
  ) {
    throw new Error(
      "Canonical Package approval requires a non-empty expected_outcome.",
    );
  }

  const latest = sqlite
    .prepare(`
      SELECT
        package_id,
        package_version,
        lineage_id,
        draft_package_id
      FROM matilda_canonical_packages
      WHERE draft_package_id = ?
        AND lineage_id = ?
      ORDER BY package_version DESC
      LIMIT 1
    `)
    .get(
      summary.draft_package_id,
      summary.lineage_id,
    ) as
      | {
          package_id: string;
          package_version: number;
          lineage_id: string;
          draft_package_id: string;
        }
      | undefined;

  const package_id =
    latest?.package_id ?? `pkg-${randomUUID()}`;

  const package_version =
    latest ? latest.package_version + 1 : 1;

  const created_at = new Date().toISOString();

  const persistCanonicalPackageAndProjection = sqlite.transaction(() => {
    try {
      sqlite
        .prepare(`
          INSERT INTO matilda_canonical_packages (
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
          ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        `)
        .run(
          package_id,
          package_version,
          summary.summary_id,
          summary.draft_package_id,
          summary.draft_revision_id,
          summary.lineage_id,
          summary.project_id,
          summary.conversation_id,
          summary.interpreted_objective,
          summary.proposed_work,
          summary.proposed_artifacts,
          summary.in_scope,
          summary.constraints,
          summary.expected_outcome,
          approval_actor,
          created_at,
          "canonical_approved",
          created_at,
        );
    } catch (err) {
      if (
        err instanceof Error
        && /UNIQUE constraint failed/i.test(err.message)
      ) {
        throw new Error(
          "Canonical Package version identity or Draft Revision provenance already exists.",
        );
      }

      throw err;
    }

    projectCanonicalPackageToMissionPackage(
      sqlite,
      {
        project_id: summary.project_id,
        package_id,
        package_version,
      },
    );
  });

  persistCanonicalPackageAndProjection();

  return {
    package_id,
    package_version,
    summary_id: summary.summary_id,
    draft_package_id: summary.draft_package_id,
    draft_revision_id: summary.draft_revision_id,
    lineage_id: summary.lineage_id,
    project_id: summary.project_id,
    conversation_id: summary.conversation_id,
    approved_interpretation: summary.interpreted_objective,
    approved_work: summary.proposed_work,
    approved_artifacts: summary.proposed_artifacts,
    approved_scope: summary.in_scope,
    approved_constraints: summary.constraints,
    approved_expected_outcome: summary.expected_outcome,
    approval_actor,
    approval_timestamp: created_at,
    status: "canonical_approved",
    created_at,
    delegation_authorized: false,
    validation_authorized: false,
    envelope_authorized: false,
    execution_authorized: false,
  };
}

```

### db/mission-read-project-scoped-handoff.test.ts

```text
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import { createMissionReadRepository } from "./mission-read-repository";
import { getOperationalPackageForProject } from "./operational-package-authority";

function createDb(): Database.Database {
  const db = new Database(":memory:");
  db.pragma("foreign_keys = ON");

  db.exec(`
    CREATE TABLE project_registry (
      project_id TEXT PRIMARY KEY,
      display_name TEXT NOT NULL
    );

    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      status TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE UNIQUE INDEX
      idx_matilda_canonical_packages_project_package_version
    ON matilda_canonical_packages (
      project_id,
      package_id,
      package_version
    );

    CREATE TABLE operational_package_authority (
      project_id TEXT PRIMARY KEY NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      selected_at TEXT NOT NULL,
      FOREIGN KEY (project_id)
        REFERENCES project_registry(project_id),
      FOREIGN KEY (project_id, package_id, package_version)
        REFERENCES matilda_canonical_packages(
          project_id,
          package_id,
          package_version
        )
    );

    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      requested_outcome TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_validation_results (
      validation_result_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      validation_status TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_envelope_gates (
      envelope_gate_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      gate_status TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      lifecycle_state TEXT,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_lifecycle_events (
      event_id INTEGER PRIMARY KEY AUTOINCREMENT,
      envelope_id TEXT NOT NULL,
      transition_authorization TEXT NOT NULL,
      persisted_at TEXT NOT NULL
    );
  `);

  return db;
}

function seedSelectedPackage(
  db: Database.Database,
  version = 1,
): void {
  db.prepare(`
    INSERT INTO project_registry (
      project_id,
      display_name
    ) VALUES ('hq', 'HQ')
  `).run();

  db.prepare(`
    INSERT INTO matilda_canonical_packages (
      package_id,
      package_version,
      project_id,
      status
    ) VALUES ('pkg-1', ?, 'hq', 'canonical_approved')
  `).run(version);

  db.prepare(`
    INSERT INTO governance_packages (
      package_id,
      package_version,
      project_id,
      conversation_id,
      requested_outcome
    ) VALUES ('pkg-1', ?, 'hq', 'conversation-1', 'Outcome')
  `).run(version);

  db.prepare(`
    INSERT INTO operational_package_authority (
      project_id,
      package_id,
      package_version,
      selected_at
    ) VALUES ('hq', 'pkg-1', ?, '2026-08-25T00:00:00.000Z')
  `).run(version);
}

async function testSelectedExactIdentity(): Promise<void> {
  const db = createDb();

  try {
    seedSelectedPackage(db, 1);

    const authority =
      getOperationalPackageForProject(db, "hq");

    assert.ok(authority);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission(authority);

    assert.ok(mission);
    assert.equal(mission.project_id, "hq");
    assert.equal(mission.package_id, "pkg-1");
    assert.equal(mission.package_version, 1);
  } finally {
    db.close();
  }
}

async function testMissingProjectionFailsClosed(): Promise<void> {
  const db = createDb();

  try {
    db.prepare(`
      INSERT INTO project_registry (
        project_id,
        display_name
      ) VALUES ('hq', 'HQ')
    `).run();

    db.prepare(`
      INSERT INTO matilda_canonical_packages (
        package_id,
        package_version,
        project_id,
        status
      ) VALUES ('pkg-1', 1, 'hq', 'canonical_approved')
    `).run();

    db.prepare(`
      INSERT INTO operational_package_authority (
        project_id,
        package_id,
        package_version,
        selected_at
      ) VALUES ('hq', 'pkg-1', 1, '2026-08-25T00:00:00.000Z')
    `).run();

    const authority =
      getOperationalPackageForProject(db, "hq");

    assert.ok(authority);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission(authority);

    assert.equal(mission, null);
  } finally {
    db.close();
  }
}

async function testWrongProjectFailsClosed(): Promise<void> {
  const db = createDb();

  try {
    seedSelectedPackage(db, 1);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission({
      project_id: "other",
      package_id: "pkg-1",
      package_version: 1,
    });

    assert.equal(mission, null);
  } finally {
    db.close();
  }
}

async function testWrongVersionFailsClosed(): Promise<void> {
  const db = createDb();

  try {
    seedSelectedPackage(db, 1);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission({
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 2,
    });

    assert.equal(mission, null);
  } finally {
    db.close();
  }
}

async function testNewerVersionDoesNotAutoActivate(): Promise<void> {
  const db = createDb();

  try {
    seedSelectedPackage(db, 1);

    db.prepare(`
      INSERT INTO matilda_canonical_packages (
        package_id,
        package_version,
        project_id,
        status
      ) VALUES ('pkg-1', 2, 'hq', 'canonical_approved')
    `).run();

    db.prepare(`
      INSERT INTO governance_packages (
        package_id,
        package_version,
        project_id,
        conversation_id,
        requested_outcome
      ) VALUES ('pkg-1', 2, 'hq', 'conversation-2', 'Newer outcome')
    `).run();

    const authority =
      getOperationalPackageForProject(db, "hq");

    assert.ok(authority);
    assert.equal(authority.package_version, 1);

    const repository = createMissionReadRepository(db);
    const mission = await repository.loadMission(authority);

    assert.ok(mission);
    assert.equal(mission.package_version, 1);
  } finally {
    db.close();
  }
}

async function testUnselectedProjectHasNoAuthority(): Promise<void> {
  const db = createDb();

  try {
    db.prepare(`
      INSERT INTO project_registry (
        project_id,
        display_name
      ) VALUES ('hq', 'HQ')
    `).run();

    assert.equal(
      getOperationalPackageForProject(db, "hq"),
      null,
    );
  } finally {
    db.close();
  }
}

await testSelectedExactIdentity();
await testMissingProjectionFailsClosed();
await testWrongProjectFailsClosed();
await testWrongVersionFailsClosed();
await testNewerVersionDoesNotAutoActivate();
await testUnselectedProjectHasNoAuthority();

console.log(
  "Project-scoped Mission Read handoff targeted tests passed.",
);

```

### db/mission-read-repository.test.ts

```text
import { strict as assert } from "node:assert";
import Database from "better-sqlite3";

import { createMissionReadRepository } from "./mission-read-repository";

async function main(): Promise<void> {
  const db = new Database(":memory:");

  db.exec(`
    CREATE TABLE governance_packages (
      package_id TEXT PRIMARY KEY,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      requested_outcome TEXT NOT NULL
    );

    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_validation_results (
      validation_result_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_status TEXT NOT NULL,
      governance_findings TEXT,
      operational_requirements TEXT,
      capability_requirements TEXT,
      escalations TEXT,
      validation_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_envelope_gates (
      envelope_gate_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      gate_status TEXT NOT NULL,
      gate_reason TEXT,
      gate_decision_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      envelope_gate_id TEXT NOT NULL,
      validation_status TEXT NOT NULL,
      required_capabilities TEXT,
      operational_corridor TEXT,
      lifecycle_state TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_lifecycle_events (
      event_id INTEGER PRIMARY KEY AUTOINCREMENT,
      envelope_id TEXT NOT NULL,
      transition_authorization TEXT NOT NULL,
      persisted_at TEXT NOT NULL
    );
  `);

  const repository = createMissionReadRepository(db);

  const mission = await repository.loadMission("test-package");

  assert.equal(mission, null);

  db.close();

  console.log("Mission Read Repository unit test passed.");
}

void main();

```

### db/mission-read-repository.ts

```text
/*
 * Mission Read Repository
 *
 * Read-only persistence adapter for the Mission Read Model.
 * This layer retrieves authoritative governance evidence only.
 * State derivation remains the responsibility of the assembler.
 */

import type { Database } from "better-sqlite3";
import type { MissionAssemblyInput } from "./mission-read-model-assembler";

export interface MissionReadIdentity {
  project_id: string;
  package_id: string;
  package_version: number;
}

export interface MissionReadRepository {
  loadMission(
    identity: MissionReadIdentity,
  ): Promise<MissionAssemblyInput | null>;
}

export function createMissionReadRepository(
  db: Database,
): MissionReadRepository {
  const packageStatement = db.prepare(`
    SELECT
      package_id,
      package_version,
      project_id,
      conversation_id,
      requested_outcome
    FROM governance_packages
    WHERE project_id = ?
      AND package_id = ?
      AND package_version = ?
    LIMIT 1
  `);

  const delegationStatement = db.prepare(`
    SELECT authorization_state
    FROM governance_delegations
    WHERE package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 1
  `);

  const validationStatement = db.prepare(`
    SELECT validation_status
    FROM governance_validation_results
    WHERE package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 1
  `);

  const gateStatement = db.prepare(`
    SELECT gate_status
    FROM governance_envelope_gates
    WHERE package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 1
  `);

  const envelopeStatement = db.prepare(`
    SELECT
      envelope_id,
      lifecycle_state
    FROM governance_envelopes
    WHERE package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 1
  `);

  const lifecycleEventsStatement = db.prepare(`
    SELECT
      transition_authorization,
      persisted_at
    FROM governance_lifecycle_events
    WHERE envelope_id = ?
    ORDER BY persisted_at ASC, event_id ASC
  `);

  return {
    async loadMission(
      identity: MissionReadIdentity,
    ): Promise<MissionAssemblyInput | null> {
      const project_id = identity.project_id.trim();
      const package_id = identity.package_id.trim();

      if (
        !project_id ||
        !package_id ||
        !Number.isInteger(identity.package_version) ||
        identity.package_version < 1
      ) {
        return null;
      }

      const pkg = packageStatement.get(
        project_id,
        package_id,
        identity.package_version,
      ) as
        | {
            package_id: string;
            package_version: number;
            project_id: string | null;
            conversation_id: string | null;
            requested_outcome: string;
          }
        | undefined;

      if (!pkg) {
        return null;
      }

      if (
        pkg.project_id !== project_id ||
        pkg.package_id !== package_id ||
        pkg.package_version !== identity.package_version
      ) {
        return null;
      }

      const delegation = delegationStatement.get(
        pkg.package_id,
        pkg.package_version,
      ) as
        | { authorization_state: string }
        | undefined;

      const validation = validationStatement.get(
        pkg.package_id,
        pkg.package_version,
      ) as
        | { validation_status: string }
        | undefined;

      const gate = gateStatement.get(
        pkg.package_id,
        pkg.package_version,
      ) as
        | { gate_status: string }
        | undefined;

      const envelope = envelopeStatement.get(
        pkg.package_id,
        pkg.package_version,
      ) as
        | {
            envelope_id: string;
            lifecycle_state: string | null;
          }
        | undefined;

      const lifecycleEvents = envelope
        ? (lifecycleEventsStatement.all(envelope.envelope_id) as Array<{
            transition_authorization: string;
            persisted_at: string;
          }>)
        : [];

      return {
        package_id: pkg.package_id,
        package_version: pkg.package_version,
        project_id: pkg.project_id,
        conversation_id: pkg.conversation_id,
        requested_outcome: pkg.requested_outcome,
        authorization_state: delegation?.authorization_state ?? null,
        validation_status: validation?.validation_status ?? null,
        gate_status: gate?.gate_status ?? null,
        lifecycle_state: envelope?.lifecycle_state ?? null,
        lifecycle_event_count: lifecycleEvents.length,
        lifecycle_events: lifecycleEvents,
        integrity_warnings: [],
      };
    },
  };
}

```

### db/operational-intake-runtime.test.ts

```text

import assert from "node:assert/strict";

import { describe, it } from "node:test";

import Database from "better-sqlite3";

import { createOperationalIntakeRecord } from "./operational-intake-runtime";

function createTestDb() {

  const db = new Database(":memory:");

  db.pragma("foreign_keys = ON");

  db.exec(`

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

      PRIMARY KEY (package_id, package_version)

    );

    CREATE TABLE governance_delegations (

      delegation_id TEXT PRIMARY KEY,

      package_id TEXT NOT NULL,

      package_version INTEGER NOT NULL,

      authorization_state TEXT NOT NULL,

      authorization_timestamp TEXT NOT NULL,

      delegated_by TEXT NOT NULL,

      created_at TEXT NOT NULL,

      FOREIGN KEY (package_id, package_version)

        REFERENCES governance_packages(package_id, package_version)

    );

    CREATE TABLE governance_validation_results (

      validation_result_id TEXT PRIMARY KEY,

      package_id TEXT NOT NULL,

      package_version INTEGER NOT NULL,

      delegation_id TEXT NOT NULL,

      validation_status TEXT NOT NULL,

      governance_findings TEXT,

      operational_requirements TEXT,

      capability_requirements TEXT,

      escalations TEXT,

      validation_timestamp TEXT NOT NULL,

      created_at TEXT NOT NULL,

      FOREIGN KEY (package_id, package_version)

        REFERENCES governance_packages(package_id, package_version),

      FOREIGN KEY (delegation_id)

        REFERENCES governance_delegations(delegation_id)

    );

    CREATE TABLE governance_envelope_gates (

      envelope_gate_id TEXT PRIMARY KEY,

      package_id TEXT NOT NULL,

      package_version INTEGER NOT NULL,

      delegation_id TEXT NOT NULL,

      validation_result_id TEXT NOT NULL,

      gate_status TEXT NOT NULL,

      gate_reason TEXT,

      gate_decision_timestamp TEXT NOT NULL,

      created_at TEXT NOT NULL,

      FOREIGN KEY (package_id, package_version)

        REFERENCES governance_packages(package_id, package_version),

      FOREIGN KEY (delegation_id)

        REFERENCES governance_delegations(delegation_id),

      FOREIGN KEY (validation_result_id)

        REFERENCES governance_validation_results(validation_result_id)

    );

    CREATE TABLE governance_envelopes (

      envelope_id TEXT PRIMARY KEY,

      package_id TEXT NOT NULL,

      package_version INTEGER NOT NULL,

      delegation_id TEXT NOT NULL,

      validation_result_id TEXT NOT NULL,

      envelope_gate_id TEXT NOT NULL,

      validation_status TEXT NOT NULL,

      required_capabilities TEXT,

      operational_corridor TEXT,

      lifecycle_state TEXT NOT NULL,

      created_at TEXT NOT NULL,

      FOREIGN KEY (package_id, package_version)

        REFERENCES governance_packages(package_id, package_version),

      FOREIGN KEY (delegation_id)

        REFERENCES governance_delegations(delegation_id),

      FOREIGN KEY (validation_result_id)

        REFERENCES governance_validation_results(validation_result_id),

      FOREIGN KEY (envelope_gate_id)

        REFERENCES governance_envelope_gates(envelope_gate_id)

    );

    CREATE TABLE operational_intake_records (

      intake_id TEXT PRIMARY KEY,

      envelope_id TEXT NOT NULL,

      package_id TEXT NOT NULL,

      package_version INTEGER NOT NULL,

      delegation_id TEXT NOT NULL,

      validation_result_id TEXT NOT NULL,

      envelope_gate_id TEXT NOT NULL,

      lifecycle_state_at_intake TEXT NOT NULL,

      assigned_department TEXT NOT NULL,

      required_capabilities_snapshot TEXT,

      intake_status TEXT NOT NULL,

      intake_created_at TEXT NOT NULL,

      intake_updated_at TEXT NOT NULL,

      governance_authority_preserved INTEGER NOT NULL,

      lifecycle_authority_preserved INTEGER NOT NULL,

      assignment_authority_preserved INTEGER NOT NULL,

      routing_authorized INTEGER NOT NULL,

      scheduler_authorized INTEGER NOT NULL,

      worker_claim_authorized INTEGER NOT NULL,

      execution_authorized INTEGER NOT NULL,

      FOREIGN KEY (envelope_id)

        REFERENCES governance_envelopes(envelope_id),

      FOREIGN KEY (package_id, package_version)

        REFERENCES governance_packages(package_id, package_version),

      FOREIGN KEY (delegation_id)

        REFERENCES governance_delegations(delegation_id),

      FOREIGN KEY (validation_result_id)

        REFERENCES governance_validation_results(validation_result_id),

      FOREIGN KEY (envelope_gate_id)

        REFERENCES governance_envelope_gates(envelope_gate_id)

    );

    CREATE UNIQUE INDEX idx_operational_intake_records_envelope_id

      ON operational_intake_records(envelope_id);

  `);

  return db;

}

function seedGovernanceLineage(db: any, lifecycleState = "ASSIGNED") {

  db.exec(`

    INSERT INTO governance_packages (

      package_id,

      package_version,

      requested_outcome,

      scope,

      containment,

      constraints,

      success_criteria,

      created_at

    ) VALUES (

      'pkg-intake-test',

      1,

      'Validate operational intake runtime',

      'Targeted test',

      'No downstream runtime',

      'Authority separation preserved',

      'Operational intake runtime works',

      '2026-06-29T00:00:00.000Z'

    );

    INSERT INTO governance_delegations (

      delegation_id,

      package_id,

      package_version,

      authorization_state,

      authorization_timestamp,

      delegated_by,

      created_at

    ) VALUES (

      'del-intake-test',

      'pkg-intake-test',

      1,

      'AUTHORIZED',

      '2026-06-29T00:00:00.000Z',

      'marcela',

      '2026-06-29T00:00:00.000Z'

    );

    INSERT INTO governance_validation_results (

      validation_result_id,

      package_id,

      package_version,

      delegation_id,

      validation_status,

      validation_timestamp,

      created_at

    ) VALUES (

      'val-intake-test',

      'pkg-intake-test',

      1,

      'del-intake-test',

      'VALIDATION_PASSED',

      '2026-06-29T00:00:00.000Z',

      '2026-06-29T00:00:00.000Z'

    );

    INSERT INTO governance_envelope_gates (

      envelope_gate_id,

      package_id,

      package_version,

      delegation_id,

      validation_result_id,

      gate_status,

      gate_decision_timestamp,

      created_at

    ) VALUES (

      'gate-intake-test',

      'pkg-intake-test',

      1,

      'del-intake-test',

      'val-intake-test',

      'OPEN',

      '2026-06-29T00:00:00.000Z',

      '2026-06-29T00:00:00.000Z'

    );

  `);

  db.prepare(`

    INSERT INTO governance_envelopes (

      envelope_id,

      package_id,

      package_version,

      delegation_id,

      validation_result_id,

      envelope_gate_id,

      validation_status,

      required_capabilities,

      operational_corridor,

      lifecycle_state,

      created_at

    ) VALUES (

      'env-intake-test',

      'pkg-intake-test',

      1,

      'del-intake-test',

      'val-intake-test',

      'gate-intake-test',

      'VALIDATION_PASSED',

      '["engineering","coordination"]',

      'Operational Intake',

      ?,

      '2026-06-29T00:00:00.000Z'

    )

  `).run(lifecycleState);

}

describe("createOperationalIntakeRecord", () => {

  it("creates an intake record for an ASSIGNED envelope", () => {

    const db = createTestDb();

    seedGovernanceLineage(db);

    const record = createOperationalIntakeRecord({

      intake_id: "intake-test-1",

      envelope_id: "env-intake-test",

      assigned_department: "engineering",

      intake_created_at: "2026-06-29T00:00:00.000Z",

      db,

    });

    assert.equal(record.intake_id, "intake-test-1");

    assert.equal(record.envelope_id, "env-intake-test");

    assert.equal(record.lifecycle_state_at_intake, "ASSIGNED");

    assert.equal(record.assigned_department, "engineering");

    assert.equal(record.required_capabilities_snapshot, '["engineering","coordination"]');

    assert.equal(record.intake_status, "RECORDED");

  });

  it("rejects intake for a non-ASSIGNED envelope", () => {

    const db = createTestDb();

    seedGovernanceLineage(db, "ENVELOPE_CREATED");

    assert.throws(

      () =>

        createOperationalIntakeRecord({

          intake_id: "intake-test-1",

          envelope_id: "env-intake-test",

          assigned_department: "engineering",

          db,

        }),

      /requires envelope lifecycle_state ASSIGNED/,

    );

  });

  it("returns the existing canonical intake record for duplicate intake", () => {

    const db = createTestDb();

    seedGovernanceLineage(db);

    const first = createOperationalIntakeRecord({

      intake_id: "intake-test-1",

      envelope_id: "env-intake-test",

      assigned_department: "engineering",

      intake_created_at: "2026-06-29T00:00:00.000Z",

      db,

    });

    const second = createOperationalIntakeRecord({

      intake_id: "intake-test-2",

      envelope_id: "env-intake-test",

      assigned_department: "engineering",

      intake_created_at: "2026-06-29T00:01:00.000Z",

      db,

    });

    assert.equal(second.intake_id, first.intake_id);

    assert.equal(

      db.prepare("SELECT COUNT(*) AS count FROM operational_intake_records").get().count,

      1,

    );

  });

  it("preserves authority separation flags", () => {

    const db = createTestDb();

    seedGovernanceLineage(db);

    const record = createOperationalIntakeRecord({

      intake_id: "intake-test-1",

      envelope_id: "env-intake-test",

      assigned_department: "engineering",

      db,

    });

    assert.equal(record.governance_authority_preserved, true);

    assert.equal(record.lifecycle_authority_preserved, true);

    assert.equal(record.assignment_authority_preserved, true);

    assert.equal(record.routing_authorized, false);

    assert.equal(record.scheduler_authorized, false);

    assert.equal(record.worker_claim_authorized, false);

    assert.equal(record.execution_authorized, false);

  });

});


```

### db/operational-package-authority.test.ts

```text
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import {
  getOperationalPackageForProject,
  selectOperationalPackageForProject,
} from "./operational-package-authority";

function createDb(): Database.Database {
  const db = new Database(":memory:");
  db.pragma("foreign_keys = ON");

  db.exec(`
    CREATE TABLE project_registry (
      project_id TEXT PRIMARY KEY,
      display_name TEXT NOT NULL
    );

    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      status TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE UNIQUE INDEX
      idx_matilda_canonical_packages_project_package_version
    ON matilda_canonical_packages (
      project_id,
      package_id,
      package_version
    );

    CREATE TABLE governance_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      PRIMARY KEY (package_id, package_version)
    );

    CREATE TABLE operational_package_authority (
      project_id TEXT PRIMARY KEY NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      selected_at TEXT NOT NULL,
      FOREIGN KEY (project_id)
        REFERENCES project_registry(project_id),
      FOREIGN KEY (project_id, package_id, package_version)
        REFERENCES matilda_canonical_packages(
          project_id,
          package_id,
          package_version
        )
    );
  `);

  return db;
}

function seed(
  db: Database.Database,
  {
    projectId = "hq",
    packageId = "pkg-1",
    version = 1,
    status = "canonical_approved",
    projection = true,
  }: {
    projectId?: string;
    packageId?: string;
    version?: number;
    status?: string;
    projection?: boolean;
  } = {},
): void {
  db.prepare(`
    INSERT OR IGNORE INTO project_registry (
      project_id,
      display_name
    ) VALUES (?, ?)
  `).run(projectId, projectId);

  db.prepare(`
    INSERT INTO matilda_canonical_packages (
      package_id,
      package_version,
      project_id,
      status
    ) VALUES (?, ?, ?, ?)
  `).run(packageId, version, projectId, status);

  if (projection) {
    db.prepare(`
      INSERT INTO governance_packages (
        package_id,
        package_version,
        project_id
      ) VALUES (?, ?, ?)
    `).run(packageId, version, projectId);
  }
}

function testReadNullWhenUnselected(): void {
  const db = createDb();

  try {
    db.prepare(`
      INSERT INTO project_registry (
        project_id,
        display_name
      ) VALUES ('hq', 'HQ')
    `).run();

    assert.equal(
      getOperationalPackageForProject(db, "hq"),
      null,
    );
  } finally {
    db.close();
  }
}

function testValidExactBinding(): void {
  const db = createDb();

  try {
    seed(db);

    const result = selectOperationalPackageForProject(db, {
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 1,
    });

    assert.equal(result.project_id, "hq");
    assert.equal(result.package_id, "pkg-1");
    assert.equal(result.package_version, 1);
  } finally {
    db.close();
  }
}

function testWrongProjectRejected(): void {
  const db = createDb();

  try {
    seed(db);
    db.prepare(`
      INSERT INTO project_registry (
        project_id,
        display_name
      ) VALUES ('other', 'Other')
    `).run();

    assert.throws(() =>
      selectOperationalPackageForProject(db, {
        project_id: "other",
        package_id: "pkg-1",
        package_version: 1,
      }),
    );
  } finally {
    db.close();
  }
}

function testNonApprovedRejected(): void {
  const db = createDb();

  try {
    seed(db, { status: "draft" });

    assert.throws(() =>
      selectOperationalPackageForProject(db, {
        project_id: "hq",
        package_id: "pkg-1",
        package_version: 1,
      }),
    );
  } finally {
    db.close();
  }
}

function testMissingProjectionRejected(): void {
  const db = createDb();

  try {
    seed(db, { projection: false });

    assert.throws(() =>
      selectOperationalPackageForProject(db, {
        project_id: "hq",
        package_id: "pkg-1",
        package_version: 1,
      }),
    );
  } finally {
    db.close();
  }
}

function testSameBindingIdempotent(): void {
  const db = createDb();

  try {
    seed(db);

    const first = selectOperationalPackageForProject(db, {
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 1,
    });

    const second = selectOperationalPackageForProject(db, {
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 1,
    });

    assert.deepEqual(second, first);
  } finally {
    db.close();
  }
}

function testExplicitReplacement(): void {
  const db = createDb();

  try {
    seed(db, {
      packageId: "pkg-1",
      version: 1,
    });

    seed(db, {
      packageId: "pkg-2",
      version: 1,
    });

    selectOperationalPackageForProject(db, {
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 1,
    });

    const replacement =
      selectOperationalPackageForProject(db, {
        project_id: "hq",
        package_id: "pkg-2",
        package_version: 1,
      });

    assert.equal(replacement.package_id, "pkg-2");

    const count = db.prepare(`
      SELECT COUNT(*) AS count
      FROM operational_package_authority
      WHERE project_id = 'hq'
    `).get() as { count: number };

    assert.equal(count.count, 1);
  } finally {
    db.close();
  }
}

function testSuccessorDoesNotAutoActivate(): void {
  const db = createDb();

  try {
    seed(db, {
      packageId: "pkg-1",
      version: 1,
    });

    selectOperationalPackageForProject(db, {
      project_id: "hq",
      package_id: "pkg-1",
      package_version: 1,
    });

    seed(db, {
      packageId: "pkg-1",
      version: 2,
    });

    const current =
      getOperationalPackageForProject(db, "hq");

    assert.ok(current);
    assert.equal(current.package_version, 1);
  } finally {
    db.close();
  }
}

testReadNullWhenUnselected();
testValidExactBinding();
testWrongProjectRejected();
testNonApprovedRejected();
testMissingProjectionRejected();
testSameBindingIdempotent();
testExplicitReplacement();
testSuccessorDoesNotAutoActivate();

console.log(
  "Operational Package Authority targeted tests passed.",
);

```

### db/operational-package-authority.ts

```text
import type { Database } from "better-sqlite3";

export interface OperationalPackageAuthority {
  project_id: string;
  package_id: string;
  package_version: number;
  selected_at: string;
}

export interface SelectOperationalPackageInput {
  project_id: string;
  package_id: string;
  package_version: number;
}

function requireText(value: string, field: string): string {
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(`${field} is required.`);
  }
  return normalized;
}

export function getOperationalPackageForProject(
  db: Database,
  projectId: string,
): OperationalPackageAuthority | null {
  const project_id = requireText(projectId, "project_id");

  const row = db.prepare(`
    SELECT
      project_id,
      package_id,
      package_version,
      selected_at
    FROM operational_package_authority
    WHERE project_id = ?
  `).get(project_id) as OperationalPackageAuthority | undefined;

  return row ?? null;
}

export function selectOperationalPackageForProject(
  db: Database,
  input: SelectOperationalPackageInput,
): OperationalPackageAuthority {
  const project_id = requireText(input.project_id, "project_id");
  const package_id = requireText(input.package_id, "package_id");

  if (
    !Number.isInteger(input.package_version) ||
    input.package_version < 1
  ) {
    throw new Error("package_version must be a positive integer.");
  }

  const package_version = input.package_version;

  const project = db.prepare(`
    SELECT project_id
    FROM project_registry
    WHERE project_id = ?
  `).get(project_id) as { project_id: string } | undefined;

  if (!project) {
    throw new Error("Operational Package Authority project was not found.");
  }

  const canonical = db.prepare(`
    SELECT
      project_id,
      package_id,
      package_version,
      status
    FROM matilda_canonical_packages
    WHERE project_id = ?
      AND package_id = ?
      AND package_version = ?
  `).get(
    project_id,
    package_id,
    package_version,
  ) as
    | {
        project_id: string;
        package_id: string;
        package_version: number;
        status: string;
      }
    | undefined;

  if (!canonical) {
    throw new Error(
      "Operational Package Authority canonical Package was not found for the exact project/package/version identity.",
    );
  }

  if (canonical.status !== "canonical_approved") {
    throw new Error(
      "Operational Package Authority requires canonical_approved status.",
    );
  }

  const projection = db.prepare(`
    SELECT
      project_id,
      package_id,
      package_version
    FROM governance_packages
    WHERE package_id = ?
      AND package_version = ?
      AND project_id = ?
  `).get(
    package_id,
    package_version,
    project_id,
  ) as
    | {
        project_id: string;
        package_id: string;
        package_version: number;
      }
    | undefined;

  if (!projection) {
    throw new Error(
      "Operational Package Authority requires an exact derived Mission Package projection.",
    );
  }

  const existing = getOperationalPackageForProject(db, project_id);

  if (
    existing &&
    existing.package_id === package_id &&
    existing.package_version === package_version
  ) {
    return existing;
  }

  const selected_at = new Date().toISOString();

  db.prepare(`
    INSERT INTO operational_package_authority (
      project_id,
      package_id,
      package_version,
      selected_at
    ) VALUES (?, ?, ?, ?)
    ON CONFLICT(project_id) DO UPDATE SET
      package_id = excluded.package_id,
      package_version = excluded.package_version,
      selected_at = excluded.selected_at
  `).run(
    project_id,
    package_id,
    package_version,
    selected_at,
  );

  const selected = getOperationalPackageForProject(db, project_id);

  if (!selected) {
    throw new Error(
      "Operational Package Authority write completed without a readable authority row.",
    );
  }

  return selected;
}

```

### server/atlas/atlas-canonical-package-observation.test.ts

```text
import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

import Database from "better-sqlite3";

import {
  readAtlasCanonicalPackageObservations,
} from "./atlas-canonical-package-observation";

function createFixtureDatabase() {
  const root = mkdtempSync(
    path.join(
      tmpdir(),
      "atlas-canonical-package-observation-",
    ),
  );

  const databasePath = path.join(root, "main.db");
  const database = new Database(databasePath);

  database.exec(`
    CREATE TABLE matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      summary_id TEXT NOT NULL,
      draft_package_id TEXT NOT NULL,
      draft_revision_id TEXT,
      lineage_id TEXT NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      approved_interpretation TEXT NOT NULL,
      approved_work TEXT,
      approved_artifacts TEXT,
      approved_scope TEXT,
      approved_constraints TEXT,
      approved_expected_outcome TEXT,
      approval_actor TEXT NOT NULL,
      approval_timestamp TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    );
  `);

  return {
    database,
    databasePath,
    cleanup() {
      database.close();
      rmSync(root, {
        recursive: true,
        force: true,
      });
    },
  };
}

function insertCanonicalPackage(
  database: Database.Database,
  input: {
    projectId: string;
    packageId: string;
    packageVersion: number;
    draftRevisionId: string;
    lineageId: string;
    conversationId: string;
    status?: string;
  },
) {
  database
    .prepare(`
      INSERT INTO matilda_canonical_packages (
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
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `)
    .run(
      input.packageId,
      input.packageVersion,
      `summary-${input.packageId}`,
      `draft-${input.packageId}`,
      input.draftRevisionId,
      input.lineageId,
      input.projectId,
      input.conversationId,
      "approved interpretation",
      "approved work",
      "approved artifacts",
      "approved scope",
      "approved constraints",
      "approved outcome",
      "marcela",
      "2026-09-16T21:00:00.000Z",
      input.status ?? "canonical_approved",
      "2026-09-16T21:00:00.000Z",
    );
}

test(
  "Atlas observes canonical Package authority directly from canonical source",
  () => {
    const fixture = createFixtureDatabase();

    try {
      insertCanonicalPackage(fixture.database, {
        projectId: "hq",
        packageId: "pkg-1",
        packageVersion: 1,
        draftRevisionId: "revision-1",
        lineageId: "lineage-1",
        conversationId: "conversation-1",
      });

      const observations =
        readAtlasCanonicalPackageObservations(
          "hq",
          fixture.databasePath,
        );

      assert.deepEqual(observations, [
        {
          observationType: "canonical_package",
          authority: "authoritative",
          status: "canonical_approved",
          projectId: "hq",
          conversationId: "conversation-1",
          packageId: "pkg-1",
          packageVersion: 1,
          draftRevisionId: "revision-1",
          lineageId: "lineage-1",
          approvalActor: "marcela",
          approvalTimestamp:
            "2026-09-16T21:00:00.000Z",
        },
      ]);
    } finally {
      fixture.cleanup();
    }
  },
);

test(
  "Atlas canonical Package observation fails closed across project scope",
  () => {
    const fixture = createFixtureDatabase();

    try {
      insertCanonicalPackage(fixture.database, {
        projectId: "other-project",
        packageId: "pkg-other",
        packageVersion: 1,
        draftRevisionId: "revision-other",
        lineageId: "lineage-other",
        conversationId: "conversation-other",
      });

      assert.deepEqual(
        readAtlasCanonicalPackageObservations(
          "hq",
          fixture.databasePath,
        ),
        [],
      );
    } finally {
      fixture.cleanup();
    }
  },
);

test(
  "Atlas does not promote non-canonical Package state",
  () => {
    const fixture = createFixtureDatabase();

    try {
      insertCanonicalPackage(fixture.database, {
        projectId: "hq",
        packageId: "pkg-pending",
        packageVersion: 1,
        draftRevisionId: "revision-pending",
        lineageId: "lineage-pending",
        conversationId: "conversation-pending",
        status: "pending",
      });

      assert.deepEqual(
        readAtlasCanonicalPackageObservations(
          "hq",
          fixture.databasePath,
        ),
        [],
      );
    } finally {
      fixture.cleanup();
    }
  },
);

test(
  "Atlas canonical Package observation requires project identity",
  () => {
    const fixture = createFixtureDatabase();

    try {
      assert.throws(
        () =>
          readAtlasCanonicalPackageObservations(
            "   ",
            fixture.databasePath,
          ),
        /requires projectId/,
      );
    } finally {
      fixture.cleanup();
    }
  },
);

```

### server/atlas/atlas-canonical-package-observation.ts

```text
import Database from "better-sqlite3";

export type AtlasCanonicalPackageObservation = {
  observationType: "canonical_package";
  authority: "authoritative";
  status: "canonical_approved";
  projectId: string;
  conversationId: string | null;
  packageId: string;
  packageVersion: number;
  draftRevisionId: string | null;
  lineageId: string;
  approvalActor: string;
  approvalTimestamp: string;
};

type CanonicalPackageSourceRecord = {
  package_id: string;
  package_version: number;
  draft_revision_id: string | null;
  lineage_id: string;
  project_id: string | null;
  conversation_id: string | null;
  approval_actor: string;
  approval_timestamp: string;
  status: string;
};

function requireProjectId(projectId: string): string {
  if (typeof projectId !== "string" || projectId.trim().length === 0) {
    throw new Error(
      "Atlas canonical Package observation requires projectId.",
    );
  }

  return projectId.trim();
}

function adaptCanonicalPackageForAtlas(
  record: CanonicalPackageSourceRecord,
  expectedProjectId: string,
): AtlasCanonicalPackageObservation {
  if (record.project_id !== expectedProjectId) {
    throw new Error(
      "Atlas canonical Package observation crossed project scope.",
    );
  }

  if (record.status !== "canonical_approved") {
    throw new Error(
      "Atlas canonical Package observation requires canonical_approved status.",
    );
  }

  if (
    typeof record.package_id !== "string"
    || record.package_id.trim().length === 0
    || !Number.isInteger(record.package_version)
    || record.package_version < 1
    || typeof record.lineage_id !== "string"
    || record.lineage_id.trim().length === 0
    || typeof record.approval_actor !== "string"
    || record.approval_actor.trim().length === 0
    || typeof record.approval_timestamp !== "string"
    || record.approval_timestamp.trim().length === 0
  ) {
    throw new Error(
      "Atlas canonical Package observation encountered invalid canonical identity.",
    );
  }

  return {
    observationType: "canonical_package",
    authority: "authoritative",
    status: "canonical_approved",
    projectId: expectedProjectId,
    conversationId: record.conversation_id,
    packageId: record.package_id,
    packageVersion: record.package_version,
    draftRevisionId: record.draft_revision_id,
    lineageId: record.lineage_id,
    approvalActor: record.approval_actor,
    approvalTimestamp: record.approval_timestamp,
  };
}

export function readAtlasCanonicalPackageObservations(
  projectId: string,
  databasePath = "db/main.db",
): AtlasCanonicalPackageObservation[] {
  const normalizedProjectId = requireProjectId(projectId);

  const database = new Database(databasePath, {
    readonly: true,
    fileMustExist: true,
  });

  try {
    const records = database
      .prepare(`
        SELECT
          package_id,
          package_version,
          draft_revision_id,
          lineage_id,
          project_id,
          conversation_id,
          approval_actor,
          approval_timestamp,
          status
        FROM matilda_canonical_packages
        WHERE project_id = ?
          AND status = 'canonical_approved'
        ORDER BY approval_timestamp ASC, package_version ASC
      `)
      .all(normalizedProjectId) as CanonicalPackageSourceRecord[];

    return records.map((record) =>
      adaptCanonicalPackageForAtlas(
        record,
        normalizedProjectId,
      ),
    );
  } finally {
    database.close();
  }
}

```

### server/index.ts

```text
/* KEEP ONLY UI ROUTE FIX (MINIMAL PATCHED ROLLBACK) */

import express from "express";
import path from "path";
import { pathToFileURL } from "url";

import apiChatRouter from "../routes/api-chat";
import packageReadRouter from "../routes/api-package-read";
import missionReadRouter from "../routes/api-mission-read";
import approvalRequestRouter from "../routes/api-approval-request";
import requestChangesRouter from "../routes/api-request-changes";
import { initializeCanonicalPackageSchema } from "../db/matilda-canonical-package-runtime";
import matildaCanonicalPackageRouter from "./routes/matilda-canonical-package-route";
import canonicalPackageReadRouter from "../routes/api-canonical-package-read";
import { createGovernancePackageRouter } from "./routes/governance-package-route";
import { createGovernanceDelegationRouter } from "./routes/governance-delegation-route";
import { createGovernanceValidationRouter } from "./routes/governance-validation-route";
import { createGovernanceEnvelopeGateRouter } from "./routes/governance-envelope-gate-route";
import { createGovernanceEnvelopeRouter } from "./routes/governance-envelope-route";
import { createProductionGovernanceExecutionRouter } from "./execution/production-governance-execution-composition.js";
import atlasPreExecutionRouter from "./routes/atlas/preexecution";

const app = express();

app.locals.canonicalPackageSchemaReady = false;

app.use(express.json());
app.use(apiChatRouter);
app.use(missionReadRouter);
app.use(packageReadRouter);
app.use("/api/approval-requests", approvalRequestRouter);
app.use(requestChangesRouter);
app.use(matildaCanonicalPackageRouter);
app.use(canonicalPackageReadRouter);
app.use(createGovernancePackageRouter());
app.use(createGovernanceDelegationRouter());
app.use(createGovernanceValidationRouter());
app.use(createGovernanceEnvelopeGateRouter());
app.use(createGovernanceEnvelopeRouter());
app.use(createProductionGovernanceExecutionRouter());
app.use(atlasPreExecutionRouter);

app.get("/ui", (_req, res) => {
  res.send(`
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>Operator Cockpit</title>
  <link rel="stylesheet" href="/ui/styles.css" />
</head>
<body>

  <div class="topbar">
    <div class="project">
      Motherboard Systems HQ
    </div>

    <div class="health">
      ● Stable
    </div>
  </div>

  <div class="grid">

    <div class="panel workspace">
      <div class="panel-header">Workspace</div>
      <div class="panel-body">
        <div class="empty">System idle</div>
      </div>
    </div>

    <div class="panel telemetry">
      <div class="panel-header">Telemetry</div>
      <div class="panel-body">
        <div class="empty">No active streams</div>
      </div>
    </div>

  </div>

  <div class="atlas">
    System stable
  </div>

</body>
</html>
  `);
});

async function bootstrap() {
  try {
    initializeCanonicalPackageSchema();
    app.locals.canonicalPackageSchemaReady = true;
  } catch (err) {
    app.locals.canonicalPackageSchemaReady = false;
    console.error(
      "[bootstrap] Canonical Package schema initialization failed; " +
        "POST /api/matilda/canonical-package will reject requests until this is resolved:",
      err,
    );
  }

  const registryPath = pathToFileURL(
    path.resolve(
      process.cwd(),
      "server",
      "project-registry.mjs",
    ),
  ).href;

  const {
    mountProjectRegistryRoutes,
  } = await import(registryPath);

  mountProjectRegistryRoutes(app);

  const port = process.env.PORT || 3000;

  app.listen(port, () => {
    console.log(
      `Server listening on port ${port}`,
    );
  });
}

bootstrap();

export default app;

```

### server/matilda-chat-workflow.explicit-target.integration.test.ts

```text
import assert from "node:assert/strict";
import { createServer, type Server } from "node:http";
import {
  copyFileSync,
  mkdirSync,
  mkdtempSync,
  rmSync,
  symlinkSync,
} from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

import Database from "better-sqlite3";

const repositoryRoot = process.cwd();

function listen(server: Server): Promise<number> {
  return new Promise((resolve, reject) => {
    server.once("error", reject);

    server.listen(0, "127.0.0.1", () => {
      const address = server.address();

      if (!address || typeof address === "string") {
        reject(
          new Error(
            "Local Ollama stub did not expose a TCP port.",
          ),
        );
        return;
      }

      resolve(address.port);
    });
  });
}

function closeServer(server: Server): Promise<void> {
  return new Promise((resolve, reject) => {
    server.close((error) => {
      if (error) {
        reject(error);
        return;
      }

      resolve();
    });
  });
}

test(
  "real shared workflow persists a revision to an explicit non-active conversation without switching active context",
  async () => {
    const temporaryRoot = mkdtempSync(
      path.join(
        tmpdir(),
        "matilda-request-changes-workflow-",
      ),
    );

    const temporaryDbDirectory =
      path.join(temporaryRoot, "db");

    const temporaryServerDirectory =
      path.join(temporaryRoot, "server");

    mkdirSync(temporaryDbDirectory, {
      recursive: true,
    });

    mkdirSync(temporaryServerDirectory, {
      recursive: true,
    });

    /*
     * project-registry.mjs is dynamically imported from CWD by
     * the production workflow. Copy the standalone registry module
     * into the isolated fixture and expose the repository's installed
     * packages through a fixture-local node_modules symlink so normal
     * ESM package resolution remains available without using production
     * persistence.
     */
    copyFileSync(
      path.join(
        repositoryRoot,
        "server",
        "project-registry.mjs",
      ),
      path.join(
        temporaryServerDirectory,
        "project-registry.mjs",
      ),
    );

    symlinkSync(
      path.join(repositoryRoot, "node_modules"),
      path.join(temporaryRoot, "node_modules"),
      "dir",
    );

    let ollamaInvocationCount = 0;
    let latestOllamaRequestBody = "";

    const stub = createServer(
      (request, response) => {
        if (
          request.method !== "POST"
          || request.url !== "/api/generate"
        ) {
          response.statusCode = 404;
          response.end();
          return;
        }

        let body = "";

        request.setEncoding("utf8");

        request.on("data", (chunk) => {
          body += chunk;
        });

        request.on("end", () => {
          assert.ok(body.length > 0);

          ollamaInvocationCount += 1;
          latestOllamaRequestBody = body;

          const structuredResponse = {
            reply:
              "I incorporated the requested revision.",
            explanationStatus: "optional",
            selectedContextCandidatePositions: [],
            supportSourceReferences: [],
            evidence: null,
            investigationLifecycle: null,
            packageSemantics: {
              expectedOutcome:
                "Preserve the reviewed intent with the requested correction.",
              proposedWork:
                "Revise the reviewed interpretation using the supplied feedback.",
              proposedArtifacts: null,
              inScope:
                "The requested correction to the reviewed interpretation.",
              outOfScope:
                "Canonical approval and all downstream execution authority.",
              constraints:
                "Remain non-authoritative until separately approved.",
              unresolvedQuestions: null,
            },
            durableInterpretation:
              "The reviewed intent should incorporate the requested correction while remaining non-authoritative.",
          };

          response.writeHead(200, {
            "content-type": "application/json",
          });

          response.end(
            JSON.stringify({
              response:
                JSON.stringify(
                  structuredResponse,
                ),
              done: true,
            }),
          );
        });
      },
    );

    let database:
      Database.Database | null = null;

    try {
      const port = await listen(stub);

      process.env.OLLAMA_BASE_URL =
        `http://127.0.0.1:${port}`;

      process.chdir(temporaryRoot);

      const conversationRuntime =
        require(
          "../db/matilda-conversation-runtime",
        ) as typeof import(
          "../db/matilda-conversation-runtime"
        );

      const interpretationRuntime =
        require(
          "../db/matilda-interpretation-runtime",
        ) as typeof import(
          "../db/matilda-interpretation-runtime"
        );

      const workflowRuntime =
        require(
          "./matilda-chat-workflow",
        ) as typeof import(
          "./matilda-chat-workflow"
        );

      const historicalObservationRuntime =
        require(
          "../db/atlas-historical-observation-persistence",
        ) as typeof import(
          "../db/atlas-historical-observation-persistence"
        );

      const historicalObservationAdapter =
        require(
          "./atlas/atlas-historical-observation-adapter",
        ) as typeof import(
          "./atlas/atlas-historical-observation-adapter"
        );

      const preexecutionObservationAggregator =
        require(
          "./atlas/atlas-preexecution-observation-aggregator",
        ) as typeof import(
          "./atlas/atlas-preexecution-observation-aggregator"
        );

      const {
        readAtlasHistoricalObservations,
      } = historicalObservationRuntime;

      const {
        readAtlasHistoricalTypedObservations,
      } = historicalObservationAdapter;

      const {
        readAtlasTypedPreexecutionObservations,
      } = preexecutionObservationAggregator;

      const activeConversation =
        conversationRuntime
          .getOrCreateActiveMatildaConversation(
            "hq",
          );

      const explicitTargetConversation =
        conversationRuntime
          .createMatildaConversation(
            "hq",
          );

      conversationRuntime
        .setActiveMatildaConversation(
          "hq",
          activeConversation.conversation_id,
        );

      assert.notEqual(
        explicitTargetConversation.conversation_id,
        activeConversation.conversation_id,
      );

      assert.equal(
        conversationRuntime
          .getOrCreateActiveMatildaConversation(
            "hq",
          )
          .conversation_id,
        activeConversation.conversation_id,
      );

      const beforeTargetEntries =
        interpretationRuntime
          .listInterpretationEvidenceLedgerEntries(
            100,
            {
              projectId: "hq",
              conversationId:
                explicitTargetConversation
                  .conversation_id,
            },
          );

      const beforeTargetTurns =
        conversationRuntime
          .listMatildaConversationTurns(
            "hq",
            100,
            explicitTargetConversation
              .conversation_id,
          );

      assert.equal(
        beforeTargetEntries.length,
        0,
      );

      assert.equal(
        beforeTargetTurns.length,
        0,
      );

      database = new Database(
        path.join(
          temporaryRoot,
          "db",
          "main.db",
        ),
      );

      const backfillConversation =
        conversationRuntime
          .createMatildaConversation(
            "hq",
          );

      conversationRuntime
        .setActiveMatildaConversation(
          "hq",
          activeConversation.conversation_id,
        );

      assert.equal(
        conversationRuntime
          .getOrCreateActiveMatildaConversation(
            "hq",
          )
          .conversation_id,
        activeConversation.conversation_id,
      );

      database.exec(`
        CREATE TABLE IF NOT EXISTS matilda_canonical_packages (
          package_id TEXT NOT NULL,
          package_version INTEGER NOT NULL CHECK (package_version >= 1),
          summary_id TEXT NOT NULL,
          draft_package_id TEXT NOT NULL,
          draft_revision_id TEXT,
          lineage_id TEXT NOT NULL,
          project_id TEXT,
          conversation_id TEXT,
          approved_interpretation TEXT NOT NULL,
          approved_work TEXT,
          approved_artifacts TEXT,
          approved_scope TEXT,
          approved_constraints TEXT,
          approved_expected_outcome TEXT,
          approval_actor TEXT NOT NULL,
          approval_timestamp TEXT NOT NULL,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL,
          PRIMARY KEY (package_id, package_version)
        );
      `);

      database.exec(`
        CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger (
          entry_id TEXT PRIMARY KEY,
          created_at TEXT NOT NULL,
          actor TEXT NOT NULL,
          project_id TEXT NOT NULL,
          conversation_id TEXT,
          interpretation_event TEXT NOT NULL,
          minimum_sufficient_context TEXT NOT NULL,
          supporting_raw_evidence TEXT NOT NULL,
          matilda_observation TEXT NOT NULL,
          unresolved_questions TEXT,
          lineage_references TEXT,
          supersession_status TEXT NOT NULL
        );
      `);

      const insertLedger =
        database.prepare(`
          INSERT INTO matilda_interpretation_evidence_ledger (
            entry_id,
            created_at,
            actor,
            project_id,
            conversation_id,
            interpretation_event,
            minimum_sufficient_context,
            supporting_raw_evidence,
            matilda_observation,
            unresolved_questions,
            lineage_references,
            supersession_status
          ) VALUES (
            ?,
            ?,
            'matilda',
            'hq',
            ?,
            'Backfill regression fixture',
            'fixture',
            ?,
            ?,
            NULL,
            NULL,
            ?
          )
        `);

      const insertTurn =
        database.prepare(`
          INSERT INTO matilda_conversation_turns (
            turn_id,
            project_id,
            conversation_id,
            user_message,
            assistant_reply,
            interpretation_entry_id,
            project_context_evidence_trace_json,
            created_at
          ) VALUES (
            ?,
            'hq',
            ?,
            ?,
            ?,
            ?,
            NULL,
            ?
          )
        `);

      for (
        let index = 1;
        index <= 40;
        index += 1
      ) {
        const suffix =
          String(index).padStart(3, "0");

        const createdAt =
          `2026-09-16T00:00:${String(index).padStart(2, "0")}.000Z`;

        const entryId =
          `backfill-iel-${suffix}`;

        const turnId =
          `backfill-turn-${suffix}`;

        const isRecentIneligible =
          index > 20;

        const supportPayload =
          JSON.stringify({
            supportSourceReferences: [],
            evidenceSufficient: true,
          });

        insertLedger.run(
          entryId,
          createdAt,
          backfillConversation.conversation_id,
          supportPayload,
          `Backfill interpretation ${suffix}`,
          isRecentIneligible
            ? "superseded"
            : "current",
        );

        insertTurn.run(
          turnId,
          backfillConversation.conversation_id,
          `Backfill user ${suffix}`,
          `Backfill assistant ${suffix}`,
          entryId,
          createdAt,
        );
      }

      const ollamaBeforeBackfill =
        ollamaInvocationCount;

      const backfillResult =
        await workflowRuntime
          .runMatildaConversationWorkflow({
            message:
              "Use the eligible conversation history.",
            agent: "matilda",
            project_id: "hq",
            conversation_id:
              backfillConversation
                .conversation_id,
          });

      assert.equal(
        ollamaInvocationCount
          - ollamaBeforeBackfill,
        1,
      );

      assert.equal(
        backfillResult.turn.conversation_id,
        backfillConversation
          .conversation_id,
      );

      assert.ok(
        latestOllamaRequestBody.includes(
          "Backfill user 001",
        ),
      );

      assert.ok(
        latestOllamaRequestBody.includes(
          "Backfill user 020",
        ),
      );

      assert.equal(
        latestOllamaRequestBody.includes(
          "Backfill user 021",
        ),
        false,
      );

      assert.equal(
        latestOllamaRequestBody.includes(
          "Backfill user 040",
        ),
        false,
      );

      const firstEligibleIndex =
        latestOllamaRequestBody.indexOf(
          "Backfill user 001",
        );

      const lastEligibleIndex =
        latestOllamaRequestBody.indexOf(
          "Backfill user 020",
        );

      assert.ok(firstEligibleIndex >= 0);
      assert.ok(lastEligibleIndex > firstEligibleIndex);

      const backfillTurnCount =
        database
          .prepare(`
            SELECT COUNT(*) AS count
            FROM matilda_conversation_turns
            WHERE project_id = 'hq'
              AND conversation_id = ?
          `)
          .get(
            backfillConversation
              .conversation_id,
          ) as {
            count: number;
          };

      assert.equal(
        backfillTurnCount.count,
        41,
      );

      const result =
        await workflowRuntime
          .runMatildaConversationWorkflow({
            message:
              "Please revise the reviewed interpretation.",
            agent: "matilda",
            project_id: "hq",
            conversation_id:
              explicitTargetConversation
                .conversation_id,
          });

      assert.equal(
        result.canonical_package_created,
        false,
      );

      assert.equal(
        result.delegation_authorized,
        false,
      );

      assert.equal(
        result.validation_authorized,
        false,
      );

      assert.equal(
        result.envelope_authorized,
        false,
      );

      assert.equal(
        result.execution_authorized,
        false,
      );

      assert.equal(
        result.draft_package_updated,
        true,
      );

      assert.equal(
        result.turn.conversation_id,
        explicitTargetConversation
          .conversation_id,
      );

      const afterTargetEntries =
        interpretationRuntime
          .listInterpretationEvidenceLedgerEntries(
            100,
            {
              projectId: "hq",
              conversationId:
                explicitTargetConversation
                  .conversation_id,
            },
          );

      const afterTargetTurns =
        conversationRuntime
          .listMatildaConversationTurns(
            "hq",
            100,
            explicitTargetConversation
              .conversation_id,
          );

      assert.equal(
        afterTargetEntries.length,
        1,
      );

      assert.equal(
        afterTargetTurns.length,
        1,
      );

      assert.equal(
        afterTargetEntries[0]
          ?.conversation_id,
        explicitTargetConversation
          .conversation_id,
      );

      assert.equal(
        afterTargetTurns[0]
          ?.user_message,
        "Please revise the reviewed interpretation.",
      );

      assert.equal(
        conversationRuntime
          .getOrCreateActiveMatildaConversation(
            "hq",
          )
          .conversation_id,
        activeConversation.conversation_id,
      );

      const draft =
        database
          .prepare(`
            SELECT
              draft_package_id,
              lineage_id,
              project_id,
              conversation_id,
              current_interpretation,
              proposed_work,
              expected_outcome,
              status,
              evidence_entry_ids
            FROM matilda_living_draft_packages
            WHERE draft_package_id = ?
            LIMIT 1
          `)
          .get(
            `matilda-draft-${explicitTargetConversation.conversation_id}`,
          ) as
          | {
              draft_package_id: string;
              lineage_id: string;
              project_id: string;
              conversation_id: string | null;
              current_interpretation: string;
              proposed_work: string | null;
              expected_outcome: string | null;
              status: string;
              evidence_entry_ids: string;
            }
          | undefined;

      assert.ok(draft);

      assert.equal(
        draft.project_id,
        "hq",
      );

      assert.equal(
        draft.conversation_id,
        explicitTargetConversation
          .conversation_id,
      );

      assert.equal(
        draft.status,
        "draft_non_authoritative",
      );

      assert.equal(
        draft.current_interpretation,
        "The reviewed intent should incorporate the requested correction while remaining non-authoritative.",
      );

      assert.equal(
        draft.expected_outcome,
        "Preserve the reviewed intent with the requested correction.",
      );

      assert.equal(
        draft.proposed_work,
        "Revise the reviewed interpretation using the supplied feedback.",
      );

      const evidenceIds =
        JSON.parse(
          draft.evidence_entry_ids,
        ) as string[];

      assert.equal(
        evidenceIds.length,
        1,
      );

      assert.equal(
        evidenceIds[0],
        afterTargetEntries[0]
          ?.entry_id,
      );

      const historicalRecords =
        readAtlasHistoricalObservations(
          "hq",
          database,
        );

      const targetHistoricalRecords =
        historicalRecords.filter(
          (observation) =>
            observation.conversationId ===
            explicitTargetConversation.conversation_id,
        );

      const historicalInterpretationEvidence =
        targetHistoricalRecords.filter(
          (observation) =>
            observation.sourceKind ===
            "interpretation_evidence",
        );

      const historicalLivingDrafts =
        targetHistoricalRecords.filter(
          (observation) =>
            observation.sourceKind ===
            "living_draft",
        );

      assert.equal(
        historicalInterpretationEvidence.length,
        1,
      );

      assert.ok(
        historicalLivingDrafts.length >= 1,
      );

      assert.equal(
        historicalInterpretationEvidence[0]
          ?.authorityStatus,
        "matilda_authored_interpretive_evidence",
      );

      assert.ok(
        historicalLivingDrafts.every(
          (observation) =>
            observation.authorityStatus ===
            "non_authoritative" &&
            observation.conversationId ===
            explicitTargetConversation.conversation_id,
        ),
      );

      const databasePath =
        path.join(
          temporaryRoot,
          "db",
          "main.db",
        );

      const typedHistorical =
        readAtlasHistoricalTypedObservations(
          "hq",
          databasePath,
        ).filter(
          (observation) =>
            observation.observation.conversationId ===
            explicitTargetConversation.conversation_id,
        );

      assert.equal(
        typedHistorical.filter(
          (observation) =>
            observation.observationKind ===
            "interpretation_evidence",
        ).length,
        1,
      );

      assert.ok(
        typedHistorical
          .filter(
            (observation) =>
              observation.observationKind ===
              "living_draft",
          )
          .every(
            (observation) =>
              observation.authorityStatus ===
              "non_authoritative",
          ),
      );

      const merged =
        readAtlasTypedPreexecutionObservations({
          projectId: "hq",
          conversationId:
            explicitTargetConversation.conversation_id,
          databasePath,
        });

      const mergedInterpretationEvidence =
        merged.filter(
          (observation) =>
            observation.sourceKind ===
              "interpretation_evidence" &&
            observation.payload.entryId ===
              afterTargetEntries[0]?.entry_id,
        );

      assert.equal(
        mergedInterpretationEvidence.length,
        1,
      );

      const mergedDrafts =
        merged.filter(
          (observation) =>
            observation.sourceKind ===
              "living_draft" &&
            observation.payload.draftPackageId ===
              draft.draft_package_id,
        );

      const mergedDraftRevisionKeys =
        mergedDrafts.map(
          (observation) =>
            `${observation.payload.draftPackageId}\u0000${observation.payload.updatedAt}`,
        );

      assert.equal(
        new Set(mergedDraftRevisionKeys).size,
        mergedDraftRevisionKeys.length,
      );

      const chronological =
        merged.map(
          (observation) =>
            observation.observedAt,
        );

      assert.deepEqual(
        chronological,
        [...chronological].sort(),
      );

      const activeDraftCount =
        database
          .prepare(`
            SELECT COUNT(*) AS count
            FROM matilda_living_draft_packages
            WHERE conversation_id = ?
          `)
          .get(
            activeConversation
              .conversation_id,
          ) as {
            count: number;
          };

      assert.equal(
        activeDraftCount.count,
        0,
      );

      const canonicalTable =
        database
          .prepare(`
            SELECT name
            FROM sqlite_master
            WHERE type = 'table'
              AND name = 'matilda_canonical_packages'
            LIMIT 1
          `)
          .get() as
          | { name: string }
          | undefined;

      if (canonicalTable) {
        const canonicalCount =
          database
            .prepare(`
              SELECT COUNT(*) AS count
              FROM matilda_canonical_packages
            `)
            .get() as {
              count: number;
            };

        assert.equal(
          canonicalCount.count,
          0,
        );
      }
    } finally {
      database?.close();

      process.chdir(repositoryRoot);

      delete process.env.OLLAMA_BASE_URL;

      await closeServer(stub)
        .catch(() => undefined);

      rmSync(
        temporaryRoot,
        {
          recursive: true,
          force: true,
        },
      );
    }
  },
);

```

### server/routes/governance-delegation-route.ts

```text

import express from "express";

import {

  consumeProductionDelegationEntryPoint,

  type ProductionDelegationConsumerInput,

  type ProductionDelegationConsumerResult,

} from "../delegation/production-delegation-consumer";

import type {

  GovernanceDelegationPersistenceFunction,

} from "../delegation/production-delegation-entry-point";

export type GovernanceDelegationRouteBody = {

  delegation_id?: unknown;

  project_id?: unknown;

  package_id?: unknown;

  package_version?: unknown;

  authorization_state?: unknown;

  authorization_timestamp?: unknown;

  delegated_by?: unknown;

};

export type GovernanceDelegationRouteOptions = {

  create_governance_delegation?: GovernanceDelegationPersistenceFunction;

};

export type GovernanceDelegationRouteRequest = ProductionDelegationConsumerInput;

export type GovernanceDelegationRouteResult =

  | {

      ok: true;

      route: "governance_delegation_route";

      delegation: Extract<ProductionDelegationConsumerResult, { ok: true }>;

      endpoint_authorized: true;

      scheduler_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      routing_authorized: false;

      assignment_authorized: false;

      lifecycle_transition_authorized: false;

      execution_authorized: false;

      downstream_governance_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    }

  | {

      ok: false;

      route: "governance_delegation_route";

      delegation?: ProductionDelegationConsumerResult;

      endpoint_authorized: true;

      scheduler_authorized: false;

      worker_claim_authorized: false;

      orchestration_authorized: false;

      routing_authorized: false;

      assignment_authorized: false;

      lifecycle_transition_authorized: false;

      execution_authorized: false;

      downstream_governance_authorized: false;

      new_authority_introduced: false;

      findings: string[];

    };

function normalizeText(value: unknown): string {

  return typeof value === "string" ? value : "";

}

function normalizeOptionalText(value: unknown): string | null {

  return typeof value === "string" && value.length > 0 ? value : null;

}

function normalizePackageVersion(value: unknown): number {

  return typeof value === "number" && Number.isInteger(value) ? value : 0;

}

export function buildGovernanceDelegationRouteRequest(

  body: GovernanceDelegationRouteBody = {},

  options: GovernanceDelegationRouteOptions = {},

): GovernanceDelegationRouteRequest {

  return {

    delegation_id: normalizeText(body.delegation_id),

    project_id: normalizeText(body.project_id),

    package_id: normalizeText(body.package_id),

    package_version: normalizePackageVersion(body.package_version),

    authorization_state: normalizeText(body.authorization_state),

    authorization_timestamp: normalizeOptionalText(body.authorization_timestamp),

    delegated_by: normalizeText(body.delegated_by),

    create_governance_delegation: options.create_governance_delegation,

  };

}

export function handleGovernanceDelegationRouteRequest(

  body: GovernanceDelegationRouteBody = {},

  options: GovernanceDelegationRouteOptions = {},

): GovernanceDelegationRouteResult {

  const delegationResult = consumeProductionDelegationEntryPoint(

    buildGovernanceDelegationRouteRequest(body, options),

  );

  if (!delegationResult.ok) {

    return {

      ok: false,

      route: "governance_delegation_route",

      delegation: delegationResult,

      endpoint_authorized: true,

      scheduler_authorized: false,

      worker_claim_authorized: false,

      orchestration_authorized: false,

      routing_authorized: false,

      assignment_authorized: false,

      lifecycle_transition_authorized: false,

      execution_authorized: false,

      downstream_governance_authorized: false,

      new_authority_introduced: false,

      findings: [

        "Governance Delegation route failed closed because the production Delegation consumer rejected the request.",

      ],

    };

  }

  return {

    ok: true,

    route: "governance_delegation_route",

    delegation: delegationResult,

    endpoint_authorized: true,

    scheduler_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    routing_authorized: false,

    assignment_authorized: false,

    lifecycle_transition_authorized: false,

    execution_authorized: false,

    downstream_governance_authorized: false,

    new_authority_introduced: false,

    findings: [

      "Governance Delegation route invoked the production Delegation consumer without scheduler, worker, orchestration, routing, assignment, lifecycle transition, execution, downstream governance, or new authority.",

    ],

  };

}

export function createGovernanceDelegationRouter(

  options: GovernanceDelegationRouteOptions = {},

): express.Router {

  const router = express.Router();

  router.post("/api/governance/delegation", (req, res) => {

    const result = handleGovernanceDelegationRouteRequest(

      req.body || {},

      options,

    );

    return res.status(result.ok ? 200 : 400).json(result);

  });

  return router;

}

export default createGovernanceDelegationRouter();


```

## Classification

IMPLEMENTATION_AUTHORIZED=YES
PRODUCT_CODE_MUTATION_PERFORMED=NO
SERVER_IMPLEMENTATION_SURFACE_CAPTURED=YES
NEXT_ACTION=IMPLEMENT_BOUNDED_EXECUTIVE_DELEGATION_DECISION_ADAPTER
