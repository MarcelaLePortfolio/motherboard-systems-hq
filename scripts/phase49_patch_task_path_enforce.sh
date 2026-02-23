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

# Require probe route presence so we can insert nearby deterministically
probe_pat = re.compile(r'''^\s*app\.(?:get|post|all)\(\s*["']\/api\/policy\/probe["']''', re.M)
m_probe = probe_pat.search(s)
if not m_probe:
  print("ERROR: could not find app.<method>(\"/api/policy/probe\" ...) in server.mjs; aborting.", file=sys.stderr)
  sys.exit(2)

# Try to find the end of the probe route handler by scanning forward to the next line that is exactly/mostly '});'
tail = s[m_probe.start():]
lines = tail.splitlines(True)

end_idx = None
depth = 0
started = False

# Lightweight brace/paren tracking to avoid naive '});' matching inside strings
for i, line in enumerate(lines):
  if not started:
    started = True

  # crude but effective: count opens/closes for braces and parens, ignoring obvious comment-only lines
  l = re.sub(r'//.*$', '', line)
  depth += l.count('{') - l.count('}')
  depth += l.count('(') - l.count(')')

  # Heuristic: a line that ends a route is typically '});' or '});\n' and depth returns near baseline
  if re.match(r'^\s*\}\);\s*$', line) and depth <= 0:
    end_idx = i
    break

if end_idx is None:
  # fallback: first '});' after probe start
  for i, line in enumerate(lines):
    if re.match(r'^\s*\}\);\s*$', line):
      end_idx = i
      break

if end_idx is None:
  print("ERROR: could not locate end of /api/policy/probe route handler; aborting.", file=sys.stderr)
  sys.exit(3)

insert_after_pos = m_probe.start() + sum(len(x) for x in lines[:end_idx+1])

# Detect the enforcement flag function name.
# Prefer policyEnforceEnabled(); else accept policy_enforce_enabled(); else bail.
fn = None
for cand in ["policyEnforceEnabled", "policy_enforce_enabled"]:
  if re.search(rf'\b{re.escape(cand)}\b', s):
    fn = cand
    break
if fn is None:
  print("ERROR: could not find policyEnforceEnabled() (or policy_enforce_enabled()) in server.mjs; aborting.", file=sys.stderr)
  sys.exit(4)

snippet = f"""
\n// Phase49: enforce gate on real mutation routes (task path)\napp.use((req, res, next) => {{\n  try {{\n    if (!{fn}()) return next();\n    if (req.path === "/api/policy/probe") return next();\n\n    const m = String(req.method || "GET").toUpperCase();\n    const isMut = (m === "POST" || m === "PUT" || m === "PATCH" || m === "DELETE");\n    if (!isMut) return next();\n\n    // Start narrow: enforce on the real task mutation surface.\n    if (req.path.startsWith("/api/tasks")) {{\n      return res.status(403).json({{\n        error: "policy.enforce",\n        detail: "mutation blocked by enforcement gate (Phase49)",\n        path: req.path,\n        method: m,\n      }});\n    }}\n\n    return next();\n  }} catch (e) {{\n    return next(e);\n  }}\n}});\n"""

out = s[:insert_after_pos] + snippet + s[insert_after_pos:]
p.write_text(out, encoding="utf-8")
print(f"OK: inserted Phase49 enforcement middleware using {fn}()")
PY
