#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output=~/Desktop/MOTHERBOARD_BACKUP_"$timestamp".zip

zip -r "$output" \
  scripts memory config pnpm-lock.yaml .env.runtime node_modules \
  -x "*.DS_Store"

echo "✅ Backup created at: $output"
