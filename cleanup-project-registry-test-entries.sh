
#!/bin/bash

set -e

node --input-type=module <<'NODE'

import path from "path";

import Database from "better-sqlite3";

const db = new Database(path.join(process.cwd(), "db", "main.db"));

const testProjectIds = [

  "prompt-test-project"

];

const deleteProject = db.prepare(`

  DELETE FROM project_registry

  WHERE project_id = ?

    AND last_opened_at IS NULL

`);

for (const projectId of testProjectIds) {

  const result = deleteProject.run(projectId);

  console.log(`Removed ${projectId}: ${result.changes}`);

}

console.log("Registry test cleanup complete.");

NODE

curl -s http://localhost:3001/api/projects/registry | python3 -m json.tool

