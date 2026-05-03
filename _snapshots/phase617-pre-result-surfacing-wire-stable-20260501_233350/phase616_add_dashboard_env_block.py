from pathlib import Path

p = Path("docker-compose.yml")
if not p.exists():
    raise SystemExit("docker-compose.yml not found")

s = p.read_text()

if "SYSTEM_SCHEDULER_ENABLED" in s:
    print("Scheduler env already present")
    exit()

target = '    ports:\n      - "3000:3000"\n'
if target not in s:
    raise SystemExit("Could not find dashboard ports block for insertion")

replacement = target + '    environment:\n      - SYSTEM_SCHEDULER_ENABLED=true\n      - SYSTEM_SCHEDULER_INTERVAL_MS=60000\n'

s = s.replace(target, replacement, 1)
p.write_text(s)

print("Environment block added to dashboard service")
