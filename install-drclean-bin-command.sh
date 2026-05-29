
#!/usr/bin/env bash

set -euo pipefail

REPORT="drclean-bin-command-install-$(date +%Y%m%d_%H%M%S).md"

BIN="$HOME/bin"

CMD="$BIN/drclean"

TARGET="$HOME/Projects/motherboard-systems-hq-clean/manage-backup-retention.sh"

mkdir -p "$BIN"

cat > "$CMD" << CMD_EOF

#!/usr/bin/env bash

exec "$TARGET" "\$@"

CMD_EOF

chmod +x "$CMD"

if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.zshrc"; then

  cat >> "$HOME/.zshrc" << 'ZSH_EOF'

# User bin commands

export PATH="$HOME/bin:$PATH"

ZSH_EOF

fi

export PATH="$HOME/bin:$PATH"

{

  echo "# drclean Bin Command Install"

  echo

  echo "## Command"

  ls -l "$CMD"

  echo

  echo "## Target"

  ls -l "$TARGET"

  echo

  echo "## Which"

  command -v drclean || true

  echo

  echo "## Test"

  drclean | head -40

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" install-drclean-bin-command.sh

git commit -m "Install drclean bin command"

git push

