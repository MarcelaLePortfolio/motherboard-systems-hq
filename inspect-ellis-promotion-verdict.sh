#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== ELLIS RECONCILIATION EVIDENCE FILES ===\n'
for f in \
  evidence/ellis-assessment/11-ellis-agent-justification-inspection.txt \
  evidence/ellis-assessment/12-ellis-constituent-authority-correction.txt \
  evidence/ellis-assessment/15-ellis-constituent-lineage-summary.txt \
  evidence/ellis-assessment/18-ellis-introduction-verdict.txt \
  evidence/ellis-assessment/21-original-ellis-definition-finding.txt \
  evidence/ellis-assessment/24-ellis-authority-drift-finding.txt \
  evidence/ellis-assessment/25-ellis-implementation-shape-conclusion.txt \
  evidence/ellis-assessment/32-ellis-runtime-invocation-boundary-assessment.txt \
  docs/governance/governance-lifecycle-assignment-boundary-reconciliation.md \
  docs/governance/HQ_ORGANIZATIONAL_CONSTITUTION.md \
  docs/governance/DEFERRED_SHAPE_REGISTRY.md
do
  if [ -f "$f" ]; then
    echo
    echo "===== $f ====="
    sed -n '1,420p' "$f"
  fi
done

printf '\n=== ELLIS PROMOTION / ROLE TRANSITION COMMITS ===\n'
git log --all \
  --date=iso \
  --format='%H %ad %s' \
  --grep='Ellis' \
  --grep='promot' \
  --grep='operational coordination' \
  --grep='constituent' \
  --regexp-ignore-case \
  | head -n 300 || true

printf '\n=== ELLIS ORIGINAL DEFINITION HISTORY ===\n'
git log --all -p -- \
  server/ellis \
  docs/governance/HQ_ORGANIZATIONAL_CONSTITUTION.md \
  docs/governance/governance-lifecycle-assignment-boundary-reconciliation.md \
  2>/dev/null | grep -nE \
  '^(commit |Date:|[-+].*(Ellis|agent|actor|authority|coordination|department|execution|assignment|promotion))' \
  | head -n 5000 || true

printf '\n=== CURRENT ELLIS RUNTIME SURFACE ===\n'
find server/ellis -maxdepth 2 -type f -print 2>/dev/null | sort
grep -RniE \
  --exclude='*.test.ts' \
  -B30 -A100 \
  '(Operational Coordination Authority|assigned_actor|department|available_actors|authorize execution|execution_authorized|agent)' \
  server/ellis server/lifecycle \
  2>/dev/null | head -n 7000 || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WAS_ELLIS_PROMOTED_TO_A_NAMED_SYSTEM_AUTHORITY'
echo 'QUESTION_2=DOES_ANY_RECONCILIATION_EXPLICITLY_CALL_ELLIS_AN_AGENT'
echo 'QUESTION_3=IS_ELLIS_AN_ACTOR_OR_COORDINATION_AUTHORITY_DISTINCT_FROM_ACTORS'
echo 'QUESTION_4=DOES_ELLIS_RECEIVE_TASKS_AS_A_DELEGATION_TARGET'
echo 'QUESTION_5=DOES_ELLIS_EXECUTE_WORK_OR_ONLY_COORDINATE_DEPARTMENTS'
echo 'QUESTION_6=SHOULD_AGENT_IDENTITY_AND_NAMED_SYSTEM_AUTHORITY_BE_SEPARATE_CANONICAL_CATEGORIES'
echo 'DO_NOT_ASSUME_OPERATIONAL_COORDINATION_AUTHORITY_EQUALS_AGENT=YES'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== FINAL REPOSITORY STATE ===\n'
git status --short
