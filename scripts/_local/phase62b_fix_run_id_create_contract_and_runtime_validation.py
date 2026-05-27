#!/usr/bin/env python3
from pathlib import Path
import re
import sys

route_file = Path("server/routes/api-tasks-postgres.mjs")
validation_file = Path("scripts/_local/phase62b_run_real_success_rate_runtime_validation.sh")

route_text = route_file.read_text()
route_original = route_text

old_create_fragment = """    const b = _asJson(req);

    // Accept caller-provided task_id; otherwise create a task row + mint a stable string task_id.
    let task_id = b.task_id ?? b.taskId ?? b.id ?? null;

    // Phase52: schema-compat — task_id must never be null (tasks.task_id is NOT NULL)
    if (!task_id) task_id = `t_${crypto.randomUUID()}`;

    // Normalize to string for lifecycle events
    task_id = String(task_id);
"""

new_create_fragment = """    const b = _asJson(req);

    let run_id = b.run_id ?? b.runId ?? null;
    if (!run_id) run_id = `run_${crypto.randomUUID()}`;
    run_id = String(run_id);

    // Accept caller-provided task_id; otherwise create a task row + mint a stable string task_id.
    let task_id = b.task_id ?? b.taskId ?? b.id ?? null;

    // Phase52: schema-compat — task_id must never be null (tasks.task_id is NOT NULL)
    if (!task_id) task_id = `t_${crypto.randomUUID()}`;

    // Normalize to string for lifecycle events
    task_id = String(task_id);
"""

if old_create_fragment not in route_text:
    print("ERROR: create route fragment not found", file=sys.stderr)
    sys.exit(1)

route_text = route_text.replace(old_create_fragment, new_create_fragment, 1)
route_text = route_text.replace("        b.run_id ?? b.runId ?? null,", "        run_id,", 1)
route_text = route_text.replace('      run_id: b.run_id ?? b.runId ?? null,', '      run_id,', 1)
route_text = route_text.replace('    res.status(201).json({ ok: true, task_id, event: evt });', '    res.status(201).json({ ok: true, task_id, run_id, event: evt });', 1)

if route_text == route_original:
    print("ERROR: no route change applied", file=sys.stderr)
    sys.exit(1)

route_file.write_text(route_text)

validation_text = validation_file.read_text()
validation_original = validation_text

success_extract_old = """SUCCESS_TASK_ID="$(
python3 - <<'PY' "${CREATE_SUCCESS_JSON}"
import json, sys
p = json.load(open(sys.argv[1]))
candidates = [
    p.get("task_id"),
    (p.get("event") or {}).get("task_id"),
    (p.get("event") or {}).get("payload", {}).get("task_id"),
    (p.get("data") or {}).get("id"),
]
for v in candidates:
    if v not in (None, ""):
        print(str(v))
        raise SystemExit(0)
raise SystemExit("ERROR: could not extract success task id from create response")
PY
)"
echo "success_task_id=${SUCCESS_TASK_ID}" | tee -a "$OUT"
echo | tee -a "$OUT"
"""

success_extract_new = """SUCCESS_TASK_ID="$(
python3 - <<'PY' "${CREATE_SUCCESS_JSON}"
import json, sys
p = json.load(open(sys.argv[1]))
candidates = [
    p.get("task_id"),
    (p.get("event") or {}).get("task_id"),
    (p.get("event") or {}).get("payload", {}).get("task_id"),
    (p.get("data") or {}).get("id"),
]
for v in candidates:
    if v not in (None, ""):
        print(str(v))
        raise SystemExit(0)
raise SystemExit("ERROR: could not extract success task id from create response")
PY
)"
SUCCESS_RUN_ID="$(
python3 - <<'PY' "${CREATE_SUCCESS_JSON}"
import json, sys
p = json.load(open(sys.argv[1]))
candidates = [
    p.get("run_id"),
    (p.get("event") or {}).get("run_id"),
    (p.get("event") or {}).get("payload", {}).get("run_id"),
    (p.get("data") or {}).get("run_id"),
]
for v in candidates:
    if v not in (None, ""):
        print(str(v))
        raise SystemExit(0)
raise SystemExit("ERROR: could not extract success run id from create response")
PY
)"
echo "success_task_id=${SUCCESS_TASK_ID}" | tee -a "$OUT"
echo "success_run_id=${SUCCESS_RUN_ID}" | tee -a "$OUT"
echo | tee -a "$OUT"
"""

