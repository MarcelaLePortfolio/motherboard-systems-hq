#!/bin/bash

# Step 1: Capture output of git push
PUSH_OUTPUT=$(git push 2>&1)

# Step 2: Check for success keyword
if echo "$PUSH_OUTPUT" | grep -q "Everything up-to-date"; then
  echo "❌ Git reports no changes pushed."
  exit 1
elif echo "$PUSH_OUTPUT" | grep -q "To "; then
  echo "✅ Git push succeeded. Checking deployment..."
else
  echo "❌ Git push failed:"
  echo "$PUSH_OUTPUT"
  exit 1
fi

# Step 3: Ping Vercel deployment (adjust URL if needed)
VERCEL_URL="https://motherboard-systems.vercel.app/_vercel/ping"
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$VERCEL_URL")

# Step 4: Respond based on status
if [ "$STATUS_CODE" = "200" ]; then
  echo "✅ Deployment confirmed live at $VERCEL_URL"
  exit 0
else
  echo "⚠️ Git push went through, but deployment unreachable (HTTP $STATUS_CODE)"
  exit 2
fi
