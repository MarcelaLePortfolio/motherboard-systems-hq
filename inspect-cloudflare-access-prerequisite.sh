#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT CLOUDFLARE ACCESS INFRASTRUCTURE PREREQUISITE ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "CLOUDFLARE_CONFIGURATION_WRITE=NO"
echo "IDENTITY_IMPLEMENTATION_AUTHORIZED=NO"
echo "AUTHORIZATION_COMPILATION_IMPLEMENTATION_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="5227e8412"
CURRENT_HEAD="$(git rev-parse HEAD)"

if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== ESTABLISHED EVIDENCE ==="
echo "CLOUDFLARED_INSTALLED=YES"
echo "NAMED_TUNNELS_DISCOVERED=YES"
echo "DISCOVERED_TUNNELS=agent-stack-ui,cade,effie,matilda,ui-server"
echo "CLOUDFLARE_TUNNEL_TRANSPORT_CAPABILITY=ESTABLISHED"
echo "EXISTING_ACCESS_POLICY=NOT_ESTABLISHED"
echo "EXISTING_VERIFIED_PROXY_IDENTITY=NOT_ESTABLISHED"
echo "APPLICATION_ACCOUNT_SYSTEM_REQUIRED=NOT_ESTABLISHED"
echo "REQUEST_BODY_AUTHORIZATION_ACTOR_TRUSTED=NO"

echo
echo "=== SECURITY OBSERVATION ==="
echo "TRACKED_CLOUDFLARE_API_CREDENTIAL_MATERIAL_DISCOVERED=YES"
echo "CREDENTIAL_VALUE_WILL_NOT_BE_REPRINTED=YES"
echo "CREDENTIAL_ROTATION_SHOULD_BE_HANDLED_SEPARATELY=YES"
echo "THIS_INVESTIGATION_WILL_NOT_MODIFY_CREDENTIALS=YES"

echo
echo "=== CLOUDFLARED TUNNEL DETAILS ==="
if command -v cloudflared >/dev/null 2>&1; then
  for tunnel in agent-stack-ui matilda cade effie ui-server; do
    echo
    echo "--- tunnel info: ${tunnel} ---"
    cloudflared tunnel info "${tunnel}" 2>&1 \
      | sed -E \
          -e 's/(token|secret|credential|certificate|cert)[=:][^[:space:]]+/\1=<REDACTED>/Ig' \
      | sed -n '1,240p' || true
  done
else
  echo "CLOUDFLARED_BINARY_PRESENT=NO"
fi

echo
echo "=== CLOUDFLARED LOCAL FILE INVENTORY ==="
if [[ -d "${HOME}/.cloudflared" ]]; then
  find "${HOME}/.cloudflared" -maxdepth 2 -type f -print \
    | sed "s#${HOME}#~#" \
    | sort \
    | sed -n '1,240p'
else
  echo "LOCAL_CLOUDFLARED_DIRECTORY_PRESENT=NO"
fi

echo
echo "=== CLOUDFLARED CONFIGURATION METADATA ==="
for candidate in \
  "${HOME}/.cloudflared/config.yml" \
  "${HOME}/.cloudflared/config.yaml"
do
  if [[ -f "${candidate}" ]]; then
    echo
    echo "--- ${candidate} ---"
    sed -E \
      -e 's/(token:[[:space:]]*).*/\1<REDACTED>/I' \
      -e 's/(secret:[[:space:]]*).*/\1<REDACTED>/I' \
      -e 's/(credentials-file:[[:space:]]*).*/\1<REDACTED_PATH>/I' \
      "${candidate}" \
      | sed -n '1,320p'
  fi
done

echo
echo "=== PM2 CLOUDFLARE PROCESS METADATA ==="
if command -v pm2 >/dev/null 2>&1; then
  pm2 jlist 2>/dev/null \
    | node -e '
      let input="";
      process.stdin.on("data",d=>input+=d);
      process.stdin.on("end",()=>{
        try {
          const rows=JSON.parse(input);
          for (const row of rows) {
            const name=String(row.name||"");
            const args=Array.isArray(row.pm2_env?.args) ? row.pm2_env.args : [];
            const script=String(row.pm2_env?.pm_exec_path||"");
            const joined=[name,script,...args].join(" ");
            if (!/cloudflared|tunnel/i.test(joined)) continue;
            const safeArgs=args.map((v,i,a)=>{
              const s=String(v);
              if (/token|secret|credential/i.test(s)) return "<REDACTED>";
              if (i>0 && /token|secret|credential/i.test(String(a[i-1]))) return "<REDACTED>";
              return s;
            });
            console.log(JSON.stringify({
              name,
              status: row.pm2_env?.status || null,
              script,
              args: safeArgs
            }, null, 2));
          }
        } catch (e) {
          console.log("PM2_METADATA_PARSE_FAILED");
        }
      });
    ' || true
