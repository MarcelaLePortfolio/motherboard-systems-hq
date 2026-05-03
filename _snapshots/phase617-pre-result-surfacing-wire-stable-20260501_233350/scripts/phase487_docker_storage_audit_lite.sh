#!/bin/bash

set -euo pipefail

mkdir -p .runtime docs

OUT_TXT=".runtime/docker_storage_audit_lite.txt"
OUT_MD="docs/phase487_docker_storage_audit_lite_summary.md"

{
  echo "🔍 PHASE 487 — DOCKER STORAGE AUDIT (LITE, READ-ONLY)"
  echo "DATE: $(date)"
  echo ""

  echo "---- docker version ----"
  docker version
  echo "exit=$?"
  echo ""

  echo "---- docker system df ----"
  docker system df
  echo "exit=$?"
  echo ""

  echo "---- docker system df -v ----"
  docker system df -v
  echo "exit=$?"
  echo ""

  echo "---- docker volume ls ----"
  docker volume ls
  echo "exit=$?"
  echo ""

  echo "---- docker images ----"
  docker images
  echo "exit=$?"
  echo ""

  echo "---- docker ps -a --size ----"
  docker ps -a --size
  echo "exit=$?"
  echo ""
} > "$OUT_TXT"

python3 - << 'PY'
from pathlib import Path
txt = Path(".runtime/docker_storage_audit_lite.txt").read_text(errors="ignore")
lines = txt.splitlines()

def section(name):
    out = []
    capture = False
    header = f"---- {name} ----"
    for line in lines:
        if line == header:
            capture = True
            continue
        if capture and line.startswith("---- ") and line != header:
            break
        if capture:
            out.append(line)
    return [x for x in out if x.strip()]

sections = {
    "docker system df": section("docker system df"),
    "docker volume ls": section("docker volume ls"),
    "docker images": section("docker images"),
    "docker ps -a --size": section("docker ps -a --size"),
}

summary = []
summary.append("# Phase 487 Docker Storage Audit Summary (Lite)")
summary.append("")
summary.append("Generated from `.runtime/docker_storage_audit_lite.txt`.")
summary.append("")
summary.append("## Health Gate")
summary.append("")
if "retrieving disk usage: EOF" in txt or "\nEOF\n" in txt:
    summary.append("- Docker storage inspection is still unstable.")
    summary.append("- Do not prune.")
else:
    summary.append("- Docker storage inspection completed without the prior EOF failure.")
    summary.append("- Safe to classify storage and plan controlled pruning rules.")
summary.append("")

for title, block in sections.items():
    summary.append(f"## {title}")
    summary.append("")
    if block:
      summary.append("```")
      summary.extend(block[:120])
      summary.append("```")
    else:
      summary.append("_No output captured._")
    summary.append("")

Path("docs/phase487_docker_storage_audit_lite_summary.md").write_text("\n".join(summary) + "\n")
print("Wrote docs/phase487_docker_storage_audit_lite_summary.md")
PY

sed -n '1,260p' "$OUT_MD"
