#!/bin/bash

set +e

mkdir -p .runtime

OUT=".runtime/docker_health_diagnose.txt"

{
  echo "🔎 PHASE 487 — DOCKER HEALTH DIAGNOSIS (READ-ONLY)"
  echo "================================================="
  echo ""
  echo "PWD: $(pwd)"
  echo "DATE: $(date)"
  echo ""

  echo "---- which docker ----"
  which docker
  echo "exit=$?"
  echo ""

  echo "---- docker version ----"
  docker version
  echo "exit=$?"
  echo ""

  echo "---- docker context ls ----"
  docker context ls
  echo "exit=$?"
  echo ""

  echo "---- docker context show ----"
  docker context show
  echo "exit=$?"
  echo ""

  echo "---- docker info ----"
  docker info
  echo "exit=$?"
  echo ""

  echo "---- docker ps ----"
  docker ps
  echo "exit=$?"
  echo ""

  echo "---- docker ps -a ----"
  docker ps -a
  echo "exit=$?"
  echo ""

  echo "---- docker system df ----"
  docker system df
  echo "exit=$?"
  echo ""

  echo "---- docker system events probe (5s) ----"
  timeout 5 docker system events --since 10m
  echo "exit=$?"
  echo ""

  echo "---- Docker Desktop processes ----"
  ps aux | grep -i "[d]ocker"
  echo "exit=$?"
  echo ""

  echo "---- cloudflared / pm2 quick visibility ----"
  ps aux | grep -E "[c]loudflared|[p]m2"
  echo "exit=$?"
  echo ""

  echo "✅ READ-ONLY DIAGNOSIS COMPLETE"
} | tee "$OUT"
