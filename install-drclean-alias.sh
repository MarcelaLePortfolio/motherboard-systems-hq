
#!/usr/bin/env bash

set -euo pipefail

REPORT="drclean-alias-install-$(date +%Y%m%d_%H%M%S).md"

ZSHRC="$HOME/.zshrc"

ALIAS_LINE="alias drclean='$HOME/Projects/motherboard-systems-hq-clean/manage-backup-retention.sh'"

cp "$ZSHRC" "$ZSHRC.pre-drclean-$(date +%Y%m%d_%H%M%S)"

grep -v "alias drclean=" "$ZSHRC" > "$ZSHRC.tmp"

mv "$ZSHRC.tmp" "$ZSHRC"

cat >> "$ZSHRC" << EOF_ALIAS

# Motherboard backup retention review

$ALIAS_LINE

EOF_ALIAS

{

  echo "# drclean Alias Install"

  echo

  echo "## Alias Line"

  grep -n "alias drclean=" "$ZSHRC" || true

  echo

  echo "## Zsh Syntax Check"

  zsh -n "$ZSHRC" 2>&1 || true

  echo

  echo "## Direct Script Exists"

  ls -l "$HOME/Projects/motherboard-systems-hq-clean/manage-backup-retention.sh" 2>/dev/null || true

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" install-drclean-alias.sh

git commit -m "Install drclean alias"

git push

echo

echo "Now run:"

echo "source ~/.zshrc && drclean"

