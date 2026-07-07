
echo "🧭 Restoring demo baseline..."
pm2 stop all
sleep 2

echo "🗃️ Backing up current SQLite database..."
mkdir -p db/backups
cp db/main.db db/backups/main_$(date +"%Y%m%d_%H%M%S").db

echo "�� Clearing temporary and log data..."
rm -rf public/tmp/*
db3 db/main.db "DELETE FROM task_events;"
db3 db/main.db "DELETE FROM reflection_index;"

echo "🌱 Seeding initial reflection log..."
db3 db/main.db "INSERT INTO reflection_index (content) VALUES ('🌅 Demo baseline restored — system ready for cinematic playback.');"

echo "🚀 Restarting all agents via PM2..."
pm2 restart all
sleep 3

echo "✅ Baseline restored. Showing last 25 lines of logs:"
pm2 logs --lines 25
