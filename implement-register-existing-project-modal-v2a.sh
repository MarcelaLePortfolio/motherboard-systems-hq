
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

p = Path("public/dashboard.html")

text = p.read_text()

modal = '''

<div id="project-register-modal" class="hidden fixed inset-0 z-[10000] bg-black/70 px-4 py-8">

  <div class="mx-auto mt-24 max-w-xl rounded-3xl border border-teal-500/30 bg-gray-950 p-6 shadow-2xl">

    <div class="mb-5">

      <h2 class="text-xl font-bold text-gray-100">Register Existing Project</h2>

      <p class="mt-2 text-sm text-gray-400">Add an existing local project to Motherboard governance without switching Active Context automatically.</p>

    </div>

    <form id="project-register-form" class="space-y-4">

      <label class="block">

        <span class="mb-1 block text-sm font-semibold text-teal-100">Display name</span>

        <input id="project-register-display-name" name="displayName" type="text" required class="w-full rounded-xl border border-gray-700 bg-gray-900 px-4 py-3 text-gray-100 outline-none focus:border-teal-400" placeholder="Example Project" />

      </label>

      <label class="block">

        <span class="mb-1 block text-sm font-semibold text-teal-100">Project root path</span>

        <input id="project-register-root-path" name="projectRootPath" type="text" required class="w-full rounded-xl border border-gray-700 bg-gray-900 px-4 py-3 text-gray-100 outline-none focus:border-teal-400" placeholder="../example-project" />

      </label>

      <label class="block">

        <span class="mb-1 block text-sm font-semibold text-teal-100">Project ID</span>

        <input id="project-register-project-id" name="projectId" type="text" required class="w-full rounded-xl border border-gray-700 bg-gray-900 px-4 py-3 text-gray-100 outline-none focus:border-teal-400" placeholder="example-project" />

      </label>

      <p id="project-register-error" class="hidden rounded-xl border border-red-500/40 bg-red-950/40 px-4 py-3 text-sm text-red-100"></p>

      <div class="flex justify-end gap-3 pt-2">

        <button id="project-register-cancel" type="button" class="rounded-xl border border-gray-700 px-4 py-2 text-sm font-semibold text-gray-200 hover:bg-gray-800">Cancel</button>

        <button type="submit" class="rounded-xl bg-teal-500 px-4 py-2 text-sm font-bold text-gray-950 hover:bg-teal-400">Register Project</button>

      </div>

    </form>

  </div>

</div>

'''

if 'id="project-register-modal"' not in text:

    text = text.replace("</body>", modal + "\n</body>", 1)

old_fn = '''  async function registerExistingProject() {

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

  }'''

new_fn = '''  function getRegisterModalElements() {

    return {

      modal: document.getElementById("project-register-modal"),

      form: document.getElementById("project-register-form"),

      displayName: document.getElementById("project-register-display-name"),

      projectRootPath: document.getElementById("project-register-root-path"),

      projectId: document.getElementById("project-register-project-id"),

      error: document.getElementById("project-register-error"),

      cancel: document.getElementById("project-register-cancel")

    };

  }

  function showRegisterError(message) {

    const { error } = getRegisterModalElements();

    if (!error) return;

    error.textContent = message || "Unable to register project.";

    error.classList.remove("hidden");

  }

  function hideRegisterError() {

    const { error } = getRegisterModalElements();

    if (!error) return;

    error.textContent = "";

    error.classList.add("hidden");

  }

  function closeRegisterModal() {

    const { modal, form } = getRegisterModalElements();

    if (form) form.reset();

    hideRegisterError();

    if (modal) modal.classList.add("hidden");

  }

  function openRegisterModal() {

    const { modal, displayName, projectId } = getRegisterModalElements();

    if (!modal) return;

    hideRegisterError();

    modal.classList.remove("hidden");

    if (displayName) displayName.focus();

    if (displayName && projectId) {

      displayName.oninput = () => {

        if (!projectId.value.trim()) {

          projectId.value = slugifyProjectName(displayName.value);

        }

      };

    }

  }

  async function submitRegisterExistingProject() {

    const { displayName, projectRootPath, projectId } = getRegisterModalElements();

    const payload = {

      projectId: projectId?.value?.trim(),

      displayName: displayName?.value?.trim(),

      projectRootPath: projectRootPath?.value?.trim(),

      gitRepositoryReference: projectRootPath?.value?.trim()

    };

    const response = await fetch("/api/projects/register", {

      method: "POST",

      headers: { "Content-Type": "application/json" },

      body: JSON.stringify(payload)

    });

    if (!response.ok) {

      const payload = await response.json().catch(() => ({}));

      throw new Error(payload.error || "Project registration failed.");

    }

    await loadProjectRegistry();

  }

  async function registerExistingProject() {

    openRegisterModal();

  }'''

if old_fn not in text:

    raise SystemExit("prompt-based registerExistingProject function not found.")

text = text.replace(old_fn, new_fn, 1)

listener_marker = '''  document.addEventListener("keydown", (event) => {

    if (event.key === "Escape") closeMenu();

  });

  loadProjectRegistry();'''

listener_add = '''  const registerModalElements = getRegisterModalElements();

  if (registerModalElements.form) {

    registerModalElements.form.addEventListener("submit", async (event) => {

      event.preventDefault();

      try {

        hideRegisterError();

        await submitRegisterExistingProject();

        closeRegisterModal();

      } catch (error) {

        console.warn("Unable to register project:", error);

        showRegisterError(error.message || "Unable to register project.");

      }

    });

  }

  if (registerModalElements.cancel) {

    registerModalElements.cancel.addEventListener("click", closeRegisterModal);

  }

  if (registerModalElements.modal) {

    registerModalElements.modal.addEventListener("click", (event) => {

      if (event.target === registerModalElements.modal) closeRegisterModal();

    });

  }

  document.addEventListener("keydown", (event) => {

    if (event.key === "Escape") {

      closeMenu();

      closeRegisterModal();

    }

  });

  loadProjectRegistry();'''

if listener_marker not in text:

    raise SystemExit("keydown listener marker not found.")

text = text.replace(listener_marker, listener_add, 1)

p.write_text(text)

PY

grep -n "project-register-modal\|openRegisterModal\|submitRegisterExistingProject\|project-register-form" public/dashboard.html

git diff -- public/dashboard.html

git add public/dashboard.html

git commit -m "Replace Register Existing Project prompts with modal"

git push

git add implement-register-existing-project-modal-v2a.sh

git commit -m "Add Register Existing Project modal implementation script"

git push

