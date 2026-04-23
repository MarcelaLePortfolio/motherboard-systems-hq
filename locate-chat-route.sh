#!/bin/bash
set -e

echo "🔍 BROAD SEARCH FOR REAL /api/chat IMPLEMENTATION"
echo "================================================="

echo
echo "1) Exact '/api/chat' references anywhere in repo"
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build "/api/chat" . || true

echo
echo "2) Files named like chat route/handler/server"
find . \
  -path ./node_modules -prune -o \
  -path ./.git -prune -o \
  -path ./.next -prune -o \
  -path ./dist -prune -o \
  -path ./build -prune -o \
  -type f \( \
    -iname "*chat*.ts" -o \
    -iname "*chat*.js" -o \
    -iname "route.ts" -o \
    -iname "route.js" -o \
    -iname "server.ts" -o \
    -iname "server.js" -o \
    -iname "index.ts" -o \
    -iname "index.js" \
  \) -print

echo
echo "3) Backend-style route registrations"
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build \
  -E 'app\.(post|get|use)\(|router\.(post|get|use)\(|export async function POST|NextResponse|Request, Response|req, res|createAgentRuntime|runAgent|/chat' \
  . || true

echo
echo "4) Rewrites / proxies / route forwarding"
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build \
  -E 'rewrites\(|redirects\(|proxy|/api/chat|destination:|source:' \
  next.config.* vercel.json package.json . 2>/dev/null || true

echo
echo "5) Common API directories"
find ./app ./pages ./src ./api ./server ./scripts 2>/dev/null \
  -path ./node_modules -prune -o \
  -path ./.next -prune -o \
  -type f \( -iname "*.ts" -o -iname "*.js" \) -print | sort

echo
echo "✅ Search complete."
echo "Paste back:"
echo "  - any exact '/api/chat' matches"
echo "  - any file that looks like the actual handler or proxy"
