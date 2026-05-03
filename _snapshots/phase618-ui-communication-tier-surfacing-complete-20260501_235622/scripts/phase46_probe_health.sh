#!/usr/bin/env bash
set -euo pipefail
curl -fsS http://127.0.0.1:8080/api/health | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{let j=JSON.parse(s); if(!j.ok) process.exit(2); console.log("OK: /api/health");});'
