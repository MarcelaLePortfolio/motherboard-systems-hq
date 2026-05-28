
#!/usr/bin/env bash

set -euo pipefail

REPORT="RIO_DRIVE_LATEST_FULL_SNAPSHOT_INSPECTION.txt"

PREVIEW="_dashboard_candidate_previews/rio-drive-latest-full-snapshot"

python3 - << 'PY'

from pathlib import Path

import shutil

import subprocess

import datetime

RIO = Path("/Volumes/Rio Drive")

REPORT = Path("RIO_DRIVE_LATEST_FULL_SNAPSHOT_INSPECTION.txt")

PREVIEW = Path("_dashboard_candidate_previews/rio-drive-latest-full-snapshot")

def run(cmd):

    return subprocess.run(cmd, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.strip()

def marker_summary(path):

    if not path.exists():

        return ""

    text = path.read_text(errors="ignore")

    markers = [

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

        "retry",

        "requeue",

    ]

    hits = []

    lower = text.lower()

    for marker in markers:

        count = lower.count(marker.lower())

        if count:

            hits.append(f"{marker}={count}")

    return ", ".join(hits)

def title(path):

    if not path.exists():

        return ""

    for line in path.read_text(errors="ignore").splitlines():

        if "<title" in line.lower():

            return line.strip()

    return ""

def newest(paths):

    paths = [p for p in paths if p.exists()]

    if not paths:

        return None

    return max(paths, key=lambda p: p.stat().st_mtime)

sections = []

sections.append("===== RIO DRIVE LATEST FULL SNAPSHOT INSPECTION =====")

sections.append(str(datetime.datetime.now()))

sections.append("")

sections.append("===== CURRENT HEAD =====")

sections.append(run("git log --oneline -8"))

sections.append("")

if not RIO.exists():

    sections.append("Rio Drive not mounted at /Volumes/Rio Drive")

else:

    sections.append(f"Rio Drive found: {RIO}")

    sections.append("")

    snapshot_dirs = []

    roots = [

        RIO / "Motherboard_External_Backup" / "snapshots",

        RIO / "Motherboard_Storage" / "snapshots",

        RIO / "Motherboard_Systems_HQ" / "_snapshots",

    ]

    for root in roots:

        if root.exists():

            for d in root.rglob("*"):

                if d.is_dir() and any((d / candidate).exists() for candidate in ["project/public/index.html", "Motherboard_Systems_HQ/public/index.html", "public/index.html"]):

                    snapshot_dirs.append(d)

    snapshot_dirs = sorted(set(snapshot_dirs), key=lambda p: p.stat().st_mtime, reverse=True)

    sections.append("===== NEWEST FULL SNAPSHOT DIRECTORIES =====")

    for d in snapshot_dirs[:25]:

        sections.append(f"{int(d.stat().st_mtime)} {d}")

    sections.append("")

    candidates = []

    for d in snapshot_dirs[:25]:

        possible_roots = [

            d / "project",

            d / "Motherboard_Systems_HQ",

            d,

        ]

        for root in possible_roots:

            index = root / "public/index.html"

            dash = root / "public/dashboard.html"

            bundle = root / "public/bundle.js"

            if index.exists() or dash.exists():

                candidates.append((d, root, index if index.exists() else None, dash if dash.exists() else None, bundle if bundle.exists() else None))

                break

    sections.append("===== CANDIDATE SNAPSHOT DASHBOARDS =====")

    PREVIEW.mkdir(parents=True, exist_ok=True)

    for i, (snap_dir, root, index, dash, bundle) in enumerate(candidates[:12], start=1):

        name = f"candidate-{i:02d}-{snap_dir.name}".replace(" ", "_")

        out = PREVIEW / name

        out.mkdir(parents=True, exist_ok=True)

        sections.append(f"--- {name} ---")

        sections.append(f"snapshot_dir: {snap_dir}")

        sections.append(f"project_root: {root}")

        if index:

            shutil.copy2(index, out / "index.html")

            sections.append(f"index: {index}")

            sections.append(f"index size: {index.stat().st_size}")

            sections.append(f"index title: {title(index)}")

            sections.append(f"index markers: {marker_summary(index)}")

        if dash:

            shutil.copy2(dash, out / "dashboard.html")

            sections.append(f"dashboard: {dash}")

            sections.append(f"dashboard size: {dash.stat().st_size}")

            sections.append(f"dashboard title: {title(dash)}")

            sections.append(f"dashboard markers: {marker_summary(dash)}")

        if bundle:

            shutil.copy2(bundle, out / "bundle.js")

            sections.append(f"bundle: {bundle}")

            sections.append(f"bundle size: {bundle.stat().st_size}")

        if index:

            sections.append(f"open: http://localhost:8099/{out}/index.html")

        elif dash:

            sections.append(f"open: http://localhost:8099/{out}/dashboard.html")

        sections.append("")

sections.append("===== SAFE NEXT ACTION =====")

sections.append("Open the latest full snapshot preview candidates under:")

sections.append("http://localhost:8099/_dashboard_candidate_previews/rio-drive-latest-full-snapshot/")

sections.append("")

sections.append("Do not restore yet. First visually confirm the matching dashboard candidate.")

REPORT.write_text("\n".join(sections) + "\n", encoding="utf-8")

print(REPORT.read_text(encoding="utf-8"))

PY

git add inspect-rio-drive-latest-full-snapshot.sh "$REPORT" "$PREVIEW" || true

git commit -m "Inspect Rio Drive latest full snapshot dashboard candidates" || true

git push

