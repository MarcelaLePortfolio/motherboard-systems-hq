
#!/usr/bin/env bash

set -euo pipefail

echo "== Execution Bridge Audit =="

echo

echo "-- Searching for execution-related infrastructure --"

find . \

  \( -path "./node_modules" -o -path "./.git" \) -prune -o \

  -type f \

  \( \

    -iname "*execution*" -o \

    -iname "*reconcile*" -o \

    -iname "*diff*" -o \

    -iname "*snapshot*" -o \

    -iname "*apply*" -o \

    -iname "*rollback*" \

  \) \

  -print \

  | sort

echo

echo "-- Searching for Matilda references --"

grep -Rni "Matilda" . \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  || true

echo

echo "-- Searching for runtime mutation indicators --"

grep -RniE "fs\.writeFile|execSync|spawn|docker|kubectl|applyDiff|mutate|executeTask" . \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  || true

echo

echo "Execution gap audit complete."

