
#!/bin/bash

set -e

cat > server/project-registry.mjs << 'REGISTRY'

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

export function mountProjectRegistryRoutes(app) {

  ensureProjectRegistry();

  app.get("/api/projects/registry", (req, res) => {

    res.json(getProjectRegistryState());

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

REGISTRY

python3 << 'PY'

from pathlib import Path

server_path = Path("server.mjs")

server = server_path.read_text()

import_line = 'import { mountProjectRegistryRoutes } from "./server/project-registry.mjs";\n'

if import_line not in server:

    lines = server.splitlines(keepends=True)

    insert_at = 0

    for index, line in enumerate(lines):

        if line.startswith("import "):

            insert_at = index + 1

    lines.insert(insert_at, import_line)

    server = "".join(lines)

mount_line = 'mountProjectRegistryRoutes(app);\n'

if mount_line not in server:

    marker = 'app.use(express.json());\n'

    if marker not in server:

        raise SystemExit("Could not find express json middleware marker in server.mjs")

    server = server.replace(marker, marker + mount_line, 1)

server_path.write_text(server)

dashboard_path = Path("public/dashboard.html")

dashboard = dashboard_path.read_text()

old_script = '''  const button = document.getElementById("project-context-selector");

  const label = document.getElementById("project-context-label");

  const menu = document.getElementById("project-context-menu");

  if (button && menu) {

    button.addEventListener("click", (event) => {

      event.stopPropagation();

      menu.classList.toggle("hidden");

    });

    document.addEventListener("click", () => {

      menu.classList.add("hidden");

    });

    menu.addEventListener("click", (event) => {

      event.stopPropagation();

    });

  }

'''

new_script = '''  const button = document.getElementById("project-context-selector");

  const label = document.getElementById("project-context-label");

  const menu = document.getElementById("project-context-menu");

  function escapeHtml(value) {

    return String(value || "")

      .replaceAll("&", "&amp;")

      .replaceAll("<", "&lt;")

      .replaceAll(">", "&gt;")

      .replaceAll('"', "&quot;")

      .replaceAll("'", "&#039;");

  }

  async function loadProjectRegistry() {

    if (!menu || !label) return;

    try {

      const response = await fetch("/api/projects/registry");

      if (!response.ok) throw new Error("Registry request failed.");

      const state = await response.json();

      const activeProject = state.activeProject || {};

      const projects = Array.isArray(state.projects) ? state.projects : [];

      label.textContent = `${activeProject.displayName || "Motherboard HQ"} ▼`;

      const projectButtons = projects.map((project) => {

        const isActive = project.projectId === state.activeProjectId;

        return `

          <button

            type="button"

            class="project-context-option w-full rounded-xl px-3 py-2 text-left text-sm ${isActive ? "bg-gray-800 text-white" : "text-teal-100 hover:bg-gray-800"}"

            data-project-id="${escapeHtml(project.projectId)}"

          >

            ${escapeHtml(project.displayName)}

          </button>

        `;

      }).join("");

      menu.innerHTML = `

        <div class="px-3 pb-3 text-sm font-semibold text-teal-100">${escapeHtml(activeProject.displayName || "Motherboard HQ")}</div>

        <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-teal-100 hover:bg-gray-800">Switch Project...</button>

        <div class="px-3 pb-2 pt-3 text-xs font-semibold uppercase tracking-[0.2em] text-teal-300/70">Recent Projects</div>

        ${projectButtons}

        <div class="my-2 border-t border-teal-900/60"></div>

        <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-teal-100 hover:bg-gray-800">New Project...</button>

        <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-teal-100 hover:bg-gray-800">Register Existing Project...</button>

      `;

    } catch (error) {

      console.warn("Project Registry unavailable:", error);

    }

  }

  async function setActiveProject(projectId) {

    const response = await fetch("/api/projects/active", {

      method: "POST",

      headers: { "Content-Type": "application/json" },

      body: JSON.stringify({ projectId })

    });

    if (!response.ok) {

      throw new Error("Active Context update failed.");

    }

    await loadProjectRegistry();

  }

  if (button && menu) {

    button.addEventListener("click", async (event) => {

      event.stopPropagation();

      await loadProjectRegistry();

      menu.classList.toggle("hidden");

    });

    document.addEventListener("click", () => {

      menu.classList.add("hidden");

    });

    menu.addEventListener("click", async (event) => {

      event.stopPropagation();

      const option = event.target.closest(".project-context-option");

      if (!option) return;

      try {

        await setActiveProject(option.dataset.projectId);

        menu.classList.add("hidden");

      } catch (error) {

        console.warn("Unable to switch project:", error);

      }

    });

    loadProjectRegistry();

  }

'''

if old_script not in dashboard:

    raise SystemExit("Could not find existing project switcher script block in public/dashboard.html")

dashboard = dashboard.replace(old_script, new_script, 1)

dashboard_path.write_text(dashboard)

PY

node --check server/project-registry.mjs

node --check server.mjs

git diff -- server/project-registry.mjs server.mjs public/dashboard.html

git add server/project-registry.mjs server.mjs public/dashboard.html

git commit -m "Add registry-backed project switcher"

git push

