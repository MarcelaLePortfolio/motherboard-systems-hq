from pathlib import Path

p = Path("docker-compose.yml")
s = p.read_text()

s = s.replace("      - SYSTEM_SCHEDULER_ENABLED=true\n", "      - SYSTEM_SCHEDULER_ENABLED=false\n")

p.write_text(s)
print("Scheduler disabled after proof")
