
#!/usr/bin/env python3

import subprocess

from pathlib import Path

from datetime import datetime

OUT = Path("_dashboard_candidate_previews")

REPORT = Path("DASHBOARD_CANDIDATE_PREVIEW_SURFACES.txt")

CANDIDATES = [

    "phase742d-final-verification-20260526",

    "phase744-governance-continuity-sealed-20260526",

    "phase731-expanded-semantic-analysis-state",

    "phase728-continuation-sealed-20260517",

    "phase719-artifact-layer-baseline",

    "phase719-inspect-pill-restored",

    "phase717-restored-telemetry-console",

    "phase715-pre-execution-evidence-ui",

]

def run(cmd):

    return subprocess.run(cmd, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.strip()

def exists(ref):

    return subprocess.run(f"git rev-parse --verify --quiet {ref}^{{commit}}", shell=True).returncode == 0

def show(ref, path):

    p = subprocess.run(f"git show {ref}:{path}", shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    return p.stdout if p.returncode == 0 else None

OUT.mkdir(exist_ok=True)

parts = []

parts.append("===== DASHBOARD CANDIDATE PREVIEW SURFACES =====")

parts.append(datetime.now().isoformat())

parts.append("")

parts.append("This command creates static preview HTML files only.")

parts.append("It does not change the served dashboard runtime.")

parts.append("")

for ref in CANDIDATES:

    if not exists(ref):

        parts.append(f"{ref}: missing")

        continue

    html = show(ref, "public/index.html") or show(ref, "public/dashboard.html")

    if not html:

        parts.append(f"{ref}: no dashboard html found")

        continue

    safe = ref.replace("/", "_")

    out_file = OUT / f"{safe}.html"

    out_file.write_text(html, encoding="utf-8")

    parts.append(f"{ref}")

    parts.append(f"  commit: {run(f'git log -1 --oneline {ref}')}")

    parts.append(f"  preview: {out_file}")

    parts.append(f"  size: {len(html.encode('utf-8'))} bytes")

    parts.append("")

REPORT.write_text("\n".join(parts) + "\n", encoding="utf-8")

print(REPORT.read_text(encoding="utf-8"))

