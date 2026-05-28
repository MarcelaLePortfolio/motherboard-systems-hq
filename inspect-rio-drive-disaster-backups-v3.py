
#!/usr/bin/env python3

import os

import shutil

import subprocess

from pathlib import Path

from datetime import datetime

RIO = Path("/Volumes/Rio Drive")

REPORT = Path("RIO_DRIVE_DISASTER_BACKUP_INSPECTION_V3.txt")

PREVIEW = Path("_dashboard_candidate_previews/rio-drive-latest")

def run(cmd):

    return subprocess.run(cmd, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.strip()

def newest_files(root, names):

    matches = []

    for name in names:

        matches.extend(root.rglob(name))

    files = [p for p in matches if p.is_file()]

    return sorted(files, key=lambda p: p.stat().st_mtime, reverse=True)

sections = []

sections.append("===== RIO DRIVE DISASTER BACKUP INSPECTION V3 =====")

sections.append(str(datetime.now()))

sections.append("")

if not RIO.exists():

    sections.append(f"ERROR: Rio Drive is not mounted at: {RIO}")

    REPORT.write_text("\n".join(sections) + "\n")

    print(REPORT.read_text())

    raise SystemExit(1)

sections.append(f"Rio Drive found: {RIO}")

sections.append("")

archives = newest_files(RIO, ["source_*.tar.gz", "repo_*.bundle"])

dash_files = newest_files(RIO, ["index.html", "dashboard.html", "bundle.js"])

sections.append("===== NEWEST ARCHIVES =====")

for p in archives[:80]:

    sections.append(f"{int(p.stat().st_mtime)} {p}")

sections.append("")

sections.append("===== NEWEST DASHBOARD FILES =====")

for p in dash_files[:120]:

    sections.append(f"{int(p.stat().st_mtime)} {p}")

sections.append("")

PREVIEW.mkdir(parents=True, exist_ok=True)

latest_index = newest_files(RIO, ["index.html"])[:1]

latest_dash = newest_files(RIO, ["dashboard.html"])[:1]

latest_bundle = newest_files(RIO, ["bundle.js"])[:1]

sections.append("===== PREVIEW COPY =====")

if latest_index:

    shutil.copy2(latest_index[0], PREVIEW / "index.html")

    sections.append(f"Copied index: {latest_index[0]}")

if latest_dash:

    shutil.copy2(latest_dash[0], PREVIEW / "dashboard.html")

    sections.append(f"Copied dashboard: {latest_dash[0]}")

if latest_bundle:

    shutil.copy2(latest_bundle[0], PREVIEW / "bundle.js")

    sections.append(f"Copied bundle: {latest_bundle[0]}")

sections.append("")

sections.append("Open preview:")

sections.append("http://localhost:8099/_dashboard_candidate_previews/rio-drive-latest/index.html")

sections.append("")

sections.append("Do not restore yet. First confirm this preview visually matches the latest dashboard.")

REPORT.write_text("\n".join(sections) + "\n")

print(REPORT.read_text())

