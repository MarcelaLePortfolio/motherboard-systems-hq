#!/bin/bash
set -e

echo "Checking active server route wiring..."

echo "Searching for subsystem route registration:"
grep -R "registerSubsystemStatusRoute\|/api/subsystem-status\|registerRoutes" server.js server server.mjs 2>/dev/null || true

echo "Check complete."
