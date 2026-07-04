
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

p = Path("server/project-registry.mjs")

text = p.read_text()

if "export function inspectProjectPath(" not in text:

    marker = "export function registerProject(projectInput = {}, metadata = {}) {"

    if marker not in text:

        raise SystemExit("registerProject marker not found.")

    fn = '''export function inspectProjectPath(projectRootPath) {

  const inputPath = String(projectRootPath || "").trim();

  const resolvedPath = resolveProjectPathForValidation(inputPath);

  if (!inputPath) {

    return {

      ok: false,

      inputPath,

      resolvedPath: null,

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

'''

    text = text.replace(marker, fn + marker, 1)

if 'app.post("/api/projects/inspect-path"' not in text:

    marker = '  app.post("/api/projects/register", (req, res) => {'

    if marker not in text:

        raise SystemExit("register route marker not found.")

    route = '''  app.post("/api/projects/inspect-path", (req, res) => {

    try {

      res.json(inspectProjectPath(req.body?.projectRootPath));

    } catch (error) {

      res.status(error.statusCode || 500).json({

        ok: false,

        error: error.message || "Unable to inspect project path."

      });

    }

  });

'''

    text = text.replace(marker, route + marker, 1)

p.write_text(text)

PY

node --check server/project-registry.mjs

grep -n "inspectProjectPath\\|/api/projects/inspect-path" server/project-registry.mjs

git add server/project-registry.mjs

git commit -m "Add project path inspection endpoint"

git push

git add implement-project-path-validation-endpoint-v2b.sh

git commit -m "Add Project Registry V2-B path inspection endpoint script"

git push
