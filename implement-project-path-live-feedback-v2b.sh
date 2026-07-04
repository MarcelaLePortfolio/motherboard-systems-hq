
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

p = Path("public/dashboard.html")

text = p.read_text()

text = text.replace(

'''        <span class="mt-1 block text-xs text-gray-500">Example: <code>../executive-agent-suite</code>. The folder must already exist and be a Git repository.</span>''',

'''        <span class="mt-1 block text-xs text-gray-500">Example: <code>../executive-agent-suite</code>. The folder must already exist and be a Git repository.</span>

        <p id="project-register-path-status" class="mt-2 rounded-xl border border-gray-700 bg-gray-900 px-3 py-2 text-xs text-gray-400">Enter a path to inspect the repository.</p>'''

)

text = text.replace(

'''      cancel: document.getElementById("project-register-cancel")''',

'''      cancel: document.getElementById("project-register-cancel"),

      pathStatus: document.getElementById("project-register-path-status")'''

)

marker = '''  function closeRegisterModal() {'''

insert = '''  function setPathStatus(message, ok = false) {

    const { pathStatus } = getRegisterModalElements();

    if (!pathStatus) return;

    pathStatus.textContent = message || "Enter a path to inspect the repository.";

    pathStatus.classList.remove("border-gray-700", "bg-gray-900", "text-gray-400", "border-red-500/40", "bg-red-950/40", "text-red-100", "border-teal-500/40", "bg-teal-950/40", "text-teal-100");

    if (ok) {

      pathStatus.classList.add("border-teal-500/40", "bg-teal-950/40", "text-teal-100");

    } else if (message && message !== "Enter a path to inspect the repository.") {

      pathStatus.classList.add("border-red-500/40", "bg-red-950/40", "text-red-100");

    } else {

      pathStatus.classList.add("border-gray-700", "bg-gray-900", "text-gray-400");

    }

  }

  async function inspectProjectPathInput() {

    const { projectRootPath } = getRegisterModalElements();

    const value = projectRootPath?.value?.trim() || "";

    if (!value) {

      setPathStatus("Enter a path to inspect the repository.");

      return;

    }

    const response = await fetch("/api/projects/inspect-path", {

      method: "POST",

      headers: { "Content-Type": "application/json" },

      body: JSON.stringify({ projectRootPath: value })

    });

    const payload = await response.json().catch(() => ({}));

    setPathStatus(payload.message || "Unable to inspect project path.", Boolean(payload.ok));

  }

'''

if marker not in text:

    raise SystemExit("closeRegisterModal marker not found.")

if "async function inspectProjectPathInput()" not in text:

    text = text.replace(marker, insert + marker, 1)

text = text.replace(

'''    hideRegisterError();''',

'''    hideRegisterError();

    setPathStatus("Enter a path to inspect the repository.");''',

1

)

listener_marker = '''  if (registerModalElements.cancel) {'''

listener = '''  if (registerModalElements.projectRootPath) {

    registerModalElements.projectRootPath.addEventListener("input", () => {

      window.clearTimeout(registerModalElements.projectRootPath.dataset.inspectTimer);

      const timer = window.setTimeout(() => {

        inspectProjectPathInput().catch((error) => {

          console.warn("Unable to inspect project path:", error);

          setPathStatus("Unable to inspect project path.");

        });

      }, 300);

      registerModalElements.projectRootPath.dataset.inspectTimer = String(timer);

    });

  }

'''

if listener_marker not in text:

    raise SystemExit("cancel listener marker not found.")

if "registerModalElements.projectRootPath.addEventListener" not in text:

    text = text.replace(listener_marker, listener + listener_marker, 1)

p.write_text(text)

PY

grep -n "project-register-path-status\|inspectProjectPathInput\|setPathStatus\|inspect-path" public/dashboard.html

git add public/dashboard.html

git commit -m "Add Register Existing Project live path feedback"

git push

git add implement-project-path-live-feedback-v2b.sh

git commit -m "Add Project Registry V2-B live path feedback script"

git push
