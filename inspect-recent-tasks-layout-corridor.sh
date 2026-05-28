
#!/usr/bin/env bash

set -euo pipefail

REPORT="RECENT_TASKS_LAYOUT_CORRIDOR_INSPECTION.txt"

python3 - << 'PY' | tee "$REPORT"

from pathlib import Path

import re

import urllib.request

from datetime import datetime

print("===== RECENT TASKS LAYOUT CORRIDOR INSPECTION =====")

print(datetime.now().isoformat())

print()

files = [

    Path("public/index.html"),

    Path("public/dashboard.html"),

    Path("public/js/phase530_visible_panels_bridge.js"),

    Path("public/bundle.js"),

]

terms = [

    "recent-tasks-card",

    "recentTasks",

    "recentLogs",

    "renderRecent",

    "taskRows",

    "gridTemplateRows",

    "height = \"50%",

    "height:50%",

    "1fr 1fr",

    "Recent Logs",

    "Task History",

]

for path in files:

    print(f"===== FILE: {path} =====")

    if not path.exists():

        print("missing")

        print()

        continue

    text = path.read_text(encoding="utf-8", errors="replace")

    print(f"size={path.stat().st_size}")

    for term in terms:

        count = text.count(term)

        if count:

            print(f"{term}: {count}")

    print()

    for term in ["recent-tasks-card", "recentTasks", "recentLogs", "renderRecent", "gridTemplateRows", "Recent Logs"]:

        print(f"--- context for {term} ---")

        matches = list(re.finditer(re.escape(term), text))

        if not matches:

            print("none")

            continue

        for m in matches[:8]:

            start = max(0, m.start() - 450)

            end = min(len(text), m.end() + 650)

            snippet = text[start:end]

            print(snippet)

            print("-----")

    print()

bridge = Path("public/js/phase530_visible_panels_bridge.js")

if bridge.exists():

    text = bridge.read_text(encoding="utf-8", errors="replace")

    print("===== EXTRACTED renderRecent FUNCTION CANDIDATE =====")

    m = re.search(r"function renderRecent\(tasks\) \{[\s\S]{0,7000?}", text)

    if m:

        print(m.group(0)[:7000])

    else:

        idx = text.find("function renderRecent")

        print(text[idx:idx+7000] if idx >= 0 else "renderRecent not found")

    print()

print("===== SERVED RUNTIME HTML CHECK =====")

for url in [

    "http://localhost:8080/?v=layout-inspection",

    "http://localhost:8080/dashboard.html?v=layout-inspection",

]:

    print(f"--- {url} ---")

    try:

        with urllib.request.urlopen(url, timeout=8) as res:

            body = res.read().decode("utf-8", errors="replace")

        print(f"status=ok bytes={len(body)}")

        for term in terms:

            count = body.count(term)

            if count:

                print(f"{term}: {count}")

    except Exception as e:

        print(f"error={e}")

    print()

print("===== SAFE CONCLUSION PROMPT =====")

print("Use this report to identify the smallest source-level patch.")

print("Do not apply another layout force patch until the exact constraining wrapper is identified.")

PY

git add inspect-recent-tasks-layout-corridor.sh "$REPORT"

git commit -m "Inspect recent tasks layout corridor"

git push

