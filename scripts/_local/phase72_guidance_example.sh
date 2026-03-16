#!/usr/bin/env bash

set -euo pipefail

echo "PHASE 72 — OPERATOR GUIDANCE EXAMPLE"

tsx scripts/_local/phase72_operator_guidance_command.ts '{}'

echo
echo "PHASE 72 — CAUTION EXAMPLE"

tsx scripts/_local/phase72_operator_guidance_command.ts '{"replayDrift":true}'

echo
echo "PHASE 72 — RISK EXAMPLE"

tsx scripts/_local/phase72_operator_guidance_command.ts '{"protectionFailure":true}'

echo
echo "PHASE 72 EXAMPLES COMPLETE"

