/* eslint-disable import/no-commonjs */
#!/bin/bash

API_TOKEN="J3TDu2bfqoDwiykYDFDGacMM0bUZ_jNk2Hz9GCab"
ZONE_ID="c71af2f7240b47f2347166a84d42a120"

echo "🚀 Purging Cloudflare cache for Motherboard UI..."
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}' | jq

echo "✅ Purge request sent!"
