
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

p = Path("public/dashboard.html")

text = p.read_text()

modal_start = text.find('<div id="project-register-modal"')

if modal_start == -1:

    raise SystemExit("project-register-modal not found.")

phase493_marker = '<!-- PHASE 493 REASONING MODAL -->'

phase493_start = text.find(phase493_marker, modal_start)

if phase493_start == -1:

    raise SystemExit("PHASE 493 marker not found after modal.")

modal_block = text[modal_start:phase493_start].strip() + "\n\n"

text_without_modal = text[:modal_start] + text[phase493_start:]

script_marker = '<script>\n\n(() => {\n\n  const button = document.getElementById("project-context-selector");'

script_start = text_without_modal.find(script_marker)

if script_start == -1:

    raise SystemExit("project switcher script marker not found.")

text = text_without_modal[:script_start] + modal_block + text_without_modal[script_start:]

p.write_text(text)

PY

grep -n "project-register-modal\|project-register-cancel\|project-context-selector" public/dashboard.html | head -30

git add public/dashboard.html

git commit -m "Fix Register Existing Project modal binding order"

git push

git add fix-project-register-modal-binding-order-v2.sh

git commit -m "Add Register Existing Project modal binding order fix script"

git push

