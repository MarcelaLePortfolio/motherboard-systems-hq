
import { execFileSync } from "node:child_process";

import fs from "fs";

import path from "path";

import Database from "better-sqlite3";

const dbPath = path.join(process.cwd(), "db", "main.db");

const seedPath = path.join(process.cwd(), "projects", "registry.example.json");

const db = new Database(dbPath);

function nowIso() {

  return new Date().toISOString();

}

function normalizeProjectId(value) {

  return String(value || "").trim();

}

function resolveProjectPathForValidation(projectRootPath) {

  const candidate = String(projectRootPath || "").trim();

  if (!candidate) return null;

  return path.isAbsolute(candidate)

    ? candidate

    : path.resolve(process.cwd(), candidate);

}

function validateExistingGitRepository(projectRootPath) {

  const resolvedPath = resolveProjectPathForValidation(projectRootPath);

  if (!resolvedPath || !fs.existsSync(resolvedPath)) {

    const error = new Error("Project root path does not exist.");

    error.statusCode = 400;

    throw error;

  }

  const stat = fs.statSync(resolvedPath);

  if (!stat.isDirectory()) {

    const error = new Error("Project root path must be a directory.");

    error.statusCode = 400;

    throw error;

  }

  if (!fs.existsSync(path.join(resolvedPath, ".git"))) {

    const error = new Error("Project root path must be a Git repository.");

    error.statusCode = 400;

    throw error;

  }

  return resolvedPath;

}

export function ensureProjectRegistry() {

  db.exec(`

    CREATE TABLE IF NOT EXISTS project_registry (

      project_id TEXT PRIMARY KEY,

      display_name TEXT NOT NULL,

      project_root_path TEXT,

      git_repository_reference TEXT,

      registration_status TEXT NOT NULL DEFAULT 'registered',

      availability_status TEXT NOT NULL DEFAULT 'available',

      active_context_eligible INTEGER NOT NULL DEFAULT 1,

      created_at TEXT NOT NULL,

      updated_at TEXT NOT NULL,

      last_opened_at TEXT

    );

    CREATE TABLE IF NOT EXISTS active_context (

      singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),

      current_project_id TEXT NOT NULL,

      source TEXT NOT NULL DEFAULT 'system',

      action TEXT NOT NULL DEFAULT 'seed',

      updated_at TEXT NOT NULL,

      FOREIGN KEY (current_project_id) REFERENCES project_registry(project_id)

    );

  `);

  const projectCount = db.prepare("SELECT COUNT(*) AS count FROM project_registry").get().count;

  if (projectCount === 0 && fs.existsSync(seedPath)) {

    const seed = JSON.parse(fs.readFileSync(seedPath, "utf8"));

    const timestamp = nowIso();

    const insert = db.prepare(`

      INSERT INTO project_registry (

        project_id,

        display_name,

        project_root_path,

        git_repository_reference,

        registration_status,

        availability_status,

        active_context_eligible,

        created_at,

        updated_at,

        last_opened_at

      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)

    `);

    for (const project of seed.projects || []) {

      insert.run(

        project.id,

        project.name,

        project.repoPath || null,

        project.repoPath || null,

        "registered",

        "available",

        1,

        timestamp,

        timestamp,

        project.id === seed.activeProjectId ? timestamp : null

      );

    }

    if (seed.activeProjectId) {

      db.prepare(`

        INSERT OR REPLACE INTO active_context (

          singleton_id,

          current_project_id,

          source,

          action,

          updated_at

        ) VALUES (1, ?, 'seed', 'initialize_active_context', ?)

      `).run(seed.activeProjectId, timestamp);

    }

  }

  const active = db.prepare("SELECT current_project_id FROM active_context WHERE singleton_id = 1").get();

  if (!active) {

    const fallback = db.prepare(`

      SELECT project_id

      FROM project_registry

      WHERE active_context_eligible = 1

      ORDER BY last_opened_at DESC NULLS LAST, created_at ASC

      LIMIT 1

    `).get();

    if (fallback?.project_id) {

      db.prepare(`

        INSERT OR REPLACE INTO active_context (

          singleton_id,

          current_project_id,

          source,

          action,

          updated_at

        ) VALUES (1, ?, 'system', 'fallback_active_context', ?)

      `).run(fallback.project_id, nowIso());

    }

  }

}

