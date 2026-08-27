#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "=== INVESTIGATE EXISTING DEPLOYMENT AND ACCESS TRUST MODEL ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "IDENTITY_IMPLEMENTATION_AUTHORIZED=NO"
echo "AUTHORIZATION_COMPILATION_IMPLEMENTATION_AUTHORIZED=NO"
echo "ACTIVE_REPOSITORY_EXECUTION_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="9616fa860"
CURRENT_HEAD="$(git rev-parse HEAD)"

if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== DEPLOYMENT CONFIGURATION SEARCH ==="
find . \
  -path './node_modules' -prune -o \
  -path './.git' -prune -o \
  -type f \
  \( \
    -name 'vercel.json' -o \
    -name 'wrangler.toml' -o \
    -name 'wrangler.json' -o \
    -name 'wrangler.jsonc' -o \
    -name 'Dockerfile' -o \
    -name 'docker-compose.yml' -o \
    -name 'docker-compose.yaml' -o \
    -name 'fly.toml' -o \
    -name 'railway.json' -o \
    -name 'render.yaml' -o \
    -iname '*cloudflare*' -o \
    -iname '*tunnel*' -o \
    -iname '*deploy*' \
  \) \
  -print \
  | sort \
  | sed -n '1,500p'

echo
echo "=== ACCESS / PROXY / IDENTITY HEADER SEARCH ==="
git grep -n -I -E \
  'CF-Access|Cf-Access|cloudflare access|access-jwt|jwt-assertion|x-forwarded-user|x-auth-request-user|x-user|x-email|remote-user|authenticated-user|trusted proxy|trust proxy|proxy-authorization|authorization header' \
  -- \
  . \
  ':!node_modules' \
  ':!.git' \
  | sed -n '1,1200p' || true

echo
echo "=== CLOUDFLARE / TUNNEL / EXTERNAL ACCESS SEARCH ==="
git grep -n -I -E \
  'cloudflare|cloudflared|tunnel|zero trust|access policy|access application|warp|localhost.run|ngrok|tailscale' \
  -- \
  . \
  ':!node_modules' \
  ':!.git' \
  | sed -n '1,1400p' || true

echo
echo "=== APPLICATION BIND / HOST / NETWORK SURFACE ==="
git grep -n -I -E \
  'listen\(|HOST|PORT|0\.0\.0\.0|127\.0\.0\.1|localhost|trust proxy|app\.set\(' \
  -- \
  server \
  routes \
  package.json \
  '*.config.*' \
  | sed -n '1,1000p' || true

echo
echo "=== ENVIRONMENT VARIABLE TRUST / AUTH SEARCH ==="
git grep -n -I -E \
  'process\.env\..*(AUTH|USER|EMAIL|IDENTITY|ACCESS|SESSION|TOKEN|CLOUDFLARE|CF_|TUNNEL|OPERATOR)|AUTH_|USER_|IDENTITY_|ACCESS_|SESSION_|CF_' \
  -- \
  server \
  routes \
  db \
  config \
  client/src \
  package.json \
  | sed -n '1,1200p' || true

echo
echo "=== SERVER ENTRYPOINT / MIDDLEWARE ORDER ==="
for f in \
  server/index.ts \
  server/index.js \
  server/app.ts \
  server/app.js \
  index.ts \
  index.js
do
  if [[ -f "${f}" ]]; then
    echo
    echo "--- ${f} ---"
    nl -ba "${f}" | sed -n '1,520p'
  fi
done

echo
echo "=== PACKAGE / DEPENDENCY AUTH SURFACE ==="
if [[ -f package.json ]]; then
  cat package.json
fi

echo
echo "=== GITHUB REMOTE VERIFIED CLASSIFICATION CHECKPOINT ==="
echo "REMOTE_VERIFIED_CLASSIFICATION_COMMIT=9616fa860e2e9a2a24532c9672aa9ea2c7c830fc"

echo
echo "=== QUESTIONS TO RESOLVE ==="
echo "Q1=IS_APPLICATION_SINGLE_OPERATOR_BY_DEPLOYMENT_DESIGN"
echo "Q2=IS_EXTERNAL_ACCESS_ALREADY_AUTHENTICATED_BY_REVERSE_PROXY_OR_PLATFORM"
echo "Q3=DOES_PROXY_OR_PLATFORM_EXPORT_A_SERVER_VERIFIABLE_IDENTITY_SIGNAL"
echo "Q4=CAN_THAT_SIGNAL_BECOME_THE_EXISTING_EXECUTION_AUTHORIZATION_ACTOR_WITHOUT_CREATING_PARALLEL_AUTHORITY"
echo "Q5=IF_NO_IDENTITY_SIGNAL_EXISTS_IS_SINGLE_OPERATOR_POSSESSION_OF_LOCAL_RUNTIME_THE_CURRENT_TRUST_MODEL"
echo "Q6=WHAT_MINIMUM_SERVER_BOUNDARY_CAN_VERIFY_OPERATOR_PRESENCE_WITHOUT_INVENTING_ACCOUNT_INFRASTRUCTURE"

echo
echo "=== DECISION RULES ==="
echo "IF_TRUSTED_PROXY_IDENTITY_EXISTS=REUSE_AND_CLASSIFY_PROPAGATION_BOUNDARY"
echo "IF_EXISTING_APP_AUTH_EXISTS=REUSE_AND_CLASSIFY_PROPAGATION_BOUNDARY"
echo "IF_SINGLE_OPERATOR_LOCAL_ONLY_IS_ESTABLISHED=CLASSIFY_LOCAL_OPERATOR_TRUST_BOUNDARY_EXPLICITLY"
echo "IF_NONE_ARE_ESTABLISHED=STOP_BEFORE_IDENTITY_IMPLEMENTATION_AND_REQUIRE_NEW_AUTHORITY_DESIGN_CORRIDOR"
echo "DO_NOT_HARDCODE_OPERATOR_IDENTITY=YES"
echo "DO_NOT_TRUST_REQUEST_BODY_ACTOR=YES"
echo "DO_NOT_CREATE_PARALLEL_AUTH_SYSTEM_WITHOUT_PROVEN_NEED=YES"

echo
echo "=== PRESERVED BOUNDARIES ==="
echo "EXECUTION_AUTHORIZATION_RUNTIME_UNCHANGED=YES"
echo "EXECUTION_APPROVAL_GATE_UNCHANGED=YES"
echo "CANONICAL_PACKAGE_APPROVAL_UNCHANGED=YES"
echo "GOVERNANCE_ENVELOPE_UNCHANGED=YES"
echo "CADE_COMMIT_EFFECT_UNCHANGED=YES"
echo "CADE_PUSH_EFFECT_UNCHANGED=YES"
echo "GENERIC_CADE_ROUTE_UNCHANGED=YES"
echo "ACTIVE_REPOSITORY_WRITE=NO"
echo "REMOTE_RUNTIME_WRITE=NO"

echo
echo "=== NEXT ACTION ==="
echo "NEXT_ACTION=CLASSIFY_ACTUAL_DEPLOYMENT_TRUST_MODEL_AND_MINIMUM_VERIFIED_OPERATOR_IDENTITY_BOUNDARY"
echo "IMPLEMENTATION_AUTHORIZED=NO"
