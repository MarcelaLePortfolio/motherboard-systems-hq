#!/usr/bin/env bash
set -euo pipefail

echo "==== Phase 423.2 Step 1 Execution Anchor Hunt ===="

echo
echo "==== Search: entry / execution / approval / activation candidates ===="
grep -RniE 'entrypoint|run[A-Z].*Entrypoint|execute|execution|attempt|activation|activate|approval|approved|operator.*approv|human_required|self-authorize|authorizationEligible|gateStatus' src || true

echo
echo "==== Search: operator approval / human-required surfaces ===="
grep -RniE 'operator review|operator_review_required|operator approval|approved by operator|human_required|execution_authority' src || true

echo
echo "==== Search: activation / active / enabled surfaces ===="
grep -RniE 'activation|required|active|enabled|eligib|authorizationEligible|readyForLiveOwnerWiring|eligibleForExplicitLiveWiring' src || true

echo
echo "==== Search: exported runtime / entrypoint functions ===="
grep -RniE '^export function (run|create|build|start|begin)[A-Za-z0-9_]+' src || true

echo
echo "==== Candidate files likely to inspect next ===="
grep -RliE 'entrypoint|operator_review_required|human_required|authorizationEligible|eligibleForExplicitLiveWiring|readyForLiveOwnerWiring|execution_authority|activation|approved' src || true

echo
echo "==== End execution anchor hunt ===="
