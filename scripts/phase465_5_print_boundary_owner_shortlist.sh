#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

sed -n '1,260p' docs/phase465_4_boundary_owner_shortlist.txt
