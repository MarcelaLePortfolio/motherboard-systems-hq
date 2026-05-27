#!/usr/bin/env bash
set -e

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

# Find which template or HTML file is actually including bundle.js

rg '<script src="/bundle.js"' -n
