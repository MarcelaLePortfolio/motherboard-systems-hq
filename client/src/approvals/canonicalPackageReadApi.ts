export type CanonicalPackageDelegationState =
  | {
      state: "awaiting_delegation";
      delegation_id: null;
      authorization_state: null;
      authorization_timestamp: null;
      delegated_by: null;
    }
  | {
      state: "delegated";
      delegation_id: string;
      authorization_state: "AUTHORIZED";
      authorization_timestamp: string;
      delegated_by: string;
    }
  | {
      state: "ambiguous";
      delegation_id: null;
      authorization_state: null;
      authorization_timestamp: null;
      delegated_by: null;
    };

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
  delegation: CanonicalPackageDelegationState;
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
