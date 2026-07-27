#!/usr/bin/env bash

set -euo pipefail

DB_PATH="db/main.db"

if [ ! -f "$DB_PATH" ]; then
  printf 'STOP: database not found at %s\n' "$DB_PATH"
  exit 1
fi

if ! command -v sqlite3 >/dev/null 2>&1; then
  printf 'STOP: sqlite3 is not available.\n'
  exit 1
fi

printf '\n=== GOVERNANCE TABLE COLUMNS ===\n'

for table in \
  governance_packages \
  governance_delegations \
  governance_validation_results \
  governance_envelope_gates \
  governance_envelopes \
  governance_lifecycle_events
do
  printf '\n--- %s ---\n' "$table"
  sqlite3 -header -column "$DB_PATH" "PRAGMA table_info($table);"
done

printf '\n=== GOVERNANCE FOREIGN KEYS ===\n'

for table in \
  governance_packages \
  governance_delegations \
  governance_validation_results \
  governance_envelope_gates \
  governance_envelopes \
  governance_lifecycle_events
do
  printf '\n--- %s ---\n' "$table"
  sqlite3 -header -column "$DB_PATH" "PRAGMA foreign_key_list($table);"
done

printf '\n=== REPRESENTATIVE ROWS ===\n'

for table in \
  governance_packages \
  governance_delegations \
  governance_validation_results \
  governance_envelope_gates \
  governance_envelopes \
  governance_lifecycle_events
do
  printf '\n--- %s ---\n' "$table"
  sqlite3 -header -column "$DB_PATH" "SELECT * FROM $table LIMIT 2;"
done

printf '\n=== REPOSITORY QUERY LOCATIONS ===\n'
nl -ba db/mission-read-repository.ts | sed -n '1,120p'

printf '\nMission governance join-key inspection complete.\n'
