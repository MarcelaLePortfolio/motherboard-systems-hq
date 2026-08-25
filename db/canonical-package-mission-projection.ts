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
