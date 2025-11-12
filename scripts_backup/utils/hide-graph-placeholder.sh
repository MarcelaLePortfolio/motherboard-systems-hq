
echo "🚫 Hiding visual output placeholder..."
gsed -i '/#activityGraph/d' public/dashboard.css
echo '#activityGraph { display: none !important; }' >> public/dashboard.css
pm2 restart server
sleep 3
echo "✅ Hidden. Dashboard cleaned for demo."
