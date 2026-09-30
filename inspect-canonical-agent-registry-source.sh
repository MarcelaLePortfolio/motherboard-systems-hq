#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== HISTORICAL FILESYSTEM AGENT REGISTRY ===\n'
for commit in \
  7120d74b4a81a18b6860680b27e1bcc1eee91955 \
  5cd3bc4918dd9cf6fa302dacb4db8a79d1d5bf2e \
  32b9879c448608c188e01d0e06320827e61c3b03 \
  cbaa78e0c57ed6eb5040ef60cf0f5c0a61de0e60
do
  echo
  echo "===== $commit ====="
  git show --name-status --format=fuller "$commit" 2>/dev/null | head -n 1200 || true
done

printf '\n=== HISTORICAL AGENT FILE PATHS ===\n'
git log --all --name-only --format= \
  | grep -Ei '(^|/)(agents?|agent-registry|agent_registry|registry)(/|\.|-|_)' \
  | sort -fu \
  | head -n 5000 || true

printf '\n=== REGISTRY AUTHORITY PHASE 423 ===\n'
for commit in \
  ed0cf484e71807732253100ad3c9da2cffc43a76 \
  d4fe82b496c27273888cc027146df72634e4f6f9 \
  c1416eaa4f572092c6ebc06b910b30cf152e704a \
  0d6a124eafa3a55a70e520857280b862fd079e68
do
  echo
  echo "===== $commit ====="
  git show --format=fuller "$commit" 2>/dev/null \
    | grep -Ei -B40 -A160 \
      '(registry|authority|canonical|identity|agent|read|write|source.of.truth)' \
    | head -n 3000 || true
done

printf '\n=== CURRENT AGENT / REGISTRY IMPLEMENTATIONS ===\n'
find server db scripts client/src \
  -type f \
  \( -iname '*agent*' -o -iname '*registry*' -o -iname '*identity*' \) \
  -print 2>/dev/null \
  | sort \
  | head -n 5000 || true

printf '\n=== CURRENT CANONICAL IDENTITY REFERENCES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.md' \
  -B35 -A140 \
  '(canonical.{0,50}(agent|identity|registry)|agent.{0,50}(canonical|registry|identity)|registry.{0,50}(authority|canonical|identity)|identity.{0,50}(authority|canonical|registry)|source.of.truth.{0,80}(agent|identity|registry))' \
  server db docs scripts client/src \
  2>/dev/null | head -n 10000 || true

printf '\n=== NAMED IDENTITY STRUCTURAL REFERENCES ===\n'
for name in matilda cade effie atlas ellis bastion stryxx; do
  echo
  echo "===== $name ====="
  grep -RniE \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
    --include='*.ts' --include='*.mjs' --include='*.json' --include='*.md' \
    -B20 -A80 \
    "(agent[_ -]?id|identity|registry|authority|role|runtime|worker|coordinator|validator).{0,100}${name}|${name}.{0,100}(agent[_ -]?id|identity|registry|authority|role|runtime|worker|coordinator|validator)" \
    server db docs scripts client/src \
    2>/dev/null | head -n 1800 || true
done

printf '\n=== ATLAS AUTHORITY CONTRACT ===\n'
git show --format=fuller \
  40622594a00f16f992fa8407e7793a78ca3090fe \
  2>/dev/null | head -n 4000 || true

printf '\n=== VALIDATOR AUTHORITY CONTRACTS ===\n'
for commit in \
  83326d7b7412777214b6481dd2df8e2ba19b11eb \
  2185f49e59fa46437b5705ca7a4a9826bd54d42b
do
  echo
  echo "===== $commit ====="
  git show --format=fuller "$commit" 2>/dev/null | head -n 3500 || true
done

printf '\n=== ELLIS LINEAGE ===\n'
git log --all -S'ellis' \
  --date=iso \
  --format='%H %ad %s' \
  -- . \
  | head -n 1000 || true

printf '\n=== ROUTER AGENT-ID DEFINITION ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B50 -A180 \
  '(agentId|agent_id|agent-id|allowedAgents|allowed_agents|agent allowlist|agent_allowlist)' \
  server db scripts client/src \
  2>/dev/null | head -n 8000 || true

printf '\n=== CLASSIFICATION ===\n'
echo 'ROUTER_AGENT_ID_AS_GLOBAL_CANONICAL_IDENTITY=NOT_PROVEN'
echo 'HISTORICAL_FILESYSTEM_AGENT_REGISTRY=CONFIRMED_BY_LINEAGE'
echo 'REGISTRY_AUTHORITY_MODEL=CONFIRMED_BY_PHASE_423_LINEAGE'
echo 'ATLAS_AUTHORITY_MODEL=SEPARATE_CONTRACT_PRESENT'
echo 'VALIDATOR_AUTHORITY_MODEL=SEPARATE_CONTRACT_PRESENT'
echo 'ELLIS_IDENTITY_LINEAGE=REQUIRES_CANONICAL_SOURCE_CLASSIFICATION'
echo 'BASTION_IDENTITY_LINEAGE=REQUIRES_CANONICAL_SOURCE_CLASSIFICATION'
echo 'STRYXX_IDENTITY_LINEAGE=REQUIRES_CANONICAL_SOURCE_CLASSIFICATION'
echo 'NEXT_STEP=IDENTIFY_SINGLE_CANONICAL_IDENTITY_SOURCE_AND_ITS_CURRENT_SUCCESSOR'
echo 'ROUTER_ALLOWLIST_MUTATION=PROHIBITED_PENDING_CLASSIFICATION'
echo 'IDENTITY_MODEL_MUTATION=NO'
echo 'AUTHORITY_MODEL_MUTATION=NO'
echo 'RUNTIME_MUTATION=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
