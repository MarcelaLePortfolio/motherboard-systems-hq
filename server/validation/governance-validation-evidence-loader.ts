import Database from "better-sqlite3";

import {
  createGovernanceValidationDelegationLoader,
  type GovernanceValidationDelegationLoader,
  type GovernanceValidationDelegationReadRecord,
} from "../../db/governance-validation-read-repository.js";

import {
  assertValidationEligible,
} from "../../db/governance-lifecycle-enforcement.js";

import {
  loadExactGovernanceValidationPackage,
  type GovernanceValidationPackageSemantics,
} from "./governance-validation-package-read-repository.js";

export type GovernanceValidationEvidenceIdentity = {
  delegation_id: string;
  package_id: string;
  package_version: number;
};

export type GovernanceValidationEvidence = {
  delegation: GovernanceValidationDelegationReadRecord;
  package: GovernanceValidationPackageSemantics;
};

export type GovernanceValidationEvidenceLoaderOptions = {
  database_path?: string;
  load_exact_governance_delegation?: GovernanceValidationDelegationLoader;
};

export function loadGovernanceValidationEvidence(
  identity: GovernanceValidationEvidenceIdentity,
  options: GovernanceValidationEvidenceLoaderOptions = {},
): GovernanceValidationEvidence {
  const databasePath = options.database_path ?? "db/main.db";

  const loadExactGovernanceDelegation =
    options.load_exact_governance_delegation ??
    createGovernanceValidationDelegationLoader(databasePath);

  const delegation = loadExactGovernanceDelegation(identity);

  assertValidationEligible({ delegation });

  const db = new Database(databasePath, {
    readonly: true,
    fileMustExist: true,
  });

  try {
    const packageSemantics = loadExactGovernanceValidationPackage(db, {
      project_id: delegation.project_id,
      package_id: identity.package_id,
      package_version: identity.package_version,
    });

    return {
      delegation,
      package: packageSemantics,
    };
  } finally {
    db.close();
  }
}
