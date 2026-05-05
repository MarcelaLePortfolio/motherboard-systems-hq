#!/usr/bin/env bash
set -euo pipefail

sed -n '1,220p' docs/phase702-validation-blocker-replay-verify.md

git status --short
