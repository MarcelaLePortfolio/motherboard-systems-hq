#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== HISTORICAL AGENT / REGISTRY FILES ===\n'
git log --all \
  --name-only \
  --format= \
  -- \
  | grep -Ei \
    '(^|/)(agents?|agent-registry|registry|agent-runtime|agent-pool|agent-status)(/|\.|-|_)' \
  | sort -fu \
  | head -n 4000 || true

printf '\n=== PHASE 423 REGISTRY AUTHORITY PROOF ===\n'
for commit in \
  ed0cf484e71807732253100ad3c9da2cffc43a76 \
  d4fe82b496c27273888cc027146df72634e4f6f9 \
  c1416eaa4f572092c6ebc06b910b30cf152e704a \
  0d6a124eafa3a55a70e520857280b862fd079e68
do
  echo
  echo "===== $commit ====="
  git show --stat --oneline "$commit" 2>/dev/null || true
  git show --format=fuller "$commit" 2>/dev/null \
    | grep -Ei -B20 -A80 \
      '(registry|agent|identity|authority|canonical|read|write)' \
    | head -n 1500 || true
done

printf '\n=== FILESYSTEM AGENT + REGISTRY LOADING LINEAGE ===\n'
for commit in \
  7120d74b4a81a18b6860680b27e1bcc1eee91955 \
  5cd3bc4918dd9cf6fa302dacb4db8a79d1d5bf2e \
  32b9879c448608c188e01d0e06320827e61c3b03 \
  cbaa78e0c57ed6eb5040ef60cf0f5c0a61de0e60
do
  echo
  echo "===== $commit ====="
  git show --stat --oneline "$commit" 2>/dev/null || true
  git show --format=fuller "$commit" 2>/dev/null \
    | grep -Ei -B20 -A100 \
      '(agent|registry|filesystem|runtime|matilda|cade|effie|atlas|ellis)' \
    | head -n 1800 || true
done

printf '\n=== ATLAS AUTHORITY CONTRACT ===\n'
git show --format=fuller \
  40622594a00f16f992fa8407e7793a78ca3090fe \
  2>/dev/null | head -n 3000 || true

printf '\n=== VALIDATOR AUTHORITY CONTRACT ===\n'
for commit in \
  83326d7b7412777214b6481dd2df8e2ba19b11eb \
  2185f49e59fa46437b5705ca7a4a9826bd54d42b
do
  echo
  echo "===== $commit ====="
  git show --format=fuller "$commit" 2>/dev/null | head -n 2500 || true
done

printf '\n=== ELLIS CURRENT SOURCE CONTEXT ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B30 -A100 \
  '\bellis\b' \
  server db docs scripts client/src \
  2>/dev/null | head -n 5000 || true

printf '\n=== ELLIS FULL HISTORY ===\n'
git log --all -S'ellis' \
  --date=iso \
  --format='%H %ad %s' \
  -- . \
  | head -n 500 || true

printf '\n=== AGENT DEFINITIONS ACROSS HISTORY ===\n'
for name in matilda cade effie atlas ellis bastion stryxx; do
  echo
  echo "===== $name ====="
  git log --all -S"$name" \
    --date=short \
    --format='%H %ad %s' \
    -- \
      'server/**/agent*' \
      'server/**/registry*' \
      'agents/**' \
      'mirror/**' \
      'scripts/**/agent*' \
    2>/dev/null | head -n 250 || true
done

printf '\n=== CURRENT REGISTRY / AGENT IMPLEMENTATIONS ===\n'
find server db scripts client/src \
  -type f \
  \( -iname '*agent*' -o -iname '*registry*' \) \
  -print 2>/dev/null | sort | head -n 3000 || true

printf '\n=== CANONICALITY SEARCH ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.md' \
  -B30 -A100 \
  '(canonical.*agent|agent.*canonical|canonical.*identity|identity.*canonical|agent registry|agent_registry|agentRegistry|registry authority|registry.*authority|authority.*registry)' \
  server db docs scripts \
  2>/dev/null | head -n 8000 || true

printf '\n=== CLASSIFICATION ===\n'
echo 'CURRENT_ROUTER_AGENT_ID_IS_CANONICAL_GLOBAL_REGISTRY=NOT_PROVEN'
echo 'HISTORICAL_AGENT_REGISTRY_ARCHITECTURE=STRONGLY_INDICATED'
echo 'HISTORICAL_REGISTRY_AUTHORITY_PROOF=EXISTS'
echo 'ATLAS_SEPARATE_AUTHORITY_CONTRACT=EXISTS'
echo 'VALIDATOR_SEPARATE_AUTHORITY_CONTRACT=EXISTS'
echo 'ELLIS_CURRENT_SOURCE_FOOTPRINT=CONFIRMED'
echo 'ELLIS_HISTORICAL_FOOTPRINT=CONFIRMED'
echo 'BASTION_CURRENT_SOURCE_FOOTPRINT=ZERO_IN_PRIOR_CENSUS'
echo 'STRYXX_CURRENT_SOURCE_FOOTPRINT=ZERO_IN_PRIOR_CENSUS'
echo 'NEXT_DECISION=DETERMINE_WHETHER_HISTORICAL_AGENT_REGISTRY_OR_LATER_AUTHORITY_MODEL_IS_CANONICAL_IDENTITY_SOURCE'
echo 'DO_NOT_MUTATE_ROUTER_ALLOWLIST=YES'
echo 'DO_NOT_PROMOTE_ELLIS_YET=YES'
echo 'DO_NOT_COLLAPSE_VALIDATOR_OR_COORDINATOR_INTO_AGENT=YES'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
