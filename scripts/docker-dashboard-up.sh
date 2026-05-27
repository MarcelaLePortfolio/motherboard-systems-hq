#!/usr/bin/env bash
set -e

echo "🔍 Checking Docker daemon status..."

until docker info >/dev/null 2>&1; do
  echo "⏳ Docker daemon not ready yet... retrying in 3 seconds."
  sleep 3
done

echo "✅ Docker daemon is running."

echo "📦 Building dashboard containers via docker-compose..."
docker-compose build

echo "🚀 Starting dashboard containers in detached mode..."
docker-compose up -d

echo "✅ Dashboard containers are up. The updated dashboard (with Matilda Chat Console) is now running in the container."