export function getProjectRegistryState() {

  ensureProjectRegistry();

  const projects = db.prepare(`

    SELECT

      project_id AS projectId,

      display_name AS displayName,

      project_root_path AS projectRootPath,

      git_repository_reference AS gitRepositoryReference,

      registration_status AS registrationStatus,

      availability_status AS availabilityStatus,

      active_context_eligible AS activeContextEligible,

      created_at AS createdAt,

      updated_at AS updatedAt,

      last_opened_at AS lastOpenedAt

    FROM project_registry

    ORDER BY last_opened_at DESC NULLS LAST, display_name ASC

  `).all();

  const activeContext = db.prepare(`

    SELECT

      current_project_id AS currentProjectId,

      source,

      action,

      updated_at AS updatedAt

    FROM active_context

    WHERE singleton_id = 1

  `).get();

  return {

    activeProjectId: activeContext?.currentProjectId || null,

    activeProject: projects.find((project) => project.projectId === activeContext?.currentProjectId) || null,

    activeContext: activeContext || null,

    projects

  };

}

export function inspectProjectPath(projectRootPath) {

  const inputPath = String(projectRootPath || "").trim();

  const resolvedPath = resolveProjectPathForValidation(inputPath);

  if (!inputPath) {

    return {

      ok: false,

      inputPath,

      resolvedPath: null,

      projectDirectoryName: null,

      exists: false,

      isDirectory: false,

      isGitRepository: false,

      message: "Enter a project root path."

    };

  }

  if (!resolvedPath || !fs.existsSync(resolvedPath)) {

    return {

      ok: false,

      inputPath,

      resolvedPath,

      projectDirectoryName: resolvedPath ? path.basename(resolvedPath) : null,

      exists: false,

      isDirectory: false,

      isGitRepository: false,

      message: "Project root path does not exist."

    };

  }

  const stat = fs.statSync(resolvedPath);

  const isDirectory = stat.isDirectory();

  const isGitRepository = isDirectory && fs.existsSync(path.join(resolvedPath, ".git"));

  return {

    ok: Boolean(isDirectory && isGitRepository),

    inputPath,

    resolvedPath,

    projectDirectoryName: path.basename(resolvedPath),

    exists: true,

    isDirectory,

    isGitRepository,

    message: !isDirectory

      ? "Project root path must be a directory."

      : !isGitRepository

        ? "Project root path must be a Git repository."

        : "Ready to register."

  };

}

export function registerProject(projectInput = {}, metadata = {}) {

  ensureProjectRegistry();

  const projectId = normalizeProjectId(projectInput.projectId || projectInput.id);

  const displayName = String(projectInput.displayName || projectInput.name || "").trim();

  const projectRootPath = String(projectInput.projectRootPath || projectInput.projectRootReference || projectInput.repoPath || "").trim();

  const gitRepositoryReference = String(projectInput.gitRepositoryReference || projectInput.repoPath || projectRootPath || "").trim();

  if (!projectId) {

    const error = new Error("projectId is required.");

    error.statusCode = 400;

    throw error;

  }

  if (!displayName) {

    const error = new Error("displayName is required.");

    error.statusCode = 400;

    throw error;

  }

  if (!projectRootPath) {

    const error = new Error("projectRootPath is required.");

    error.statusCode = 400;

    throw error;

  }

  validateExistingGitRepository(projectRootPath);

  const duplicatePath = db.prepare(`

    SELECT project_id

    FROM project_registry

    WHERE project_root_path = ?

      AND project_id != ?

      AND registration_status = 'registered'

  `).get(projectRootPath, projectId);

  if (duplicatePath) {

    const error = new Error("A registered project already uses this projectRootPath.");

    error.statusCode = 409;

    throw error;

  }

  const timestamp = nowIso();

  db.prepare(`

    INSERT INTO project_registry (

      project_id,

      display_name,

      project_root_path,

      git_repository_reference,

      registration_status,

      availability_status,

      active_context_eligible,

      created_at,

      updated_at,

      last_opened_at

    ) VALUES (?, ?, ?, ?, 'registered', 'available', 1, ?, ?, NULL)

    ON CONFLICT(project_id) DO UPDATE SET

      display_name = excluded.display_name,

      project_root_path = excluded.project_root_path,

      git_repository_reference = excluded.git_repository_reference,

      registration_status = excluded.registration_status,

      availability_status = excluded.availability_status,

      active_context_eligible = excluded.active_context_eligible,

      updated_at = excluded.updated_at

  `).run(

    projectId,

    displayName,

    projectRootPath,

    gitRepositoryReference || projectRootPath,

    timestamp,

    timestamp

  );

  return getProjectRegistryState();

}

