
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

p = Path("server/project-registry.mjs")

text = p.read_text()

if "export function registerProject(" not in text:

    marker = "export function setActiveProject(projectId, metadata = {}) {"

    if marker not in text:

        raise SystemExit("setActiveProject marker not found.")

    fn = '''

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

  const duplicatePath = sqlite.prepare(`

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

  sqlite.prepare(`

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

'''

    text = text.replace(marker, fn + marker, 1)

if 'app.post("/api/projects/register"' not in text:

    marker = '  app.post("/api/projects/active", (req, res) => {'

    if marker not in text:

        raise SystemExit("active project route marker not found.")

    route = '''  app.post("/api/projects/register", (req, res) => {

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

'''

    text = text.replace(marker, route + marker, 1)

p.write_text(text)

PY

node --check server/project-registry.mjs

grep -n "registerProject\|/api/projects/register" server/project-registry.mjs

git add server/project-registry.mjs

git commit -m "Add Project Registry registration route"

git push

