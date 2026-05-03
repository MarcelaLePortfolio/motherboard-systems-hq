
echo "🎨 Restoring visual output placeholder..."
gsed -i '/#activityGraph { display: none !important; }/d' public/dashboard.css
pm2 restart server
sleep 3
echo "✅ Placeholder restored. Ready for Phase 7 visual output reintegration."
