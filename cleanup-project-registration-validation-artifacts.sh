
#!/bin/bash

set -e

node --input-type=module <<'NODE'

import fs from "fs";

import path from "path";

import Database from "better-sqlite3";

const db = new Database(path.join(process.cwd(), "db", "main.db"));

const result = sqlite.prepare(`

  DELETE FROM project_registry

  WHERE project_id = 'git-validation-test'

    AND last_opened_at IS NULL

`).run();

console.log(`Removed git-validation-test registry row: ${result.changes}`);

fs.rmSync(path.join(process.cwd(), "tmp", "git-project-validation"), { recursive: true, force: true });

fs.rmSync(path.join(process.cwd(), "tmp", "non-git-project-validation"), { recursive: true, force: true });

try {

  const tmpPath = path.join(process.cwd(), "tmp");

  if (fs.existsSync(tmpPath) && fs.readdirSync(tmpPath).length === 0) {

    fs.rmdirSync(tmpPath);

  }

} catch {}

console.log("Removed validation temp directories.");

NODE

curl -s http://localhost:3001/api/projects/registry | python3 -m json.tool

git status

