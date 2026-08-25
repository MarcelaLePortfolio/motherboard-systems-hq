#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY EXACT EMPTY MISSION PRESENTATION VALUES ==="
echo "BASELINE_COMMIT=6ecdca07"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== EVIDENCE-SUPPORTED EMPTY VALUES ==="
echo 'packageId="No active mission"'
echo 'projectId=activeProjectId'
echo 'version=0'
echo 'requestedOutcome="No active mission"'
echo 'stage="idle"'
echo 'owner=""'
echo 'health="idle"'
echo 'awaiting=null'
echo 'artifactCount=0'
echo 'lifecycleEventCount=0'
echo 'integrityWarnings=[]'
echo 'latestTimestamp=null'
echo 'timeline=[]'
echo 'startedTimestamp=null'
echo 'progressStages=null'
echo 'progressPosition=null'
echo 'progressTotal=0'
echo 'nextStageLabel=null'

echo
echo "=== CARD BEHAVIOR VALIDATION ==="
echo "EMPTY_OWNER_RENDERING=Unassigned"
echo "EMPTY_TIMELINE_RENDERING=No_Recent_Activity"
echo "EMPTY_AWAITING_RENDERING=No_Pending_Action"
echo "EMPTY_PROGRESS_RENDERING=EXPLICIT_UNRECOGNIZED_IDLE_STAGE"
echo "EMPTY_AGENT_RENDERING=Unassigned"
echo "INVENTED_MISSION_ACTIVITY=NONE"

echo
echo "=== REQUIRED REPLACEMENT ==="
echo "REMOVE_NON_CONTRACT_FIELD=evidenceCount"
echo "REMOVE_NON_CONTRACT_FIELD=latestEvent"
echo "REMOVE_NON_CONTRACT_FIELD=nextStep"
echo "REMOVE_NON_CONTRACT_FIELD=activeAgent"
echo "ADD_REQUIRED_FIELD=requestedOutcome"
echo "ADD_REQUIRED_FIELD=artifactCount"
echo "ADD_REQUIRED_FIELD=lifecycleEventCount"
echo "ADD_REQUIRED_FIELD=integrityWarnings"
echo "ADD_REQUIRED_FIELD=latestTimestamp"
echo "ADD_REQUIRED_FIELD=timeline"
echo "ADD_REQUIRED_FIELD=startedTimestamp"
echo "ADD_REQUIRED_FIELD=nextStageLabel"
echo "OWNER_NULL_MUST_BECOME_EMPTY_STRING=YES"

echo
echo "=== SAFETY BOUNDARY ==="
echo "MISSION_PRESENTATION_MODEL_CHANGE_REQUIRED=NO"
echo "MISSION_READ_CHANGE_REQUIRED=NO"
echo "SERVER_CHANGE_REQUIRED=NO"
echo "PROJECT_CONTEXT_CHANGE_REQUIRED=NO"
echo "ACTIVE_MISSION_RENDERING_CHANGE_REQUIRED=NO"
echo "ERROR_STATE_CHANGE_REQUIRED=NO"
echo "EMPTY_STATE_ONLY_FIX_IS_SUFFICIENT=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "NEXT_ACTION=AUTHORIZE_ONE_NARROW_EMPTY_MISSION_PRESENTATION_OBJECT_REPAIR_USING_THE_CLASSIFIED_VALUES"
