#!/usr/bin/env bash

set -euo pipefail

printf '\n=== CANONICAL APPROVAL SLICE ONE VALIDATION ===\n'

EXPECTED_FILES="$(printf '%s\n' \
  db/matilda-canonical-package-runtime.ts \
  server/index.ts \
  server/routes/matilda-canonical-package-route.ts \
  | sort)"

printf '\n=== COMMIT SCOPE ===\n'
ACTUAL_FILES="$(git diff-tree --no-commit-id --name-only -r HEAD | sort)"

if [ "$ACTUAL_FILES" != "$EXPECTED_FILES" ]; then
  printf '\nSTOP: HEAD does not contain exactly the authorized files.\n'
  printf '\nExpected:\n%s\n' "$EXPECTED_FILES"
  printf '\nActual:\n%s\n' "$ACTUAL_FILES"
  exit 1
fi

printf 'Authorized file scope confirmed.\n'

printf '\n=== DIFF SAFETY CHECK ===\n'
git diff --check HEAD^ HEAD

printf '\n=== READINESS OWNERSHIP CHECK ===\n'
if grep -nE 'schemaInitialized|isCanonicalPackageSchemaReady' \
  db/matilda-canonical-package-runtime.ts; then
  printf '\nSTOP: runtime-local readiness state remains.\n'
  exit 1
fi

grep -nF 'app.locals.canonicalPackageSchemaReady = false' server/index.ts
grep -nF 'app.locals.canonicalPackageSchemaReady = true' server/index.ts
grep -nF 'schemaReady: req.app.locals.canonicalPackageSchemaReady === true' \
  server/routes/matilda-canonical-package-route.ts

printf '\n=== DATABASE GUARANTEE CHECK ===\n'
grep -nF 'CREATE UNIQUE INDEX IF NOT EXISTS' \
  db/matilda-canonical-package-runtime.ts
grep -nF 'idx_matilda_canonical_packages_draft_package_id' \
  db/matilda-canonical-package-runtime.ts
grep -nF 'SELECT package_id FROM matilda_canonical_packages WHERE draft_package_id = ?' \
  db/matilda-canonical-package-runtime.ts

printf '\n=== HTTP SEMANTICS CHECK ===\n'
grep -nF 'CanonicalPackageSchemaUnavailableError' \
  server/routes/matilda-canonical-package-route.ts
grep -nF 'res.status(503)' \
  server/routes/matilda-canonical-package-route.ts
grep -nF 'CANONICAL_PACKAGE_SCHEMA_UNAVAILABLE' \
  db/matilda-canonical-package-runtime.ts
grep -nF 'res.status(400)' \
  server/routes/matilda-canonical-package-route.ts

printf '\n=== AUTHORITY BOUNDARY CHECK ===\n'
for flag in \
  delegation_authorized \
  validation_authorized \
  envelope_authorized \
  execution_authorized
do
  grep -nF "${flag}: false" db/matilda-canonical-package-runtime.ts
  grep -nF "${flag}: false" server/routes/matilda-canonical-package-route.ts
done

printf '\n=== TYPESCRIPT / BUILD VALIDATION ===\n'

if [ -f .matilda-retrieval-trace-check.tsconfig.json ]; then
  npx tsc --project .matilda-retrieval-trace-check.tsconfig.json
else
  npx tsc --noEmit
fi

npm --prefix client run build

printf '\n=== REPOSITORY STATUS ===\n'
git status --short

printf '\n=== VALIDATION COMPLETE ===\n'
printf 'Canonical Approval Slice One passed focused static validation.\n'
