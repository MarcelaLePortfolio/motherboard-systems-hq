#!/bin/bash
set -e

echo "�� Deploying Motherboard Dashboard UI..."

# 1️⃣ Define paths
PROJECT_DIR="$HOME/Desktop/Motherboard_Systems_HQ"
UI_SRC="$PROJECT_DIR/ui/dashboard"
SERVE_ROOT="$UI_SRC/serve-root"
TOOLS_DIR="$PROJECT_DIR/tools"

# 2️⃣ Copy updated files to serve-root
echo "📦 Copying UI files to serve-root..."
mkdir -p "$SERVE_ROOT"
cp "$UI_SRC/index.html" "$SERVE_ROOT/index.html"
cp -R "$UI_SRC/public/"* "$SERVE_ROOT/"

# 3️⃣ Restart cloudflared tunnel
echo "🔄 Restarting Cloudflare tunnel..."
pm2 stop cloudflared-ui || true
pm2 delete cloudflared-ui || true
pm2 start cloudflared --name cloudflared-ui --interpreter none -- \
  tunnel --url http://localhost:59272 --name ui-server
pm2 save

# 4️⃣ Purge Cloudflare cache
echo "🧹 Purging Cloudflare cache..."
"$TOOLS_DIR/purge-ui-cache.sh"

# 5️⃣ Verify first 20 lines of live index
echo "🔍 Verifying live dashboard..."
sleep 5
curl -s https://ui.marketingmother.org/index.html | head -20

echo "✅ UI deployment complete!"
