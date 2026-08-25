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
