
#!/bin/bash

set -e

node --input-type=module <<'NODE'

import fs from "fs";

import path from "path";

import Database from "better-sqlite3";

const db = new Database(path.join(process.cwd(), "db", "main.db"));

const seed = JSON.parse(fs.readFileSync(path.join(process.cwd(), "projects", "registry.example.json"), "utf8"));

const timestamp = new Date().toISOString();

const upsert = sqlite.prepare(`

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

`);

for (const project of seed.projects || []) {

  upsert.run(

    project.id,

    project.name,

    project.repoPath || null,

    project.repoPath || null,

    timestamp,

    timestamp

  );

}

console.log("Registry seed synced.");

NODE

curl -s http://localhost:3001/api/projects/registry | python3 -m json.tool

