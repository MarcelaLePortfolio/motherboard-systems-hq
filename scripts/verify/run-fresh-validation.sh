#!/bin/bash
set -e

echo "Running Phase 633 fresh DB validation..."

bash scripts/verify/fresh-db-rebuild.sh

echo "Validation run complete. Review output above for:"
echo "- No worker errors"
echo "- tasks table includes next_run_at and completed_at"
