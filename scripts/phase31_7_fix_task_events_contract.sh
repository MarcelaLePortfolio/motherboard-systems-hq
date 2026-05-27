#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

rg -n --hidden --no-ignore-vcs -S "(/events/task-events|task-events|task_events|task\.event)" server || true
rg -n --hidden --no-ignore-vcs -S "(mb\.task\.event|CustomEvent|dispatchEvent|addEventListener|Recent Tasks)" public app || true

python3 - <<'PY'
from pathlib import Path
import re

root = Path(".")
server = root/"server"
public = root/"public"
app = root/"app"

def pick(pattern, bases):
    hits=[]
    for b in bases:
        if not b.exists(): continue
        for p in b.rglob("*"):
            if p.is_file() and p.suffix.lower() in {".js",".mjs",".ts",".tsx",".html"}:
                try:
                    t=p.read_text(encoding="utf-8", errors="ignore")
                except Exception:
                    continue
                if re.search(pattern, t):
                    hits.append(p)
    return sorted(hits, key=lambda x: str(x))

mapper = pick(r"/events/task-events|task-events|task_events|task\.event", [server])[0]
dash   = pick(r"mb\.task\.event|CustomEvent|dispatchEvent|addEventListener|Recent Tasks", [public, app])[0]

def patch(p, fn):
    t=p.read_text(encoding="utf-8", errors="ignore")
    nt=fn(t)
    if nt!=t:
        p.write_text(nt, encoding="utf-8")

def patch_mapper(t):
    if "payload.taskId" not in t:
        t=re.sub(r"(const\s+payload\s*=\s*[^;]+;)",
                 r"\1\n  if (payload?.task_id!=null && payload.taskId==null) payload.taskId=payload.task_id;\n  if (payload?.run_id!=null && payload.runId==null) payload.runId=payload.run_id;\n  if (payload?.actor==null && payload?.owner!=null) payload.actor=payload.owner;",
                 t, count=1)
    t=t.replace("taskId: payload.task_id","taskId: (payload.taskId ?? payload.task_id ?? null)")
    t=t.replace("runId: payload.run_id","runId: (payload.runId ?? payload.run_id ?? null)")
    t=t.replace("actor: payload.actor","actor: (payload.actor ?? payload.owner ?? null)")
    return t

def ensure_norm(t):
    if "__mbNormalizeTaskEvent" in t: return t
    ins=0
    lines=t.splitlines(True)
    for i,l in enumerate(lines[:80]):
        if l.startswith("import "): ins=i+1
    helper="""
// phase31.7 normalize
function __mbNormalizeTaskEvent(ev){
  const p=(ev?.payload??ev?.detail?.payload??ev?.detail??ev)??{};
  const d=ev?.detail??ev?.data??{};
  return {
    taskId: p.taskId??p.task_id??d.taskId??d.task_id??null,
    runId:  p.runId ??p.run_id ??d.runId ??d.run_id ??null,
    actor:  p.actor ??d.actor ??p.owner ??d.owner ??null,
    kind:   p.kind  ??d.kind  ??null,
    ts:     p.ts    ??d.ts    ??null,
    payload:p
  };
}
"""
    lines.insert(ins, helper+"\n")
    return "".join(lines)

def patch_dash(t):
    t=t.replace("mb.task.events","mb.task.event")
    t=re.sub(r'addEventListener\(["\']task(\.|_)event["\']','addEventListener("mb.task.event"',t)
    t=re.sub(r'new\s+CustomEvent\(["\']task(\.|_)event["\']','new CustomEvent("mb.task.event"',t)
    t=re.sub(r'new\s+CustomEvent\("mb\.task\.event"\s*,\s*\{\s*detail\s*:\s*([^\}]+)\}\s*\)',
             r'new CustomEvent("mb.task.event",{detail:__mbNormalizeTaskEvent(\1)})',t)
    t=re.sub(r'window\.dispatchEvent\(\s*new\s+CustomEvent\("mb\.task\.event"\s*,\s*\{\s*detail\s*:\s*([a-zA-Z_$][\w$]*)\s*\}\s*\)\s*\)',
             r'window.dispatchEvent(new CustomEvent("mb.task.event",{detail:__mbNormalizeTaskEvent(\1)}))',t)
    return t

patch(mapper, patch_mapper)
patch(dash, lambda x: patch_dash(ensure_norm(x)))
PY
rg -n --hidden --no-ignore-vcs -S "mb\\.task\\.event" public app server || true

mkdir -p tmp
curl -sS -N --max-time 6 -H 'Accept: text/event-stream' http://127.0.0.1:8080/events/task-events | sed -n '1,120p' | tee tmp/phase31_7_sse.log || true
