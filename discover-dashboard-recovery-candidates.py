
#!/usr/bin/env python3

import os

import subprocess

from pathlib import Path

REPORT = Path("DASHBOARD_RECOVERY_CANDIDATES_DISCOVERY.txt")

def run(cmd):

    try:

        return subprocess.run(

            cmd,

            shell=True,

            text=True,

            stdout=subprocess.PIPE,

            stderr=subprocess.STDOUT,

            check=False,

        ).stdout.rstrip()

    except Exception as exc:

        return f"ERROR: {exc}"

sections = []

def add(title, body):

    sections.append(f"===== {title} =====\n{body}\n")

add("DASHBOARD RECOVERY CANDIDATES DISCOVERY", run("date"))

add("CURRENT HEAD", run("git log --oneline -5"))

add("ALL DASHBOARD-RELATED TAGS", run("git tag | grep -Ei 'phase|golden|dashboard|guidance|operator' | sort || true"))

add("POSSIBLE DASHBOARD BRANCHES", run("git branch -a | grep -Ei 'dashboard|phase-9|guidance|operator|workspace|telemetry' || true"))

add("RECENT STASHES", run("git stash list || true"))

add(

    "POSSIBLE DASHBOARD HTML FILES",

    run("find . -type f \\( -iname '*dashboard*.html' -o -iname '*operator*.html' -o -iname '*workspace*.html' \\) | sort"),

)

add(

    "POSSIBLE DASHBOARD BACKUPS",

    run("find . -type f \\( -iname '*backup*dashboard*' -o -iname '*restore*dashboard*' -o -iname '*golden*dashboard*' \\) | sort"),

)

add(

    "POSSIBLE VISUAL SNAPSHOTS",

    run("find . -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \\) | grep -Ei 'dashboard|workspace|operator|telemetry|matilda' | sort || true"),

)

add(

    "DASHBOARD COMMITS AFTER PHASE 91",

    run("git log --oneline --all --since='2026-03-16' -- public/index.html public/dashboard.html public/css public/js | head -120"),

)

add(

    "EXTERNAL / BACKUP DIRECTORIES",

    run("find . -maxdepth 3 -type d \\( -iname '*backup*' -o -iname '*snapshot*' -o -iname '*recovery*' -o -iname '*archive*' \\) | sort"),

)

add(

    "LIKELY NEXT ACTION",

    "Review candidate branches, tags, snapshots, and screenshots.\nIdentify the exact remembered dashboard lineage before any further restore.",

)

REPORT.write_text("\n".join(sections), encoding="utf-8")

print(REPORT.read_text(encoding="utf-8"))

