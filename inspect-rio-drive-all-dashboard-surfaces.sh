
#!/usr/bin/env bash

set -euo pipefail

REPORT="RIO_DRIVE_ALL_DASHBOARD_SURFACES.txt"

PREVIEW="_dashboard_candidate_previews/rio-drive-all-dashboard-surfaces"

python3 - << 'PY'

from pathlib import Path

import shutil, subprocess, datetime, re

RIO = Path("/Volumes/Rio Drive")

REPORT = Path("RIO_DRIVE_ALL_DASHBOARD_SURFACES.txt")

PREVIEW = Path("_dashboard_candidate_previews/rio-drive-all-dashboard-surfaces")

MARKERS = ["Recent Tasks","Task History","Execution Inspector","Matilda","Operator Guidance","Agent Pool","telemetry","phase719","phase530","artifact preview","Preview","Retry","Requeue"]

def run(cmd):

    return subprocess.run(cmd, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.strip()

def title(p):

    try:

        for line in p.read_text(errors="ignore").splitlines():

            if "<title" in line.lower():

                return line.strip()

    except Exception:

        pass

    return ""

def markers(p):

    try:

        text = p.read_text(errors="ignore").lower()

    except Exception:

        return ""

    hits = []

    for m in MARKERS:

        c = text.count(m.lower())

        if c:

            hits.append(f"{m}={c}")

    return ", ".join(hits)

def score(p):

    s = p.stat().st_size

    m = markers(p)

    bonus = 0

    for token in ["Execution Inspector", "Task History", "Operator Guidance", "phase719", "phase530", "artifact preview", "Preview"]:

        if token in m:

            bonus += 100000

    return bonus + s

sections = []

sections.append("===== RIO DRIVE ALL DASHBOARD SURFACES =====")

sections.append(str(datetime.datetime.now()))

sections.append("")

sections.append("===== CURRENT HEAD =====")

sections.append(run("git log --oneline -8"))

sections.append("")

if not RIO.exists():

    sections.append("Rio Drive not mounted at /Volumes/Rio Drive")

else:

    htmls = []

    for p in RIO.rglob("*"):

        if p.is_file() and p.name in {"index.html", "dashboard.html"} and "/public/" in str(p):

            try:

                if p.stat().st_size > 20000:

                    htmls.append(p)

            except Exception:

                pass

    htmls = sorted(set(htmls), key=lambda p: (score(p), p.stat().st_mtime), reverse=True)

    sections.append("===== TOP DASHBOARD HTML CANDIDATES BY MARKER SCORE =====")

    for p in htmls[:80]:

        sections.append(f"{int(p.stat().st_mtime)} size={p.stat().st_size} score={score(p)} {p}")

        sections.append(f"title: {title(p)}")

        sections.append(f"markers: {markers(p)}")

        sections.append("")

    PREVIEW.mkdir(parents=True, exist_ok=True)

    grouped = []

    used_roots = set()

    for p in htmls:

        parts = list(p.parts)

        if "public" not in parts:

            continue

        root = Path(*parts[:parts.index("public")])

        if root in used_roots:

            continue

        used_roots.add(root)

        grouped.append(root)

        if len(grouped) >= 20:

            break

    sections.append("===== PREVIEW CANDIDATES CREATED =====")

    for i, root in enumerate(grouped, start=1):

        safe = re.sub(r"[^A-Za-z0-9_.-]+", "_", root.name or f"candidate-{i}")

        out = PREVIEW / f"candidate-{i:02d}-{safe}"

        out.mkdir(parents=True, exist_ok=True)

        for rel in ["public/index.html", "public/dashboard.html", "public/bundle.js"]:

            src = root / rel

            if src.exists():

                shutil.copy2(src, out / Path(rel).name)

        sections.append(f"candidate-{i:02d}: {root}")

        if (out / "index.html").exists():

            sections.append(f"open: http://localhost:8099/{out}/index.html")

            sections.append(f"index size: {(out / 'index.html').stat().st_size}")

            sections.append(f"index markers: {markers(out / 'index.html')}")

        elif (out / "dashboard.html").exists():

            sections.append(f"open: http://localhost:8099/{out}/dashboard.html")

            sections.append(f"dashboard size: {(out / 'dashboard.html').stat().st_size}")

            sections.append(f"dashboard markers: {markers(out / 'dashboard.html')}")

        sections.append("")

sections.append("===== NEXT SAFE ACTION =====")

sections.append("Open the candidate preview folder and visually scan the top candidates.")

sections.append("No runtime restore has been performed.")

REPORT.write_text("\n".join(sections) + "\n", encoding="utf-8")

print(REPORT.read_text(encoding="utf-8"))

PY

git add inspect-rio-drive-all-dashboard-surfaces.sh "$REPORT" "$PREVIEW" || true

git commit -m "Inspect all Rio Drive dashboard surfaces" || true

git push

