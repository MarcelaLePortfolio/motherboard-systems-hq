
#!/usr/bin/env bash

set -euo pipefail

REPORT="RIO_DRIVE_RUNTIME_DASHBOARD_ARTIFACTS.txt"

PREVIEW="_dashboard_candidate_previews/rio-drive-runtime-artifacts"

python3 - << 'PY'

from pathlib import Path

import shutil, subprocess, datetime, re

RIO = Path("/Volumes/Rio Drive")

REPORT = Path("RIO_DRIVE_RUNTIME_DASHBOARD_ARTIFACTS.txt")

PREVIEW = Path("_dashboard_candidate_previews/rio-drive-runtime-artifacts")

MARKERS = [

    "Recent Tasks",

    "Task History",

    "Execution Inspector",

    "Matilda",

    "Operator Guidance",

    "Agent Pool",

    "telemetry",

    "phase719",

    "phase530",

    "artifact preview",

    "Preview",

    "Retry",

    "Requeue",

    "phase61-workspace-grid",

    "phase62-top-row",

    "visible_panels_bridge",

]

def run(cmd):

    return subprocess.run(cmd, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.strip()

def read_text(p, limit=2_000_000):

    try:

        data = p.read_bytes()[:limit]

        return data.decode("utf-8", errors="ignore")

    except Exception:

        return ""

def marker_summary(p):

    text = read_text(p).lower()

    hits = []

    for marker in MARKERS:

        count = text.count(marker.lower())

        if count:

            hits.append(f"{marker}={count}")

    return ", ".join(hits)

def score(p):

    try:

        size = p.stat().st_size

    except Exception:

        return 0

    hits = marker_summary(p)

    bonus = 0

    for token in ["Execution Inspector", "Task History", "Operator Guidance", "phase719", "phase530", "artifact preview", "Preview"]:

        if token in hits:

            bonus += 100000

    return bonus + min(size, 200000)

sections = []

sections.append("===== RIO DRIVE RUNTIME DASHBOARD ARTIFACTS =====")

sections.append(str(datetime.datetime.now()))

sections.append("")

sections.append("===== CURRENT HEAD =====")

sections.append(run("git log --oneline -8"))

sections.append("")

if not RIO.exists():

    sections.append("Rio Drive not mounted at /Volumes/Rio Drive")

else:

    candidates = []

    wanted_exts = {".html", ".js", ".css", ".json", ".tsx", ".ts", ".jsx"}

    for p in RIO.rglob("*"):

        if not p.is_file():

            continue

        name = p.name.lower()

        path_s = str(p).lower()

        if p.suffix.lower() not in wanted_exts:

            continue

        if not any(k in path_s for k in ["dashboard", "bundle", "matilda", "operator", "telemetry", "phase530", "phase719", "artifact", "preview", "execution"]):

            continue

        try:

            if p.stat().st_size < 1000:

                continue

        except Exception:

            continue

        marks = marker_summary(p)

        if marks:

            candidates.append(p)

    candidates = sorted(set(candidates), key=lambda p: (score(p), p.stat().st_mtime), reverse=True)

    sections.append("===== TOP RUNTIME/UI ARTIFACT FILES BY MARKER SCORE =====")

    for p in candidates[:120]:

        sections.append(f"{int(p.stat().st_mtime)} size={p.stat().st_size} score={score(p)} {p}")

        sections.append(f"markers: {marker_summary(p)}")

        sections.append("")

    PREVIEW.mkdir(parents=True, exist_ok=True)

    copied = 0

    sections.append("===== PREVIEW COPIES =====")

    for i, p in enumerate(candidates[:40], start=1):

        safe = re.sub(r"[^A-Za-z0-9_.-]+", "_", "_".join(p.parts[-6:]))

        out = PREVIEW / f"{i:02d}-{safe}"

        shutil.copy2(p, out)

        sections.append(f"{i:02d}: {p}")

        sections.append(f"copy: {out}")

        if out.suffix.lower() == ".html":

            sections.append(f"open: http://localhost:8099/{out}")

        sections.append("")

        copied += 1

    sections.append(f"copied={copied}")

sections.append("")

sections.append("===== DOCKER LOCAL IMAGE CHECK =====")

sections.append(run("docker images --format '{{.Repository}}:{{.Tag}} {{.ID}} {{.CreatedSince}} {{.Size}}' | grep -Ei 'motherboard|dashboard' || true"))

sections.append("")

sections.append("===== DOCKER CONTAINER CHECK =====")

sections.append(run("docker ps -a --format '{{.Names}} {{.Image}} {{.Status}}' | grep -Ei 'motherboard|dashboard' || true"))

sections.append("")

sections.append("===== NEXT SAFE ACTION =====")

sections.append("Review the high-scoring runtime/UI artifact report before restoring anything.")

sections.append("If the remembered UI was runtime-composed, this search is more likely to find the missing surface than public/index.html alone.")

REPORT.write_text("\n".join(sections) + "\n", encoding="utf-8")

print(REPORT.read_text(encoding="utf-8"))

PY

git add inspect-rio-drive-runtime-dashboard-artifacts.sh "$REPORT" "$PREVIEW" || true

git commit -m "Inspect Rio Drive runtime dashboard artifacts" || true

git push

