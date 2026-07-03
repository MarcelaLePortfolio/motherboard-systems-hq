
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

p = Path("server/project-registry.mjs")

text = p.read_text()

insert_after = '''export function setActiveProject(projectId, metadata = {}) {

'''

if insert_after not in text:

    raise SystemExit("Could not find setActiveProject insertion point.")

register_fn = '''export function registerProject(projectInput = {}, metadata = {}) {

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

    projectRootPath || null,

    gitRepositoryReference || null,

    timestamp,

    timestamp

  );

  return getProjectRegistryState();

}

'''

if register_fn not in text:

    text = text.replace(insert_after, register_fn + insert_after, 1)

route_marker = '''  app.post("/api/projects/active", (req, res) => {

'''

if route_marker not in text:

    raise SystemExit("Could not find active project route marker.")

register_route = '''  app.post("/api/projects/register", (req, res) => {

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

if register_route not in text:

    text = text.replace(route_marker, register_route + route_marker, 1)

p.write_text(text)

PY

node --check server/project-registry.mjs

grep -n "registerProject\|/api/projects/register" server/project-registry.mjs

curl -s -X POST http://localhost:3001/api/projects/register \

  -H "Content-Type: application/json" \

  -d '{"projectId":"crystal-vibes-wellness","displayName":"Crystal Vibes Wellness","projectRootPath":"../crystal-vibes-wellness","gitRepositoryReference":"../crystal-vibes-wellness"}' \

  | python3 -m json.tool || true

git diff -- server/project-registry.mjs

git add server/project-registry.mjs

git commit -m "Add project registration API"

git push

