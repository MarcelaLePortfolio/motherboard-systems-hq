
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

p = Path("public/dashboard.html")

text = p.read_text()

text = text.replace(

'''      <p class="mt-2 text-sm text-gray-400">Add an existing local project to Motherboard governance without switching Active Context automatically.</p>''',

'''      <p class="mt-2 text-sm text-gray-400">Add an existing local Git repository to Motherboard governance without switching Active Context automatically.</p>

      <p class="mt-2 rounded-xl border border-teal-500/20 bg-teal-950/20 px-3 py-2 text-xs leading-5 text-teal-100">

        The project root path must point to an existing folder that already contains a <code class="rounded bg-gray-900 px-1 py-0.5 text-teal-200">.git</code> directory. You may use a relative path like <code class="rounded bg-gray-900 px-1 py-0.5 text-teal-200">../executive-agent-suite</code> or an absolute path.

      </p>'''

)

text = text.replace(

'''        <input id="project-register-root-path" name="projectRootPath" type="text" required class="w-full rounded-xl border border-gray-700 bg-gray-900 px-4 py-3 text-gray-100 outline-none focus:border-teal-400" placeholder="../example-project" />''',

'''        <input id="project-register-root-path" name="projectRootPath" type="text" required class="w-full rounded-xl border border-gray-700 bg-gray-900 px-4 py-3 text-gray-100 outline-none focus:border-teal-400" placeholder="../example-project" />

        <span class="mt-1 block text-xs text-gray-500">Example: <code>../executive-agent-suite</code>. The folder must already exist and be a Git repository.</span>'''

)

p.write_text(text)

PY

grep -n "existing local Git repository\\|project root path must point\\|folder must already exist" public/dashboard.html

git add public/dashboard.html

git commit -m "Improve Register Existing Project path guidance"

git push
