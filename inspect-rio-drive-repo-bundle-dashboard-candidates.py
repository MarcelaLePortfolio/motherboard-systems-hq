
from pathlib import Path

import subprocess, shutil

from datetime import datetime

RIO = Path("/Volumes/Rio Drive/backups")

OUT = Path("_dashboard_candidate_previews/rio-drive-repo-bundles")

WORK = Path("/tmp/rio-drive-repo-bundle-dashboard-candidates")

REPORT = Path("RIO_DRIVE_REPO_BUNDLE_DASHBOARD_CANDIDATES.txt")

MARKERS = [

    "Recent Tasks", "Task History", "Execution Inspector", "Artifact Preview",

    "Preview", "Matilda", "Operator Guidance", "phase715", "phase719",

    "phase728", "phase742", "phase744", "phase530", "telemetry", "Agent Pool"

]

def run(cmd, cwd=None):

    return subprocess.run(cmd, shell=True, cwd=cwd, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.strip()

def marker_summary(path):

    if not path.exists():

        return ""

    text = path.read_text(errors="ignore")

    lower = text.lower()

    hits = []

    for marker in MARKERS:

        c = lower.count(marker.lower())

        if c:

            hits.append(f"{marker}={c}")

    return ", ".join(hits)

def title(path):

    if not path.exists():

        return ""

    for line in path.read_text(errors="ignore").splitlines():

        if "<title" in line.lower():

            return line.strip()

    return ""

if WORK.exists():

    shutil.rmtree(WORK)

WORK.mkdir(parents=True, exist_ok=True)

OUT.mkdir(parents=True, exist_ok=True)

bundles = sorted(RIO.glob("repo_*.bundle"), key=lambda p: p.stat().st_mtime, reverse=True)

lines = []

lines.append("===== RIO DRIVE REPO BUNDLE DASHBOARD CANDIDATES =====")

lines.append(str(datetime.now()))

lines.append("")

lines.append("===== CURRENT HEAD =====")

lines.append(run("git log --oneline -8"))

lines.append("")

lines.append("===== BUNDLES SCANNED =====")

for b in bundles[:20]:

    lines.append(f"{int(b.stat().st_mtime)} {b}")

lines.append("")

count = 0

for bundle in bundles[:20]:

    name = bundle.stem

    clone_dir = WORK / name

    preview_dir = OUT / name

    preview_dir.mkdir(parents=True, exist_ok=True)

    lines.append(f"===== BUNDLE: {bundle.name} =====")

    lines.append(str(bundle))

    clone_result = run(f"git clone --quiet {bundle!s} {clone_dir!s} 2>&1 || true")

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

lines.append("Open the newest repo-bundle preview candidates under:")

lines.append("http://localhost:8099/_dashboard_candidate_previews/rio-drive-repo-bundles/")

lines.append("")

lines.append("Do not restore yet. Pick the exact visually matching dashboard first.")

lines.append(f"candidate_count={count}")

REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(REPORT.read_text(encoding="utf-8"))