failure_extract_old = """FAILURE_TASK_ID="$(
python3 - <<'PY' "${CREATE_FAILURE_JSON}"
import json, sys
p = json.load(open(sys.argv[1]))
candidates = [
    p.get("task_id"),
    (p.get("event") or {}).get("task_id"),
    (p.get("event") or {}).get("payload", {}).get("task_id"),
    (p.get("data") or {}).get("id"),
]
for v in candidates:
    if v not in (None, ""):
        print(str(v))
        raise SystemExit(0)
raise SystemExit("ERROR: could not extract failure task id from create response")
PY
)"
echo "failure_task_id=${FAILURE_TASK_ID}" | tee -a "$OUT"
echo | tee -a "$OUT"
"""

failure_extract_new = """FAILURE_TASK_ID="$(
python3 - <<'PY' "${CREATE_FAILURE_JSON}"
import json, sys
p = json.load(open(sys.argv[1]))
candidates = [
    p.get("task_id"),
    (p.get("event") or {}).get("task_id"),
    (p.get("event") or {}).get("payload", {}).get("task_id"),
    (p.get("data") or {}).get("id"),
]
for v in candidates:
    if v not in (None, ""):
        print(str(v))
        raise SystemExit(0)
raise SystemExit("ERROR: could not extract failure task id from create response")
PY
)"
FAILURE_RUN_ID="$(
python3 - <<'PY' "${CREATE_FAILURE_JSON}"
import json, sys
p = json.load(open(sys.argv[1]))
candidates = [
    p.get("run_id"),
    (p.get("event") or {}).get("run_id"),
    (p.get("event") or {}).get("payload", {}).get("run_id"),
    (p.get("data") or {}).get("run_id"),
]
for v in candidates:
    if v not in (None, ""):
        print(str(v))
        raise SystemExit(0)
raise SystemExit("ERROR: could not extract failure run id from create response")
PY
)"
echo "failure_task_id=${FAILURE_TASK_ID}" | tee -a "$OUT"
echo "failure_run_id=${FAILURE_RUN_ID}" | tee -a "$OUT"
echo | tee -a "$OUT"
"""

if success_extract_old not in validation_text:
    print("ERROR: success extraction block not found", file=sys.stderr)
    sys.exit(1)
validation_text = validation_text.replace(success_extract_old, success_extract_new, 1)

if failure_extract_old not in validation_text:
    print("ERROR: failure extraction block not found", file=sys.stderr)
    sys.exit(1)
validation_text = validation_text.replace(failure_extract_old, failure_extract_new, 1)

validation_text = validation_text.replace(
    '  -d "{\n    \\"task_id\\":\\"${SUCCESS_TASK_ID}\\",\n    \\"status\\":\\"completed\\",',
    '  -d "{\n    \\"task_id\\":\\"${SUCCESS_TASK_ID}\\",\n    \\"run_id\\":\\"${SUCCESS_RUN_ID}\\",\n    \\"status\\":\\"completed\\",',
    1,
)
validation_text = validation_text.replace(
    '  -d "{\n    \\"task_id\\":\\"${FAILURE_TASK_ID}\\",\n    \\"status\\":\\"failed\\",',
    '  -d "{\n    \\"task_id\\":\\"${FAILURE_TASK_ID}\\",\n    \\"run_id\\":\\"${FAILURE_RUN_ID}\\",\n    \\"status\\":\\"failed\\",',
    1,
)

if validation_text == validation_original:
    print("ERROR: no runtime validation change applied", file=sys.stderr)
    sys.exit(1)

validation_file.write_text(validation_text)

print("Patched create route to mint/surface run_id and updated runtime validation to pass run_id through terminal routes.")
