#!/usr/bin/env bash
set -euo pipefail

echo "Scanning for governance consumption surfaces..."

grep -R "registry" src || true
grep -R "governance" src || true
grep -R "authorization" src || true
grep -R "policy" src || true
grep -R "situation" src || true

echo "Scan complete."
