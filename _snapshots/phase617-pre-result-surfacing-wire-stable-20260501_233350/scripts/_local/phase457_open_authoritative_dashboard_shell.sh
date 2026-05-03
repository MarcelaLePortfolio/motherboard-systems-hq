#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mkdir -p docs/recovery_full_audit

cat > docs/recovery_full_audit/46_authoritative_dashboard_shell_urls.txt <<'REPORT'
PHASE 457 - AUTHORITATIVE DASHBOARD SHELL URLS
==============================================

AUTHORITATIVE RULE
Use /dashboard.html as the visual validation surface.

Do not use / for dashboard shell validation unless explicitly proving index-entry behavior.

KNOWN GOOD VISUAL CHECKS
- http://localhost:8131/dashboard.html
- http://localhost:8132/dashboard.html
- http://localhost:8133/dashboard.html
- http://localhost:8134/dashboard.html

KNOWN ROOT ENTRYPOINTS (OLDER SHELL SURFACE)
- http://localhost:8131/
- http://localhost:8132/
- http://localhost:8133/
- http://localhost:8134/
REPORT

open "http://localhost:8131/dashboard.html" || true
open "http://localhost:8132/dashboard.html" || true
open "http://localhost:8133/dashboard.html" || true
open "http://localhost:8134/dashboard.html" || true

sed -n '1,220p' docs/recovery_full_audit/46_authoritative_dashboard_shell_urls.txt
