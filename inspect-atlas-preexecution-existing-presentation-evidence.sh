#!/usr/bin/env bash
set -u

printf '\n===== CONCLUSION TARGET =====\n'
printf '%s\n' 'Determine whether an existing Atlas operator-presentation implementation or preserved candidate can be restored/adapted instead of inventing a new presentation surface.'

printf '\n===== ACTIVE SHELL / WORKSPACE SOURCE =====\n'
grep -RniE -B80 -A300 \
'function Shell|export default function Shell|MatildaChatWorkspace|WorkspaceRegion|activeWorkspace' \
client/src \
--include='*.ts' --include='*.tsx' \
--exclude='*.test.ts' \
2>/dev/null | head -n 6000 || true

printf '\n===== PHASE 7.15 PRE-EXECUTION UI CANDIDATE =====\n'
if test -f "_dashboard_candidate_previews/phase715-pre-execution-evidence-ui.html"; then
  sed -n '1,2600p' "_dashboard_candidate_previews/phase715-pre-execution-evidence-ui.html"
else
  printf '%s\n' 'ACTIVE CANDIDATE PREVIEW NOT FOUND'
fi

printf '\n===== PRE-RESTORE PHASE 7.15 CANDIDATE =====\n'
if test -f "_PRE_RESTORE_BROKEN_STATE/_dashboard_candidate_previews/phase715-pre-execution-evidence-ui.html"; then
  sed -n '1,2600p' "_PRE_RESTORE_BROKEN_STATE/_dashboard_candidate_previews/phase715-pre-execution-evidence-ui.html"
else
  printf '%s\n' 'PRE-RESTORE CANDIDATE PREVIEW NOT FOUND'
fi

printf '\n===== PRESENTATION CLASSIFICATION / INVESTIGATION ARTIFACTS =====\n'
for f in \
  classify-atlas-preexecution-operator-presentation-boundary.sh \
  inspect-atlas-preexecution-operator-presentation-boundary.sh \
  inspect-atlas-preexecution-presentation-integration-boundary.sh \
  investigate-atlas-active-conversation-ui-boundary.sh
do
  if test -f "$f"; then
    printf '\n----- %s -----\n' "$f"
    sed -n '1,2200p' "$f"
  fi
done

printf '\n===== HISTORICAL ATLAS DASHBOARD PLACEMENT SCRIPTS =====\n'
for f in \
  scripts/_local/phase61_move_atlas_outside_workspace_grid_exact.sh \
  scripts/_local/phase61_move_atlas_to_bottom_band.sh \
  scripts/_local/phase61_apply_css_only_atlas_full_width.sh \
  scripts/_local/phase61_verify_atlas_bottom_band.sh \
  scripts/_local/phase61_verify_css_only_atlas_full_width.sh
do
  if test -f "$f"; then
    printf '\n----- %s -----\n' "$f"
    sed -n '1,1800p' "$f"
  fi
done

printf '\n===== ACTIVE ATLAS HTTP CONTRACT =====\n'
sed -n '1,260p' server/routes/atlas/preexecution.ts 2>/dev/null || true

printf '\n===== ACTIVE ATLAS PRESENTATION REFERENCES =====\n'
grep -RniE -B30 -A100 \
'/atlas/preexecution|atlas_preexecution_read_route|lineageSequences|causalExplanation|authorityDecision' \
client public \
--include='*.ts' --include='*.tsx' --include='*.js' --include='*.html' \
2>/dev/null | head -n 5000 || true
