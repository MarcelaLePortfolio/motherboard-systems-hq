#!/usr/bin/env bash
set -euo pipefail

FILE="server.mjs"
if [[ ! -f "$FILE" ]]; then
  echo "ERROR: $FILE not found at repo root. Run from repo root." >&2
  exit 1
fi

python3 - << 'PY'
import re, sys, pathlib

p = pathlib.Path("server.mjs")
s = p.read_text(encoding="utf-8")

if "Phase49: enforce gate on real mutation routes" in s:
  print("OK: Phase49 middleware already present; no changes.")
  sys.exit(0)

# Detect the enforcement flag function name.
fn = None
for cand in ["policyEnforceEnabled", "policy_enforce_enabled"]:
  if re.search(rf'\b{re.escape(cand)}\b', s):
    fn = cand
    break
if fn is None:
  print("ERROR: could not find policyEnforceEnabled() (or policy_enforce_enabled()) in server.mjs; aborting.", file=sys.stderr)
  sys.exit(4)

# Find a good insertion point:
# Prefer inserting right AFTER the definition of policyEnforceEnabled / policy_enforce_enabled.
# We handle common forms:
#  - function policyEnforceEnabled(...) { ... }
#  - const policyEnforceEnabled = (...) => { ... }
#  - const policyEnforceEnabled = function(...) { ... }
insert_pos = None

# 1) function form
m = re.search(rf'(^\s*function\s+{re.escape(fn)}\s*\([^)]*\)\s*\{{)', s, re.M)
if m:
  start = m.start(1)
  i = m.end(1)
  depth = 1
  while i < len(s):
    ch = s[i]
    if ch == "{": depth += 1
    elif ch == "}":
      depth -= 1
      if depth == 0:
        i += 1
        # include trailing semicolon/newline if present
        while i < len(s) and s[i] in " \t;":
          i += 1
        if i < len(s) and s[i] == "\n":
          i += 1
        insert_pos = i
        break
    i += 1

# 2) const/let/var assignment to arrow/function
if insert_pos is None:
  m = re.search(rf'(^\s*(?:const|let|var)\s+{re.escape(fn)}\s*=\s*)', s, re.M)
  if m:
    # from assignment start, find first '{' that begins a block, then balance to its end.
    j = m.end(1)
    brace = s.find("{", j)
    if brace != -1:
      i = brace + 1
      depth = 1
      while i < len(s):
        ch = s[i]
        if ch == "{": depth += 1
        elif ch == "}":
          depth -= 1
          if depth == 0:
            i += 1
            # consume to end of statement
            while i < len(s) and s[i] != "\n":
              i += 1
            if i < len(s) and s[i] == "\n":
              i += 1
            insert_pos = i
            break
        i += 1

# 3) fallback: insert BEFORE the first /api route wiring line
if insert_pos is None:
  m = re.search(r'^\s*app\.(?:get|post|put|patch|delete|all|use)\(.*?/api/', s, re.M)
  if m:
    insert_pos = m.start()
  else:
    # last resort: after app creation
    m = re.search(r'^\s*const\s+app\s*=\s*express\(\)\s*;?\s*$', s, re.M)
    if not m:
      print("ERROR: could not find insertion point (no policy fn block, no /api route, no app init).", file=sys.stderr)
      sys.exit(5)
    insert_pos = m.end()

snippet = f"""

// Phase49: enforce gate on real mutation routes (task path)
app.use((req, res, next) => {{
  try {{
    if (!{fn}()) return next();
    if (req.path === "/api/policy/probe") return next();

    const m = String(req.method || "GET").toUpperCase();
    const isMut = (m === "POST" || m === "PUT" || m === "PATCH" || m === "DELETE");
    if (!isMut) return next();

    // Start narrow: enforce on the real task mutation surface.
    if (req.path.startsWith("/api/tasks")) {{
      return res.status(403).json({{
        error: "policy.enforce",
        detail: "mutation blocked by enforcement gate (Phase49)",
        path: req.path,
        method: m,
      }});
    }}

    return next();
  }} catch (e) {{
    return next(e);
  }}
}});
"""

out = s[:insert_pos] + snippet + s[insert_pos:]
p.write_text(out, encoding="utf-8")
print(f"OK: inserted Phase49 enforcement middleware using {fn}()")
PY
