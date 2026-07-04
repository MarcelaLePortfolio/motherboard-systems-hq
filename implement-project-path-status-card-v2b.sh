
#!/bin/bash

set -e

python3 <<'PY'

from pathlib import Path

p = Path("public/dashboard.html")

text = p.read_text()

text = text.replace(

'''  function setPathStatus(message, ok = false) {

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

  }''',

'''  function setPathStatus(payloadOrMessage, ok = false) {

    const { pathStatus } = getRegisterModalElements();

    if (!pathStatus) return;

    const payload = typeof payloadOrMessage === "object" && payloadOrMessage !== null

      ? payloadOrMessage

      : { message: payloadOrMessage, ok };

    const message = payload.message || "Enter a path to inspect the repository.";

    const ready = Boolean(payload.ok);

    pathStatus.classList.remove("border-gray-700", "bg-gray-900", "text-gray-400", "border-red-500/40", "bg-red-950/40", "text-red-100", "border-teal-500/40", "bg-teal-950/40", "text-teal-100");

    if (ready) {

      pathStatus.classList.add("border-teal-500/40", "bg-teal-950/40", "text-teal-100");

    } else if (payload.inputPath || message !== "Enter a path to inspect the repository.") {

      pathStatus.classList.add("border-red-500/40", "bg-red-950/40", "text-red-100");

    } else {

      pathStatus.classList.add("border-gray-700", "bg-gray-900", "text-gray-400");

    }

    const statusIcon = ready ? "✓" : payload.inputPath ? "✕" : "•";

    const folderName = payload.projectDirectoryName || "—";

    const resolvedPath = payload.resolvedPath || "—";

    const exists = payload.exists ? "Yes" : "No";

    const isGitRepository = payload.isGitRepository ? "Yes" : "No";

    pathStatus.innerHTML = `

      <div class="font-semibold">${statusIcon} ${escapeHtml(message)}</div>

      <div class="mt-2 grid gap-1 text-[11px] leading-5">

        <div><span class="text-gray-400">Folder:</span> ${escapeHtml(folderName)}</div>

        <div><span class="text-gray-400">Resolved path:</span> <code class="break-all">${escapeHtml(resolvedPath)}</code></div>

        <div><span class="text-gray-400">Exists:</span> ${escapeHtml(exists)}</div>

        <div><span class="text-gray-400">Git repository:</span> ${escapeHtml(isGitRepository)}</div>

      </div>

    `;

  }'''

)

text = text.replace(

'''    const payload = await response.json().catch(() => ({}));

    setPathStatus(payload.message || "Unable to inspect project path.", Boolean(payload.ok));''',

'''    const payload = await response.json().catch(() => ({}));

    setPathStatus(payload);'''

)

p.write_text(text)

PY

node --check server/project-registry.mjs

grep -n "function setPathStatus\|projectDirectoryName\|Resolved path\|Git repository" public/dashboard.html

git add public/dashboard.html

git commit -m "Render Project Registry path inspection status card"

git push