export function createNewProject(projectInput = {}, metadata = {}) {

  ensureProjectRegistry();

  const parentDirectoryInput = String(
    projectInput.parentDirectory || projectInput.parentPath || ""
  ).trim();

  const projectDirectoryName = String(
    projectInput.projectDirectoryName || projectInput.directoryName || ""
  ).trim();

  if (!parentDirectoryInput) {

    const error = new Error("parentDirectory is required.");

    error.statusCode = 400;

    throw error;

  }

  if (
    !projectDirectoryName
    || projectDirectoryName === "."
    || projectDirectoryName === ".."
    || path.basename(projectDirectoryName) !== projectDirectoryName
  ) {

    const error = new Error(
      "projectDirectoryName must be a single directory name."
    );

    error.statusCode = 400;

    throw error;

  }

  const resolvedParentDirectory =
    resolveProjectPathForValidation(parentDirectoryInput);

  if (
    !resolvedParentDirectory
    || !fs.existsSync(resolvedParentDirectory)
  ) {

    const error = new Error("Parent directory does not exist.");

    error.statusCode = 400;

    throw error;

  }

  const parentStat = fs.statSync(resolvedParentDirectory);

  if (!parentStat.isDirectory()) {

    const error = new Error("Parent path must be a directory.");

    error.statusCode = 400;

    throw error;

  }

  const targetPath = path.resolve(
    resolvedParentDirectory,
    projectDirectoryName
  );

  if (path.dirname(targetPath) !== path.resolve(resolvedParentDirectory)) {

    const error = new Error(
      "New project must be created directly inside the selected parent directory."
    );

    error.statusCode = 400;

    throw error;

  }

  if (fs.existsSync(targetPath)) {

    const error = new Error("Target project path already exists.");

    error.statusCode = 409;

    throw error;

  }

  const derivedProjectId = projectDirectoryName
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");

  const derivedDisplayName = projectDirectoryName
    .replace(/[-_]+/g, " ")
    .replace(/\b\w/g, (character) => character.toUpperCase());

  const projectId = normalizeProjectId(
    projectInput.projectId || projectInput.id || derivedProjectId
  );

  const displayName = String(
    projectInput.displayName || projectInput.name || derivedDisplayName
  ).trim();

  if (!projectId) {

    const error = new Error("projectId is required.");

    error.statusCode = 400;

    throw error;

  }

  if (!displayName) {

    const error = new Error("displayName is required.");

    error.statusCode = 400;

    throw error;

  }

  const duplicateProjectId = db.prepare(`
    SELECT project_id
    FROM project_registry
    WHERE project_id = ?
      AND registration_status = 'registered'
  `).get(projectId);

  if (duplicateProjectId) {

    const error = new Error("A registered project already uses this projectId.");

    error.statusCode = 409;

    throw error;

  }

  let createdTarget = false;

  try {

    fs.mkdirSync(targetPath);

    createdTarget = true;

    execFileSync("git", ["init"], {
      cwd: targetPath,
      stdio: "ignore",
      shell: false
    });

    validateExistingGitRepository(targetPath);

    return registerProject(
      {
        projectId,
        displayName,
        projectRootPath: targetPath,
        gitRepositoryReference: targetPath
      },
      {
        source: metadata.source || "dashboard",
        action: metadata.action || "create_project"
      }
    );

  } catch (error) {

    if (createdTarget && fs.existsSync(targetPath)) {

      fs.rmSync(targetPath, {
        recursive: true,
        force: true
      });

    }

    if (!error.statusCode) {

      error.statusCode = 500;

    }

    throw error;

  }

}

