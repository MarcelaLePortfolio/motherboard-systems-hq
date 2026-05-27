#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re

path = Path("server/routes/task-events-sse.mjs")
text = path.read_text()

pattern = re.compile(
    r'(\s*)console\.log\("\[task-events\] pool cfg",\s*\{.*?\n\1\}\);',
    re.DOTALL
)

replacement = """\\1const TASK_EVENTS_DB_URL_RAW = process.env.POSTGRES_URL || process.env.DATABASE_URL || "";
\\1const TASK_EVENTS_DB_URL_HAS_PASSWORD = /\\/\\/[^:]+:[^@]+@/.test(TASK_EVENTS_DB_URL_RAW);
\\1console.log("[task-events] pool cfg", {
\\1  mode: (TASK_EVENTS_DB_URL_RAW ? "url" : "params"),
\\1  DB_URL_present: Boolean(TASK_EVENTS_DB_URL_RAW),
\\1  host: o.host ?? null,
\\1  port: o.port ?? null,
\\1  user: o.user ?? null,
\\1  database: o.database ?? null,
\\1  password_type: (TASK_EVENTS_DB_URL_RAW ? "url-hidden" : typeof o.password),
\\1  password_len: (TASK_EVENTS_DB_URL_RAW ? "hidden" : (o.password == null ? null : String(o.password).length)),
\\1  has_password: (TASK_EVENTS_DB_URL_RAW ? TASK_EVENTS_DB_URL_HAS_PASSWORD : (o.password != null)),
\\1});"""

new_text, count = pattern.subn(replacement, text, count=1)
if count != 1:
    raise SystemExit("failed to replace [task-events] pool cfg logger block")

path.write_text(new_text)
print("patched server/routes/task-events-sse.mjs")
PY
