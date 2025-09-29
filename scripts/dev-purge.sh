
set -e

echo "🔥 Purging ALL local + temp build caches..."

rm -rf dist .next .turbo out build
rm -rf ./*.tsbuildinfo

rm -rf ~/.cache/tsx ~/.cache/esbuild

pnpm store prune || true

rm -rf /var/folders/*/*/*/tsx
rm -rf /var/folders/*/*/*/esbuild

find scripts/agents -type f \( -name "*.js" -o -name "*.map" \) -delete

echo "✅ Purge complete. Restarting server..."
PORT=${PORT:-3001} npx tsx --no-cache server.ts
