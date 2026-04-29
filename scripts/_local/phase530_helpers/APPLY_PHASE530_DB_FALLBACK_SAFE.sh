#!/bin/bash
set -euo pipefail

FILE="server/routes/task-events-sse.mjs"

python3 - << 'PY'
from pathlib import Path

path = Path("server/routes/task-events-sse.mjs")
text = path.read_text()

old = '''const DB_URL = process.env.POSTGRES_URL || process.env.DATABASE_URL || "";

let pool = null;

function getPool() {
  if (pool) return pool;
  if (!DB_URL) return null;
  pool = new Pool({ connectionString: DB_URL });
  return pool;
}
'''

new = '''const DB_URL = process.env.POSTGRES_URL || process.env.DATABASE_URL || null;

let pool = null;

function getPool() {
  if (pool) return pool;

  if (!DB_URL) {
    pool = new Pool({
      user: process.env.POSTGRES_USER || "postgres",
      host: process.env.DB_HOST || "postgres",
      database: process.env.POSTGRES_DB || "dashboard_db",
      password: process.env.POSTGRES_PASSWORD || "password",
      port: 5432,
    });
    return pool;
  }

  pool = new Pool({ connectionString: DB_URL });
  return pool;
}
'''

if old not in text:
    raise SystemExit("Expected exact DB_URL/getPool block not found. No changes made.")

path.write_text(text.replace(old, new, 1))
PY

node --check "$FILE"
git diff -- "$FILE"

git add "$FILE"
git commit -m "Apply minimal SSE DB fallback fix"
git push
