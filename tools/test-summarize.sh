set -euo pipefail

FILE_PATH="${1:-}"
OUTPUT_PATH="${2:-}"

if [[ -z "$FILE_PATH" ]]; then
  echo "❌ Missing file path."
  echo "Usage: bash tools/test-summarize.sh <path/to/file> [outputPath]"
  exit 1
fi

if [[ -n "$OUTPUT_PATH" ]]; then
  /opt/homebrew/bin/pnpm exec dotenv -e .env.runtime -- tsx -e "import { cadeCommandRouter } from './scripts/agents/cade'; cadeCommandRouter('summarize', { file: '${FILE_PATH}', outputPath: '${OUTPUT_PATH}', maxChunkSize: 8000 }).then(res => { console.log(JSON.stringify(res, null, 2)); }).catch(err => { console.error(err); process.exit(1); });"
else
  /opt/homebrew/bin/pnpm exec dotenv -e .env.runtime -- tsx -e "import { cadeCommandRouter } from './scripts/agents/cade'; cadeCommandRouter('summarize', { file: '${FILE_PATH}', maxChunkSize: 8000 }).then(res => { console.log(JSON.stringify(res, null, 2)); }).catch(err => { console.error(err); process.exit(1); });"
fi
