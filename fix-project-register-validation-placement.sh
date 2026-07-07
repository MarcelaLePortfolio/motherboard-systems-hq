
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

p = Path("server/project-registry.mjs")

text = p.read_text()

text = text.replace(

'''    validateExistingGitRepository(projectRootPath);

    const timestamp = nowIso();''',

'''    const timestamp = nowIso();''',

1

)

needle = '''  const duplicatePath = sqlite.prepare(`

    SELECT project_id

    FROM project_registry

    WHERE project_root_path = ?

      AND project_id != ?

      AND registration_status = 'registered'

  `).get(projectRootPath, projectId);'''

replacement = '''  validateExistingGitRepository(projectRootPath);

  const duplicatePath = sqlite.prepare(`

    SELECT project_id

    FROM project_registry

    WHERE project_root_path = ?

      AND project_id != ?

      AND registration_status = 'registered'

  `).get(projectRootPath, projectId);'''

if needle not in text:

    raise SystemExit("registerProject duplicatePath marker not found.")

if replacement not in text:

    text = text.replace(needle, replacement, 1)

p.write_text(text)

PY

node --check server/project-registry.mjs

node --input-type=module <<'NODE'

import path from "path";

import Database from "better-sqlite3";

const db = new Database(path.join(process.cwd(), "db", "main.db"));

const result = sqlite.prepare(`

  DELETE FROM project_registry

  WHERE project_id = 'invalid-path-test'

    AND last_opened_at IS NULL

`).run();

console.log(`Removed invalid-path-test: ${result.changes}`);

NODE

grep -n -B 8 -A 16 "validateExistingGitRepository(projectRootPath)" server/project-registry.mjs

git add server/project-registry.mjs

git commit -m "Fix project registration path validation placement"

git push

git status

