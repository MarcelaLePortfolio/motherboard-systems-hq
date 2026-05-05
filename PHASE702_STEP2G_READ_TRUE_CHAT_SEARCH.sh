#!/usr/bin/env bash
set -euo pipefail

echo "Reading true Matilda chat search report..."

sed -n '1,220p' docs/phase702-true-matilda-chat-search.md

git status --short
