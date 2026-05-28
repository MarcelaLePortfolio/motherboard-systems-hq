
#!/usr/bin/env python3

import subprocess

from pathlib import Path

from datetime import datetime

REPORT = Path("POST_PHASE715_DASHBOARD_CANDIDATES.txt")

CANDIDATES = [

    "phase716-static-execution-evidence-surface-stable",

    "phase716-renderer-containment-verified",

    "phase717-recent-tasks-polished",

    "phase717-restored-telemetry-console",

    "phase717-stable-telemetry-console",

    "phase718-operator-lineage-ui-stable",

    "phase719-artifact-layer-baseline",

    "phase719-triage-ui-baseline",

    "phase719-recent-tasks-single-owner",

    "phase719-inspect-pill-restored",

    "phase719-session-start-clean",

    "phase728-continuation-sealed-20260517",

    "phase728-semantic-observability-sealed",

    "phase729-preview-aware-classification-sealed",

    "phase730-semantic-section-extraction-sealed",

    "phase731-preview-overlay-mock-validated",

    "phase731-expanded-semantic-analysis-state",

    "phase742d-final-verification-20260526",

    "phase742d-sealed-20260526",

    "phase743-planning-sealed-20260526",

    "phase744-governance-continuity-sealed-20260526",

]

MARKERS = [

    "Recent Tasks",

    "Task History",

    "Execution Inspector",

    "Artifact Preview",

    "Preview",

    "Inspect",

    "Retry",

    "Requeue",

    "Matilda",

    "Operator Guidance",

    "Agent Pool",

    "telemetry",

    "phase530",

    "phase719",

    "semantic",

    "artifact",

]

def run(cmd):

    return subprocess.run(cmd, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.strip()

def exists(ref):

    return subprocess.run(f"git rev-parse --verify --quiet {ref}^{{commit}}", shell=True).returncode == 0

def show(ref, path):

    p = subprocess.run(f"git show {ref}:{path}", shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)

    return p.stdout if p.returncode == 0 else None

parts = []

parts.append("===== POST PHASE715 DASHBOARD CANDIDATES =====")

parts.append(datetime.now().strftime("%a %b %d %H:%M:%S %Z %Y"))

parts.append("")

parts.append("===== CURRENT HEAD =====")

parts.append(run("git log --oneline -8"))

parts.append("")

parts.append("===== CURRENT SERVED SURFACE =====")

for p in ["public/index.html", "public/dashboard.html", "public/bundle.js"]:

    if Path(p).exists():

        parts.append(f"{p}: {Path(p).stat().st_size} bytes")

parts.append("")

parts.append("===== CANDIDATE COMPARISON =====")

for ref in CANDIDATES:

    parts.append("")

    parts.append(f"--- {ref} ---")

    if not exists(ref):

        parts.append("exists: no")

        continue

    parts.append("exists: yes")

    parts.append("commit: " + run(f"git log -1 --oneline {ref}"))

    for path in ["public/index.html", "public/dashboard.html", "public/bundle.js"]:

        content = show(ref, path)

        if content is None:

            parts.append(f"{path}: missing")

            continue

        parts.append(f"{path}: {len(content.encode('utf-8'))} bytes")

        if path.endswith(".html"):

            title = next((line.strip() for line in content.splitlines() if "<title" in line.lower()), "")

            if title:

                parts.append(f"title: {title}")

            lower = content.lower()

            hits = []

            for marker in MARKERS:

                count = lower.count(marker.lower())

                if count:

                    hits.append(f"{marker}={count}")

            if hits:

                parts.append("markers: " + ", ".join(hits))

parts.append("")

parts.append("===== DASHBOARD COMMITS AFTER PHASE715 =====")

parts.append(run("git log --oneline --all --since='2026-05-06' -- public/index.html public/dashboard.html public/css public/js public/bundle.js | head -180"))

parts.append("")

parts.append("===== BACKUP SOURCE ARCHIVES =====")

parts.append(run("find backups external_backups snapshots recovery-vault -maxdepth 3 -type f \\( -iname '*.tar.gz' -o -iname '*.bundle' -o -iname '*dashboard*' \\) 2>/dev/null | sort | head -200"))

parts.append("")

parts.append("===== NEXT SAFE ACTION =====")

parts.append("Pick the candidate that visually matches the remembered dashboard before restoring another surface.")

parts.append("Do not patch runtime again until one exact candidate is selected.")

REPORT.write_text("\n".join(parts) + "\n", encoding="utf-8")

print(REPORT.read_text(encoding="utf-8"))

