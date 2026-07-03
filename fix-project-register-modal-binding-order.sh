
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

p = Path("public/dashboard.html")

text = p.read_text()

modal_start = text.find('<div id="project-register-modal"')

if modal_start == -1:

    raise SystemExit("project-register-modal not found.")

modal_end_marker = '</div>\n</body>'

modal_end = text.find(modal_end_marker, modal_start)

if modal_end == -1:

    raise SystemExit("modal end marker not found.")

modal_block = text[modal_start:modal_end + len('</div>')]

text_without_modal = text[:modal_start] + text[modal_end + len('</div>'):]

script_start_marker = '<script>\n\n(() => {\n\n  const button = document.getElementById("project-context-selector");'

script_start = text_without_modal.find(script_start_marker)

if script_start == -1:

    raise SystemExit("project switcher script start not found.")

text = text_without_modal[:script_start] + modal_block + "\n\n" + text_without_modal[script_start:]

p.write_text(text)

PY

grep -n "project-register-modal\|project-register-cancel\|project-context-selector" public/dashboard.html | head -20

git add public/dashboard.html

git commit -m "Fix Register Existing Project modal event binding"

git push

