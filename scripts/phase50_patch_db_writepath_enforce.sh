#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
import re, sys
from pathlib import Path

def ensure_import(s: str, import_line: str) -> str:
  if import_line in s:
    return s
  # insert after the last import ... from ...; at top
  m = None
  for mm in re.finditer(r'^\s*import\s+.*?;\s*$', s, re.M):
    m = mm
  if m:
    i = m.end()
    return s[:i] + "\n" + import_line + "\n" + s[i:]
  return import_line + "\n" + s

def patch_tasks_mutations():
  p = Path("server/tasks-mutations.mjs")
  if not p.exists():
    print("ERROR: missing server/tasks-mutations.mjs", file=sys.stderr)
    sys.exit(2)
  s = p.read_text(encoding="utf-8")
  if "Phase50: DB write-path enforcement (tasks)" in s:
    print("OK: tasks-mutations already patched")
    return

  s = ensure_import(s, 'import { assertNotEnforced } from "./policy/enforce.mjs";')

  # Add guard inside each exported function (first line of body) for create/update paths.
  # We patch "export async function NAME(...)" blocks by injecting right after "{"
  def inject(fn_name_pat, detail):
    nonlocal s
    rx = re.compile(rf'(^\s*export\s+async\s+function\s+{fn_name_pat}\s*\([^)]*\)\s*\{{)', re.M)
    m = rx.search(s)
    if not m:
      return False
    ins = m.end(1)
    # avoid double insert
    window = s[ins:ins+200]
    if "assertNotEnforced(" in window:
      return True
    s = s[:ins] + f'\n  // Phase50: DB write-path enforcement (tasks)\n  assertNotEnforced("{detail}");\n' + s[ins:]
    return True

  ok_any = False
  ok_any |= inject(r'createTask', "tasks.create")
  ok_any |= inject(r'upsertTask', "tasks.upsert")
  ok_any |= inject(r'updateTask', "tasks.update")
  ok_any |= inject(r'deleteTask', "tasks.delete")
  ok_any |= inject(r'mutateTask', "tasks.mutate")

  # If we didn't find expected names, at least add a module-level exported guard helper usage by inserting a banner near top.
  if not ok_any:
    # fallback: inject a comment marker after imports so we can find this later
    if "assertNotEnforced" not in s:
      s = ensure_import(s, 'import { assertNotEnforced } from "./policy/enforce.mjs";')
    # no function names found -> do nothing else (explicit)
    print("WARN: no known exported mutation function names found in tasks-mutations.mjs; imported assertNotEnforced only.", file=sys.stderr)

  p.write_text(s, encoding="utf-8")
  print("OK: patched server/tasks-mutations.mjs")

def patch_task_events():
  p = Path("server/task-events.mjs")
  if not p.exists():
    print("ERROR: missing server/task-events.mjs", file=sys.stderr)
    sys.exit(3)
  s = p.read_text(encoding="utf-8")
  if "Phase50: DB write-path enforcement (task_events)" in s:
    print("OK: task-events already patched")
    return

  s = ensure_import(s, 'import { assertNotEnforced } from "./policy/enforce.mjs";')

  # Inject in appendTaskEvent at top of function body
  rx = re.compile(r'(^\s*export\s+async\s+function\s+appendTaskEvent\s*\([^)]*\)\s*\{)', re.M)
  m = rx.search(s)
  if not m:
    print("ERROR: could not find export async function appendTaskEvent(...) in server/task-events.mjs", file=sys.stderr)
    sys.exit(4)
  ins = m.end(1)
  window = s[ins:ins+220]
  if "assertNotEnforced(" not in window:
    s = s[:ins] + '\n  // Phase50: DB write-path enforcement (task_events)\n  assertNotEnforced("task_events.append");\n' + s[ins:]

  # Also inject in writeTaskEvent if present (belt & suspenders)
  rx2 = re.compile(r'(^\s*export\s+async\s+function\s+writeTaskEvent\s*\([^)]*\)\s*\{)', re.M)
  m2 = rx2.search(s)
  if m2:
    ins2 = m2.end(1)
    window2 = s[ins2:ins2+220]
    if "assertNotEnforced(" not in window2:
      s = s[:ins2] + '\n  // Phase50: DB write-path enforcement (task_events)\n  assertNotEnforced("task_events.write");\n' + s[ins2:]

  p.write_text(s, encoding="utf-8")
  print("OK: patched server/task-events.mjs")

patch_tasks_mutations()
patch_task_events()
PY
