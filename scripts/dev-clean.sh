
set -e

echo "🧹 Cleaning build + cache directories..."
rm -rf dist .next .turbo out build
rm -rf ~/.cache/tsx ~/.cache/esbuild

echo "📦 Removing lock files to force fresh resolution..."
rm -f pnpm-lock.yaml package-lock.json yarn.lock

echo "📥 Reinstalling dependencies..."
pnpm install || npm install

echo "🚀 Starting server..."
PORT=${PORT:-3001} npx tsx --no-cache server.ts
