
#!/usr/bin/env bash

set -euo pipefail

REPORT="UI_TASK_ACTION_ROUTE_SMOKE.txt"

python3 - << 'PY' | tee "$REPORT"

import json

import subprocess

import urllib.request

from datetime import datetime

def get_json(url):

    with urllib.request.urlopen(url, timeout=10) as response:

        return json.loads(response.read().decode("utf-8"))

def post_json(url, payload):

    data = json.dumps(payload).encode("utf-8")

    req = urllib.request.Request(

        url,

        data=data,

        headers={"Content-Type": "application/json"},

        method="POST",

    )

    with urllib.request.urlopen(req, timeout=10) as response:

        return json.loads(response.read().decode("utf-8"))

print("===== UI TASK ACTION ROUTE SMOKE =====")

print(datetime.now().isoformat())

tasks_payload = get_json("http://localhost:8080/api/tasks?limit=1")

target = (tasks_payload.get("tasks") or [{}])[0].get("task_id") or ""

print(f"TARGET_TASK_ID={target}")

print("\n===== SUBMIT REQUEUE VIA SAME ROUTE USED BY UI =====")

created = post_json("http://localhost:8080/api/delegate-task", {

    "kind": "retry",

    "strategy": "standard",

    "title": f"requeue {target}",

    "meta": {"retry_of_task_id": target},

    "source": "operator-guidance-ui",

})

print(json.dumps(created, indent=2))

print("\n===== VERIFY /api/tasks RESPONSE =====")

tasks_after = get_json("http://localhost:8080/api/tasks?limit=8")

print(json.dumps(tasks_after, indent=2))

print("\n===== VERIFY TASK EVENTS =====")

subprocess.run([

    "docker", "exec", "motherboard-systems-hq-clean-postgres-1",

    "psql", "-U", "postgres", "-d", "postgres",

    "-c", "select id, kind, task_id, run_id, actor, created_at from task_events order by id desc limit 12;"

], check=False)

PY

git add smoke-ui-task-action-route.sh "$REPORT"

git commit -m "Smoke UI task action route"

git push

