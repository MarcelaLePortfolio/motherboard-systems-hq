
#!/usr/bin/env bash

set -euo pipefail

python3 - << 'PY'

from pathlib import Path

p = Path("public/dashboard.html")

s = p.read_text()

s = s.replace(

'''    <section id="phase61-atlas-band" class="space-y-4">

    

    <section id="atlas-status-card" class="bg-gray-800 rounded-2xl shadow-lg border border-gray-700">

    <section id="phase61-atlas-band" class="space-y-4">

<section id="atlas-status-card" class="bg-gray-800 p-6 rounded-2xl shadow-lg border border-gray-700">''',

'''    <section id="phase61-atlas-band" class="space-y-4">

<section id="atlas-status-card" class="bg-gray-800 p-6 rounded-2xl shadow-lg border border-gray-700">'''

)

p.write_text(s)

PY

grep -nE 'phase61-workspace-shell|phase61-atlas-band|atlas-status-card' public/dashboard.html

./inspect-dashboard-inline-script-syntax.sh | tee dashboard-inline-script-syntax-after-atlas-boundary-repair.txt

git add public/dashboard.html repair-dashboard-duplicate-atlas-boundary.sh dashboard-inline-script-syntax-after-atlas-boundary-repair.txt

git commit -m "Repair dashboard duplicate atlas boundary"

git push

