#!/usr/bin/env bash
set -e

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

grep -R "bundle.js" -n public || echo "No bundle.js reference found under public/"
