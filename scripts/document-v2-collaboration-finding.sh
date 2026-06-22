
#!/usr/bin/env bash

set -euo pipefail

FILE="docs/governance/MATILDA_COLLABORATION_MODE_V2_EVIDENCE_LEDGER.md"

echo "Review the following section before creating a ledger entry:"

echo

grep -nA25 -B5 "Attention Preservation and Scrutiny Capacity" "$FILE" || true

