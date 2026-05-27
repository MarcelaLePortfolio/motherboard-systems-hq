/* eslint-disable import/no-commonjs */
#!/bin/bash
echo "🔎 Checking for Settings panel buttons in the dashboard..."

# Look for Start/Stop/Restart in your dashboard HTML (adjust path if needed)
SETTINGS_FILE="ui/dashboard/index.html"

if grep -q -i "Start" "$SETTINGS_FILE" && \
   grep -q -i "Stop" "$SETTINGS_FILE" && \
   grep -q -i "Restart" "$SETTINGS_FILE"; then
    echo "✅ Settings panel appears to have Start/Stop/Restart buttons wired!"
else
    echo "⚠️  Buttons not detected in $SETTINGS_FILE yet."
    echo "    Check Cade logs with: pm2 logs cade --lines 40"
fi

echo
echo "🔎 Current agent status:"
pm2 ls
