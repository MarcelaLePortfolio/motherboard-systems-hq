#!/bin/bash

# Step 1: Capture output of git push
PUSH_OUTPUT=$(git push 2>&1)

# Step 2: Check for success keyword
if echo "$PUSH_OUTPUT" | grep -q "Everything up-to-date"; then
  echo "❌ Git reports no changes pushed."
  exit 1
elif echo "$PUSH_OUTPUT" | grep -q "To "; then
  echo "✅ Git push succeeded. Skipping remote deployment check."
  exit 0
else
  echo "❌ Git push failed:"
  echo "$PUSH_OUTPUT"
  exit 1
fi
