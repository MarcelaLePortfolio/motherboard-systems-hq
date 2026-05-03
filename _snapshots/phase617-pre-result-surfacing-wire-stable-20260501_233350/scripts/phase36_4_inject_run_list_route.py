#!/usr/bin/env python3
from __future__ import annotations

import os
import re
import sys
from pathlib import Path

ROOT = Path(os.getcwd())

NEEDLE = r"/api/runs/:run_id"
INSERT_NEEDLE_RE = re.compile(r'router\.(get|post|put|delete)\(\s*[\'"]\/api\/runs\/:run_id[\'"]', re.IGNORECASE)

def find_candidate_files() -> list[Path]:
  exts = {".ts", ".tsx", ".js", ".mjs", ".cjs"}
  out: list[Path] = []
  for p in ROOT.rglob("*"):
    if not p.is_file():
      continue
    if p.suffix not in exts:
      continue
    try:
      s = p.read_text(encoding="utf-8", errors="ignore")
    except Exception:
      continue
    if NEEDLE in s or "/api/runs/" in s and ":run_id" in s:
      out.append(p)
  return out

def pick_route_file(files: list[Path]) -> Path:
  matches = []
  for p in files:
    s = p.read_text(encoding="utf-8", errors="ignore")
    if INSERT_NEEDLE_RE.search(s):
      matches.append(p)
  if len(matches) != 1:
    print("ERROR: expected exactly 1 route file containing router.get('/api/runs/:run_id', ...).", file=sys.stderr)
    print("Found:", file=sys.stderr)
    for m in matches:
      print(f"  - {m}", file=sys.stderr)
    sys.exit(1)
  return matches[0]

def infer_db_ident(src: str) -> str:
  # Find first await X.query( ... ) in the file; assume X is the pg client/pool wrapper.
  m = re.search(r"await\s+([A-Za-z_]\w*)\s*\.\s*query\s*\(", src)
  if not m:
    print("ERROR: could not infer DB client identifier (expected pattern: await X.query(...)).", file=sys.stderr)
    sys.exit(1)
  return m.group(1)

def already_has_run_list(src: str) -> bool:
  return re.search(r"router\.\s*get\s*\(\s*[\'\"]\/api\/runs[\'\"]\s*,", src) is not None

def inject(src: str, db: str) -> str:
  if already_has_run_list(src):
    print("OK: /api/runs already present; no changes made.")
    return src

  # Insert immediately before the /api/runs/:run_id route definition.
  m = INSERT_NEEDLE_RE.search(src)
  if not m:
    print("ERROR: insertion point not found.", file=sys.stderr)
    sys.exit(1)

  insert_at = m.start()

  block = f"""
// Phase 36.4: Run list observability (read-only; backed strictly by SQL run_view)
router.get("/api/runs", async (req, res) => {{
  try {{
    const rawLimit = (req.query.limit ?? "") as string;
    const limitParsed = rawLimit === "" ? 50 : Number(rawLimit);
    const limit = Number.isFinite(limitParsed) ? Math.max(1, Math.min(200, Math.trunc(limitParsed))) : 50;

    const rawStatus = (req.query.task_status ?? req.query.status ?? "") as string;
    const statuses = rawStatus
      .split(",")
      .map(s => s.trim())
      .filter(Boolean);
    const taskStatusArr = statuses.length ? statuses : null;

    const rawTerminal = (req.query.is_terminal ?? "") as string;
    const isTerminal =
      rawTerminal === "" ? null :
      rawTerminal === "true" ? true :
      rawTerminal === "false" ? false :
      null;

    const rawSince = (req.query.since_ts ?? "") as string;
    const sinceTs = rawSince === "" ? null : (() => {{
      const n = Number(rawSince);
      return Number.isFinite(n) ? Math.trunc(n) : null;
    }})();

    const q = `
      SELECT
        run_id,
        task_id,
        actor,
        task_status,
        is_terminal,
        last_event_kind,
        last_event_ts,
        last_event_id,
        last_heartbeat_ts,
        heartbeat_age_ms,
        lease_expires_at,
        lease_fresh,
        lease_ttl_ms,
        terminal_event_kind,
        terminal_event_ts,
        terminal_event_id
      FROM run_view
      WHERE ($2::text[] IS NULL OR task_status = ANY($2))
        AND ($3::boolean IS NULL OR is_terminal = $3)
        AND ($4::bigint IS NULL OR last_event_ts >= $4)
      ORDER BY last_event_ts DESC NULLS LAST, last_event_id DESC NULLS LAST, run_id DESC
      LIMIT $1;
    `;

    const r = await {db}.query(q, [limit, taskStatusArr, isTerminal, sinceTs]);

    return res.json({{
      ok: true,
      data: {{
        items: r.rows ?? [],
        next_cursor: null
      }}
    }});
  }} catch (e: any) {{
    return res.status(500).json({{
      ok: false,
      error: e?.message ?? String(e)
    }});
  }}
}});

"""
  return src[:insert_at] + block + src[insert_at:]

def main() -> None:
  files = find_candidate_files()
  route_file = pick_route_file(files)
  src = route_file.read_text(encoding="utf-8", errors="ignore")

  db = infer_db_ident(src)
  new_src = inject(src, db)

  if new_src != src:
    route_file.write_text(new_src, encoding="utf-8")
    print(f"UPDATED: {route_file} (db={db})")
  else:
    print(f"NOOP: {route_file} (db={db})")

if __name__ == "__main__":
  main()
