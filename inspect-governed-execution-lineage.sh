
#!/usr/bin/env bash

set -euo pipefail

echo "===== SEARCH GOVERNED EXECUTION LINEAGE ====="

git branch -a | grep -Ei '743|744|govern|execution|matilda|cade|phase74|phase73' || true

echo

echo "===== SEARCH COMMITS ====="

git log --oneline --all --decorate --graph --grep='govern\|execution\|matilda\|cade\|phase743\|phase744' -n 120 || true

echo

echo "===== TRACE KEY FILE HISTORY ====="

git log --all --stat -- \

  server/contracts/execution-envelope.v1.mjs \

  server/routes/governed-planning-route.mjs \

  server/execution/governed-planning-pipeline.mjs \

  server/execution/cade-engineer-adapter.mjs \

  server/execution/governance-validator.mjs \

  server/guards/validate-execution-envelope.mjs \

  | head -400

echo

echo "===== CURRENT GOVERNED EXECUTION FILE HASHES ====="

shasum \

  server/contracts/execution-envelope.v1.mjs \

  server/routes/governed-planning-route.mjs \

  server/execution/governed-planning-pipeline.mjs \

  server/execution/cade-engineer-adapter.mjs \

  server/execution/governance-validator.mjs \

  server/guards/validate-execution-envelope.mjs

echo

echo "===== SEARCH FOR SAME FILES IN GIT HISTORY ====="

git rev-list --all | while read -r rev; do

  for f in \

    server/contracts/execution-envelope.v1.mjs \

    server/routes/governed-planning-route.mjs \

    server/execution/governed-planning-pipeline.mjs

  do

    if git ls-tree -r "$rev" --name-only | grep -qx "$f"; then

      echo "$rev HAS $f"

    fi

  done

done | head -200

