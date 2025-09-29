
set -e

echo "🧹 Quick clean: wiping build + cache dirs..."
rm -rf dist .next .turbo out build
rm -rf ~/.cache/tsx ~/.cache/esbuild

echo "🚀 Starting server (no reinstall)..."
PORT=${PORT:-3001} npx tsx --no-cache server.ts
