
#!/usr/bin/env bash

set -euo pipefail

echo "GOVERNED PLANNING DATAFLOW"

echo

echo "--- route references ---"

rg -n "buildGovernedPlanningArtifactBundle|governed-planning-route" server public

echo

echo "--- bundle builder references ---"

rg -n "buildGovernedPlanningArtifactBundle" .

echo

echo "--- dashboard references to governed planning ---"

rg -n -i "planning preview|governed planning|artifact bundle|approval_required|planning_completed" public server

