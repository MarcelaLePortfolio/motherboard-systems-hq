#!/bin/bash

echo "Triggering guidance endpoint..."
curl -s http://localhost:8080/api/guidance > /dev/null

echo "Fetching guidance history..."
curl -s http://localhost:8080/api/guidance-history | jq

echo ""
echo "PASS if history array contains at least 1 entry."
