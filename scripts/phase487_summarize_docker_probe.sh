#!/bin/bash

set -euo pipefail

mkdir -p .runtime

OUT=".runtime/docker_probe_summary.md"

{
  echo "# Phase 487 Docker Probe Summary"
  echo ""
  echo "Generated: $(date)"
  echo ""

  echo "## Key Findings"
  echo ""

  if [ -f ".runtime/docker_health_diagnose.txt" ]; then
    echo "### From docker_health_diagnose.txt"
    echo ""
    awk '
      /---- which docker ----/ {flag=1}
      /---- docker context ls ----/ {print; next}
      /---- docker context show ----/ {print; next}
      /---- docker version ----/ {flag=1}
      /---- docker info ----/ {flag=1}
      /---- docker ps ----/ {flag=1}
      /---- docker ps -a ----/ {flag=1}
      /---- docker system df ----/ {flag=1}
      flag==1 {print}
      /exit=/ && flag==1 {flag=0; print ""}
    ' .runtime/docker_health_diagnose.txt | sed -n '1,220p'
    echo ""
  fi

  if [ -f ".runtime/docker_health_probe_timeout.txt" ]; then
    echo "### From docker_health_probe_timeout.txt"
    echo ""
    awk '
      /---- which docker ----/ {flag=1}
      /---- docker context show ----/ {flag=1}
      /---- docker context inspect desktop-linux ----/ {flag=1}
      /---- docker version \(time-bounded\) ----/ {flag=1}
      /---- docker info \(time-bounded\) ----/ {flag=1}
      /---- docker ps \(time-bounded\) ----/ {flag=1}
      /---- docker system df \(time-bounded\) ----/ {flag=1}
      /---- filtered docker processes ----/ {flag=1}
      /---- docker socket visibility ----/ {flag=1}
      /---- recent Docker Desktop logs \(if present\) ----/ {flag=1}
      flag==1 {print}
      /exit=/ && flag==1 {flag=0; print ""}
      /TIMEOUT:/ {print ""}
    ' .runtime/docker_health_probe_timeout.txt | sed -n '1,260p'
    echo ""
  fi

  echo "## Extracted Conclusions"
  echo ""
  echo "- Docker Desktop processes are present."
  echo "- Docker socket exists at /Users/marcela-dev/.docker/run/docker.sock."
  echo "- docker version returned client details but did not complete cleanly in the earlier probe."
  echo "- docker info appeared to hang or stall in the earlier diagnose run."
  echo "- docker system df previously returned: retrieving disk usage: EOF."
  echo "- This indicates Docker Desktop/backend is present, but disk-usage inspection is unstable or partially unhealthy."
  echo ""
  echo "## Recommended Corridor Status"
  echo ""
  echo "- Do not prune yet."
  echo "- Treat Docker storage classification as blocked by daemon/backend instability."
  echo "- Next safe move is targeted Docker Desktop/backend recovery diagnosis, not storage mutation."
} > "$OUT"

cp "$OUT" docs/phase487_docker_probe_summary.md
echo "Wrote docs/phase487_docker_probe_summary.md"
