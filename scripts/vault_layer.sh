
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

VAULT_DIR="$ROOT_DIR/recovery-vault"

BACKUP_EXCLUDES="$ROOT_DIR/.backup_excludes"

echo "INIT: VAULT LAYER (STABLE MODE)"

mkdir -p "$VAULT_DIR"

# ensure exclude rules exist BEFORE backups run

cat > "$BACKUP_EXCLUDES" << EX

recovery-vault

*.gpg

*.key

*.enc

EX

# initialize vault structure if empty

if [ ! -f "$VAULT_DIR/vault.gpg" ]; then

  echo "NO ENCRYPTED VAULT FOUND → INITIALIZING PLACEHOLDER VAULT"

  mkdir -p "$VAULT_DIR/data"

  echo "vault_initialized" > "$VAULT_DIR/data/README.txt"

fi

# encryption function (safe, optional trigger)

vault_encrypt() {

  if [ -z "${VAULT_PASSPHRASE:-}" ]; then

    echo "VAULT_PASSPHRASE NOT SET (SKIPPING ENCRYPTION)"

    return 0

  fi

  tar -czf - "$VAULT_DIR/data" | \

    gpg --symmetric --cipher-algo AES256 \

    --batch --yes --passphrase "$VAULT_PASSPHRASE" \

    -o "$VAULT_DIR/vault.gpg"

}

echo "VAULT LAYER READY"

