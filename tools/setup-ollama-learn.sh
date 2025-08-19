
set -euo pipefail

PKG_MANAGER=${PKG_MANAGER:-pnpm}

echo "📦 Installing dependencies: better-sqlite3, ollama"
$PKG_MANAGER add better-sqlite3 ollama >/dev/null 2>&1 || $PKG_MANAGER add better-sqlite3 ollama

echo "🗂️ Ensuring memory directory exists"
mkdir -p memory
echo "⚙️ Environment hint:"
echo "  • Ensure Ollama is running locally (default http://127.0.0.1:11434)"
echo "  • Optionally export OLLAMA_HOST to override"

echo "✅ Setup complete."
