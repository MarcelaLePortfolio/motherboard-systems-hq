#!/usr/bin/env bash
set -euo pipefail

rg -n "situation summary|SituationSummary|situationSummary|summary" src || true
printf '\n────────────────────────────────\n'
rg -n "interface .*Summary|type .*Summary" src || true
printf '\n────────────────────────────────\n'
rg -n "select.*Summary|build.*Summary|compose.*Summary" src || true
printf '\n────────────────────────────────\n'
rg -n "governance" src || true