else
  echo "PM2_PRESENT=NO"
fi

echo
echo "=== TRACKED HOSTNAME / TUNNEL MAPPING EVIDENCE ==="
git grep -n -I -E \
  'marketingmother\.org|trycloudflare\.com|agent-stack-ui|ui-server|cloudflared.*tunnel|tunnel.*cloudflared' \
  -- . \
  | sed -E \
      -e 's/(Bearer[[:space:]]+)[A-Za-z0-9._~-]+/\1<REDACTED>/g' \
      -e 's/(API_TOKEN[="'"'"']+)[^"'"'"']+/\1<REDACTED>/g' \
  | sed -n '1,1000p' || true

echo
echo "=== ACCESS IDENTITY CODE SURFACE CHECK ==="
git grep -n -I -E \
  'CF-Access-Authenticated-User-Email|Cf-Access-Authenticated-User-Email|CF-Access-Jwt-Assertion|Cf-Access-Jwt-Assertion|CF_Authorization|cloudflare.*access|access.*cloudflare' \
  -- . \
  | sed -n '1,800p' || true

echo
echo "=== CLASSIFICATION RULE ==="
echo "TUNNEL_EXISTENCE_DOES_NOT_EQUAL_ACCESS_POLICY=YES"
echo "REMOTE_TRANSPORT_DOES_NOT_EQUAL_OPERATOR_AUTHENTICATION=YES"
echo "NO_PROXY_IDENTITY_MAY_BE_TRUSTED_UNTIL_ACCESS_POLICY_AND_SERVER_VALIDATION_ARE_ESTABLISHED=YES"
echo "DO_NOT_CREATE_PARALLEL_APPLICATION_AUTH_YET=YES"
echo "DO_NOT_HARDCODE_MARCELA_AS_RUNTIME_ACTOR=YES"
echo "DO_NOT_TRUST_CLIENT_SUPPLIED_ACTOR=YES"

echo
echo "=== NEXT DECISION ==="
echo "IF_ACCESS_CONFIGURATION_EVIDENCE_FOUND=CLASSIFY_EXISTING_ACCESS_POLICY_AND_IDENTITY_ASSERTION"
echo "IF_ONLY_TUNNEL_CONFIGURATION_FOUND=CLOUDFLARE_ACCESS_CONFIGURATION_IS_INFRASTRUCTURE_PREREQUISITE"
echo "IF_NO_SUITABLE_REMOTE_IDENTITY_BOUNDARY_EXISTS=RETURN_TO_BOUNDED_APPLICATION_OPERATOR_AUTH_DESIGN"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== PRESERVED BOUNDARIES ==="
echo "USER_INTENT_AUTHORITY_UNCHANGED=YES"
echo "MATILDA_INTERPRETATION_AUTHORITY_UNCHANGED=YES"
echo "CANONICAL_PACKAGE_APPROVAL_UNCHANGED=YES"
echo "EXECUTION_APPROVAL_GATE_UNCHANGED=YES"
echo "EXECUTION_AUTHORIZATION_RUNTIME_UNCHANGED=YES"
echo "CADE_LOCAL_COMMIT_EFFECT_UNCHANGED=YES"
echo "CADE_REMOTE_PUSH_EFFECT_UNCHANGED=YES"
echo "GENERIC_MUTATION_AUTHORITY_DISABLED=YES"
echo "GENERIC_SHELL_AUTHORITY_DISABLED=YES"
echo "AUTONOMOUS_EXECUTION_AUTHORITY_DISABLED=YES"

echo
echo "=== SAFETY ==="
echo "NO_PRODUCTION_FILE_EDIT=YES"
echo "NO_DATABASE_SCHEMA_WRITE=YES"
echo "NO_AUTH_IMPLEMENTATION=YES"
echo "NO_CLOUDFLARE_CONFIGURATION_WRITE=YES"
echo "NO_APPROVAL_WRITE=YES"
echo "NO_EXECUTION_AUTHORIZATION_WRITE=YES"
echo "NO_REMOTE_RUNTIME_WRITE=YES"