export function archiveProject(projectId, metadata = {}) {

  ensureProjectRegistry();

  const normalizedProjectId = normalizeProjectId(projectId);

  if (!normalizedProjectId) {

    const error = new Error("projectId is required.");

    error.statusCode = 400;

    throw error;

  }

  const activeContext = db.prepare(`

    SELECT current_project_id

    FROM active_context

    WHERE singleton_id = 1

  `).get();

  if (activeContext?.current_project_id === normalizedProjectId) {

    const error = new Error("Cannot archive the active project. Switch Active Context before archiving this project.");

    error.statusCode = 409;

    throw error;

  }

  const project = db.prepare(`

    SELECT project_id

    FROM project_registry

    WHERE project_id = ?

      AND registration_status = 'registered'

  `).get(normalizedProjectId);

  if (!project) {

    const error = new Error("Project is not registered or has already been archived.");

    error.statusCode = 404;

    throw error;

  }

  const timestamp = nowIso();

  db.prepare(`

    UPDATE project_registry

    SET

      registration_status = 'archived',

      availability_status = 'unavailable',

      active_context_eligible = 0,

      updated_at = ?

    WHERE project_id = ?

  `).run(timestamp, normalizedProjectId);

  return getProjectRegistryState();

}

export function restoreProject(projectId, metadata = {}) {

  ensureProjectRegistry();

  const normalizedProjectId = normalizeProjectId(projectId);

  if (!normalizedProjectId) {

    const error = new Error("projectId is required.");

    error.statusCode = 400;

    throw error;

  }

  const project = db.prepare(`

    SELECT project_id

    FROM project_registry

    WHERE project_id = ?

      AND registration_status = 'archived'

  `).get(normalizedProjectId);

  if (!project) {

    const error = new Error("Project is not archived or does not exist.");

    error.statusCode = 404;

    throw error;

  }

  const timestamp = nowIso();

  db.prepare(`

    UPDATE project_registry

    SET

      registration_status = 'registered',

      availability_status = 'available',

      active_context_eligible = 1,

      updated_at = ?

    WHERE project_id = ?

  `).run(timestamp, normalizedProjectId);

  return getProjectRegistryState();

}

export function setActiveProject(projectId, metadata = {}) {

  ensureProjectRegistry();

  const normalizedProjectId = normalizeProjectId(projectId);

  const project = db.prepare(`

    SELECT project_id

    FROM project_registry

    WHERE project_id = ?

      AND registration_status = 'registered'

      AND availability_status = 'available'

      AND active_context_eligible = 1

  `).get(normalizedProjectId);

  if (!project) {

    const error = new Error("Project is not registered, available, and eligible for Active Context.");

    error.statusCode = 404;

    throw error;

  }

  const timestamp = nowIso();

  const transaction = db.transaction(() => {

    db.prepare(`

      UPDATE project_registry

      SET last_opened_at = ?, updated_at = ?

      WHERE project_id = ?

    `).run(timestamp, timestamp, normalizedProjectId);

    db.prepare(`

      INSERT OR REPLACE INTO active_context (

        singleton_id,

        current_project_id,

        source,

        action,

        updated_at

      ) VALUES (1, ?, ?, ?, ?)

    `).run(

      normalizedProjectId,

      metadata.source || "dashboard",

      metadata.action || "switch_project",

      timestamp

    );

  });

  transaction();

  return getProjectRegistryState();

}

