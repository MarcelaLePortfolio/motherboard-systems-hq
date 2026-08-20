#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

REQUEST='Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing. Each workstream should show an owner, current status, next milestone, and blocker. Do not execute or delegate anything; help me define the request first.'

printf '%s' "$REQUEST" | pbcopy
open 'http://localhost:5173'

printf '%s\n' \
  'FINAL_VISIBLE_SMOKE_TEST=READY' \
  'REQUEST_COPIED_TO_CLIPBOARD=YES' \
  'ACTION=PASTE_INTO_MATILDA_AND_SUBMIT_EXACTLY_ONCE' \
  'DO_NOT_RETRY=YES' \
  'RETURN_EXACT_VISIBLE_RESPONSE_OR_ERROR=YES'
