#!/bin/sh
set -e

echo "=== DISABLING DASHBOARD SCHEMA AUTO-HEAL ==="

# This is the critical lock:
# dashboard must NOT run ALTER / CREATE / bootstrap logic

export SCHEMA_MUTATION_DISABLED=1

echo "SCHEMA_MUTATION_DISABLED=1"
