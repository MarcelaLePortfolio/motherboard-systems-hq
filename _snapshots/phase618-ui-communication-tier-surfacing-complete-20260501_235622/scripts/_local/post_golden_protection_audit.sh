#!/usr/bin/env bash
set -euo pipefail

OUT="POST_GOLDEN_PROTECTION_AUDIT.txt"

{
  echo "POST-GOLDEN PROTECTION AUDIT"
  echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
  echo

  echo "== Git status =="
  git status --short || true
  echo

  echo "== Current branch =="
  git branch --show-current || true
  echo

  echo "== Recent commits =="
  git log --oneline -n 10 || true
  echo

  echo "== Golden tags =="
  git tag --list '*golden*' | tail -n 20 || true
  echo

  echo "== Docker / container assets =="
  find . \
    \( -name 'Dockerfile' -o -name 'docker-compose.yml' -o -name 'docker-compose.yaml' -o -name 'compose.yml' -o -name 'compose.yaml' -o -name '.dockerignore' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    | sort || true
  echo

  echo "== Workflow assets =="
  find .github/workflows -type f 2>/dev/null | sort || true
  echo

  echo "== Local runtime scripts =="
  find scripts -type f 2>/dev/null | grep '_local' | sort || true
  echo

  echo "== Package scripts =="
  node -e 'const p=require("./package.json"); console.log(JSON.stringify(p.scripts ?? {}, null, 2));' 2>/dev/null || true
  echo

  echo "== Protection docs =="
  find . -maxdepth 1 -type f \
    \( -name 'PHASE*' -o -name '*GOLDEN*' -o -name '*CHECKPOINT*' -o -name '*PROTECTION*' \) \
    | sort || true
  echo

  echo "== Next-action guidance =="
  echo "If container assets are absent, containerization is a new bounded task."
  echo "If container assets are present, reconcile them against current golden before modification."
  echo "Do not change runtime or deployment shape inside this audit."
} > "$OUT"

cat "$OUT"
