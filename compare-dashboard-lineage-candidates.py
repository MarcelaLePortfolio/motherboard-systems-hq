
#!/usr/bin/env python3

import subprocess

from pathlib import Path

REPORT = Path("DASHBOARD_LINEAGE_CANDIDATE_COMPARISON.txt")

CANDIDATES = [

    "phase717-restored-telemetry-console",

    "phase717-stable-telemetry-console",

    "phase718-operator-lineage-ui-stable",

    "phase719-artifact-layer-baseline",

    "phase719-recent-tasks-single-owner",

    "phase719-inspect-pill-restored",

    "phase530-ui-debug-ready",

    "phase531-recent-tasks-layout-stable",

    "phase532-task-history-stable",

    "phase533-execution-inspector-stable",

    "phase598-agent-pool-stable",

    "phase622-passive-guidance-layer-containerized",

    "phase623-passive-guidance-sse-wiring-verified",

    "phase624-ui-guidance-plan-containerized",

    "phase715-pre-execution-evidence-ui",

    "phase717-recent-tasks-polished",

]

MARKERS = [

    "Recent Tasks",

    "Task History",

    "Execution Inspector",

    "Artifact Preview",

    "Inspect",

    "Retry",

    "Requeue",

    "Operator Guidance",

    "Matilda",

    "Agent Pool",

    "telemetry",

    "phase530",

    "phase719",

    "preview",

]

def run(cmd):

    return subprocess.run(

        cmd,

        shell=True,

        text=True,

        stdout=subprocess.PIPE,

        stderr=subprocess.STDOUT,

        check=False,

    ).stdout.rstrip()

def git_show(ref, path):

    return run(f"git show {ref}:{path}")

parts = []

parts.append("===== DASHBOARD LINEAGE CANDIDATE COMPARISON =====")

parts.append(run("date"))

parts.append("")

for ref in CANDIDATES:

    parts.append(f"===== CANDIDATE: {ref} =====")

    exists = run(f"git rev-parse --verify --quiet {ref} >/dev/null && echo yes || echo no")

    parts.append(f"exists: {exists}")

    if exists != "yes":

        parts.append("")

        continue

    for path in ["public/index.html", "public/dashboard.html", "public/bundle.js"]:

        content = git_show(ref, path)

        if "fatal:" in content[:200]:

            parts.append(f"{path}: missing")

            continue

        parts.append(f"{path}: {len(content.encode('utf-8'))} bytes")

        title = ""

        for line in content.splitlines():

            if "<title" in line.lower():

                title = line.strip()

                break

        if title:

            parts.append(f"title: {title}")

        hits = []

        lower = content.lower()

        for marker in MARKERS:

            count = lower.count(marker.lower())

            if count:

                hits.append(f"{marker}={count}")

        if hits:

            parts.append("markers: " + ", ".join(hits))

    parts.append("recent commit:")

    parts.append(run(f"git log -1 --oneline {ref}"))

    parts.append("")

REPORT.write_text("\n".join(parts), encoding="utf-8")

print(REPORT.read_text(encoding="utf-8"))

