#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 MATILDA REINTRODUCTION SOURCE AUDIT ==="

echo
echo "=== 1) current server.ts Matilda surface (first 120 lines) ==="
sed -n '1,120p' server.ts || true

echo
echo "=== 2) actual Matilda module (first 160 lines) ==="
sed -n '1,160p' agents/matilda.ts/matilda.mjs || true

echo
echo "=== 3) Matilda local utility (first 160 lines) ==="
sed -n '1,160p' agents/matilda.ts/utils/matilda_chat.ts || true

echo
echo "=== 4) Ollama plan dependency (first 160 lines) ==="
sed -n '1,160p' scripts/utils/ollamaPlan.ts || true

echo
echo "=== 5) Ask router companion (first 160 lines) ==="
sed -n '1,160p' agents/matilda.ts/askRouter.ts || true

echo
echo "=== 6) bounded import scan around Matilda surfaces ==="
grep -RInE 'ollama|chatWithOllama|matilda|export const matilda|export async function ask' \
  agents/matilda.ts scripts/utils server.ts \
  | head -120 || true

echo
echo "=== END PHASE 487 MATILDA REINTRODUCTION SOURCE AUDIT ==="
