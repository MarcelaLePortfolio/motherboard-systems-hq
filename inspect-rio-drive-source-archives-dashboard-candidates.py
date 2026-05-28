
from pathlib import Path

import tarfile

import shutil

import subprocess

from datetime import datetime

RIO = Path("/Volumes/Rio Drive/backups")

REPORT = Path("RIO_DRIVE_SOURCE_ARCHIVE_DASHBOARD_CANDIDATES.txt")

OUT = Path("_dashboard_candidate_previews/rio-drive-source-archives")

WORK = Path("/tmp/rio-drive-source-archive-dashboard-candidates")

MARKERS = [

    "Recent Tasks",

    "Task History",

    "Execution Inspector",

    "Artifact Preview",

    "Preview",

    "Matilda",

    "Operator Guidance",

    "phase715",

    "phase719",

    "phase728",

    "phase742",

    "phase744",

    "phase530",

    "telemetry",

    "Agent Pool",

]

def run(cmd):

    return subprocess.run(cmd, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.strip()

def safe_extract_member(tf, member_name, dest):

    try:

        member = tf.getmember(member_name)

    except KeyError:

        return None

    dest.parent.mkdir(parents=True, exist_ok=True)

    src = tf.extractfile(member)

    if src is None:

        return None

    dest.write_bytes(src.read())

    return dest

def find_members(tf, suffix):

    return [m.name for m in tf.getmembers() if m.isfile() and m.name.endswith(suffix)]

def marker_summary(path):

    if not path or not path.exists():

        return ""

    text = path.read_text(errors="ignore")

    lower = text.lower()

    hits = []

    for marker in MARKERS:

        count = lower.count(marker.lower())

        if count:

            hits.append(f"{marker}={count}")

    return ", ".join(hits)

def title(path):

    if not path or not path.exists():

        return ""

    for line in path.read_text(errors="ignore").splitlines():

        if "<title" in line.lower():

            return line.strip()

    return ""

if WORK.exists():

    shutil.rmtree(WORK)

WORK.mkdir(parents=True, exist_ok=True)

OUT.mkdir(parents=True, exist_ok=True)

archives = sorted(RIO.glob("source_*.tar.gz"), key=lambda p: p.stat().st_mtime, reverse=True)

lines = []

lines.append("===== RIO DRIVE SOURCE ARCHIVE DASHBOARD CANDIDATES =====")

lines.append(str(datetime.now()))

lines.append("")

lines.append("===== CURRENT HEAD =====")

lines.append(run("git log --oneline -8"))

lines.append("")

lines.append("===== ARCHIVES SCANNED =====")

for archive in archives[:20]:

    lines.append(f"{int(archive.stat().st_mtime)} {archive}")

lines.append("")

candidate_count = 0

for archive in archives[:20]:

    safe_name = archive.name.replace(".tar.gz", "").replace("/", "_")

    target = WORK / safe_name

    preview = OUT / safe_name

    preview.mkdir(parents=True, exist_ok=True)

    lines.append(f"===== ARCHIVE: {archive.name} =====")

    lines.append(str(archive))

    try:

        with tarfile.open(archive, "r:gz") as tf:

            index_members = find_members(tf, "/public/index.html")

            dashboard_members = find_members(tf, "/public/dashboard.html")

            bundle_members = find_members(tf, "/public/bundle.js")

            if not index_members and not dashboard_members:

                lines.append("no public index/dashboard candidate found")

                lines.append("")

                continue

            lines.append("index candidates:")

            lines.extend(index_members[:10] or ["none"])

            lines.append("dashboard candidates:")

            lines.extend(dashboard_members[:10] or ["none"])

            lines.append("bundle candidates:")

            lines.extend(bundle_members[:5] or ["none"])

            chosen_index = index_members[0] if index_members else None

            chosen_dash = dashboard_members[0] if dashboard_members else None

            chosen_bundle = bundle_members[0] if bundle_members else None

            index_out = safe_extract_member(tf, chosen_index, preview / "index.html") if chosen_index else None

            dash_out = safe_extract_member(tf, chosen_dash, preview / "dashboard.html") if chosen_dash else None

            bundle_out = safe_extract_member(tf, chosen_bundle, preview / "bundle.js") if chosen_bundle else None

            if index_out:

                lines.append(f"preview index: {index_out}")

                lines.append(f"index size: {index_out.stat().st_size}")

                lines.append(f"index title: {title(index_out)}")

                lines.append(f"index markers: {marker_summary(index_out)}")

            if dash_out:

                lines.append(f"preview dashboard: {dash_out}")

                lines.append(f"dashboard size: {dash_out.stat().st_size}")

                lines.append(f"dashboard title: {title(dash_out)}")

                lines.append(f"dashboard markers: {marker_summary(dash_out)}")

            if bundle_out:

                lines.append(f"preview bundle: {bundle_out}")

                lines.append(f"bundle size: {bundle_out.stat().st_size}")

            lines.append(f"open: http://localhost:8099/{preview}/index.html")

            candidate_count += 1

    except Exception as e:

        lines.append(f"ERROR: {e}")

    lines.append("")

lines.append("===== NEXT SAFE ACTION =====")

lines.append("Open the newest source-archive preview candidates under:")

lines.append("http://localhost:8099/_dashboard_candidate_previews/rio-drive-source-archives/")

lines.append("")

lines.append("Do not restore yet. Pick the exact visually matching dashboard first.")

lines.append(f"candidate_count={candidate_count}")

REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(REPORT.read_text(encoding="utf-8"))

