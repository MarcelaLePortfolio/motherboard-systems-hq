
#!/bin/bash

set -e

python3 <<'PY'

from pathlib import Path

p = Path("public/dashboard.html")

text = p.read_text()

text = text.replace(

'''      cancel: document.getElementById("project-register-cancel"),

      pathStatus: document.getElementById("project-register-path-status")''',

'''      cancel: document.getElementById("project-register-cancel"),

      submit: document.getElementById("project-register-submit"),

      pathStatus: document.getElementById("project-register-path-status")'''

)

text = text.replace(

'''        <button type="submit" class="rounded-xl bg-teal-500 px-4 py-2 text-sm font-bold text-gray-950 hover:bg-teal-400">Register Project</button>''',

'''        <button id="project-register-submit" type="submit" disabled class="rounded-xl bg-teal-500 px-4 py-2 text-sm font-bold text-gray-950 opacity-50 hover:bg-teal-400 disabled:cursor-not-allowed disabled:opacity-50">Register Project</button>'''

)

text = text.replace(

'''    const { pathStatus } = getRegisterModalElements();

    if (!pathStatus) return;''',

'''    const { pathStatus, submit } = getRegisterModalElements();

    if (!pathStatus) return;'''

)

text = text.replace(

'''    const ready = Boolean(payload.ok);''',

'''    const ready = Boolean(payload.ok);

    if (submit) {

      submit.disabled = !ready;

      submit.classList.toggle("opacity-50", !ready);

    }'''

)

text = text.replace(

'''    if (form) form.reset();''',

'''    if (form) form.reset();

    const { submit } = getRegisterModalElements();

    if (submit) submit.disabled = true;'''

)

p.write_text(text)

PY

grep -n "project-register-submit\\|submit.disabled\\|setPathStatus" public/dashboard.html

git add public/dashboard.html

git commit -m "Disable project registration until path inspection passes"

git push

git add implement-project-register-disable-until-valid-v2b.sh

git commit -m "Add Project Registry V2-B submit guard script"

git push

