
#!/usr/bin/env bash

set -euo pipefail

python3 - << 'PY'

from pathlib import Path

p = Path("public/dashboard.html")

s = p.read_text()

replacements = {

'''<!-- phase474.3 temporary neutralization: removed local stylesheet :: <link rel="stylesheet" href="css/broadcast.css" /> -->''':

'''<link rel="stylesheet" href="css/broadcast.css" />''',

'''<!-- phase474.3 temporary neutralization: removed local stylesheet :: <link rel="stylesheet" href="css/dashboard.css?v=darkmode" /> -->''':

'''<link rel="stylesheet" href="css/dashboard.css?v=darkmode" />''',

'''<!-- phase474.3 temporary neutralization: removed local stylesheet :: <link rel="stylesheet" href="css/dashboard-reflections.css" /> -->''':

'''<link rel="stylesheet" href="css/dashboard-reflections.css" />''',

'''<!-- phase474.3 temporary neutralization: removed local stylesheet :: <link rel="stylesheet" href="css/agent-status-row.css" /> -->''':

'''<link rel="stylesheet" href="css/agent-status-row.css" />''',

'''<!-- phase474.3 temporary neutralization: removed local stylesheet :: <link rel="stylesheet" href="css/matilda-chat.css" /> -->''':

'''<link rel="stylesheet" href="css/matilda-chat.css" />''',

'''<!-- phase474.3 temporary neutralization: removed local stylesheet :: <link rel="stylesheet" href="css/demo_layout_trim.css" /> -->''':

'''<link rel="stylesheet" href="css/demo_layout_trim.css" />''',

'''<!-- phase474.3 temporary neutralization: removed local stylesheet :: <link rel="stylesheet" href="css/phase59_demo_focus.css" /> -->''':

'''<link rel="stylesheet" href="css/phase59_demo_focus.css" />''',

'''<!-- phase474.3 temporary neutralization: removed local stylesheet :: <link rel="stylesheet" href="css/phase60_live_polish.css" /> -->''':

'''<link rel="stylesheet" href="css/phase60_live_polish.css" />''',

'''<!-- phase474.3 temporary neutralization: removed local stylesheet :: <link rel="stylesheet" href="css/phase61_workspace_consolidation.css" /> -->''':

'''<link rel="stylesheet" href="css/phase61_workspace_consolidation.css" />''',

'''<!-- phase474.3 temporary neutralization: removed local stylesheet :: <link rel="stylesheet" href="css/phase61_tabs_observational_workspace.css" /> -->''':

'''<link rel="stylesheet" href="css/phase61_tabs_observational_workspace.css" />''',

}

for old, new in replacements.items():

    s = s.replace(old, new)

p.write_text(s)

PY

grep -nE 'css/phase61_workspace_consolidation.css|css/phase61_tabs_observational_workspace.css|temporary neutralization: removed local stylesheet' public/dashboard.html || true

git diff -- public/dashboard.html

git add public/dashboard.html

git commit -m "Restore served dashboard layout styles"

git push

