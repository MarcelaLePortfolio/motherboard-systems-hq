#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "❌ Please provide a snapshot message."
  exit 1
fi

MESSAGE="$1"
TAG="v$(date +%y.%m.%d-%H%M)-stable"

echo "📸 Creating snapshot: $TAG"
git add -A
git commit -m "📸 Snapshot — $MESSAGE"
git tag -a "$TAG" -m "$MESSAGE"
git push origin --tags

echo "✨ Snapshot saved as $TAG"
