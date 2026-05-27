#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
from pathlib import Path

def patch_file(path_str, replacements):
    path = Path(path_str)
    text = path.read_text()
    original = text
    for old, new in replacements:
        if old not in text:
            raise SystemExit(f"required pattern not found in {path_str}:\n{old}")
        text = text.replace(old, new, 1)
    if text != original:
        path.write_text(text)
        print(f"patched {path_str}")
    else:
        print(f"no changes needed for {path_str}")

patch_file(
    "server/tasks-mutations.mjs",
    [
        (
            '      actor: body?.actor ?? payload.source,\n',
            '      actor: body?.actor ?? body?.agent ?? payload.agent ?? payload.source,\n',
        ),
        (
            '      actor: body?.actor ?? body?.source ?? "api",\n',
            '      actor: body?.actor ?? body?.agent ?? payload.agent ?? body?.source ?? "api",\n',
        ),
    ],
)

patch_file(
    "server/routes/api-tasks-postgres.mjs",
    [
        (
            '        actor: b.actor ?? "api",\n',
            '        actor: b.actor ?? b.agent ?? "api",\n',
        ),
        (
            '        actor: b.actor ?? "api",\n',
            '        actor: b.actor ?? b.agent ?? "api",\n',
        ),
        (
            '        actor: b.actor ?? "api",\n',
            '        actor: b.actor ?? b.agent ?? "api",\n',
        ),
        (
            '        actor: b.actor ?? "api",\n',
            '        actor: b.actor ?? b.agent ?? "api",\n',
        ),
    ],
)
PY
