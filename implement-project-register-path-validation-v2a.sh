
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

p = Path("server/project-registry.mjs")

text = p.read_text()

if 'function resolveProjectPathForValidation' not in text:

    marker = 'function normalizeProjectId(value) {\n\n  return String(value || "").trim();\n\n}\n'

    helper = '''function resolveProjectPathForValidation(projectRootPath) {

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

'''

    if marker not in text:

        raise SystemExit("normalizeProjectId marker not found.")

    text = text.replace(marker, marker + "\n" + helper, 1)

old = '''  const timestamp = nowIso();'''

new = '''  validateExistingGitRepository(projectRootPath);

  const timestamp = nowIso();'''

if old not in text:

    raise SystemExit("timestamp marker not found.")

if new not in text:

    text = text.replace(old, new, 1)

p.write_text(text)

PY

node --check server/project-registry.mjs

grep -n "resolveProjectPathForValidation\|validateExistingGitRepository\|Project root path must be a Git repository" server/project-registry.mjs

git add server/project-registry.mjs

git commit -m "Validate registered project paths"

git push

git add implement-project-register-path-validation-v2a.sh

git commit -m "Add project registration path validation script"

git push

