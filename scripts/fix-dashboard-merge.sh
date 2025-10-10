
DASHBOARD="public/dashboard.html"

if grep -q '<<<<<<< HEAD' "$DASHBOARD"; then
  echo "🔧 Cleaning merge conflict markers from $DASHBOARD ..."
  # Remove Git conflict markers and any stray divider lines
  sed -i '' '/<<<<<<< HEAD/d' "$DASHBOARD"
  sed -i '' '/=======/d' "$DASHBOARD"
  sed -i '' '/>>>>>>>/d' "$DASHBOARD"
  awk 'NF {p=1} p' "$DASHBOARD" > "${DASHBOARD}.tmp" && mv "${DASHBOARD}.tmp" "$DASHBOARD"
  echo "✅ Merge artifacts removed successfully."
else
  echo "✅ No merge markers found in $DASHBOARD."
fi
