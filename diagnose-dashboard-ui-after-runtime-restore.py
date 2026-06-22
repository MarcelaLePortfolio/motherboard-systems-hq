
#!/usr/bin/env python3

from pathlib import Path

import subprocess

import urllib.request

import urllib.error

import re

OUTPUT = Path("DASHBOARD_UI_AFTER_RUNTIME_RESTORE_DIAGNOSIS.txt")

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

def fetch(path, method="GET", timeout=5):

    url = BASE_URL + path

    req = urllib.request.Request(url, method=method)

    try:

        with urllib.request.urlopen(req, timeout=timeout) as res:

            body = res.read(12000).decode("utf-8", errors="replace")

            headers = "\n".join(f"{k}: {v}" for k, v in res.headers.items())

            return f"HTTP {res.status}\n{headers}\n\n{body}"

    except urllib.error.HTTPError as exc:

        body = exc.read(12000).decode("utf-8", errors="replace")

        return f"HTTP {exc.code}\n{exc.headers}\n\n{body}"

    except Exception as exc:

        return f"FETCH_ERROR {url}: {exc}"

OUTPUT.unlink(missing_ok=True)

write("===== DASHBOARD UI AFTER RUNTIME RESTORE DIAGNOSIS =====")

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

    "/events/task-events",

    "/events/artifacts",

    "/agent-status.json",

]:

    write()

    write(f"----- {path} -----")

    write(fetch(path))

write()

write("===== KEY STATIC ASSET STATUS =====")

for asset in assets[:30]:

    if asset.startswith("http"):

        continue

    if asset.startswith("#"):

        continue

    if not asset.startswith("/"):

        asset = "/" + asset

    write()

    write(f"----- {asset} -----")

    write(fetch(asset, method="HEAD"))

write()

write("===== PUBLIC DASHBOARD FILES IN CONTAINER =====")

write(run([

    "docker",

    "exec",

    "motherboard-systems-hq-clean-dashboard-1",

    "sh",

    "-lc",

    "find /app/public -maxdepth 3 -type f | sort | head -200"

]))

write()

write("===== SERVER ROUTE MOUNTS =====")

write(run([

    "docker",

    "exec",

    "motherboard-systems-hq-clean-dashboard-1",

    "sh",

    "-lc",

    "grep -n \"app.use\\|app.get\\|app.post\\|events/task-events\\|api/tasks\\|agent-status\" /app/server.mjs | head -220"

]))

write()

write("===== RECENT DASHBOARD LOGS =====")

write(run([

    "docker",

    "logs",

    "--tail",

    "200",

    "motherboard-systems-hq-clean-dashboard-1"

]))

write()

write("===== POSTGRES TABLES =====")

write(run([

    "docker",

    "compose",

    "exec",

    "-T",

    "postgres",

    "psql",

    "-U",

    "postgres",

    "-d",

    "postgres",

    "-c",

    "\\dt"

]))

write()

write("===== TASK COUNTS =====")

write(run([

    "docker",

    "compose",

    "exec",

    "-T",

    "postgres",

    "psql",

    "-U",

    "postgres",

    "-d",

    "postgres",

    "-c",

    "select count(*) as tasks_count from tasks;"

]))

write(run([

    "docker",

    "compose",

    "exec",

    "-T",

    "postgres",

    "psql",

    "-U",

    "postgres",

    "-d",

    "postgres",

    "-c",

    "select count(*) as task_events_count from task_events;"

]))

write()

write("===== GOVERNED ROUTE AUTHORITY ASSERTION =====")

governed = run([

    "sh",

    "-lc",

    "curl -sS -X POST http://localhost:8080/api/governed-planning/dry-run -H 'Content-Type: application/json' --data @server/execution/smoke-test-governed-route-payload.json | node -e 'let s=\"\";process.stdin.on(\"data\",d=>s+=d);process.stdin.on(\"end\",()=>{const b=JSON.parse(s);const a=b.bundle?.execution_authority||b.bundle?.response?.execution_authority||{};console.log(JSON.stringify({ok:b.ok===true,route:b.route,mutation_performed:a.mutation_performed,shell_execution_performed:a.shell_execution_performed,autonomous_execution_performed:a.autonomous_execution_performed},null,2));})'"

])

write(governed)

write()

write("===== WORKTREE =====")

write(run(["git", "status", "--short"]))

write()

write("Inspection complete.")