export function normalizeProjectRegistration(projectId, canonicalRoot, metadata = {}) {

  ensureProjectRegistry();

  const normalizedProjectId = normalizeProjectId(projectId);
  const targetRoot = String(canonicalRoot || "").trim();

  if (!normalizedProjectId) {
    const error = new Error("projectId is required.");
    error.statusCode = 400;
    throw error;
  }

  if (!targetRoot) {
    const error = new Error("canonicalRoot is required.");
    error.statusCode = 400;
    throw error;
  }

  validateExistingGitRepository(targetRoot);

  const duplicatePath = db.prepare(`
    SELECT project_id
    FROM project_registry
    WHERE project_root_path = ?
      AND project_id != ?
      AND registration_status = 'registered'
  `).get(targetRoot, normalizedProjectId);

  if (duplicatePath) {
    const error = new Error(
      "A registered project already uses this canonical project root."
    );
    error.statusCode = 409;
    throw error;
  }

  const project = db.prepare(`
    SELECT
      project_id,
      registration_status
    FROM project_registry
    WHERE project_id = ?
  `).get(normalizedProjectId);

  if (!project) {
    const error = new Error("Project does not exist.");
    error.statusCode = 404;
    throw error;
  }

  const timestamp = nowIso();

  db.prepare(`
    UPDATE project_registry
    SET
      project_root_path = ?,
      git_repository_reference = ?,
      updated_at = ?
    WHERE project_id = ?
  `).run(
    targetRoot,
    targetRoot,
    timestamp,
    normalizedProjectId
  );

  return getProjectRegistryState();

}

export function mountProjectRegistryRoutes(app) {

  ensureProjectRegistry();

  app.get("/api/projects/registry", (req, res) => {

    res.json(getProjectRegistryState());

  });

  app.post("/api/projects/inspect-path", (req, res) => {

    try {

      res.json(inspectProjectPath(req.body?.projectRootPath));

    } catch (error) {

      res.status(error.statusCode || 500).json({

        ok: false,

        error: error.message || "Unable to inspect project path."

      });

    }

  });

  app.post("/api/projects/register", (req, res) => {

    try {

      const state = registerProject(req.body || {}, {

        source: "dashboard",

        action: "register_project"

      });

      res.status(201).json(state);

    } catch (error) {

      res.status(error.statusCode || 500).json({

        error: error.message || "Unable to register project."

      });

    }

  });

  app.post("/api/projects/create", (req, res) => {

    try {

      const state = createNewProject(req.body || {}, {

        source: "dashboard",

        action: "create_project"

      });

      res.status(201).json(state);

    } catch (error) {

      res.status(error.statusCode || 500).json({

        error: error.message || "Unable to create project."

      });

    }

  });

  app.post("/api/projects/normalize", (req, res) => {

    try {

      const state = normalizeProjectRegistration(
        req.body?.projectId,
        req.body?.canonicalRoot,
        {
          source: "dashboard",
          action: "normalize_project_registration"
        }
      );

      res.status(200).json(state);

    } catch (error) {

      res.status(error.statusCode || 500).json({
        error: error.message || "Unable to normalize project registration."
      });

    }

  });

  app.post("/api/projects/archive", (req, res) => {

    try {

      const state = archiveProject(req.body?.projectId, {

        source: "dashboard",

        action: "archive_project"

      });

      res.json(state);

    } catch (error) {

      res.status(error.statusCode || 500).json({

        error: error.message || "Unable to archive project."

      });

    }

  });

  app.post("/api/projects/restore", (req, res) => {

    try {

      const state = restoreProject(req.body?.projectId, {

        source: "dashboard",

        action: "restore_project"

      });

      res.json(state);

    } catch (error) {

      res.status(error.statusCode || 500).json({

        error: error.message || "Unable to restore project."

      });

    }

  });

  app.post("/api/projects/active", (req, res) => {

    try {

      const state = setActiveProject(req.body?.projectId, {

        source: "dashboard",

        action: "switch_project"

      });

      res.json(state);

    } catch (error) {

      res.status(error.statusCode || 500).json({

        error: error.message || "Unable to update Active Context."

      });

    }

  });

}

