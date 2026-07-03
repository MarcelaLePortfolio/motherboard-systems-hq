
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

p = Path("public/dashboard.html")

text = p.read_text()

style_marker = "</style>"

modal_style = '''

.project-register-modal-panel-solid {

  background: #030712 !important;

  background-color: #030712 !important;

  opacity: 1 !important;

  backdrop-filter: none !important;

}

'''

if ".project-register-modal-panel-solid" not in text:

    text = text.replace(style_marker, modal_style + "\n" + style_marker, 1)

text = text.replace(

  '<div class="mx-auto mt-24 max-w-xl rounded-3xl border border-teal-500/30 bg-gray-950 p-6 shadow-2xl">',

  '<div class="project-register-modal-panel-solid mx-auto mt-24 max-w-xl rounded-3xl border border-teal-500/30 bg-gray-950 p-6 shadow-2xl" style="background:#030712;background-color:#030712;opacity:1;">'

)

p.write_text(text)

PY

grep -n "project-register-modal-panel-solid\|project-register-modal" public/dashboard.html

git add public/dashboard.html

git commit -m "Fix Register Existing Project modal opacity"

git push

