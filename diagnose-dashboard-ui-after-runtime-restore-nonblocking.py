
#!/usr/bin/env python3

from pathlib import Path

import subprocess

import urllib.request

import urllib.error

import re

OUTPUT = Path("DASHBOARD_UI_AFTER_RUNTIME_RESTORE_DIAGNOSIS_NONBLOCKING.txt")

BASE_URL = "http://localhost:8080"

def write(text=""):

    print(text)

    with OUTPUT.open("a", encoding="utf-8") as f:

        f.write(text + "\n")

def run(cmd, timeout=20):

    try:

        result = subprocess.run(cmd, text=True, capture_output=True, timeout=timeout, check=False)

        out = (result.stdout or "") + (result.stderr or "")

        return out.rstrip()

    except Exception as exc:

        return f"ERROR running {' '.join(cmd)}: {exc}"

def fetch(path, method="GET", timeout=5, max_bytes=12000):

    url = BASE_URL + path

    req = urllib.request.Request(url, method=method)

    try:

        with urllib.request.urlopen(req, timeout=timeout) as res:

            body = res.read(max_bytes).decode("utf-8", errors="replace")

            headers = "\n".join(f"{k}: {v}" for k, v in res.headers.items())

            return f"HTTP {res.status}\n{headers}\n\n{body}"

    except urllib.error.HTTPError as exc:

        body = exc.read(max_bytes).decode("utf-8", errors="replace")

        return f"HTTP {exc.code}\n{exc.headers}\n\n{body}"

    except Exception as exc:

        return f"FETCH_ERROR {url}: {exc}"

OUTPUT.unlink(missing_ok=True)

write("===== DASHBOARD UI AFTER RUNTIME RESTORE NONBLOCKING DIAGNOSIS =====")

write(run(["date"]))

write()

write("===== COMPOSE PS =====")

write(run(["docker", "compose", "ps"]))

write()

write("===== DASHBOARD ROOT STATUS =====")

root = fetch("/")

write(root[:12000])

write()

write("===== DASHBOARD HTML ASSET REFERENCES =====")

assets = re.findall(r'(?:src|href)="([^"]+)"', root)

for asset in assets[:120]:

    write(asset)

if not assets:

    write("NO_ASSET_REFERENCES_FOUND")

write()

write("===== KEY API ROUTES =====")

for path in [

    "/api/tasks/health",

    "/api/tasks?limit=12",

    "/agent-status.json",

]:

    write()

    write(f"----- {path} -----")

    write(fetch(path))

write()

write("===== SSE ROUTES HEADER-ONLY / TIMEBOXED =====")

for cmd in [

    ["sh", "-lc", "curl -i --max-time 2 http://localhost:8080/events/task-events || true"],

    ["sh", "-lc", "curl -i --max-time 2 http://localhost:8080/events/artifacts || true"],

]:

    write()

    write("----- " + " ".join(cmd) + " -----")

    write(run(cmd, timeout=5))

write()

write("===== KEY STATIC ASSET STATUS =====")

for asset in assets[:30]:

    if asset.startswith("http") or asset.startswith("#"):

        continue

    if not asset.startswith("/"):

        asset = "/" + asset

    write()

    write(f"----- {asset} -----")

    write(fetch(asset, method="HEAD"))

write()

write("===== TASK COUNTS =====")

write(run(["docker", "compose", "exec", "-T", "postgres", "psql", "-U", "postgres", "-d", "postgres", "-c", "select count(*) as tasks_count from tasks;"]))

write(run(["docker", "compose", "exec", "-T", "postgres", "psql", "-U", "postgres", "-d", "postgres", "-c", "select count(*) as task_events_count from task_events;"]))

write()

write("===== RECENT DASHBOARD LOGS =====")

write(run(["docker", "logs", "--tail", "160", "motherboard-systems-hq-clean-dashboard-1"]))

write()

write("===== WORKTREE =====")

write(run(["git", "status", "--short"]))

write()

write("Inspection complete.")

