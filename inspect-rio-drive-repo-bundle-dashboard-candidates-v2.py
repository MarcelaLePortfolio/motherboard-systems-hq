
from pathlib import Path

import subprocess

import shutil

from datetime import datetime

ROOTS = [

    Path("/Volumes/Rio Drive/backups"),

    Path("/Volumes/Rio Drive/Motherboard_External_Backup"),

    Path("/Volumes/Rio Drive/Motherboard_Storage"),

    Path("/Volumes/Rio Drive/Motherboard_Systems_HQ"),

]

OUT = Path("_dashboard_candidate_previews/rio-drive-repo-bundles-v2")

WORK = Path("/tmp/rio-drive-repo-bundle-dashboard-candidates-v2")

REPORT = Path("RIO_DRIVE_REPO_BUNDLE_DASHBOARD_CANDIDATES_V2.txt")

MARKERS = [

    "Recent Tasks", "Task History", "Execution Inspector", "Artifact Preview",

    "Preview", "Matilda", "Operator Guidance", "phase715", "phase719",

    "phase728", "phase742", "phase744", "phase530", "telemetry", "Agent Pool"

]

def run(cmd, cwd=None):

    return subprocess.run(cmd, shell=True, cwd=cwd, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.strip()

def read_text(path):

    try:

        return path.read_text(errors="ignore")

    except Exception:

        return ""

def title(path):

    for line in read_text(path).splitlines():

        if "<title" in line.lower():

            return line.strip()

    return ""

def marker_summary(path):

    text = read_text(path).lower()

    hits = []

    for marker in MARKERS:

        count = text.count(marker.lower())

        if count:

            hits.append(f"{marker}={count}")

    return ", ".join(hits)

if WORK.exists():

    shutil.rmtree(WORK)

WORK.mkdir(parents=True, exist_ok=True)

OUT.mkdir(parents=True, exist_ok=True)

bundles = []

for root in ROOTS:

    if root.exists():

        bundles.extend(root.rglob("*.bundle"))

bundles = sorted(set(bundles), key=lambda p: p.stat().st_mtime, reverse=True)

lines = []

lines.append("===== RIO DRIVE REPO BUNDLE DASHBOARD CANDIDATES V2 =====")

lines.append(str(datetime.now()))

lines.append("")

lines.append("===== CURRENT HEAD =====")

lines.append(run("git log --oneline -8"))

lines.append("")

lines.append("===== ROOTS SCANNED =====")

for root in ROOTS:

    lines.append(f"{root}: {'found' if root.exists() else 'missing'}")

lines.append("")

lines.append("===== BUNDLES FOUND =====")

for b in bundles[:40]:

    lines.append(f"{int(b.stat().st_mtime)} {b}")

lines.append("")

count = 0

for bundle in bundles[:25]:

    safe = bundle.stem.replace("/", "_").replace(" ", "_")

    clone_dir = WORK / safe

    preview_dir = OUT / safe

    preview_dir.mkdir(parents=True, exist_ok=True)

    lines.append(f"===== BUNDLE: {bundle.name} =====")

    lines.append(str(bundle))

    clone_result = run(f"git clone --quiet '{bundle}' '{clone_dir}' 2>&1 || true")

    if not clone_dir.exists():

        lines.append("clone failed:")

        lines.append(clone_result)

        lines.append("")

        continue

    lines.append("head:")

    lines.append(run("git log --oneline -5", cwd=clone_dir))

    copied = []

    for rel in ["public/index.html", "public/dashboard.html", "public/bundle.js"]:

        src = clone_dir / rel

        if src.exists():

            dst = preview_dir / Path(rel).name

            shutil.copy2(src, dst)

            copied.append((rel, dst))

    if not copied:

        lines.append("no dashboard public files found")

        lines.append("")

        continue

    for rel, dst in copied:

        lines.append(f"{rel}: {dst.stat().st_size} bytes")

        if dst.suffix == ".html":

            lines.append(f"title: {title(dst)}")

            lines.append(f"markers: {marker_summary(dst)}")

    lines.append(f"open: http://localhost:8099/{preview_dir}/index.html")

    lines.append("")

    count += 1

lines.append("===== NEXT SAFE ACTION =====")

lines.append("Open:")

lines.append("http://localhost:8099/_dashboard_candidate_previews/rio-drive-repo-bundles-v2/")

lines.append("")

lines.append("Do not restore yet. Pick the exact visually matching dashboard first.")

lines.append(f"candidate_count={count}")

REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(REPORT.read_text(encoding="utf-8"))

