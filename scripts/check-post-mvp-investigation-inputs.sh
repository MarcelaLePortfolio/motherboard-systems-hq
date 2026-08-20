#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'POST_MVP_INVESTIGATION_REGISTRY=docs/POST_MVP_NEXT_STEPS.md' \
  'POST_MVP_INVESTIGATION_POLICY=docs/REPOSITORY_INVESTIGATION_POST_MVP_POLICY.md' \
  'QA_RECOVERY_AGENT_ARCHITECTURE=docs/architecture/QA_RECOVERY_AGENT.md'

for file in \
  docs/POST_MVP_NEXT_STEPS.md \
  docs/REPOSITORY_INVESTIGATION_POST_MVP_POLICY.md \
  docs/architecture/QA_RECOVERY_AGENT.md
do
  if [[ ! -f "$file" ]]; then
    echo "MISSING_REQUIRED_POST_MVP_INPUT=$file"
    exit 1
  fi
done

grep -q 'QA Recovery Agent' docs/POST_MVP_NEXT_STEPS.md
grep -q 'docs/POST_MVP_NEXT_STEPS.md' docs/REPOSITORY_INVESTIGATION_POST_MVP_POLICY.md
grep -q 'three failed attempts' docs/architecture/QA_RECOVERY_AGENT.md

printf '%s\n' \
  'POST_MVP_INVESTIGATION_INPUTS_PRESENT=YES' \
  'QA_RECOVERY_AGENT_REGISTERED=YES' \
  'IMPLEMENTATION_AUTHORIZED=NO'
