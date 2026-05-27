#!/usr/bin/env python3
import re
from pathlib import Path

p = Path("docker-compose.yml")
s = p.read_text()

if "dashboard:" not in s:
    raise SystemExit("ERROR: docker-compose.yml has no dashboard: service")

if "POLICY_ENFORCE_ENABLED" in s and "POLICY_SHADOW_ENABLED" in s:
    print("OK: compose already contains policy env vars; no changes.")
    raise SystemExit(0)

# Find the dashboard service block (best-effort, YAML by indentation).
m = re.search(r"(?ms)^\s{2}dashboard:\n(?P<body>.*?)(?=^\s{2}\S|\Z)", s)
if not m:
    raise SystemExit("ERROR: could not isolate dashboard service block")

body = m.group("body")

def ensure_environment_block(body: str) -> str:
    # If environment block exists, append missing vars.
    if re.search(r"(?m)^\s{4}environment:\s*\n", body):
        if "POLICY_SHADOW_ENABLED" not in body:
            body = re.sub(r"(?m)^(\s{4}environment:\s*\n)",
                          r"\1      - POLICY_SHADOW_ENABLED=${POLICY_SHADOW_ENABLED:-0}\n",
                          body, count=1)
        if "POLICY_ENFORCE_ENABLED" not in body:
            body = re.sub(r"(?m)^(\s{4}environment:\s*\n)",
                          r"\1      - POLICY_ENFORCE_ENABLED=${POLICY_ENFORCE_ENABLED:-0}\n",
                          body, count=1)
        return body

    # Otherwise, insert a new environment block near the top of the service
    # (after image/build if present; else right after dashboard:).
    lines = body.splitlines(True)
    insert_at = 0
    for i, line in enumerate(lines):
        if re.match(r"^\s{4}(image|build):", line):
            insert_at = i + 1
            continue
        if insert_at and re.match(r"^\s{4}\S", line) and not re.match(r"^\s{4}(image|build):", line):
            break
    env_block = (
        "    environment:\n"
        "      - POLICY_SHADOW_ENABLED=${POLICY_SHADOW_ENABLED:-0}\n"
        "      - POLICY_ENFORCE_ENABLED=${POLICY_ENFORCE_ENABLED:-0}\n"
    )
    lines.insert(insert_at, env_block)
    return "".join(lines)

new_body = ensure_environment_block(body)
s2 = s[:m.start("body")] + new_body + s[m.end("body"):]
p.write_text(s2)
print("OK: patched docker-compose.yml dashboard env to include POLICY_* vars")
