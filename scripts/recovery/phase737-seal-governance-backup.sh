
#!/usr/bin/env bash

set -euo pipefail

STAMP="$(date -u +"%Y-%m-%dT%H-%M-%SZ")"

BACKUP_ROOT="DISASTER_RECOVERY/phase737-governance-seal-${STAMP}"

mkdir -p "${BACKUP_ROOT}"

mkdir -p "${BACKUP_ROOT}/contracts"

mkdir -p "${BACKUP_ROOT}/audit"

mkdir -p "${BACKUP_ROOT}/validators"

echo "== Phase 737 Governance Seal Backup =="

safe_copy() {

  local source="$1"

  local target_dir="$2"

  if [[ -f "${source}" ]]; then

    cp "${source}" "${target_dir}/"

    echo "Copied: ${source}"

  else

    echo "Skipped missing file: ${source}"

  fi

}

safe_copy "EXECUTION_BRIDGE_ELIGIBILITY_CONTRACT.md" "${BACKUP_ROOT}/contracts"

safe_copy "DISASTER_RECOVERY/phase737-execution-gap-audit-result.md" "${BACKUP_ROOT}/audit"

safe_copy "DISASTER_RECOVERY/phase737-execution-bridge-eligibility-check.md" "${BACKUP_ROOT}/audit"

safe_copy "scripts/phase737-execution-gap-audit.mjs" "${BACKUP_ROOT}/validators"

safe_copy "scripts/phase737-execution-bridge-eligibility-check.mjs" "${BACKUP_ROOT}/validators"

git rev-parse HEAD > "${BACKUP_ROOT}/GIT_COMMIT.txt"

git branch --show-current > "${BACKUP_ROOT}/GIT_BRANCH.txt"

git remote -v > "${BACKUP_ROOT}/GIT_REMOTES.txt"

cat > "${BACKUP_ROOT}/MANIFEST.md" <<MANIFEST

# Phase 737 Governance Seal Backup

## Timestamp

${STAMP}

## Purpose

Seal governance-only execution eligibility stabilization state.

## Included

- execution bridge eligibility contract

- execution gap audit result

- execution eligibility checkpoint

- read-only validators

- Git commit metadata

- Git branch metadata

- Git remote metadata

## Constraints

This backup contains governance and validation artifacts only.

It does not:

- grant execution authority

- mutate runtime

- mutate Preview

- mutate renderer

- mutate database state

- trigger workers

- bypass reconciliation

MANIFEST

echo ""

echo "Backup created:"

echo "${BACKUP_ROOT}"

echo ""

echo "Phase 737 governance stabilization sealed successfully."

