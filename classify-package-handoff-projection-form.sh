#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY PACKAGE HANDOFF PROJECTION FORM ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PACKAGE_HANDOFF_CONTRACT"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CANONICAL APPROVAL PERSISTENCE IMPLEMENTATION ==="
for file in \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  db/approval-request-repository.ts \
  db/approval-request-model-assembler.ts \
  routes/api-approval-request.ts
do
  echo "--- ${file} ---"
  if [[ -f "$file" ]]; then
    sed -n '1,1200p' "$file"
  else
    echo "MISSING"
  fi
done

echo
echo "=== GOVERNANCE PACKAGE SCHEMA AND WRITERS ==="
rg -n -C 24 \
  'CREATE TABLE governance_packages|INSERT INTO governance_packages|UPDATE governance_packages|DELETE FROM governance_packages|governance_packages\s*\(' \
  db server routes migrations \
  2>/dev/null | head -n 3200 || true

echo
echo "=== CANONICAL PACKAGE SCHEMA AND WRITERS ==="
rg -n -C 24 \
  'CREATE TABLE matilda_canonical_packages|INSERT INTO matilda_canonical_packages|UPDATE matilda_canonical_packages|DELETE FROM matilda_canonical_packages|matilda_canonical_packages\s*\(' \
  db server routes migrations \
  2>/dev/null | head -n 3200 || true

echo
echo "=== GOVERNANCE PACKAGE RUNTIME SURFACES ==="
rg -l \
  'governance_packages|createGovernancePackage|insertGovernancePackage|persistGovernancePackage|writeGovernancePackage' \
  db server routes \
  2>/dev/null | sort || true

echo
echo "=== CANONICAL TO GOVERNANCE IDENTITY TRANSPORT ==="
rg -n -C 20 \
  'canonical.*governance|governance.*canonical|package_id.*package_version|package_version.*package_id|source_package|canonical_package_id|canonical_package_version|project_id' \
  db server routes \
  2>/dev/null | head -n 3600 || true

echo
echo "=== MISSION READ INPUT CONTRACT ==="
for file in \
  db/mission-read-repository.ts \
  db/mission-read-repository.integration.test.ts
do
  echo "--- ${file} ---"
  if [[ -f "$file" ]]; then
    sed -n '1,1400p' "$file"
  else
    echo "MISSING"
  fi
done

echo
echo "=== PROJECTION / MATERIALIZATION / HANDOFF CONTRACT SEARCH ==="
rg -n -C 20 \
  'read-only|read_only|projection|projected|materializ|handoff|canonical handoff|package handoff|mission package|authoritative package|authority root|new authority' \
  db server routes \
  2>/dev/null | head -n 3600 || true

echo
echo "=== STATIC OWNERSHIP CLASSIFICATION ==="
python3 <<'PY'
from pathlib import Path
import re

roots = [Path("db"), Path("server"), Path("routes")]
files = []

for root in roots:
    if root.exists():
        files.extend(
            p for p in root.rglob("*")
            if p.is_file() and p.suffix in {".ts", ".js", ".mjs", ".sql"}
        )

def read(path):
    try:
        return path.read_text()
    except Exception:
        return ""

canonical_writers = []
governance_writers = []
cross_boundary = []

write_patterns = (
    r"INSERT\s+INTO",
    r"UPDATE\s+",
    r"DELETE\s+FROM",
)

for path in files:
    text = read(path)
    low = text.lower()

    if "matilda_canonical_packages" in low:
        if any(re.search(pattern, text, re.I) for pattern in write_patterns):
            canonical_writers.append(str(path))

    if "governance_packages" in low:
        if any(re.search(pattern, text, re.I) for pattern in write_patterns):
            governance_writers.append(str(path))

    if "matilda_canonical_packages" in low and "governance_packages" in low:
        cross_boundary.append(str(path))

print(
    "CANONICAL_PACKAGE_WRITE_FILES="
    + (",".join(sorted(set(canonical_writers))) if canonical_writers else "NONE")
)
print(
    "GOVERNANCE_PACKAGE_WRITE_FILES="
    + (",".join(sorted(set(governance_writers))) if governance_writers else "NONE")
)
print(
    "FILES_REFERENCING_BOTH_PACKAGE_STORES="
    + (",".join(sorted(set(cross_boundary))) if cross_boundary else "NONE")
)
PY

echo
echo "=== DECISION TEST ==="
echo "QUESTION_1=DOES_AN_EXISTING_RUNTIME_PROJECT_CANONICAL_APPROVAL_INTO_GOVERNANCE_PACKAGES"
echo "QUESTION_2=IF_YES_IS_THAT_PROJECTION_DERIVED_WITHOUT_NEW_AUTHORITY"
echo "QUESTION_3=IF_NO_DOES_MISSION_READ_REQUIRE_GOVERNANCE_PACKAGES_AS_ITS_DURABLE_SOURCE"
echo "QUESTION_4=CAN_HANDOFF_BE_A_READ_ONLY_PROJECTION_OF_CANONICAL_APPROVAL_WITHOUT_A_SECOND_AUTHORITY_ROOT"
echo "QUESTION_5=IF_DURABLE_MATERIALIZATION_IS_REQUIRED_WHICH_EXISTING_BOUNDARY_OWNS_THE_WRITE"

echo
echo "=== CURRENT EVIDENCE-BOUND CLASSIFICATION ==="
echo "CANONICAL_APPROVAL_PERSISTENCE_BOUNDARY=PRIMARY_UPSTREAM_AUTHORITY_CANDIDATE"
echo "CANONICAL_PACKAGE_ROUTE=TRANSPORT_ONLY_UNLESS_WRITE_OWNERSHIP_EVIDENCE_PROVES_OTHERWISE"
echo "APPROVAL_REQUEST=PRE_APPROVAL_READ_MODEL_NOT_HANDOFF_OWNER"
echo "MISSION_READ=DOWNSTREAM_CONSUMER"
echo "MISSION_CONTROL=DOWNSTREAM_CONSUMER"
echo "DELEGATION_VALIDATION_ROUTING_ASSIGNMENT_EXECUTION=OUT_OF_SCOPE"
echo "GOVERNANCE_PACKAGES_PRESENT_AS_DOWNSTREAM_MISSION_SOURCE=YES"
echo "CANONICAL_TO_GOVERNANCE_MATERIALIZATION=NOT_YET_ESTABLISHED"
echo "HANDOFF_FORM=AWAITING_THIS_EVIDENCE"
echo "PROJECT_BOUND_HANDOFF_STARTED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
