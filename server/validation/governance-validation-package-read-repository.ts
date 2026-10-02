import type { Database } from "better-sqlite3";

export interface GovernanceValidationPackageIdentity {
  project_id: string;
  package_id: string;
  package_version: number;
}

export interface GovernanceValidationPackageSemantics {
  project_id: string;
  package_id: string;
  package_version: number;
  requested_outcome: string;
  scope: string;
  constraints: string;
  success_criteria: string;
}

function requireIdentityText(value: string, field: string): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(`Governance Validation ${field} is required.`);
  }

  return normalized;
}

export function loadExactGovernanceValidationPackage(
  db: Database,
  identity: GovernanceValidationPackageIdentity,
): GovernanceValidationPackageSemantics {
  const project_id = requireIdentityText(identity.project_id, "project_id");
  const package_id = requireIdentityText(identity.package_id, "package_id");

  if (
    !Number.isInteger(identity.package_version)
    || identity.package_version < 1
  ) {
    throw new Error(
      "Governance Validation package_version must be a positive integer.",
    );
  }

  const row = db.prepare(`
    SELECT
      project_id,
      package_id,
      package_version,
      requested_outcome,
      scope,
      constraints,
      success_criteria
    FROM governance_packages
    WHERE project_id = ?
      AND package_id = ?
      AND package_version = ?
    LIMIT 2
  `).all(
    project_id,
    package_id,
    identity.package_version,
  ) as GovernanceValidationPackageSemantics[];

  if (row.length !== 1) {
    throw new Error(
      "Governance Validation Package was not found or ambiguous for the exact project/package/version identity.",
    );
  }

  const exact = row[0];

  if (
    exact.project_id !== project_id
    || exact.package_id !== package_id
    || exact.package_version !== identity.package_version
  ) {
    throw new Error(
      "Governance Validation Package identity did not match the requested exact identity.",
    );
  }

  return exact;
}
