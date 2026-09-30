#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== RESUMPTION BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
echo 'EXPECTED_RESUMPTION_HEAD=ba73d93e0'
echo 'ELLIS_SPECIALIZED_LIFECYCLE_AUTHORITY=YES'
echo 'ELLIS_GENERIC_ROUTABILITY=NO'
echo 'IDENTITY_MUTATION_AUTHORIZED=NO'

printf '\n=== CURRENT IDENTITY / ROLE / AUTHORITY TYPES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' --include='*.md' \
  -B25 -A120 \
  '(type|interface|enum|const).{0,100}(Agent|Actor|Authority|Principal|Identity|Role|Coordinator|Executor|Validator|Interpreter|Orchestrator|Worker)' \
  server db docs scripts \
  2>/dev/null | head -n 18000 || true

printf '\n=== EXPLICIT TAXONOMY / CLASSIFICATION LANGUAGE ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.md' --include='*.ts' --include='*.mjs' \
  -B35 -A140 \
  '(taxonomy|classification|identity class|identity type|actor class|agent class|role class|named authority|system authority|operational authority|lifecycle authority|execution authority|routing authority|delegation authority)' \
  docs server db \
  2>/dev/null | head -n 18000 || true

printf '\n=== AUTHORITY DIMENSIONS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.md' \
  -B25 -A100 \
  '(execution_authorized|routing_authorized|delegation_authorized|assignment_authorized|actor_assignment_authorized|mutation_authorized|persistence_authorized|autonomous_authority|new_authority_introduced)' \
  server db docs \
  2>/dev/null | head -n 18000 || true

printf '\n=== GENERIC ROUTABILITY CONTRACTS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  -B30 -A130 \
  '(AgentId|AgentSnapshot|routeTask|allowedAgents|allowed_agents|invalid_target|target must be|assignedAgent|assigned_agent)' \
  server db scripts \
  2>/dev/null | head -n 14000 || true

printf '\n=== SPECIALIZED NAMED AUTHORITIES ===\n'
for name in matilda cade effie atlas ellis; do
  echo
  echo "===== $name ====="
  grep -RniE \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
    --include='*.ts' --include='*.mjs' --include='*.md' \
    -B25 -A100 \
    "\\b${name}\\b.{0,160}(authority|agent|actor|role|coordinator|executor|interpreter|orchestrator|validator|routing|delegation|assignment)|(authority|agent|actor|role|coordinator|executor|interpreter|orchestrator|validator|routing|delegation|assignment).{0,160}\\b${name}\\b" \
    server db docs \
    2>/dev/null | head -n 5000 || true
done

printf '\n=== GOVERNANCE CONSTITUTION / CANONICAL CONTRACTS ===\n'
for f in \
  docs/governance/HQ_ORGANIZATIONAL_CONSTITUTION.md \
  docs/governance/CANONICAL_ENVELOPE_SPECIFICATION.md \
  docs/governance/governance-lifecycle-assignment-boundary-reconciliation.md \
  docs/governance/GOVERNANCE_VALIDATION_CHARTER.md
do
  if [ -f "$f" ]; then
    echo
    echo "===== $f ====="
    sed -n '1,700p' "$f"
  fi
done

printf '\n=== HISTORICAL TAXONOMY EVOLUTION ===\n'
git log --all \
  --date=iso \
  --format='COMMIT=%H%nDATE=%ad%nSUBJECT=%s' \
  -G'(agent|actor|authority|identity|role|coordinator|executor|orchestrator|interpreter|validator)' \
  -- docs/governance server/orchestration server/ellis server/atlas server/cade \
  2>/dev/null | head -n 10000 || true

printf '\n=== IDENTITY VERSUS CAPABILITY EVIDENCE ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.md' \
  -B25 -A100 \
  '(capability|capabilities|caps|requiredCaps).{0,160}(agent|actor|route|delegat|authority)|(agent|actor|route|delegat|authority).{0,160}(capability|capabilities|caps|requiredCaps)' \
  server db docs \
  2>/dev/null | head -n 12000 || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=DOES_THE_REPOSITORY_ALREADY_DEFINE_A_CANONICAL_IDENTITY_TAXONOMY'
echo 'QUESTION_2=IS_AGENT_AN_UMBRELLA_IDENTITY_OR_A_CONTEXT_SPECIFIC_ROUTING_CLASS'
echo 'QUESTION_3=ARE_IDENTITY_ROLE_AUTHORITY_CAPABILITY_AND_ROUTABILITY_SEPARATE_DIMENSIONS'
echo 'QUESTION_4=WHAT_CATEGORY_CANONICALLY_CONTAINS_ELLIS'
echo 'QUESTION_5=WHAT_CATEGORY_CANONICALLY_CONTAINS_MATILDA'
echo 'QUESTION_6=WHAT_CATEGORY_CANONICALLY_CONTAINS_CADE_EFFIE_ATLAS'
echo 'QUESTION_7=CAN_AN_ENTITY_BE_AN_AGENT_WITHOUT_BEING_A_GENERIC_DELEGATION_TARGET'
echo 'QUESTION_8=CAN_ROUTABILITY_BE_DERIVED_FROM_CAPABILITY_AND_AUTHORITY_INSTEAD_OF_IDENTITY'
echo 'QUESTION_9=IS_A_NEW_CANONICAL_IDENTITY_REGISTRY_ACTUALLY_NEEDED'
echo 'QUESTION_10=CAN_EXISTING_CONTRACTS_BE_RECONCILED_WITHOUT_NEW_AUTHORITY'
echo 'DO_NOT_COLLAPSE_IDENTITY_ROLE_AUTHORITY_CAPABILITY_OR_ROUTABILITY=YES'
echo 'IDENTITY_MUTATION=NO'
echo 'ROUTER_MUTATION=NO'
echo 'ALLOWLIST_MUTATION=NO'
echo 'AUTHORITY_MUTATION=NO'
echo 'RUNTIME_MUTATION=NO'
echo 'WORKTREE_CLEANUP=NO'

printf '\n=== FINAL REPOSITORY STATE ===\n'
git status --short
