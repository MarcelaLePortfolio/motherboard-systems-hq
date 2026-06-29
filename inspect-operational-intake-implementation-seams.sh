
#!/usr/bin/env bash

set -euo pipefail

OUT="operational-intake-implementation-seams-inspection.txt"

{

  echo "# Operational Intake Implementation Seams Inspection"

  echo

  echo "Generated: $(date)"

  echo

  echo "## Current Git State"

  git status --short

  echo

  git log --oneline -5

  echo

  echo "## DB Runtime Files"

  find db -type f | sort | grep -E 'governance|lifecycle'

  echo

  echo "## Server Runtime Files"

  find server -type f | sort | grep -E 'governance|lifecycle|ellis'

  echo

  echo "## Tests / Smoke Scripts"

  find . -type f | sort | grep -E 'governance|lifecycle|ellis' | grep -E 'test|smoke|validate'

  echo

  echo "## Drizzle Migrations"

  find drizzle -type f | sort

} > "$OUT"

cat "$OUT"

