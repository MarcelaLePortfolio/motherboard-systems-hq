from pathlib import Path
import re

compose = Path("docker-compose.yml")
out = Path("PHASE616_COMPOSE_STRUCTURE_INSPECTION_RESULT.txt")

if not compose.exists():
    raise SystemExit("docker-compose.yml not found")

s = compose.read_text()

lines = s.splitlines()
matches = []
for i, line in enumerate(lines, start=1):
    if re.search(r"dashboard|environment|command|ports|image|build|SYSTEM_SCHEDULER", line):
        matches.append(f"{i}: {line}")

out.write_text(
    "Phase 616 compose structure inspection result.\n\n"
    "Goal:\n"
    "Inspect docker-compose.yml structure before attempting another scheduler enablement patch.\n\n"
    "--- MATCHED COMPOSE REFERENCES ---\n"
    + ("\n".join(matches) if matches else "(none)")
    + "\n\n--- FULL DOCKER COMPOSE FILE ---\n"
    + s
    + "\n"
)

print(out.read_text())
