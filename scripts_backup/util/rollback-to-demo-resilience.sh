
set -e
echo "<0001f9ed> Rolling back to verified demo snapshot (v1.0.8-demo-resilience-snapshot)..."
git fetch --all --tags
git reset --hard v1.0.8-demo-resilience-snapshot
pm2 restart all
echo "✅ Rolled back to v1.0.8 demo snapshot and restarted agents."
