#!/bin/bash
# Matilda Chat – Phase 2 Quick Resume Helper
# Branch: feature/v11-dashboard-bundle

set -e

PROJECT_ROOT="/Users/marcela-dev/Projects/Motherboard_Systems_HQ"
BRANCH_NAME="feature/v11-dashboard-bundle"

echo "📂 Moving to project root: $PROJECT_ROOT"
cd "$PROJECT_ROOT"

echo "🔍 Current git status:"
git status

echo "🔀 Ensuring branch '$BRANCH_NAME' is checked out..."
git checkout "$BRANCH_NAME"

echo "✅ Active branch is now:"
git branch --show-current

echo "🚀 Starting local dev server on PORT=3000 (Matilda Chat)..."
# If an old server is running on 3000, this will fail visibly; handle manually if needed.
NODE_ENV=development PORT=3000 node server.mjs &

DEV_PID=$!
echo "   ↳ server.mjs started with PID $DEV_PID"

echo "⏳ Waiting 5 seconds for dev server to come up..."
sleep 5

echo "🐳 Starting dashboard + Postgres via Docker helper script..."
./scripts/docker-dashboard-up.sh

echo ""
echo "✅ Matilda Chat Phase 2 resume checklist complete."
echo "You should now be able to:"
echo "  • Visit http://127.0.0.1:3000 to see the dashboard"
echo "  • Confirm Matilda Chat Console appears under the main header"
echo ""
echo "Next suggested milestones:"
echo "  1) UI & placement polish for the chat console"
echo "  2) Swap placeholder reply for real Matilda brain in /api/chat"
echo "  3) Integrate chat JS into the official bundled dashboard build"
echo ""
echo "When ready, run:"
echo "  bash scripts/matilda-chat-phase2-resume.sh"
