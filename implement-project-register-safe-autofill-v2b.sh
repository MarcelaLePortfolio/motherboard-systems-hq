
#!/bin/bash

set -e

python3 <<'PY'

from pathlib import Path

p = Path("public/dashboard.html")

text = p.read_text()

text = text.replace(

'''  async function inspectProjectPathInput() {

    const { projectRootPath } = getRegisterModalElements();

    const value = projectRootPath?.value?.trim() || "";''',

'''  function resetRegisterAutofillState() {

    const { displayName, projectId } = getRegisterModalElements();

    if (displayName) displayName.dataset.operatorEdited = "";

    if (projectId) projectId.dataset.operatorEdited = "";

  }

  function markRegisterFieldEdited(event) {

    if (!event?.target) return;

    event.target.dataset.operatorEdited = "1";

  }

  function titleFromProjectDirectoryName(value) {

    return String(value || "")

      .trim()

      .replace(/[-_]+/g, " ")

      .replace(/\\s+/g, " ")

      .replace(/\\b\\w/g, (character) => character.toUpperCase());

  }

  function applyProjectAutofillFromInspection(payload) {

    if (!payload?.ok || !payload.projectDirectoryName) return;

    const { displayName, projectId } = getRegisterModalElements();

    const suggestedName = titleFromProjectDirectoryName(payload.projectDirectoryName);

    const suggestedId = slugifyProjectName(payload.projectDirectoryName);

    if (displayName && !displayName.dataset.operatorEdited && !displayName.value.trim()) {

      displayName.value = suggestedName;

    }

    if (projectId && !projectId.dataset.operatorEdited && !projectId.value.trim()) {

      projectId.value = suggestedId;

    }

  }

  async function inspectProjectPathInput() {

    const { projectRootPath } = getRegisterModalElements();

    const value = projectRootPath?.value?.trim() || "";'''

)

text = text.replace(

'''    const payload = await response.json().catch(() => ({}));

    setPathStatus(payload);''',

'''    const payload = await response.json().catch(() => ({}));

    setPathStatus(payload);

    applyProjectAutofillFromInspection(payload);'''

)

text = text.replace(

'''    hideRegisterError();

    setPathStatus("Enter a path to inspect the repository.");''',

'''    hideRegisterError();

    resetRegisterAutofillState();

    setPathStatus("Enter a path to inspect the repository.");''',

1

)

text = text.replace(

'''  if (registerModalElements.projectRootPath) {''',

'''  if (registerModalElements.displayName) {

    registerModalElements.displayName.addEventListener("input", markRegisterFieldEdited);

  }

  if (registerModalElements.projectId) {

    registerModalElements.projectId.addEventListener("input", markRegisterFieldEdited);

  }

  if (registerModalElements.projectRootPath) {'''

)

p.write_text(text)

PY

grep -n "resetRegisterAutofillState\|applyProjectAutofillFromInspection\|titleFromProjectDirectoryName\|markRegisterFieldEdited" public/dashboard.html

git add public/dashboard.html

git commit -m "Add safe autofill to project registration modal"

git push

git add implement-project-register-safe-autofill-v2b.sh

git commit -m "Add Project Registry V2-B safe autofill script"

git push

