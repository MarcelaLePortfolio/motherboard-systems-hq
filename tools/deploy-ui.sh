/* eslint-disable import/no-commonjs */
#!/bin/bash
set -e

echo "�� Deploying Motherboard Dashboard UI (Stable HTTP-Server)..."

PROJECT_DIR="$HOME/Desktop/Motherboard_Systems_HQ"
UI_SRC="$PROJECT_DIR/ui/dashboard"
SERVE_ROOT="$UI_SRC/serve-root"
TOOLS_DIR="$PROJECT_DIR/tools"

# 1️⃣ Copy updated files to serve-root
echo "📦 Copying UI files to serve-root..."
mkdir -p "$SERVE_ROOT"
cp "$UI_SRC/index.html" "$SERVE_ROOT/index.html"
cp -R "$UI_SRC/public/"* "$SERVE_ROOT/" 2>/dev/null || true

# 2️⃣ Kill any old local servers and cloudflared instances
echo "🛑 Stopping any old servers and tunnels..."
pkill -f "node .*serve" || true
pkill -f http-server || true
pkill -f cloudflared || true
pm2 stop cloudflared-ui || true
pm2 delete cloudflared-ui || true

# 3️⃣ Start new HTTP server on port 59272
echo "🌐 Starting http-server on port 59272..."
cd "$SERVE_ROOT"
http-server -p 59272 &

# 4️⃣ Start Cloudflare tunnel via PM2
echo "🔄 Starting Cloudflare tunnel via PM2..."
pm2 start cloudflared --name cloudflared-ui --interpreter none -- \
  tunnel --url http://localhost:59272 --name ui-server
pm2 save

# 5️⃣ Purge Cloudflare cache
echo "🧹 Purging Cloudflare cache..."
"$TOOLS_DIR/purge-ui-cache.sh"

# 6️⃣ Verify live index
echo "🔍 Verifying live dashboard..."
sleep 5
curl -I https://ui.marketingmother.org/index.html

echo "✅ UI deployment complete and stable!"
