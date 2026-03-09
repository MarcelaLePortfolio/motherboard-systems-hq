#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"

rg -l \
  -g 'public/**/*.html' \
  -g 'public/**/*.js' \
  -g 'public/**/*.ts' \
  -g 'public/**/*.tsx' \
  -g 'public/**/*.jsx' \
  'Matilda Chat Console|Task Delegation|Recent Tasks|Task Activity|Task History|Task Events' \
  "$ROOT" \
| sort -u
