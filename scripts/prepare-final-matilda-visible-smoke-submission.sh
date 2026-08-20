#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

REQUEST='Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing. Each workstream should show an owner, current status, next milestone, and blocker. Do not execute or delegate anything; help me define the request first.'

printf '%s' "$REQUEST" | pbcopy

printf '%s\n' \
  'MATILDA_UI_503_FINAL_VISIBLE_SMOKE_TEST=READY' \
  'DASHBOARD_URL=http://localhost:5173' \
  'ORIGINAL_REQUEST_COPIED_TO_CLIPBOARD=YES' \
  'AUTHORIZED_SUBMISSION_COUNT=1' \
  'ADDITIONAL_SUBMISSIONS_AUTHORIZED=NO' \
  'ACTION=PASTE_REQUEST_IN_MATILDA_AND_SUBMIT_EXACTLY_ONCE'

open 'http://localhost:5173'
