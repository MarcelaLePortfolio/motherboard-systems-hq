
echo "�� Running convenience & recovery automations..."
bash scripts/util/backup-db.sh
bash scripts/util/restore-demo-baseline.sh || echo "⚠️ Baseline already active."
tsx scripts/sequences/prewarm-all-agents.ts
echo "🧠 All recovery utilities executed successfully."
