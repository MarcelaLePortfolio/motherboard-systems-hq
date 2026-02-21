#!/usr/bin/env python3
import re
from pathlib import Path
p = Path("docker-compose.yml")
s = p.read_text().splitlines(True)

# isolate dashboard service block (2-space indent)
txt = "".join(s)
m = re.search(r"(?ms)^\s{2}dashboard:\n(?P<body>.*?)(?=^\s{2}\S|\Z)", txt)
if not m:
    raise SystemExit("ERROR: could not find dashboard service block")

body = m.group("body").splitlines(True)

# find environment block inside dashboard (4-space indent)
env_i = None
for i, line in enumerate(body):
    if re.match(r"^\s{4}environment:\s*$", line):
        env_i = i
        break

def body_to_text(lines): return "".join(lines)

def ensure_env_mapping(lines):
    # If no environment:, insert one near the top (after image/build if present).
    if env_i is None:
        insert_at = 0
        for i, line in enumerate(lines):
            if re.match(r"^\s{4}(image|build):", line):
                insert_at = i + 1
        block = [
            "    environment:\n",
            "      POLICY_SHADOW_ENABLED: ${POLICY_SHADOW_ENABLED:-0}\n",
            "      POLICY_ENFORCE_ENABLED: ${POLICY_ENFORCE_ENABLED:-0}\n",
        ]
        lines[insert_at:insert_at] = block
        return lines

    # env exists: consume its children until next 4-space key (or end)
    i = env_i + 1
    j = i
    while j < len(lines):
        if re.match(r"^\s{4}\S", lines[j]) and not re.match(r"^\s{6}\S", lines[j]):
            break
        j += 1

    children = lines[i:j]

    # parse existing entries from either list or mapping
    env = {}

    for line in children:
        if re.match(r"^\s{6}-\s*", line):  # list form: - KEY=VALUE
            item = re.sub(r"^\s{6}-\s*", "", line).rstrip("\n")
            if "=" in item:
                k, v = item.split("=", 1)
                env[k.strip()] = v.strip()
        else:
            mm = re.match(r"^\s{6}([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.*)$", line.rstrip("\n"))
            if mm:
                env[mm.group(1)] = mm.group(2)

    # ensure keys
    env.setdefault("POLICY_SHADOW_ENABLED", "${POLICY_SHADOW_ENABLED:-0}")
    env.setdefault("POLICY_ENFORCE_ENABLED", "${POLICY_ENFORCE_ENABLED:-0}")

    # rebuild as mapping (sorted for stability, but keep policy keys near top)
    ordered = []
    for k in ["POLICY_SHADOW_ENABLED", "POLICY_ENFORCE_ENABLED"]:
        ordered.append((k, env.pop(k)))
    for k in sorted(env.keys()):
        ordered.append((k, env[k]))

    new_children = [f"      {k}: {v}\n" for k, v in ordered]

    # replace children
    return lines[:i] + new_children + lines[j:]

body2 = ensure_env_mapping(body)
txt2 = txt[:m.start("body")] + body_to_text(body2) + txt[m.end("body"):]
p.write_text(txt2)
print("OK: normalized dashboard.environment to mapping + ensured POLICY_* keys")
