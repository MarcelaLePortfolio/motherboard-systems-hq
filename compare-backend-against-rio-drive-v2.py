
from pathlib import Path

import subprocess

import filecmp

REPORT = Path("BACKEND_RIO_DRIVE_COMPARISON_V2.txt")

RIO = Path("/Volumes/Rio Drive")

RIO_ROOT = RIO / "Motherboard_Systems_HQ"

KEY_PATHS = [

    "server/contracts/execution-envelope.v1.mjs",

    "server/routes/governed-planning-route.mjs",

    "server/execution/governed-planning-pipeline.mjs",

    "server/execution/cade-engineer-adapter.mjs",

    "server/execution/governance-validator.mjs",

    "server/guards/validate-execution-envelope.mjs",

    "server/routes/api-tasks-postgres.mjs",

    "server/worker/phase26_task_worker.mjs",

    "package.json",

    "docker-compose.yml",

]

def run(cmd):

    return subprocess.run(cmd, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.strip()

lines = []

lines.append("===== BACKEND RIO DRIVE COMPARISON V2 =====")

lines.append(run("date"))

lines.append("")

lines.append("===== CURRENT HEAD =====")

lines.append(run("git log --oneline -10"))

lines.append("")

lines.append("===== RIO DRIVE STATUS =====")

lines.append(f"Rio Drive exists: {RIO.exists()}")

lines.append(f"Rio project root exists: {RIO_ROOT.exists()}")

lines.append("")

lines.append("===== LOCAL BACKEND FILE COUNT =====")

local_files = []

for root in ["server", "routes", "api", "src"]:

    p = Path(root)

    if p.exists():

        local_files.extend(sorted(str(x) for x in p.rglob("*") if x.is_file()))

lines.append(str(len(local_files)))

lines.extend(local_files[:250])

lines.append("")

lines.append("===== KEY BACKEND FILE COMPARISON =====")

for rel in KEY_PATHS:

    current = Path(rel)

    rio_file = RIO_ROOT / rel

    lines.append(f"--- {rel} ---")

    lines.append(f"current exists: {current.exists()}")

    lines.append(f"rio exists: {rio_file.exists()}")

    if current.exists() and rio_file.exists():

        lines.append("MATCH" if filecmp.cmp(current, rio_file, shallow=False) else "DIFFERS")

    lines.append("")

lines.append("===== NEWEST RIO BACKEND FILES =====")

if RIO.exists():

    candidates = []

    keywords = ("server/", "routes/", "api/", "src/", "package.json", "docker-compose", "Dockerfile", "worker", "orchestr", "execution", "governed", "matilda", "cade")

    for p in RIO.rglob("*"):

        try:

            if p.is_file() and any(k.lower() in str(p).lower() for k in keywords):

                candidates.append((p.stat().st_mtime, p.stat().st_size, p))

        except OSError:

            pass

    for mtime, size, p in sorted(candidates, reverse=True)[:300]:

        lines.append(f"{int(mtime)} size={size} {p}")

lines.append("")

lines.append("===== CONCLUSION =====")

lines.append("Backend comparison completed without shell pipe parsing.")

lines.append("Use the DIFFERS/MATCH results above before claiming full backend restoration.")

REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(REPORT.read_text(encoding="utf-8"))

