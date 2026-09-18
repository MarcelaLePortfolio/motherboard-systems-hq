#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="df4f43023ef72a62f98db3d9d6833ce4831fb9a5"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

cat > client/vite.config.ts <<'EOF_VITE'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      "/api": {
        target: "http://localhost:3000",
        changeOrigin: true,
      },
      "/atlas": {
        target: "http://localhost:3000",
        changeOrigin: true,
      },
    },
  },
});
EOF_VITE

printf '\n=== VERIFY EXACT CHANGE ===\n'
git diff --check
git diff -- client/vite.config.ts

test "$(git diff --name-only)" = "client/vite.config.ts"

printf '\n=== BUILD CLIENT ===\n'
npm --prefix client run build

printf '\n=== COMMIT NARROW PROXY FIX ===\n'
git add -- client/vite.config.ts
test "$(git diff --cached --name-only)" = "client/vite.config.ts"

git commit -m "Proxy Atlas browser requests through Vite"
FIX_HEAD="$(git rev-parse HEAD)"

printf '\n=== PUSH ===\n'
git push origin "$BRANCH"
git fetch origin "$BRANCH"

test "$(git rev-parse HEAD)" = "$FIX_HEAD"
test "$(git rev-parse "origin/$BRANCH")" = "$FIX_HEAD"

printf '\n=== FINAL STATUS ===\n'
echo "ATLAS_VITE_PROXY=IMPLEMENTED"
echo "AUTHORIZED_PATH_ONLY=client/vite.config.ts"
echo "ATLAS_BACKEND_CHANGED=NO"
echo "ATLAS_PERSISTENCE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=RESTART_OR_VERIFY_VITE_AND_PROVE_ATLAS_BROWSER_READBACK"
