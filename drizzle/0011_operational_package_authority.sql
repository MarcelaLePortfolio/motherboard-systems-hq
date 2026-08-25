CREATE TABLE operational_package_authority (
  project_id TEXT PRIMARY KEY NOT NULL,
  package_id TEXT NOT NULL,
  package_version INTEGER NOT NULL,
  selected_at TEXT NOT NULL,
  FOREIGN KEY (project_id)
    REFERENCES project_registry(project_id),
  FOREIGN KEY (project_id, package_id, package_version)
    REFERENCES matilda_canonical_packages(project_id, package_id, package_version)
);
