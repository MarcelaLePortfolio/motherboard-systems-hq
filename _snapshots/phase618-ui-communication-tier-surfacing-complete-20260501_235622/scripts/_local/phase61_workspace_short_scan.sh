#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"

rg -l \
  -g '!node_modules' \
  -g '!dist' \
  -g '!build' \
  -g '!coverage' \
  -g '!*.map' \
  'Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity|Task History|Task Events' \
  "$ROOT" \
| sort -u
