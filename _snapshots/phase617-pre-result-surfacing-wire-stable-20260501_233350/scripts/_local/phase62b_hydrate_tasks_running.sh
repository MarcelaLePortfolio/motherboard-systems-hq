#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

cp public/bundle.js public/bundle.js.bak.phase62b-tasks-running

python3 <<'PY'
from pathlib import Path

path = Path("public/bundle.js")
text = path.read_text()

old = 'let k=new Set,l={created:0,completed:0,failed:0};function I(n){n==="task.created"&&(l.created+=1),n==="task.completed"&&(l.completed+=1),n==="task.failed"&&(l.failed+=1);let o=document.getElementById(S);o&&(o.textContent=`created:${l.created}  completed:${l.completed}  failed:${l.failed}`)}'
new = 'let k=new Set,l={created:0,completed:0,failed:0},Q=new Set,F=document.getElementById("metric-running");function U(){F||(F=document.getElementById("metric-running")),F&&(F.textContent=String(Q.size))}function z(n){return n&&typeof n=="object"?String(n.task_id??n.taskId??n.meta?.task_id??n.meta?.taskId??"").trim():""}function G(n,o){let g=String(n?.kind??o??"").toLowerCase(),e=String(n?.status??n?.meta?.status??"").toLowerCase(),m=z(n);if(!m)return;/task\\.created|task\\.started|task\\.running|task\\.queued|task\\.resumed/.test(g)||/created|started|running|queued|pending|active/.test(e)?Q.add(m):(/task\\.completed|task\\.failed|task\\.cancelled|task\\.canceled|task\\.done/.test(g)||/completed|failed|cancelled|canceled|done|error/.test(e))&&Q.delete(m),U()}function I(n){n==="task.created"&&(l.created+=1),n==="task.completed"&&(l.completed+=1),n==="task.failed"&&(l.failed+=1);let o=document.getElementById(S);o&&(o.textContent=`created:${l.created}  completed:${l.completed}  failed:${l.failed}`),U()}'

if old not in text:
    raise SystemExit("target block 1 not found")

text = text.replace(old, new, 1)

old2 = 'if(!k.has(m)){if(k.add(m),(e.kind==="task.created"||e.kind==="task.completed"||e.kind==="task.failed")&&I(String(e.kind)),E(e,n),window.__UI_DEBUG)try{console.log("[task-events] mb.task.event",e)}catch{}T(e)}}'
new2 = 'if(!k.has(m)){if(k.add(m),(e.kind==="task.created"||e.kind==="task.completed"||e.kind==="task.failed")&&I(String(e.kind)),G(e,n),E(e,n),window.__UI_DEBUG)try{console.log("[task-events] mb.task.event",e)}catch{}T(e)}}'

if old2 not in text:
    raise SystemExit("target block 2 not found")

text = text.replace(old2, new2, 1)

path.write_text(text)
PY

scripts/verify-phase62-dashboard-golden.sh
scripts/verify-phase63-telemetry-baseline.sh
