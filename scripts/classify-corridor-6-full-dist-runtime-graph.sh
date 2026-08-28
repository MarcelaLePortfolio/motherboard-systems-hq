#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="ee532d575dbbb725b277118f3bb2ea4623d1aa36"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

echo "=== FULL GOVERNANCE EXECUTION RUNTIME GRAPH ==="

python3 - <<'PY'
from pathlib import Path
import re

roots = [
    Path("server/routes/governance-execution-route.ts"),
    Path("server/execution/production-execution-entry-point.ts"),
]

seen = set()
queue = roots[:]

pattern = re.compile(r'(?:from\s+|require\()["\']([^"\']+)["\']')

while queue:
    path = queue.pop(0)
    if path in seen or not path.exists():
        continue
    seen.add(path)
    print(f"FILE={path}")

    text = path.read_text(errors="ignore")
    for match in pattern.findall(text):
        if not match.startswith("."):
            continue

        base = (path.parent / match)
        candidates = []

        if base.suffix:
            candidates.append(base)
        else:
            candidates.extend([
                Path(str(base) + ".ts"),
                Path(str(base) + ".mjs"),
                Path(str(base) + ".js"),
            ])

        resolved = next((c for c in candidates if c.exists()), None)
        if resolved:
            print(f"  DEP={resolved}")
            if resolved not in seen:
                queue.append(resolved)
        else:
            print(f"  DEP_UNRESOLVED={match}")
PY

echo
echo "=== ALL MJS FILES IN REACHABLE EXECUTION DOMAINS ==="
grep -RInE 'from ["'\''][^"'\'']+\.mjs["'\'']|require\(["'\''][^"'\'']+\.mjs["'\'']\)' \
  server/routes/governance-execution-route.ts \
  server/execution/production-execution-entry-point.ts \
  server/execution/compile-persisted-execution-approval.mjs \
  server/execution/execution-approval-gate.mjs \
  2>/dev/null || true

echo
echo "=== BUILD / DIST PRESENCE ==="
npm run build

for src in \
  server/execution/compile-persisted-execution-approval.mjs \
  server/execution/execution-approval-gate.mjs \
  server/execution/production-governance-execution-composition.mjs
do
  base="$(basename "${src}")"
  dist="dist/server/execution/${base}"
  if [[ -f "${dist}" ]]; then
    echo "${dist}=PASS"
  else
    echo "${dist}=MISSING"
  fi
done

echo
echo "=== CLASSIFICATION ==="
echo "FAILED_HYPOTHESIS_1=SOURCE_MJS_COMPOSITION_IMPORTED_FROM_COMPILED_SERVER"
echo "FAILED_HYPOTHESIS_2=TYPESCRIPT_COMPOSITION_WITH_EXISTING_ROUTE_RUNTIME_GRAPH"
echo "KNOWN_NONEMITTED_RUNTIME_DEPENDENCY=COMPILE_PERSISTED_EXECUTION_APPROVAL_MJS"
echo "NEXT_IMPLEMENTATION_HYPOTHESIS_NOT_YET_ESTABLISHED=YES"
echo "NEXT_ACTION=DETERMINE_COMPLETE_MINIMUM_TSC_EMITTED_RUNTIME_CONVERSION_BOUNDARY"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY=NO"
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
echo "PRODUCTION_CHANGE=NONE"
