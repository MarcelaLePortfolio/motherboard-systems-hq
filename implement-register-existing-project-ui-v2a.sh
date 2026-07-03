
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

p = Path("public/dashboard.html")

text = p.read_text()

text = text.replace(

'''          <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-gray-100 hover:bg-gray-800">Register Existing Project...</button>''',

'''          <button type="button" data-project-action="register-existing" class="w-full rounded-xl px-3 py-2 text-left text-sm text-gray-100 hover:bg-gray-800">Register Existing Project...</button>'''

)

marker = '''  async function setActiveProject(projectId) {'''

if marker not in text:

    raise SystemExit("setActiveProject marker not found.")

register_fn = '''  function slugifyProjectName(value) {

    return String(value || "")

      .trim()

      .toLowerCase()

      .replace(/[^a-z0-9]+/g, "-")

      .replace(/^-+|-+$/g, "");

  }

  async function registerExistingProject() {

    const displayName = window.prompt("Project display name:");

    if (!displayName) return;

    const projectRootPath = window.prompt("Project root path:");

    if (!projectRootPath) return;

    const projectId = window.prompt("Project ID:", slugifyProjectName(displayName));

    if (!projectId) return;

    const response = await fetch("/api/projects/register", {

      method: "POST",

      headers: { "Content-Type": "application/json" },

      body: JSON.stringify({

        projectId,

        displayName,

        projectRootPath,

        gitRepositoryReference: projectRootPath

      })

    });

    if (!response.ok) {

      const payload = await response.json().catch(() => ({}));

      throw new Error(payload.error || "Project registration failed.");

    }

    await loadProjectRegistry();

  }

'''

if "async function registerExistingProject()" not in text:

    text = text.replace(marker, register_fn + marker, 1)

old_click = '''    const option = event.target.closest(".project-context-option");

    if (!option) return;

    try {

      await setActiveProject(option.dataset.projectId);

      closeMenu();

    } catch (error) {

      console.warn("Unable to switch project:", error);

    }'''

new_click = '''    const registerAction = event.target.closest('[data-project-action="register-existing"]');

    if (registerAction) {

      try {

        await registerExistingProject();

        closeMenu();

      } catch (error) {

        console.warn("Unable to register project:", error);

        window.alert(error.message || "Unable to register project.");

      }

      return;

    }

    const option = event.target.closest(".project-context-option");

    if (!option) return;

    try {

      await setActiveProject(option.dataset.projectId);

      closeMenu();

    } catch (error) {

      console.warn("Unable to switch project:", error);

    }'''

if old_click not in text:

    raise SystemExit("project switcher click handler marker not found.")

text = text.replace(old_click, new_click, 1)

p.write_text(text)

PY

grep -n "registerExistingProject\|data-project-action=\"register-existing\"\|/api/projects/register" public/dashboard.html

git diff -- public/dashboard.html

git add public/dashboard.html

git commit -m "Add Register Existing Project dashboard workflow"

git push

