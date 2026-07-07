set -euo pipefail

echo "🔍 Verifying storage cleanliness..."
echo "────────────────────────────────────────"

APPROVED_PATHS=(
  "db/main.db"
  "backups/demo_backup_latest.db"
  "memory/agent_data.db"
  "memory/agent_memory.db"
  "scripts/_local/agent-runtime/memory/agent_brain.db"
)

echo "✅ Approved database files:"
for f in "${APPROVED_PATHS[@]}"; do
  if [[ -f "$f" ]]; then
    size_kb=$(du -k "$f" | awk '{print $1}')
    printf "   • %-55s %6s KB\n" "$f" "$size_kb"
  else
    echo "   ⚠️ Missing expected file: $f"
  fi
done
echo "────────────────────────────────────────"

echo "📦 Checking for stray .db/.db/.zip files..."
STRAYS=$(find . -type f \( -name "*.db" -o -name "*.db" -o -name "*.zip" \) \
  | grep -v -E "$(printf "|%s" "${APPROVED_PATHS[@]}")|legacy_db_archive|demo_backup_latest.sqlite.md5" || true)

if [[ -n "$STRAYS" ]]; then
  echo "⚠️ Found potential leftovers:"
  echo "$STRAYS"
else
  echo "✅ No stray database or backup files detected."
fi
echo "────────────────────────────────────────"

TOTAL_KB=$(find db backups memory -type f \( -name "*.db" -o -name "*.db" \) -exec du -k {} + | awk '{s+=$1} END {print s}')
TOTAL_MB=$((TOTAL_KB / 1024))
echo "💽 Total database storage used: ${TOTAL_MB} MB"
echo "✅ Storage verification complete."
