#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
from pathlib import Path
import re

def patch(path_str, substitutions):
    path = Path(path_str)
    text = path.read_text()
    original = text

    for pattern, repl, min_count in substitutions:
        text, count = re.subn(pattern, repl, text, flags=re.MULTILINE)
        if count < min_count:
            raise SystemExit(
                f"patch failed for {path_str}\npattern: {pattern}\nexpected at least: {min_count}\nactual: {count}"
            )

    if text != original:
        path.write_text(text)
        print(f"patched {path_str}")
    else:
        print(f"no changes needed for {path_str}")

patch(
    "server/routes/api-tasks-postgres.mjs",
    [
        (
            r'actor:\s*b\.actor\s*\?\?\s*"api",',
            'actor: b.actor ?? b.agent ?? "api",',
            4,
        ),
    ],
)

patch(
    "server/tasks-mutations.mjs",
    [
        (
            r'actor:\s*body\?\.actor\s*\?\?\s*payload\.source,',
            'actor: body?.actor ?? body?.agent ?? payload.agent ?? payload.source,',
            1,
        ),
        (
            r'actor:\s*body\?\.actor\s*\?\?\s*body\?\.source\s*\?\?\s*"api",',
            'actor: body?.actor ?? body?.agent ?? payload.agent ?? body?.source ?? "api",',
            1,
        ),
    ],
)

patch(
    "public/js/phase64_agent_activity_wire.js",
    [
        (
            r'const eventState = String\(payload\?\.state \?\? payload\?\.status \?\? payload\?\.kind \?\? ""\)\.toLowerCase\(\);',
            'const eventState = String(payload?.state ?? payload?.status ?? payload?.kind ?? "").toLowerCase();\n      const eventToken = eventState.split(".").pop();',
            1,
        ),
        (
            r'if \(\s*eventState === "started" \|\|\s*eventState === "running" \|\|\s*eventState === "created" \|\|\s*eventState === "dispatch" \|\|\s*eventState === "assigned"\s*\)',
            'if (\n        eventToken === "started" ||\n        eventToken === "running" ||\n        eventToken === "created" ||\n        eventToken === "dispatch" ||\n        eventToken === "assigned"\n      )',
            1,
        ),
        (
            r'lastEvent: eventState \|\| "running",',
            'lastEvent: eventToken || eventState || "running",',
            1,
        ),
        (
            r'if \(\s*eventState === "completed" \|\|\s*eventState === "failed" \|\|\s*eventState === "cancelled" \|\|\s*eventState === "canceled" \|\|\s*eventState === "timeout" \|\|\s*eventState === "terminal"\s*\)',
            'if (\n        eventToken === "completed" ||\n        eventToken === "failed" ||\n        eventToken === "cancelled" ||\n        eventToken === "canceled" ||\n        eventToken === "timeout" ||\n        eventToken === "terminal"\n      )',
            1,
        ),
        (
            r'lastEvent: eventState \|\| "idle",',
            'lastEvent: eventToken || eventState || "idle",',
            1,
        ),
    ],
)

patch(
    "public/js/phase61_recent_history_wire.js",
    [
        (
            r'agent:\s*row\?\.agent \|\| payload\?\.agent \|\| payload\?\.target \|\| row\?\.actor \|\| row\?\.owner \|\| "unassigned",',
            'agent: row?.agent || payload?.agent || payload?.target || row?.actor || row?.owner || "unassigned",',
            1,
        ),
    ],
)

print("phase64.3 signal-path fixes applied")
PY
