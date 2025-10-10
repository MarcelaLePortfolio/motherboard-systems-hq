
file="public/dashboard.html"
echo "🧩 Verifying dashboard structure..."
bodies=$(grep -c "<body>" "$file")
sections=$(grep -c "<section id=" "$file")
if [ "$bodies" -gt 1 ]; then
  echo "❌ Duplicate <body> tags detected ($bodies)"
  exit 1
fi
if [ "$sections" -gt 3 ]; then
  echo "❌ Unexpected section count ($sections)"
  exit 1
fi
echo "✅ Dashboard structure verified — no duplicates found."
