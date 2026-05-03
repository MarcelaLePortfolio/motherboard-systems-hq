from pathlib import Path
import re

p = Path("docker-compose.yml")
if not p.exists():
    raise SystemExit("docker-compose.yml not found")

s = p.read_text()

# Try to find dashboard service environment block
pattern = r"(dashboard:[\s\S]*?environment:\n)([\s\S]*?)(\n\s*[^\s-])"
match = re.search(pattern, s)

if not match:
    raise SystemExit("Could not find dashboard environment block")

prefix, env_block, suffix_start = match.groups()

if "SYSTEM_SCHEDULER_ENABLED" in env_block:
    print("Scheduler env already present")
else:
    new_env = env_block.rstrip() + "\n      - SYSTEM_SCHEDULER_ENABLED=true\n      - SYSTEM_SCHEDULER_INTERVAL_MS=60000\n"
    s = s.replace(prefix + env_block, prefix + new_env)
    p.write_text(s)
    print("Scheduler env injected into dashboard service")

