#!/usr/bin/env bash
set -e

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

echo "────────────────────────────────────────────"
echo " Phase 14.2 — Locate Task Routes"
echo "────────────────────────────────────────────"
echo

rg "api/.*task" || true
echo
rg "delegate" || true
echo
rg "complete" || true
echo
echo "Done."
