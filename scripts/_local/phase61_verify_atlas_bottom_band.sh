#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

nl -ba public/dashboard.html | sed -n '320,355p'
echo
scripts/_local/phase61_run_local_verify.sh || true
open http://127.0.0.1:8080/dashboard
git --no-pager log --oneline --decorate -8
