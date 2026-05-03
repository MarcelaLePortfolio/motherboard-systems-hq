#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path

path = Path("server.mjs")
text = path.read_text()

old = """  const safe = {
    mode: (DB_URL ? "url" : "params"),
    DB_URL_present: Boolean(DB_URL),
    host: o.host || null,
    port: o.port || null,
    user: o.user || null,
    database: o.database || null,
    password_type: typeof o.password,
    password_len: (o.password == null ? null : String(o.password).length),
    has_password: (o.password != null),
  };
  console.log("[db] effective pool config", safe);"""

new = """  const SERVER_DB_URL_HAS_PASSWORD = /\\/\\/[^:]+:[^@]+@/.test(DB_URL_RAW);
  const safe = {
    mode: (DB_URL ? "url" : "params"),
    DB_URL_present: Boolean(DB_URL),
    host: o.host ?? null,
    port: o.port ?? null,
    user: o.user ?? null,
    database: o.database ?? null,
    password_type: (DB_URL ? "url-hidden" : typeof o.password),
    password_len: (DB_URL ? "hidden" : (o.password == null ? null : String(o.password).length)),
    has_password: (DB_URL ? SERVER_DB_URL_HAS_PASSWORD : (o.password != null)),
  };
  console.log("[db] effective pool config", safe);"""

if old not in text:
    raise SystemExit("expected logger block not found in server.mjs")

path.write_text(text.replace(old, new, 1))
print("patched server.mjs")
PY
