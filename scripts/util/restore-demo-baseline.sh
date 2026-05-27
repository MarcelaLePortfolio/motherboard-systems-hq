
set -e
echo "<0001f9ed> Restoring demo baseline (v1.0.4.1-demo-locked)..."
git fetch --all --tags
git reset --hard v1.0.4.1-demo-locked
pm2 restart all
echo "✅ Demo baseline restored and agents restarted."
