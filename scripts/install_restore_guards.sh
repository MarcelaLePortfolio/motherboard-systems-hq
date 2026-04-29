#!/bin/bash
set -euo pipefail

HOOK_DIR=".git/hooks"

echo "Installing restore protection hooks..."

# PREVENT TAG DELETION
cat > "$HOOK_DIR/pre-push" << 'HOOK'
#!/bin/bash

while read local_ref local_sha remote_ref remote_sha
do
  if [[ "$remote_ref" == refs/tags/phase* ]]; then
    if [[ "$local_sha" == 0000000000000000000000000000000000000000 ]]; then
      echo "ERROR: Deleting protected phase tag is not allowed."
      exit 1
    fi
  fi
done
HOOK

# PREVENT SNAPSHOT MODIFICATION
cat > "$HOOK_DIR/pre-commit" << 'HOOK'
#!/bin/bash

if git diff --cached --name-only | grep -E "^snapshots/phase"; then
  echo "ERROR: Modifying snapshot files is prohibited."
  echo "Create a new snapshot instead."
  exit 1
fi
HOOK

# PREVENT FORCE PUSH ON MAIN BRANCH (OPTIONAL SAFE GUARD)
cat > "$HOOK_DIR/pre-rebase" << 'HOOK'
#!/bin/bash
branch=$(git rev-parse --abbrev-ref HEAD)

if [[ "$branch" == "main" || "$branch" == "temp-fix-worker-heartbeat" ]]; then
  echo "WARNING: Rebase on protected branch is discouraged."
  read -p "Continue anyway? (y/N): " confirm
  if [[ "$confirm" != "y" ]]; then
    exit 1
  fi
fi
HOOK

chmod +x "$HOOK_DIR/pre-push"
chmod +x "$HOOK_DIR/pre-commit"
chmod +x "$HOOK_DIR/pre-rebase"

echo "Restore protection hooks installed."

