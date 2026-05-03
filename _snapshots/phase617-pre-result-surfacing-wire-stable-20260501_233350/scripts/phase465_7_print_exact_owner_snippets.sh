#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

sed -n '1,320p' docs/phase465_6_exact_owner_snippets.txt
