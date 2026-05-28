
from pathlib import Path

import os

import shutil

import subprocess

import tarfile

from datetime import datetime

REPORT = Path("LATEST_SNAPSHOT_DASHBOARD_CANDIDATE_INSPECTION_V2.txt")

WORKDIR = Path("/tmp/latest-dashboard-snapshot-inspect-v2")

PREVIEW = Path("_dashboard_candidate_previews/latest-snapshot")

ROOTS = [Path("backups"), Path("external_backups"), Path("snapshots"), Path("recovery-vault")]

MARKERS = [

    "Recent Tasks", "Task History", "Execution Inspector", "Artifact Preview",

    "Matilda", "Operator Guidance", "phase715", "phase719", "phase724",

    "phase725", "phase530", "Preview"

]

def run(cmd):

    return subprocess.run(cmd, shell=True, text=True, capture_output=True).stdout.strip()

def files_matching():

    out = []

    for root in ROOTS:

        if not root.exists():

            continue

        for p in root.rglob("*"):

            if p.is_file() and (p.name.endswith(".tar.gz") or p.name.endswith(".bundle")):

                try:

                    out.append((p.stat().st_mtime, p))

                except OSError:

                    pass

    return sorted(out, key=lambda x: x[0], reverse=True)

def first_file(name):

    matches = list(WORKDIR.rglob(name))

    return matches[0] if matches else None

def marker_lines(path):

    if not path or not path.exists():

        return ["missing"]

    text = path.read_text(errors="ignore")

    lines = []

    for i, line in enumerate(text.splitlines(), 1):

        low = line.lower()

        if any(m.lower() in low for m in MARKERS):

            lines.append(f"{i}:{line[:220]}")

        if len(lines) >= 160:

            break

    return lines or ["no marker hits"]

def wc(path):

    if not path or not path.exists():

        return "missing"

    return f"{path.stat().st_size} {path}"

sections = []

sections.append("===== LATEST SNAPSHOT DASHBOARD CANDIDATE INSPECTION V2 =====")

sections.append(str(datetime.now()))

sections.append("")

sections.append("===== CURRENT HEAD =====")

sections.append(run("git log --oneline -8"))

sections.append("")

all_archives = files_matching()

sections.append("===== LATEST SNAPSHOT ARCHIVES =====")

sections.extend([str(p) for _, p in all_archives[:60]])

sections.append("")

source_archives = [(m, p) for m, p in all_archives if p.name.startswith("source_") and p.name.endswith(".tar.gz")]

latest = source_archives[0][1] if source_archives else None

sections.append("===== LATEST SOURCE SNAPSHOT =====")

sections.append(str(latest) if latest else "NONE")

sections.append("")

if latest:

    if WORKDIR.exists():

        shutil.rmtree(WORKDIR)

    WORKDIR.mkdir(parents=True, exist_ok=True)

    with tarfile.open(latest, "r:gz") as tf:

        tf.extractall(WORKDIR)

    snap_index = first_file("index.html")

    snap_dash_candidates = [p for p in WORKDIR.rglob("dashboard.html") if "/public/" in str(p)]

    snap_dash = snap_dash_candidates[0] if snap_dash_candidates else None

    snap_bundle_candidates = [p for p in WORKDIR.rglob("bundle.js") if "/public/" in str(p)]

    snap_bundle = snap_bundle_candidates[0] if snap_bundle_candidates else None

    sections.append("===== SNAPSHOT FILE SIZE CHECK =====")

    sections.append(wc(snap_index))

    sections.append(wc(snap_dash))

    sections.append(wc(snap_bundle))

    sections.append("")

    sections.append("===== SNAPSHOT INDEX MARKERS =====")

    sections.extend(marker_lines(snap_index))

    sections.append("")

    sections.append("===== SNAPSHOT DASHBOARD MARKERS =====")

    sections.extend(marker_lines(snap_dash))

    sections.append("")

    sections.append("===== CURRENT FILE SIZE CHECK =====")

    for p in [Path("public/index.html"), Path("public/dashboard.html"), Path("public/bundle.js")]:

        sections.append(wc(p))

    sections.append("")

    PREVIEW.mkdir(parents=True, exist_ok=True)

    if snap_index:

        shutil.copy2(snap_index, PREVIEW / "index.html")

    if snap_dash:

        shutil.copy2(snap_dash, PREVIEW / "dashboard.html")

    if snap_bundle:

        shutil.copy2(snap_bundle, PREVIEW / "bundle.js")

    sections.append("===== PREVIEW COPY =====")

    sections.append("http://localhost:8099/_dashboard_candidate_previews/latest-snapshot/index.html")

    sections.append("")

sections.append("===== SAFE NEXT ACTION =====")

sections.append("Open the latest snapshot preview before restoring it.")

sections.append("Do not restore from snapshot until this preview is visually confirmed as the intended latest dashboard.")

REPORT.write_text("\n".join(sections) + "\n")

print(REPORT.read_text())

