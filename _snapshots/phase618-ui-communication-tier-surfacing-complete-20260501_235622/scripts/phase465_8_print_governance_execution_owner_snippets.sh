#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

DOC="docs/phase465_6_exact_owner_snippets.txt"

awk '
/^FILE: server\/policy\/policy_eval\.mjs$/ {flag=1}
(/^FILE: / && $0 !~ /^FILE: server\/policy\/policy_eval\.mjs$/ && seen_policy && !seen_exec) {flag=0}
flag {print}
(/^FILE: server\/policy\/policy_eval\.mjs$/) {seen_policy=1}
' "$DOC"

printf '\n\n====================\n\n'

awk '
/^FILE: server\/orchestration\/policy-pipeline\.ts$/ {flag=1}
(/^FILE: / && $0 !~ /^FILE: server\/orchestration\/policy-pipeline\.ts$/ && seen_exec) {flag=0}
flag {print}
(/^FILE: server\/orchestration\/policy-pipeline\.ts$/) {seen_exec=1}
' "$DOC"
