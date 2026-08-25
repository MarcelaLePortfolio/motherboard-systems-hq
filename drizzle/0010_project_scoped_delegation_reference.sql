PRAGMA foreign_keys = OFF;

CREATE UNIQUE INDEX IF NOT EXISTS idx_matilda_canonical_packages_project_package_version
ON matilda_canonical_packages(project_id, package_id, package_version);

ALTER TABLE governance_delegations
RENAME TO governance_delegations_pre_project_scope;

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

INSERT INTO governance_delegations (
  delegation_id,
  project_id,
  package_id,
  package_version,
  authorization_state,
  authorization_timestamp,
  delegated_by,
  created_at
)
SELECT
  legacy.delegation_id,
  canonical.project_id,
  legacy.package_id,
  legacy.package_version,
  legacy.authorization_state,
  legacy.authorization_timestamp,
  legacy.delegated_by,
  legacy.created_at
FROM governance_delegations_pre_project_scope AS legacy
LEFT JOIN matilda_canonical_packages AS canonical
  ON canonical.package_id = legacy.package_id
 AND canonical.package_version = legacy.package_version;

DROP TABLE governance_delegations_pre_project_scope;

PRAGMA foreign_keys = ON;
