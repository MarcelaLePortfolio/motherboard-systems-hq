import type { Database } from "better-sqlite3";

export type RegisteredProjectRepository = {
  projectId: string;
  projectRootPath: string;
  gitRepositoryReference: string;
  registrationStatus: string;
  availabilityStatus: string;
};

type StatusError = Error & {
  statusCode?: number;
};

function createStatusError(
  message: string,
  statusCode: number,
): StatusError {
  const error = new Error(message) as StatusError;
  error.statusCode = statusCode;
  return error;
}

export function resolveRegisteredProjectRepository(
  db: Database,
  projectId: string,
): RegisteredProjectRepository {
  const normalizedProjectId = String(projectId || "").trim();

  if (!normalizedProjectId) {
    throw createStatusError("projectId is required.", 400);
  }

  const projects = db.prepare(`
    SELECT
      project_id AS projectId,
      project_root_path AS projectRootPath,
      git_repository_reference AS gitRepositoryReference,
      registration_status AS registrationStatus,
      availability_status AS availabilityStatus
    FROM project_registry
    WHERE project_id = ?
      AND registration_status = 'registered'
      AND availability_status = 'available'
    LIMIT 2
  `).all(normalizedProjectId) as RegisteredProjectRepository[];

  if (projects.length !== 1) {
    throw createStatusError(
      "Project is not uniquely registered and available for governed repository resolution.",
      404,
    );
  }

  const resolved = projects[0];
  const projectRootPath = String(resolved.projectRootPath || "").trim();
  const gitRepositoryReference = String(
    resolved.gitRepositoryReference || "",
  ).trim();

  if (!projectRootPath || !gitRepositoryReference) {
    throw createStatusError(
      "Registered project is missing authoritative repository identity.",
      409,
    );
  }

  return {
    projectId: resolved.projectId,
    projectRootPath,
    gitRepositoryReference,
    registrationStatus: resolved.registrationStatus,
    availabilityStatus: resolved.availabilityStatus,
  };
}
