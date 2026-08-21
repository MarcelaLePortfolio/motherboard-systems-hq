#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '✅ CORRIDOR 5 · BOUNDED MISSION CONTROL VALIDATION\n'
printf 'STATUS: VALIDATION ONLY\n'
printf '============================================================\n\n'

printf '%s\n' \
'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
'PHASE=PROJECT_SCOPED_MISSION_CONTROL_AND_ACTIVE_MISSION_BINDING' \
'CORRIDOR=PROJECT_ISOLATION_BOUNDARY' \
'IMPLEMENTATION_COMMIT=1e2c8343' \
'BLOCKER_CHECKPOINT=c292352b' \
'ROLLBACK_DR=20260820_221628' \
'ATLAS_CHANGE_AUTHORIZED=NO' \
'ADDITIONAL_IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== CHANGED FILE SCOPE ===\n'
git diff --name-only c828acb8..1e2c8343

printf '\n=== VERIFY ATLAS UNCHANGED BY CORRIDOR 5 ===\n'
if git diff c828acb8..1e2c8343 --name-only | grep -Eq '^routes/atlas/'
then
  echo 'ATLAS_CHANGED_BY_CORRIDOR_5=YES'
  exit 1
else
  echo 'ATLAS_CHANGED_BY_CORRIDOR_5=NO'
fi

printf '\n=== VERIFY PROJECT BINDING CONTRACT ===\n'
grep -Fq 'projectId: string | null;' \
  client/src/mission-control/MissionControlProvider.tsx
grep -Fq 'projectId={activeProjectId}' \
  client/src/shell/WorkspaceMount.tsx
echo 'PROJECT_BINDING_CONTRACT=PASS'

printf '\n=== VERIFY PROJECT CHANGE INVALIDATION ===\n'
grep -Fq 'useEffect(() => {' \
  client/src/mission-control/MissionControlProvider.tsx
grep -Fq 'requestSequenceRef.current += 1;' \
  client/src/mission-control/MissionControlProvider.tsx
grep -Fq 'setMission(null);' \
  client/src/mission-control/MissionControlProvider.tsx
grep -Fq 'setLastPackageId(null);' \
  client/src/mission-control/MissionControlProvider.tsx
grep -Fq 'setStatus("idle");' \
  client/src/mission-control/MissionControlProvider.tsx
echo 'PROJECT_CHANGE_INVALIDATION=PASS'

printf '\n=== VERIFY FAIL-CLOSED PROJECT MISMATCH ===\n'
grep -Fq 'readModel.identity.project_id !== normalizedProjectId' \
  client/src/mission-control/MissionControlProvider.tsx
grep -Fq 'does not belong to the active project' \
  client/src/mission-control/MissionControlProvider.tsx
echo 'PROJECT_MISMATCH_FAIL_CLOSED=PASS'

printf '\n=== VERIFY PROHIBITED SURFACES UNCHANGED ===\n'
for file in \
  db/mission-read-repository.ts \
  routes/api-mission-read.ts \
  client/src/shell/MissionDashboardWorkspace.tsx
do
  if git diff --quiet c828acb8..1e2c8343 -- "$file"; then
    printf '%s=UNCHANGED\n' "$file"
  else
    printf '%s=CHANGED\n' "$file"
    exit 1
  fi
done

printf '\n=== BOUNDED TYPESCRIPT TRANSPILE CHECK ===\n'
node << 'NODE'
const fs = require("fs");
const ts = require("typescript");

const files = [
  "client/src/mission-control/MissionControlProvider.tsx",
  "client/src/shell/WorkspaceMount.tsx",
];

let failed = false;

for (const file of files) {
  const source = fs.readFileSync(file, "utf8");
  const result = ts.transpileModule(source, {
    compilerOptions: {
      target: ts.ScriptTarget.ES2020,
      module: ts.ModuleKind.ESNext,
      jsx: ts.JsxEmit.ReactJSX,
      strict: true,
      esModuleInterop: true,
      skipLibCheck: true,
    },
    fileName: file,
    reportDiagnostics: true,
  });

  const diagnostics = result.diagnostics ?? [];

  if (diagnostics.length > 0) {
    failed = true;
    console.error(`TRANSPILE=${file}:FAIL`);

    for (const diagnostic of diagnostics) {
      console.error(
        ts.flattenDiagnosticMessageText(
          diagnostic.messageText,
          "\n",
        ),
      );
    }
  } else {
    console.log(`TRANSPILE=${file}:PASS`);
  }
}

if (failed) {
  process.exit(1);
}
NODE

printf '\n=== BOUNDED VALIDATION DISPOSITION ===\n'
printf '%s\n' \
'CORRIDOR_5_SPECIFIC_ASSERTIONS=PASS' \
'PROJECT_BINDING_CONTRACT=PASS' \
'PROJECT_CHANGE_INVALIDATION=PASS' \
'PROJECT_MISMATCH_FAIL_CLOSED=PASS' \
'PROHIBITED_SURFACES_UNCHANGED=YES' \
'BOUNDED_TYPESCRIPT_TRANSPILE=PASS' \
'REPOSITORY_WIDE_TYPECHECK=BLOCKED_BY_PRE_EXISTING_ATLAS_ERROR' \
'ATLAS_REPAIR_AUTHORIZED=NO' \
'ADDITIONAL_IMPLEMENTATION_AUTHORIZED=NO' \
'CORRIDOR_5_BOUNDED_VALIDATION=PASS' \
'CORRIDOR_5_CLOSURE_READINESS=READY_FOR_CLASSIFICATION' \
'PRODUCTION_CHANGE=NONE'
