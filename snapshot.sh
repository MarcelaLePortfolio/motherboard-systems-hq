#!/bin/bash

MESSAGE="$1"
TS=$(date +"%Y%m%d-%H%M%S")
DIR="snapshots/$TS"

echo "📸 Creating REAL snapshot at $DIR"
mkdir -p "$DIR"

# Copy key project areas
cp -R server.ts "$DIR"/ 2>/dev/null || true
cp -R index.ts "$DIR"/ 2>/dev/null || true
cp -R routes "$DIR"/ 2>/dev/null || true
cp -R db "$DIR"/ 2>/dev/null || true
cp -R scripts "$DIR"/ 2>/dev/null || true
cp -R public "$DIR"/ 2>/dev/null || true
cp package.json "$DIR"/ 2>/dev/null || true

# Git tag for reference only (non-blocking)
git tag -a "snapshot-$TS" -m "$MESSAGE" 2>/dev/null
git push --tags 2>/dev/null || true

echo "✅ Snapshot created: $DIR"
