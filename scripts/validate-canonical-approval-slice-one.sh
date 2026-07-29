#!/usr/bin/env bash

set -euo pipefail

printf '\n=== CANONICAL APPROVAL SLICE ONE VALIDATION ===\n'

AUTHORIZED_FILES="$(printf '%s\n' \
  db/matilda-canonical-package-runtime.ts \
  server/index.ts \
  server/routes/matilda-canonical-package-route.ts \
  | sort)"

IMPLEMENTATION_COMMIT="$(
  git log -1 \
    --format='%H' \
    -- \
    db/matilda-canonical-package-runtime.ts \
    server/index.ts \
    server/routes/matilda-canonical-package-route.ts
)"

if [ -z "$IMPLEMENTATION_COMMIT" ]; then
  printf '\nSTOP: no Canonical Approval implementation commit was found.\n'
  exit 1
fi

printf '\nImplementation commit: %s\n' "$IMPLEMENTATION_COMMIT"

printf '\n=== IMPLEMENTATION COMMIT SCOPE ===\n'

ACTUAL_FILES="$(
  git diff-tree \
    --no-commit-id \
    --name-only \
    -r \
    "$IMPLEMENTATION_COMMIT" \
    | sort
)"

if [ "$ACTUAL_FILES" != "$AUTHORIZED_FILES" ]; then
  printf '\nSTOP: implementation commit does not contain exactly the authorized files.\n'
  printf '\nExpected:\n%s\n' "$AUTHORIZED_FILES"
  printf '\nActual:\n%s\n' "$ACTUAL_FILES"
  exit 1
fi

printf 'Authorized implementation scope confirmed.\n'

printf '\n=== IMPLEMENTATION DIFF SAFETY CHECK ===\n'
git diff --check "${IMPLEMENTATION_COMMIT}^" "$IMPLEMENTATION_COMMIT"

printf '\n=== READINESS OWNERSHIP CHECK ===\n'

if grep -nE 'schemaInitialized|isCanonicalPackageSchemaReady' \
  db/matilda-canonical-package-runtime.ts
then
  printf '\nSTOP: runtime-local readiness state remains.\n'
  exit 1
fi

grep -nF 'app.locals.canonicalPackageSchemaReady = false' \
  server/index.ts

grep -nF 'app.locals.canonicalPackageSchemaReady = true' \
  server/index.ts

grep -nF \
  'schemaReady: req.app.locals.canonicalPackageSchemaReady === true' \
  server/routes/matilda-canonical-package-route.ts

printf '\n=== DATABASE GUARANTEE CHECK ===\n'

grep -nF 'CREATE UNIQUE INDEX IF NOT EXISTS' \
  db/matilda-canonical-package-runtime.ts

grep -nF 'idx_matilda_canonical_packages_draft_package_id' \
  db/matilda-canonical-package-runtime.ts

grep -nF \
  'SELECT package_id FROM matilda_canonical_packages WHERE draft_package_id = ?' \
  db/matilda-canonical-package-runtime.ts

grep -nF 'UNIQUE constraint failed' \
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
  grep -nF "${flag}: false" \
    db/matilda-canonical-package-runtime.ts

  grep -nF "${flag}: false" \
    server/routes/matilda-canonical-package-route.ts
done

printf '\n=== ROUTE MOUNT CHECK ===\n'

grep -nF \
  'import matildaCanonicalPackageRouter from "./routes/matilda-canonical-package-route"' \
  server/index.ts

grep -nF 'app.use(matildaCanonicalPackageRouter)' \
  server/index.ts

grep -nF 'initializeCanonicalPackageSchema();' \
  server/index.ts

printf '\n=== SERVER MODULE RESOLUTION CHECK ===\n'

BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/canonical-approval-build.XXXXXX")"

cleanup() {
  rm -rf "$BUILD_DIR"
}

trap cleanup EXIT

npx esbuild \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  server/index.ts \
  --bundle \
  --platform=node \
  --format=esm \
  --packages=external \
  --outdir="$BUILD_DIR"

test -f "$BUILD_DIR/db/matilda-canonical-package-runtime.js"
test -f "$BUILD_DIR/server/routes/matilda-canonical-package-route.js"
test -f "$BUILD_DIR/server/index.js"

printf 'Canonical Approval server modules parsed and resolved successfully.\n'

printf '\n=== CLIENT BUILD ===\n'
npm --prefix client run build

printf '\n=== KNOWN UNRELATED REPOSITORY TYPE DEBT ===\n'
printf '%s\n' \
  'Repository-wide TypeScript validation remains unavailable for this corridor because:' \
  '1. routes/atlas/why.ts contains an unrelated pre-existing argument-count error.' \
  '2. the standalone TypeScript environment does not currently provide the Node type definitions.' \
  'Neither condition was introduced or modified by the Canonical Approval implementation.'

printf '\n=== REPOSITORY STATUS ===\n'
git status --short

printf '\n=== VALIDATION COMPLETE ===\n'
printf 'Canonical Approval Slice One passed focused static and module-resolution validation.\n'
